use gdnative::{PackedScene, Vector2};

use crate::{crafting::IngredientTypes, load_scene::{load_scene, instance_scene}, spells::{SpellStatusType, Spell}};

fn create_spell_type(
    spell_status_type: SpellStatusType,
    spell_type_name: &str,
    spell_base: &str,
    direction: Vector2,
) -> Option<PackedScene> {
    let spell_scene = load_scene(&format!(
        "res://spells/{}{}.tscn",
        spell_type_name, spell_base
    ));

    if let Some(mut spell_scene) = spell_scene {
        match instance_scene::<Spell>(&spell_scene) {
            Ok(mut spell_scene) {
                spell_scene.map_mut(|spell_scene, owner| {
                    spell_scene.status_type = spell_status_type;
                    if spell_base == "shield" {
                        spell_scene.velocity = 0;
                    } else {
                        spell_scene.velocity = 600;
                        spell_scene.direction =
                    }
                });

                spell_scene
            },
            Err(err) => godot_print!("Could not load spell scene as spell type"),
        }
    }

    None
}
