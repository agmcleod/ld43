use std::collections::HashMap;

use gdnative::{api::TileMap, prelude::*};
use lyon_tessellation::math::{point, Point};
use lyon_tessellation::path::Path;
use lyon_tessellation::Orientation;
use lyon_tessellation::{
    geometry_builder::simple_builder, FillOptions, FillTessellator, VertexBuffers,
};
use nav;

mod panic;
mod point_math;

#[derive(NativeClass)]
#[inherit(Node)]
struct PathFinding {
    mesh: Option<nav::NavMesh>,
    walls: HashMap<i64, TypedArray<Vector2>>,
}

#[gdnative::methods]
impl PathFinding {
    fn new(_owner: &Node) -> Self {
        PathFinding {
            mesh: None,
            walls: HashMap::new(),
        }
    }

    fn create_mesh(&mut self, tessellate_output: &VertexBuffers<Point, u16>) {
        let mut polygons: Vec<nav::PolyData> = Vec::new();

        let mut min_x = std::i32::MAX;
        let mut min_z = std::i32::MAX;
        let mut max_x = 0i32;
        let mut max_z = 0i32;

        for chunk in tessellate_output.indices.chunks(3) {
            let mut points = chunk
                .iter()
                .map(|idx| {
                    let vert = tessellate_output.vertices.get(*idx as usize).unwrap();
                    let x = vert.x.floor();
                    let z = vert.y.ceil();
                    min_x = min_x.min(x as i32);
                    min_z = min_z.min(z as i32);
                    max_x = max_x.max(x as i32);
                    max_z = max_z.max(z as i32);
                    nav::Point::new(x, 0.0, z)
                })
                .collect::<Vec<nav::Point>>();

            // 0 area triangle, so skip it
            if (points[0].x == points[1].x && points[1].x == points[2].x)
                || (points[0].z == points[1].z && points[2].z == points[2].z)
            {
                continue;
            }

            let x = points.iter().fold(0.0, |sum, point| sum + point.x);
            let z = points.iter().fold(0.0, |sum, point| sum + point.z);
            points.sort_by(point_math::sort(nav::Point::new(x / 3.0, 0.0, z / 3.0)));
            polygons.push(
                nav::PolyData::new(points)
                    .map_err(|err| {
                        godot_dbg!(err);
                    })
                    .unwrap(),
            );
        }

        self.write_data_file(&polygons);

        let region = nav::Region {
            index_in_mesh: nav::Index3D::new(0, 0, 0),
            polygons,
        };

        let params = nav::MeshParams {
            agent_height: None,
            agent_max_climb: None,
            agent_radius: 1.0,
            max_polys_per_region: 3000,
            mesh_origin: nav::Point::new(min_x as f32, 0.0, min_z as f32),
            voxel_length: 1.0,
            voxels_per_region: nav::Count3D::new(
                (max_x - min_x) as usize,
                1,
                (max_z - min_z) as usize,
            ),
        };

        let mut mesh =
            nav::NavMesh::new(&params).expect("Navigation mesh should be creatable from params");

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
                    for i in 0..polygon.len() {
                        let poly_vec = polygon.get(i);
                        let x = poly_vec.x + tile_pos.x;
                        let y = poly_vec.y + tile_pos.y;

                        if i == 0 {
                            path_builder.begin(point(x, y));
                        } else {
                            path_builder.line_to(point(x, y));
                        }
                    }

                    has_pathed = true;
                }
            }

            if self.walls.is_empty() {
                path_builder.close();
            } else {
                if has_pathed {
                    path_builder.end(false);
                }
                for (i, (_id, poly)) in self.walls.iter().enumerate() {
                    for i in 0..poly.len() {
                        let poly_vec = poly.get(i);
                        if i == 0 {
                            path_builder.begin(point(poly_vec.x, poly_vec.y));
                        } else {
                            path_builder.line_to(point(poly_vec.x, poly_vec.y));
                        }
                    }
                    path_builder.end(i == self.walls.len() - 1);
                }
            }

            let path = path_builder.build();

            let result = tessellator.tessellate_path(
                &path,
                &FillOptions::default().with_sweep_orientation(Orientation::Horizontal),
                &mut geometry_builder,
            );
            assert!(result.is_ok());

            self.create_mesh(&tessellate_output);
        }
    }

    fn write_data_file(&self, nav_polygons: &Vec<nav::PolyData>) {
        use std::fs;

        let data: Vec<String> = nav_polygons
            .iter()
            .map(|poly| {
                poly.vertices
                    .iter()
                    .map(|point| format!("{},{}", point.x, point.z))
                    .collect::<Vec<String>>()
                    .join(",")
            })
            .collect();

        fs::write("../coords-data.csv", data.join("\n"));
    }

    #[export]
    fn add_wall_to_mesh(&mut self, owner: &Node, instance_id: i64, wall: TypedArray<Vector2>) {
        godot_dbg!(format!("Adding {:?}", wall));
        self.walls.insert(instance_id, wall);
        self.create_tilemap_data(owner);
    }

    #[export]
    fn remove_wall_from_mesh(&mut self, owner: &Node, instance_id: i64) {
        self.walls.remove(&instance_id);
        self.create_tilemap_data(owner);
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
