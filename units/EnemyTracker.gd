class_name EnemyTracker

# onready var vision_area: Area2D = $Vision
# onready var nav_2d: Navigation2D = $"/root/game/Navigation2D"

var tracked_node = null
var last_tracked_position := Vector2(0, 0)
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
  for i in range(path.size()):
    var distance_to_point := start_point.distance_to(path[0])
    if delta <= distance_to_point && delta >= 0.0:
      self.owner.move_and_collide((path[0] - start_point).normalized() * delta)
      break
      delta -= distance_to_point
    start_point = path[0]
    self.owner.move_and_collide((path[0] - start_point).normalized())
    path.remove(0)


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