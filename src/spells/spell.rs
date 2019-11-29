use gdnative::{
    godot_error, godot_wrap_method, godot_wrap_method_inner, godot_wrap_method_parameter_count,
    init::{ClassBuilder, Property, PropertyHint, PropertyUsage},
    methods,
    user_data::MutexData,
    Area2D, GodotString, GodotObject, KinematicBody2D, NativeClass, VariantArray,
    godot_print
};

use crate::spells::{SpellStatusType, SpellType};

pub struct Spell {
    spell_type: SpellType,
    spell_status_type: SpellStatusType,
    damage: isize,
    status_duration: isize,
    status_damage: isize,
    duration: f32,
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

        builder.add_property(Property {
            name: "Damage",
            default: 0,
            hint: PropertyHint::None,
            getter: |this: &Spell| this.damage,
            setter: |this: &mut Spell, v| this.damage = v,
            usage: PropertyUsage::DEFAULT,
        });

        builder.add_property(Property {
            name: "Status duration",
            default: 0,
            hint: PropertyHint::None,
            getter: |this: &Spell| this.status_duration,
            setter: |this: &mut Spell, v| this.status_duration = v,
            usage: PropertyUsage::DEFAULT,
        });

        builder.add_property(Property {
            name: "Status damage",
            default: 0,
            hint: PropertyHint::None,
            getter: |this: &Spell| this.status_damage,
            setter: |this: &mut Spell, v| this.status_damage = v,
            usage: PropertyUsage::DEFAULT,
        });

        builder.add_property(Property {
            name: "Duration",
            default: 0.0,
            hint: PropertyHint::None,
            getter: |this: &Spell| this.duration,
            setter: |this: &mut Spell, v| this.duration = v,
            usage: PropertyUsage::DEFAULT,
        });
    }
}

// not even sure if this is the right approach
unsafe impl GodotObject for Spell {}

#[methods]
impl Spell {
    fn _init(_owner: Area2D) -> Self {
        Spell {
            spell_type: SpellType::BALL,
            spell_status_type: SpellStatusType::ARCANE,
            damage: 0,
            status_duration: 0,
            status_damage: 0,
            duration: 0.0,
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
    unsafe fn _onbody_entered(&self, owner: Area2D, body: KinematicBody2D) {
        godot_print!("owner: {:?}, body: {:?}", owner, body);
    }
}
