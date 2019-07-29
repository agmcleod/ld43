extends Label

class_name FloatingText

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var timer_to_disappear = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  timer_to_disappear -= delta
  self.add_color_override("font_color", Color(1, 1, 0, timer_to_disappear / 2 + 0.5))
  
  self.margin_top = lerp(-10, -30, 1.0 - timer_to_disappear)
  
  if timer_to_disappear < 0:
    queue_free()
  pass
