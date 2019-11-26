use crate::crafting::INGREDIENT_TYPES;

pub struct InventoryData {
    pub red: usize,
    pub blue: usize,
    pub bird: usize,
    pub frog: usize,
    pub squirrel: usize,
    pub turtle: usize,
}

impl InventoryData {
    pub fn get_for_type(&self, ingredient_type: INGREDIENT_TYPES) -> usize {
        match ingredient_type {
            INGREDIENT_TYPES::RED => self.red,
            INGREDIENT_TYPES::BLUE => self.blue,
            INGREDIENT_TYPES::BIRD => self.bird,
            INGREDIENT_TYPES::FROG => self.frog,
            INGREDIENT_TYPES::SQUIRREL => self.squirrel,
            INGREDIENT_TYPES::TURTLE => self.turtle,
        }
    }
}
