extends "res://units/EnemyTracker.gd"

onready var attack_zone: Area2D = $AttackZone
onready var player: Player = $"/root/game/Player"

export (float) var attack_rate = 1.5

var out_of_range = true
var last_target: Vector2 = Vector2(0, 0)

var attack_ticker := 0.0

func _ready():
  attack_ticker = 0.0
  attack_zone.connect("body_entered", self, "_on_body_entered_attack_zone")
  attack_zone.connect("body_exited", self, "_on_body_exited_attack_zone")


func _physics_process(delta):
  if is_knockedback():
    return
  if out_of_range && tracked_node && last_target != tracked_node.position:
    last_target = tracked_node.position
    _set_path_for_tracked_position(last_target)
  
  if !out_of_range:
    attack_ticker += delta
    if attack_ticker > attack_rate:
      player.take_damage(10)
      attack_ticker = 0.0   


func _on_body_entered_attack_zone(body):
  if body.name == "Player":
    out_of_range = false


func _on_body_exited_attack_zone(body):
  if body.name == "Player":
    out_of_range = true
  
  
func should_follow():
  return out_of_range
