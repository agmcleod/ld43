extends Node2D

class_name FloatingText

onready var label: Label = $"./Label"
onready var icon: Sprite = $"./Sprite"
onready var IngredientsData = $"/root/IngredientsData"

var start_y

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var timer_to_disappear = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
  start_y = position.y
  pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  timer_to_disappear -= delta
  label.add_color_override("font_color", Color(1, 1, 0, timer_to_disappear / 2 + 0.5))


  position.y = lerp(start_y, start_y - 30, 1.0 - timer_to_disappear)

  if timer_to_disappear < 0:
    queue_free()
  pass


func set_text(value: String):
  label.text = value


func set_icon(ingredient_type: int):
  icon.visible = true
  icon.texture = IngredientsData.INGREDIENTS_MAPPING[ingredient_type].texture
