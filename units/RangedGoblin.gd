extends "./EnemyTracker.gd"

const Arrow = preload("res://units/Arrow.tscn")

export (float) var fire_rate = 1.5

var attack_ticker := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
  attack_ticker = 0.0


func _physics_process(delta: float):
  if tracked_node != null:
    attack_ticker += delta
    if attack_ticker > fire_rate:
      attack_ticker = 0.0
      var arrow_scene = Arrow.instance()
      var direction :Vector2 = (tracked_node.position - self.position).normalized()
      arrow_scene.position = self.position + direction * 5
      arrow_scene.set_direction(direction) 
      $"/root/game".add_child(arrow_scene)