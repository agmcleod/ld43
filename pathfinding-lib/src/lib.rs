use std::collections::HashMap;

use gdnative::{api::TileMap, prelude::*};
use nav;
use lyon_tessellation::math::{point, Point};
use lyon_tessellation::path::Path;
use lyon_tessellation::Orientation;
use lyon_tessellation::{
    geometry_builder::simple_builder, FillOptions, FillTessellator, VertexBuffers,
};

mod point_math;
mod panic;

#[derive(NativeClass)]
#[inherit(Node)]
struct PathFinding {
    mesh: Option<nav::NavMesh>,
}

#[gdnative::methods]
impl PathFinding {
    fn new(_owner: &Node) -> Self {
        PathFinding { mesh: None }
    }

    fn create_mesh(&mut self, polydata: Vec<nav::PolyData>) {
        let params = nav::MeshParams {
            agent_height: None,
            agent_max_climb: None,
            agent_radius: 1.0,
            max_polys_per_region: 2000,
            mesh_origin: nav::Point::new(-32.0, 0.0, -32.0),
            voxel_length: 1.0,
            voxels_per_region: nav::Count3D::new(2500, 1, 2500),
        };

        let mut mesh =
            nav::NavMesh::new(&params).expect("Navigation mesh should be creatable from params");

        let region = nav::Region {
            index_in_mesh: nav::Index3D::new(0, 0, 0),
            polygons: polydata,
        };

        mesh.put_region(&region).unwrap();

        self.mesh = Some(mesh);
    }

    fn create_tilemap_data(&mut self, owner: &Node) {
        unsafe {
            let tile_map = owner
                .get_node("/root/game/Navigation2D/TileMap")
                .expect("TileMap node should exist")
                .assume_safe()
                .cast::<TileMap>()
                .expect("TileMap casts to TileMap type");

            let tileset = tile_map.tileset();
            let tileset = tileset
                .as_ref()
                .expect("TileMap should have a tile set")
                .assume_safe();

            let mut tile_ids_with_polygon = HashMap::new();

            for id in &tileset.get_tiles_ids() {
                let poly = tileset.tile_get_navigation_polygon(id.to_i64());
                if let Some(poly) = poly {
                    let nav_polygon = poly.assume_safe();
                    tile_ids_with_polygon.insert(id.to_i64(), nav_polygon.vertices());
                }
            }

            let map_pos = tile_map.position();

            let cells = tile_map.get_used_cells();
            let cells_to_map = cells.iter().filter(|vec| {
                let vec = vec.to_vector2();
                let id = tile_map.get_cellv(vec);
                tile_ids_with_polygon.get(&id).is_some()
            });

            let mut nav_polygons = Vec::new();

            let mut tessellate_output: VertexBuffers<Point, u16> = VertexBuffers::new();
            let mut geometry_builder = simple_builder(&mut tessellate_output);
            let mut tessellator = FillTessellator::new();

            let mut path_builder = Path::builder();
            let mut has_pathed = false;

            for idx in cells_to_map {
                // if last loop had pathed, close it now
                if has_pathed {
                    path_builder.end(false);
                }
                has_pathed = false;

                let tile_vec_index = idx.to_vector2();
                let id = tile_map.get_cellv(tile_vec_index);
                let tile_pos = tile_map.map_to_world(tile_vec_index, false) + map_pos;
                if let Some(polygon) = tile_ids_with_polygon.get(&id) {
                    let mut poly_coords = Vec::new();

                    let mut min_x = None;
                    let mut max_x = None;
                    let mut min_z = None;
                    let mut max_z = None;

                    for i in 0..polygon.len() {
                        let poly_vec = polygon.get(i);
                        let x = poly_vec.x + tile_pos.x;
                        let z = poly_vec.y + tile_pos.y;
                        let point = nav::Point::new(x, 0.0, z);

                        if min_x.is_none() || x < min_x.unwrap() {
                            min_x = Some(x);
                        }
                        if max_x.is_none() || x > max_x.unwrap() {
                            max_x = Some(x);
                        }
                        if min_z.is_none() || z < min_z.unwrap() {
                            min_z = Some(z);
                        }
                        if max_z.is_none() || z > max_z.unwrap() {
                            max_z = Some(z);
                        }

                        poly_coords.push(point);
                    }

                    let center = nav::Point::new((max_x.unwrap() - min_x.unwrap()) / 2.0 + min_x.unwrap(), 0.0, (max_z.unwrap() - min_z.unwrap()) / 2.0 + min_z.unwrap());

                    poly_coords.sort_by(point_math::sort(center));

                    nav_polygons.push(nav::PolyData::new(poly_coords).unwrap());
                }
            }

            self.write_data_file(&nav_polygons);
            self.create_mesh(nav_polygons);
        }
    }

    fn write_data_file(&self, nav_polygons: &Vec<nav::PolyData>) {
        use std::fs;

        let data: Vec<String> = nav_polygons.iter().map(|poly| {
            poly.vertices.iter().map(|point| {
                format!("{},{}", point.x, point.z)
            }).collect::<Vec<String>>().join(",")
        }).collect();

        fs::write("../coords-data.csv", data.join("\n"));
    }

    #[export]
    fn get_path(&self, _owner: &Node, from: Vector2, to: Vector2) -> Vector2Array {
        if let Some(ref mesh) = self.mesh {
            let path = mesh
                .find_path(
                    nav::Point::new(from.x, 0.0, from.y),
                    nav::Point::new(to.x, 0.0, to.y),
                )
                .ok();
            if let Some(coords) = path {
                let coords = coords
                    .iter()
                    .map(|coord| Vector2::new(coord.x, coord.z))
                    .collect::<Vec<Vector2>>();
                return Vector2Array::from_vec(coords);
            } else {
                godot_print!("find_path returned None");
            }
        } else {
            godot_print!("no mesh");
        }
        Vector2Array::new()
    }

    #[export]
    fn _ready(&mut self, owner: &Node) {
        godot_print!("_ready");
        self.create_tilemap_data(owner);
    }
}

fn init(handle: InitHandle) {
    handle.add_class::<PathFinding>();
    panic::init_panic_hook();
}

godot_init!(init);
