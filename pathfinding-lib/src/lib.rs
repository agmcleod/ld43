use gdnative::prelude::*;

#[derive(NativeClass)]
#[inherit(Node)]
struct PathFinding;

#[gdnative::methods]
impl PathFinding {
    fn new(_owner: &Node) -> Self {
        PathFinding
    }

    #[export]
    fn _ready(&self, _owner: &Node) {
        godot_print!("hello, world.")
    }
}

fn init(handle: InitHandle) {
    handle.add_class::<PathFinding>();
}

godot_init!(init);
