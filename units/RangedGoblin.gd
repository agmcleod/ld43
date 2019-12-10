extends KinematicBody2D

onready var vision_area: Area2D = $Vision
onready var nav_2d: Navigation2D = $"/root/game/Navigation2D"

const Arrow = preload("res://units/Arrow.tscn")
var EnemyTracker = preload("res://units/EnemyTracker.gd")
var SpellReceiver = preload("res://units/SpellReceiver.gd")

export (float) var fire_rate = 1.5

var attack_ticker := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
  add_to_group("enemies")
  attack_ticker = 0.0
  self.spell_receiver: SpellReceiver = SpellReceiver.new(30)
  self.enemy_tracker: EnemyTracker = EnemyTracker.new(self, nav_2d, 120, 400, vision_area, self.position)


func _physics_process(delta: float):
  if is_knockedback():
    return
  if tracked_node != null:
    attack_ticker += delta
    if attack_ticker > fire_rate:
      attack_ticker = 0.0
      var arrow_scene = Arrow.instance()
      var direction :Vector2 = (tracked_node.position - self.position).normalized()
      arrow_scene.position = self.position + direction * 5
      arrow_scene.set_direction(direction)
      $"/root/game".add_child(arrow_scene)

  self.enemy_tracker._physics_process(delta)