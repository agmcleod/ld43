const FloatingText = preload("res://ui/FloatingText.tscn")

class_name FloatingTextService

enum SIDE {
  LEFT,
  RIGHT
}

var last_side_used = SIDE.RIGHT

# Can expand on this to make it stagger by having an array of queued
# items, then have fn to call on the owner's ready function
func initialize_ft(owner: Node2D, text: String, icon: int, y_offset = 0):
  var floating_text = FloatingText.instance()
  floating_text.position.y += y_offset
  owner.add_child(floating_text)
  if icon != null:
    floating_text.set_icon(icon)
  floating_text.set_text(text)

  if last_side_used == SIDE.LEFT:
    floating_text.position.x += 32
    last_side_used = SIDE.RIGHT
  else:
    last_side_used = SIDE.LEFT
