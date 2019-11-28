use gdnative::{methods, Area2D, GodotString, NativeClass, Object, VariantArray, init::{ClassBuilder, Property, PropertyHint, PropertyUsage}, user_data::MutexData};

use spells::{SPELL_TYPE, SPELL_STATUS_TYPE};

pub struct Spell {
    spell_type: SPELL_TYPE,
    spell_status_type: SPELL_TYPE
}

impl NativeClass for Spell {
    type Base = Area2D;
    type UserData = MutexData<Spell>;

    fn class_name() -> &'static str {
        "Spell"
    }

    fn init(_owner: Self::Base) -> Self {
        Self::init()
    }

    fn register_properties(builder: &ClassBuilder<Self>) {
        builder.add_property(Property {
            name: "Spell Type",
            default: SPELL_TYPE::BALL.to_str(),
            hint: PropertyHint::Enum {
                values: &[SPELL_TYPE::BALL.to_str(), SPELL_TYPE::WAVE.to_str(), SPELL_TYPE::SHEILD.to_str()]
            },
            getter: |this: &Spell| this.spell_type,
            setter: |this: &mut Spell, v| this.spell_type = SPELL_TYPE::from_str(v),
            usage: PropertyUsage::DEFAULT
        })
    }
}

#[methods]
impl Spell {
    fn _init(_owner: Area2D) -> Self {
        Spell
    }

    #[export]
    fn _ready(&self, mut owner: Area2D) {
        unsafe {
            owner.connect(GodotString::from_str("body_entered"), owner, , "_onbody_entered", VariantArray::new(), 0);
            if ()
        }
    }

    #[export]
    fn _onbody_entered(body: Object) {
        println!
    }
}
