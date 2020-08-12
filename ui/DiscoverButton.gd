extends Control

onready var discover_button = $Button
onready var item_list = $IngredientItemList
onready var craft_list = $"../Craft"

func _on_ItemList_multi_selected(item, selected):
  discover_button.disabled = item_list.get_selected_items().size() == 0

# discover the ingredients and create a new crafted spell
func _on_Button_pressed():
  var items = item_list.get_selected_items()
  var ingredient_types = []
  for item in items:
    ingredient_types.append(item_list.current_ingredients[item])

  craft_list.discover(ingredient_types)
