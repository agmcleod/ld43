class_name EnemyTracker

# onready var vision_area: Area2D = $Vision
# onready var nav_2d: Navigation2D = $"/root/game/Navigation2D"

var tracked_node = null
var last_tracked_position := Vector2(0, 0)
# default to facing left
var last_direction_vector := Vector2(-0.9, 0.9)
var path := PoolVector2Array([])
var nav_2d
var chase_distance
var vision_area
var owner

func _init(owner: Node, nav_2d: Navigation2D, chase_distance: float, vision_area: Area2D):
  self.nav_2d = nav_2d
  self.chase_distance = chase_distance
  self.vision_area = vision_area
  last_tracked_position.x = owner.position.x
  last_tracked_position.y = owner.position.y
  self.owner = owner
  owner.add_to_group("enemies")
  self.vision_area.connect("body_entered", self, "_on_body_entered_vision")
  self.vision_area.connect("body_exited", self, "_on_body_exited_vision")


func get_tracked_node() -> Node:
  return tracked_node


func move_towards_target(delta: float):
  var start_point :Vector2 = self.owner.position

  if path.size() == 0:
    self.owner.set_animation("%sStill" % self._get_animation_name_from_direction())
    return

  for _i in range(path.size()):
    var distance_to_point := start_point.distance_to(path[0])
    if delta <= distance_to_point && delta >= 0.0:
      last_direction_vector = (path[0] - start_point).normalized()
      self.owner.move_and_collide(last_direction_vector * delta)
      break
      delta -= distance_to_point
    start_point = path[0]
    last_direction_vector = (path[0] - start_point).normalized()
    self.owner.move_and_collide(last_direction_vector)
    path.remove(0)

  var dir_name = self._get_animation_name_from_direction()
  print(rad2deg(last_direction_vector.angle()), " ", last_direction_vector)
  self.owner.set_animation("%sMove" % [dir_name])


func _get_animation_name_from_direction() -> String:
  var angle = rad2deg(last_direction_vector.angle())
  if angle >= -45 && angle <= 45:
    return "Right"
  elif angle > 45 && angle <= 135:
    return "Down"
  elif (angle > 135 && angle <= 180) || (angle >= -180 && angle <= -135):
    return "Left"
  else:
    return "Up"


func _on_body_entered_vision(body):
  if body.name == "Player":
    tracked_node = body


func _on_body_exited_vision(body):
  if body.name == "Player":
    last_tracked_position.x = tracked_node.position.x
    last_tracked_position.y = tracked_node.position.y
    tracked_node = null
    _set_path_for_tracked_position(last_tracked_position)


func _set_path_for_tracked_position(pos):
  path = self.nav_2d.get_simple_path(self.owner.global_position, pos)


func handle_spell(spell: Spell):
  # Move towards where spell came from
  if tracked_node == null:
    last_tracked_position.x = spell.direction.x * -self.chase_distance + self.owner.position.x
    last_tracked_position.y = spell.direction.y * -self.chase_distance + self.owner.position.y
    _set_path_for_tracked_position(last_tracked_position)