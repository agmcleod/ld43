use crate::crafting::IngredientTypes;

pub struct InventoryData {
    pub red: usize,
    pub blue: usize,
    pub bird: usize,
    pub frog: usize,
    pub squirrel: usize,
    pub turtle: usize,
}

impl InventoryData {
    pub fn get_for_type(&self, ingredient_type: IngredientTypes) -> usize {
        match ingredient_type {
            IngredientTypes::RED => self.red,
            IngredientTypes::BLUE => self.blue,
            IngredientTypes::BIRD => self.bird,
            IngredientTypes::FROG => self.frog,
            IngredientTypes::SQUIRREL => self.squirrel,
            IngredientTypes::TURTLE => self.turtle,
        }
    }
}
