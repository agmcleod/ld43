use gdnative::{PackedScene, Vector2};

use crate::{crafting::INGREDIENT_TYPES, load_scene::load_scene, spells::SPELL_STATUS_TYPE};

fn create_spell_type(
    spell_status_type: SPELL_STATUS_TYPE,
    spell_type_name: &str,
    spell_base: &str,
    direction: Vector2,
) -> Option<PackedScene> {
    let spell_scene = load_scene(format!(
        "res://spells/{}{}.tscn",
        spell_type_name, spell_base
    ));

    if let Some(mut spell_scene) = spell_scene {
        instance_scene
    }

    None
}
