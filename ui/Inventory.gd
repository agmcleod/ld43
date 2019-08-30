extends WindowDialog

func _ready():
  pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass


func _on_Inventory_popup_hide():
  print("popup hide")
  get_tree().paused = false
