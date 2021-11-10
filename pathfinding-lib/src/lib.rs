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

    fn create_mesh(&mut self, tessellate_output: &VertexBuffers<Point, u16>) {
        let params = nav::MeshParams {
            agent_height: None,
            agent_max_climb: None,
            agent_radius: 1.0,
            max_polys_per_region: 20,
            mesh_origin: nav::Point::new(0.0, 0.0, 0.0),
            voxel_length: 1.0,
            voxels_per_region: nav::Count3D::new(10, 10, 10),
        };

        let mut mesh =
            nav::NavMesh::new(&params).expect("Navigation mesh should be creatable from params");

        let polygons = tessellate_output
            .indices
            .chunks(3)
            .map(|chunk| {
                let mut points = chunk
                    .iter()
                    .map(|idx| {
                        let vert = tessellate_output.vertices.get(*idx as usize).unwrap();
                        nav::Point::new(vert.x, 0.0, vert.y)
                    })
                    .collect::<Vec<nav::Point>>();
                let mut center = (0.0, 0.0);
                for point in &points {
                    center.0 += point.x;
                    center.1 += point.z;
                }
                center.0 /= points.len() as f32;
                center.1 /= points.len() as f32;
                let mut angles = HashMap::<String, f32>::new();
                for point in &points {
                    angles.insert(
                        format!("{},{}", point.x, point.z),
                        (point.z - center.1).atan2(point.x - center.0),
                    );
                }
                points.sort_by(|a, b| {
                    // let cmp = a.x.partial_cmp(&b.x);
                    // match cmp {
                    //     Some(Ordering::Equal) => a.z.partial_cmp(&b.z).unwrap(),
                    //     _ => cmp.unwrap(),
                    // }
                    let b = angles.get(&format!("{},{}", b.x, b.z)).unwrap();
                    b.partial_cmp(angles.get(&format!("{},{}", a.x, a.z)).unwrap())
                        .unwrap()
                });
                nav::PolyData::new(points).unwrap()
            })
            .collect();

        let region = nav::Region {
            index_in_mesh: nav::Index3D::new(0, 0, 0),
            polygons,
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

            let mut tessellate_output: VertexBuffers<Point, u16> = VertexBuffers::new();
            let mut geometry_builder = simple_builder(&mut tessellate_output);
            let mut tessellator = FillTessellator::new();

            let mut path_builder = Path::builder();

            let cells = tile_map.get_used_cells();
            let cells_to_map = cells.iter().filter(|vec| {
                let vec = vec.to_vector2();
                let id = tile_map.get_cellv(vec);
                tile_ids_with_polygon.get(&id).is_some()
            });
            let mut has_pathed = false;
            let mut written_coords = Vec::new();
            for vec in cells_to_map {
                // if last loop had pathed, close it now
                if has_pathed {
                    path_builder.end(false);
                }
                has_pathed = false;
                let vec = vec.to_vector2();
                let id = tile_map.get_cellv(vec);
                if let Some(polygon) = tile_ids_with_polygon.get(&id) {
                    let mut poly_coords = Vec::new();
                    for i in 0..polygon.len() {
                        let poly_vec = polygon.get(i);
                        if i == 0 {
                            path_builder.begin(point(poly_vec.x + vec.x, poly_vec.y + vec.y));
                        } else {
                            path_builder.line_to(point(poly_vec.x + vec.x, poly_vec.y + vec.y));
                        }
                        poly_coords.push((poly_vec.x + vec.x, poly_vec.y + vec.y));
                        has_pathed = true;
                    }
                    written_coords.push(poly_coords);
                }
            }

            // godot_dbg!(written_coords);

            path_builder.close();

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
