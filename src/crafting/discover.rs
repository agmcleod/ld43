use gdnative::{godot_print, Instance, PackedScene, Vector2};

use crate::{crafting::IngredientTypes, load_scene::{load_scene, instance_scene}, spells::{SpellStatusType, Spell}};

fn create_spell_type(
    spell_status_type: SpellStatusType,
    spell_type_name: &str,
    spell_base: &str,
    direction: Vector2,
) -> Option<Instance<Spell>> {
    let spell_scene = load_scene(&format!(
        "res://spells/{}{}.tscn",
        spell_type_name, spell_base
    ));

    if let Some(spell_scene) = spell_scene {
        unsafe {
            match instance_scene::<Spell>(&spell_scene) {
                Ok(spell_instance) => {
                    spell_instance.map_mut(|spell_scene, _owner| {
                        spell_scene.spell_status_type = spell_status_type;
                        if spell_base == "shield" {
                            spell_scene.velocity = 0.0;
                        } else {
                            spell_scene.velocity = 600.0;
                            spell_scene.direction = direction;
                        }
                    });

                    return Some(spell_instance)
                },
                Err(err) => godot_print!("Could not load spell scene as spell type"),
            }
        }
    }

    None
}
