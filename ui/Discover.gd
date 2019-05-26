extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


func _on_ItemList_item_selected(item):
  print(item)


func _on_ItemList_multi_selected(item, selected):
  print("multi", item, selected)
