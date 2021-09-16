use gdnative::{api::TileMap, prelude::*};

#[derive(NativeClass)]
#[inherit(Node)]
struct PathFinding;

#[gdnative::methods]
impl PathFinding {
    fn new(_owner: &Node) -> Self {
        PathFinding
    }

    #[export]
    fn _ready(&self, owner: &Node) {
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

            for id in tileset.get_tiles_ids().iter() {
                let poly = tileset.tile_get_navigation_polygon(id.to_i64());
                if let Some(poly) = poly {
                    let polygon = poly.assume_safe();
                    godot_dbg!(polygon.vertices());
                }
            }
        }
    }
}

fn init(handle: InitHandle) {
    handle.add_class::<PathFinding>();
}

godot_init!(init);
