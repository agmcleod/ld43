extends Sprite

var target_owner: Node = null

func set_owner(o: Node):
  target_owner = o
  position.x = target_owner.position.x
  position.y = target_owner.position.y
  print('owner ', target_owner)


func _process(_delta: float):
  if target_owner != null:
    var mouse_pos = get_global_mouse_position()
    var distance = target_owner.position.distance_to(mouse_pos)
    if distance > 300:
      mouse_pos = target_owner.position.linear_interpolate(mouse_pos, 300 / distance)

    position.x = mouse_pos.x
    position.y = mouse_pos.y
