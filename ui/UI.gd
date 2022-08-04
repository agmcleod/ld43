extends CanvasLayer

const Constants = preload("res://Constants.gd")

var INGREDIENT_TYPES = Constants.INGREDIENT_TYPES

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


func get_bindings():
  return $"Inventory/TabContainer/Bindings"


func get_ingredient_item_list():
  return get_discover().get_node("IngredientItemList")


func get_spell_bindings():
  return $"SpellBindings"


func get_discover():
  return $"Inventory/TabContainer/Discover"
