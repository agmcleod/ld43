extends "./SpellReceiver.gd"

onready var vision_area: Area2D = $"./Vision"

const Arrow = preload("res://units/Arrow.tscn")

export (float) var fire_rate = 1.5

var tracked_node = null
var attack_ticker := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
  vision_area.connect("body_entered", self, "_on_body_entered_vision")
  vision_area.connect("body_exited", self, "_on_body_exited_vision")
  attack_ticker = 0.0
  pass # Replace with function body.


func _physics_process(delta):
  if tracked_node != null:
    attack_ticker += delta
    if attack_ticker > fire_rate:
      attack_ticker = 0.0
      var arrow_scene = Arrow.instance()
      arrow_scene.position = self.position
      arrow_scene.set_target(tracked_node.position)
      get_tree().get_root().add_child(arrow_scene)


func _on_body_entered_vision(body):
  if body.name == "Player":
    tracked_node = body
    

func _on_body_exited_vision(body):
  if body.name == "Player":
    tracked_node = null
  
