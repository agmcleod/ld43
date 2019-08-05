extends "./SpellReceiver.gd"

onready var vision_area: Area2D = $Vision
onready var nav_2d: Navigation2D = $"/root/game/Navigation2D"

const Arrow = preload("res://units/Arrow.tscn")

export (float) var speed = 1800
export (float) var fire_rate = 1.5

var tracked_node = null
var last_tracked_position := Vector2(0, 0)
var attack_ticker := 0.0
var path := PoolVector2Array([])

# Called when the node enters the scene tree for the first time.
func _ready():
  vision_area.connect("body_entered", self, "_on_body_entered_vision")
  vision_area.connect("body_exited", self, "_on_body_exited_vision")
  attack_ticker = 0.0
  last_tracked_position.x = self.position.x
  last_tracked_position.y = self.position.y
  pass # Replace with function body.


func _physics_process(delta: float):
  if tracked_node != null:
    attack_ticker += delta
    if attack_ticker > fire_rate:
      attack_ticker = 0.0
      var arrow_scene = Arrow.instance()
      arrow_scene.position = self.position
      arrow_scene.set_target(tracked_node.position)
      get_tree().get_root().add_child(arrow_scene)
  else:
    var distance: float = speed * delta
    var start_point := self.position
    for i in range(path.size()):
      var distance_to_point := start_point.distance_to(path[0])
      if distance <= distance_to_point && distance >= 0.0:
        move_and_slide((path[0] - start_point).normalized() * distance)
        break
      distance -= distance_to_point
      start_point = path[0]
      move_and_slide((path[0] - start_point).normalized())
      path.remove(0)


func _on_body_entered_vision(body):
  if body.name == "Player":
    tracked_node = body
    

func _on_body_exited_vision(body):
  if body.name == "Player":
    last_tracked_position.x = tracked_node.position.x
    last_tracked_position.y = tracked_node.position.y
    tracked_node = null
    path = nav_2d.get_simple_path(self.position, last_tracked_position)
    print(self.position, " to ", last_tracked_position, " ", path)
