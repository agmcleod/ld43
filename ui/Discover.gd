extends Control

onready var discover_button = $Button
onready var item_list = $IngredientItemList


func _on_ItemList_multi_selected(item, selected):
  discover_button.disabled = item_list.get_selected_items().size() == 0


func _on_Button_pressed():
  var items = item_list.get_selected_items()
  for item in items:
    print(item_list.DATA[item])
  pass # Replace with function body.
