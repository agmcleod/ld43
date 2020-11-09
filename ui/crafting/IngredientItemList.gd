extends ItemList

class_name IngredientItemList

const Constants = preload("res://Constants.gd")

var INGREDIENT_TYPES = Constants.INGREDIENT_TYPES

onready var InventoryStorage = $"/root/InventoryStorage"

onready var DATA: Dictionary = {
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

onready var INGREDIENT_TYPES_BY_INDEX = DATA.keys()
onready var current_ingredients = [INGREDIENT_TYPES.RED, INGREDIENT_TYPES.BLUE]

# Called when the node enters the scene tree for the first time.
func _ready():
  for ingredient in current_ingredients:
    var item = DATA[ingredient]
    self.add_item(item.label, item.texture)


func enable_ingredient_type(ingredient_type):
  current_ingredients.append(ingredient_type)
  var item = DATA[ingredient_type]
  self.add_item(item.label, item.texture)


func update_resources():
  var i := 0
  for ingredient_type in current_ingredients:
    self.set_item_text(i, str(InventoryStorage.inventory_data[ingredient_type]))
    i += 1

