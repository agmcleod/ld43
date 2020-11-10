extends ItemList

class_name IngredientItemList

const Constants = preload("res://Constants.gd")

var INGREDIENT_TYPES = Constants.INGREDIENT_TYPES

onready var InventoryStorage = $"/root/InventoryStorage"
onready var IngredientsData = $"/root/IngredientsData"

onready var current_ingredients = [INGREDIENT_TYPES.RED, INGREDIENT_TYPES.BLUE]

# Called when the node enters the scene tree for the first time.
func _ready():
  for ingredient in current_ingredients:
    var item = IngredientsData.INGREDIENTS_MAPPING[ingredient]
    self.add_item(item.label, item.texture)


func enable_ingredient_type(ingredient_type):
  current_ingredients.append(ingredient_type)
  var item = IngredientsData.INGREDIENTS_MAPPING[ingredient_type]
  self.add_item(item.label, item.texture)


func update_resources():
  var i := 0
  for ingredient_type in current_ingredients:
    self.set_item_text(i, str(InventoryStorage.inventory_data[ingredient_type]))
    i += 1

