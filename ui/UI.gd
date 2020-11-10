extends CanvasLayer

const Constants = preload("res://Constants.gd")

var INGREDIENT_TYPES = Constants.INGREDIENT_TYPES

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


func get_craft():
  return $"Inventory/TabContainer/Craft"


func get_ingredient_item_list():
  return $"Inventory/TabContainer/Discover/IngredientItemList"


func get_spell_bindings():
  return $"SpellBindings"


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass
