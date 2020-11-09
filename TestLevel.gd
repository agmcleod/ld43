extends "./Game.gd"

onready var INGREDIENT_TYPES = Constants.INGREDIENT_TYPES
onready var InventoryStorage = $"/root/InventoryStorage"

class_name TestLevel

func _ready():
  ._ready()
  InventoryStorage.inventory_data[INGREDIENT_TYPES.RED] = 999
  InventoryStorage.inventory_data[INGREDIENT_TYPES.BLUE] = 999
  InventoryStorage.inventory_data[INGREDIENT_TYPES.BIRD] = 999
  InventoryStorage.inventory_data[INGREDIENT_TYPES.FROG] = 999
  InventoryStorage.inventory_data[INGREDIENT_TYPES.SQUIRREL] = 999
  InventoryStorage.inventory_data[INGREDIENT_TYPES.TURTLE] = 999

  var ui = $"UI"
  var ingredient_item_list = ui.get_ingredient_item_list()
  ingredient_item_list.enable_ingredient_type(INGREDIENT_TYPES.BIRD)
  ingredient_item_list.enable_ingredient_type(INGREDIENT_TYPES.FROG)
  ingredient_item_list.enable_ingredient_type(INGREDIENT_TYPES.SQUIRREL)
  ingredient_item_list.enable_ingredient_type(INGREDIENT_TYPES.TURTLE)
  ingredient_item_list.update_resources()
