use gdnative::{
    godot_error, godot_wrap_method, godot_wrap_method_inner, godot_wrap_method_parameter_count,
    init::{ClassBuilder, Property, PropertyHint, PropertyUsage},
    methods,
    user_data::MutexData,
    Area2D, GodotString, NativeClass, Object, VariantArray,
};

use crate::spells::{SpellStatusType, SpellType};

pub struct Spell {
    spell_type: SpellType,
    spell_status_type: SpellStatusType,
}

impl NativeClass for Spell {
    type Base = Area2D;
    type UserData = MutexData<Spell>;

    fn class_name() -> &'static str {
        "Spell"
    }

    fn init(owner: Self::Base) -> Self {
        Self::_init(owner)
    }

    fn register_properties(builder: &ClassBuilder<Self>) {
        builder.add_property(Property {
            name: "Spell Type",
            default: GodotString::from_str(SpellType::BALL.to_str()),
            hint: PropertyHint::Enum {
                values: &[
                    SpellType::BALL.to_str(),
                    SpellType::WAVE.to_str(),
                    SpellType::SHIELD.to_str(),
                ],
            },
            getter: |this: &Spell| GodotString::from_str(this.spell_type.to_str()),
            setter: |this: &mut Spell, v: GodotString| {
                this.spell_type = SpellType::from_str(&v.to_string())
            },
            usage: PropertyUsage::DEFAULT,
        });

        builder.add_property(Property {
            name: "Spell Status Type",
            default: GodotString::from_str(SpellStatusType::ARCANE.to_str()),
            hint: PropertyHint::Enum {
                values: &[
                    SpellStatusType::ARCANE.to_str(),
                    SpellStatusType::FIRE.to_str(),
                    SpellStatusType::FROST.to_str(),
                ],
            },
            getter: |this: &Spell| GodotString::from_str(this.spell_status_type.to_str()),
            setter: |this: &mut Spell, v: GodotString| {
                this.spell_status_type = SpellStatusType::from_str(&v.to_string())
            },
            usage: PropertyUsage::DEFAULT,
        });
    }
}

#[methods]
impl Spell {
    fn _init(_owner: Area2D) -> Self {
        Spell {
            spell_type: SpellType::BALL,
            spell_status_type: SpellStatusType::ARCANE,
        }
    }

    #[export]
    fn _ready(&self, mut owner: Area2D) {
        unsafe {
            owner.connect(
                GodotString::from_str("body_entered"),
                Some(owner.to_object()),
                GodotString::from_str("_onbody_entered"),
                VariantArray::new(),
                0,
            );
            if self.spell_type != SpellType::SHIELD {}
        }
    }

    #[export]
    fn _onbody_entered(body: Object) {
        println!("{:?}", body);
    }
}
