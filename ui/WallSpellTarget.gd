extends Sprite

var click_target: Vector2 = Vector2(0, 0)
var default_direction := Vector2(1, 0)
var target_owner: Node = null

func set_owner(o: Node):
  target_owner = o


func set_click_target(x: float, y: float):
  click_target.x = x
  click_target.y = y


func update_position():
  var mouse_pos = get_global_mouse_position()
  var direction = (mouse_pos - click_target).normalized()
  set_rotation(default_direction.angle_to(direction))

  var distance = click_target.distance_to(mouse_pos)
  var target_dist = self.texture.get_width() / 2.0
  # Not sure if a more math-y way to do this, but it fixes initial position
  if distance == 0:
    position.x = mouse_pos.x + target_dist
    position.y = mouse_pos.y
  else:
    var new_pos = click_target.linear_interpolate(mouse_pos, target_dist / distance)
    position.x = new_pos.x
    position.y = new_pos.y


func _ready():
  update_position()


func _process(_delta: float):
  update_position()
