extends Sprite

var target_owner: Node = null

func set_owner(o: Node):
  target_owner = o
  position.x = target_owner.position.x
  position.y = target_owner.position.y
  print('owner ', target_owner)


func _physics_process(delta):
  if target_owner != null:
    var space_state = get_world_2d().direct_space_state
    var mouse_pos = get_global_mouse_position()
    # 4th param, the collision mask is hardcoded here. Based on wall layer having a value of 2
    var result = space_state.intersect_ray(target_owner.position, mouse_pos, [target_owner], 2)
    if result.has('collider'):
      # print(result.normal, " ", result.position)
      position = result.position
    else:
      var distance = target_owner.position.distance_to(mouse_pos)
      if distance > 300:
        mouse_pos = target_owner.position.linear_interpolate(mouse_pos, 300 / distance)

      position.x = mouse_pos.x
      position.y = mouse_pos.y


func _ready():
  set_physics_process(true)
