extends ColorRect

class_name HealthBar

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# sets the width to the percentage. So if unit is at 1/2 health, pass 0.5
func set_width_from_percent(percent: float) -> void:
  self.rect_size.x = 16 * percent
