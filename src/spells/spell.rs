use gdnative::{
    godot_error, godot_print, godot_wrap_method, godot_wrap_method_inner,
    godot_wrap_method_parameter_count,
    init::{ClassBuilder, Property, PropertyHint, PropertyUsage},
    methods,
    user_data::MutexData,
    Area2D, GodotObject, GodotString, KinematicBody2D, NativeClass, Node, VariantArray, Vector2,
};

const DEFAULT_DIRECTION: Vector2 = Vector2::new(1.0, 0.0);

use crate::spells::{SpellStatusType, SpellType};

pub struct Spell {
    pub spell_type: SpellType,
    pub spell_status_type: SpellStatusType,
    pub damage: isize,
    pub status_duration: isize,
    pub status_damage: isize,
    pub duration: f32,
    pub direction: Vector2,
    pub velocity: f32,
    pub time_alive: f32,
    pub caster: Option<Node>,
}

unsafe impl Send for Spell {}

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
            direction: DEFAULT_DIRECTION.clone(),
            velocity: 0.0,
            time_alive: 0.0,
            caster: None,
        }
    }

    #[export]
    fn _ready(&self, mut owner: Area2D) {
        unsafe {
            let owner_obj = owner.clone().to_object();
            let res = owner.connect(
                GodotString::from_str("body_entered"),
                Some(owner_obj),
                GodotString::from_str("_onbody_entered"),
                VariantArray::new(),
                0,
            );
            if res.is_err() {
                panic!("Could not connect spell body_entered");
            }
            if self.spell_type != SpellType::SHIELD {
                owner.add_to_group(GodotString::from_str("projectiles"), false);
            }
        }
    }

    #[export]
    fn _process(&mut self, mut owner: Area2D, delta: f32) {
        self.time_alive += delta;
        if self.velocity != 0.0 {
            unsafe {
                owner.translate(self.direction.normalize() * self.velocity * delta);
            }
        }

        if self.time_alive >= self.duration {
            unsafe {
                owner.queue_free();
            }
        }
    }

    #[export]
    unsafe fn _onbody_entered(&self, owner: Area2D, body: KinematicBody2D) {
        godot_print!("owner: {:?}, body: {:?}", owner, body);
    }

    pub fn set_direction(&mut self, mut owner: Area2D, direction: Vector2) {
        self.direction = direction;
        unsafe {
            owner.rotate(DEFAULT_DIRECTION.angle_to(self.direction).get().into());
        }
    }
}
