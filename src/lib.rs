use gdnative::*;

mod crafting;
mod inventory_data;
mod load_scene;
mod paths;
mod spells;

/// The HelloWorld "class"
#[derive(NativeClass)]
#[inherit(Node)]
pub struct HelloWorld;

// __One__ `impl` block can have the `#[methods]` attribute, which will generate
// code to automatically bind any exported methods to Godot.
#[methods]
impl HelloWorld {
    /// The "constructor" of the class.
    fn _init(_owner: Node) -> Self {
        HelloWorld
    }

    // In order to make a method known to Godot, the #[export] attribute has to be used.
    // In Godot script-classes do not actually inherit the parent class.
    // Instead they are"attached" to the parent object, called the "owner".
    // The owner is passed to every single exposed method.
    #[export]
    fn _ready(&self, _owner: Node) {
        let ingredient_list: Option<ItemList> = unsafe {
            let node = _owner.get_node(NodePath::from_str(paths::INGREDIENT_ITEM_LIST));

            if let Some(node) = node {
                node.cast::<ItemList>()
            } else {
                None
            }
        };

        let inventory_data_object = inventory_data::InventoryData {
            red: 999,
            blue: 999,
            bird: 999,
            frog: 999,
            squirrel: 999,
            turtle: 999,
        };

        if let Some(mut ingredient_list) = ingredient_list {
            crafting::create_ingredient_items(&inventory_data_object, &mut ingredient_list);
        }
    }
}

// Function that registers all exposed classes to Godot
fn init(handle: gdnative::init::InitHandle) {
    handle.add_class::<HelloWorld>();
}

// macros that create the entry-points of the dynamic library.
godot_gdnative_init!();
godot_nativescript_init!(init);
godot_gdnative_terminate!();
