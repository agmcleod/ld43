use gdnative::{GodotString, ItemList, Resource, ResourceLoader, Texture};

use crate::inventory_data::InventoryData;

pub enum INGREDIENT_TYPES {
  RED,
  BLUE,
  BIRD,
  FROG,
  SQUIRREL,
  TURTLE,
}

struct IngredientItem {
  ingredient_type: INGREDIENT_TYPES,
  texture: String,
  amount: usize,
}

impl IngredientItem {
  fn new(ingredient_type: INGREDIENT_TYPES, texture: &str, amount: usize) -> IngredientItem {
    IngredientItem {
      ingredient_type,
      texture: format!("res://images/ingredients/{}", texture),
      amount,
    }
  }
}

pub fn create_ingredient_items(inventory_data: &InventoryData, item_list: &mut ItemList) {
  let data = [
    IngredientItem::new(INGREDIENT_TYPES::RED, "redflower.png", inventory_data.red),
    IngredientItem::new(
      INGREDIENT_TYPES::BLUE,
      "blueflower.png",
      inventory_data.blue,
    ),
    IngredientItem::new(
      INGREDIENT_TYPES::SQUIRREL,
      "squirrel.png",
      inventory_data.blue,
    ),
    IngredientItem::new(INGREDIENT_TYPES::BIRD, "bird.png", inventory_data.blue),
    IngredientItem::new(INGREDIENT_TYPES::FROG, "frog.png", inventory_data.blue),
    IngredientItem::new(INGREDIENT_TYPES::TURTLE, "turtle.png", inventory_data.blue),
  ];

  for item in &data {
    unsafe {
      item_list.add_item(
        GodotString::from(format!("{}", item.amount)),
        ResourceLoader::godot_singleton()
          .load(
            GodotString::from(&item.texture),
            GodotString::from("Texture"),
            false,
          )
          .and_then(|r| r.cast::<Texture>()),
        true,
      );
    }
  }
}
