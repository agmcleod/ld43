use gdnative::{GodotString, ItemList, Node, NodePath, ResourceLoader, Texture};

use crate::{inventory_data::InventoryData, paths};

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

fn get_ingredetient_items_data(inventory_data: &InventoryData) -> [IngredientItem; 6] {
  [
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
  ]
}

pub fn create_ingredient_items(inventory_data: &InventoryData, item_list: &mut ItemList) {
  let data = get_ingredetient_items_data(inventory_data);

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

pub fn update_resources(inventory_data: &InventoryData, owner: Node) {
  let ingredient_list: Option<ItemList> = unsafe {
    let node = owner.get_node(NodePath::from_str(paths::INGREDIENT_ITEM_LIST));

    if let Some(node) = node {
      node.cast::<ItemList>()
    } else {
      None
    }
  };

  if let Some(mut ingredient_list) = ingredient_list {
    let data = get_ingredetient_items_data(inventory_data);
    for (i, item) in data.iter().enumerate() {
      unsafe {
        ingredient_list.set_item_text(i as i64, GodotString::from(format!("{}", item.amount)));
      }
    }
  }
}
