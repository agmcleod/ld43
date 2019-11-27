use gdnative::{methods, Area2D, GodotString, NativeClass};

#[derive(NativeClass)]
#[inherit(Area2D)]
pub struct Spell;

#[methods]
impl Spell {
    fn _init(_owner: Area2D) -> Self {
        Spell
    }

    #[export]
    fn _ready(&self, mut owner: Area2D) {
        unsafe {
            owner.connect(GodotString::from_str("body_entered"), owner, , "_onbody_entered");
        }
    }

    #[export]
    fn _onbody_entered() {}
}
