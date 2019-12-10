class_name EnemyTracker

# onready var vision_area: Area2D = $Vision
# onready var nav_2d: Navigation2D = $"/root/game/Navigation2D"

var tracked_node = null
var last_tracked_position := Vector2(0, 0)
var path := PoolVector2Array([])

func _init(owner: Node, nav_2d: Navigation2D, speed: float, chase_distance: float, vision_area: Area2D, position: Vector2):
  self.nav_2d = nav_2d
  self.speed = speed
  self.chase_distance = chase_distance
  self.vision_area: Area2D = vision_area
  last_tracked_position.x = position.x
  last_tracked_position.y = position.y


# setup so it can be overridden by sub classes
func should_follow():
  return tracked_node == null

# Called when the node enters the scene tree for the first time.
func _ready():
  vision_area.connect("body_entered", self, "_on_body_entered_vision")
  vision_area.connect("body_exited", self, "_on_body_exited_vision")


func _physics_process(delta: float):
  if should_follow():
    var distance: float = speed * delta
    if status == Constants.SPELL_STATUS_TYPE.FROST:
      distance /= 2
    var start_point := self.owner.position
    for i in range(path.size()):
      var distance_to_point := start_point.distance_to(path[0])
      if distance <= distance_to_point && distance >= 0.0:
        move_and_collide((path[0] - start_point).normalized() * distance)
        break
      distance -= distance_to_point
      start_point = path[0]
      move_and_collide((path[0] - start_point).normalized())
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
  path = nav_2d.get_simple_path(self.owner.global_position, pos)


func handle_spell(spell: Spell):
  .handle_spell(spell)
  # Move towards where spell came from
  if tracked_node == null:
    last_tracked_position.x = spell.direction.x * -chase_distance + position.x
    last_tracked_position.y = spell.direction.y * -chase_distance + position.y
    _set_path_for_tracked_position(last_tracked_position)