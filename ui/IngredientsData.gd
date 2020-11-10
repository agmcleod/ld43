extends Node

const Constants = preload("res://Constants.gd")
var INGREDIENT_TYPES = Constants.INGREDIENT_TYPES

onready var INGREDIENTS_MAPPING: Dictionary = {
  INGREDIENT_TYPES.RED: {
    "texture": load("res://images/ingredients/redflower.png"),
    "label": str(InventoryStorage.inventory_data[INGREDIENT_TYPES.RED])
  },
  INGREDIENT_TYPES.BLUE: {
    "texture": load("res://images/ingredients/blueflower.png"),
    "label": str(InventoryStorage.inventory_data[INGREDIENT_TYPES.BLUE])
  },
  INGREDIENT_TYPES.SQUIRREL: {
    "texture": load("res://images/ingredients/squirrel.png"),
    "label": str(InventoryStorage.inventory_data[INGREDIENT_TYPES.SQUIRREL])
  },
  INGREDIENT_TYPES.BIRD: {
    "texture": load("res://images/ingredients/bird.png"),
    "label": str(InventoryStorage.inventory_data[INGREDIENT_TYPES.BIRD])
  },
  INGREDIENT_TYPES.FROG: {
    "texture": load("res://images/ingredients/frog.png"),
    "label": str(InventoryStorage.inventory_data[INGREDIENT_TYPES.FROG])
  },
  INGREDIENT_TYPES.TURTLE: {
    "texture": load("res://images/ingredients/turtle.png"),
    "label": str(InventoryStorage.inventory_data[INGREDIENT_TYPES.TURTLE])
  }
}
