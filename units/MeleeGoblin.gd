extends KinematicBody2D

const Constants = preload("res://Constants.gd")
var EnemyTracker = preload("res://units/EnemyTracker.gd")
var SpellReceiver = preload("res://units/SpellReceiver.gd")

onready var vision_area: Area2D = $Vision
onready var nav_2d: Navigation2D = get_tree().get_current_scene().get_node("Navigation2D")
onready var attack_zone: Area2D = $AttackZone
onready var player: Player = get_tree().get_current_scene().get_node("Player")
onready var health_bar = $"./Sprite/HealthBar"

export (float) var attack_rate = 1.5

var out_of_range = true
var last_target: Vector2 = Vector2(0, 0)

var attack_ticker := 0.0
var spell_receiver
var enemy_tracker
var speed := 120

func _ready():
  attack_ticker = 0.0
  self.spell_receiver = SpellReceiver.new(self, 40)
  self.enemy_tracker = EnemyTracker.new(self, nav_2d, 600, vision_area)
  attack_zone.connect("body_entered", self, "_on_body_entered_attack_zone")
  attack_zone.connect("body_exited", self, "_on_body_exited_attack_zone")


func _process(delta):
  self.spell_receiver._process(delta)
  if self.spell_receiver.is_knockedback() || !spell_receiver.can_move():
    return

  var tracked_node = self.enemy_tracker.tracked_node
  if out_of_range && tracked_node && last_target != tracked_node.position:
    last_target = tracked_node.position
    self.enemy_tracker._set_path_for_tracked_position(last_target)


func _physics_process(delta):
  if self.spell_receiver.is_knockedback() || !spell_receiver.can_move():
    return

  if !out_of_range:
    attack_ticker += delta
    if attack_ticker > attack_rate:
      player.take_damage(10)
      attack_ticker = 0.0

  var distance: float = self.speed * delta
  if self.spell_receiver.status == Constants.SPELL_STATUS_TYPE.FROST:
    distance /= 2
  if out_of_range:
    self.enemy_tracker.move_towards_target(distance)


func take_damage(amount: int):
  self.spell_receiver.take_damage(amount)


func _on_body_entered_attack_zone(body):
  if body.name == "Player":
    out_of_range = false


func _on_body_exited_attack_zone(body):
  if body.name == "Player":
    out_of_range = true


func should_follow():
  return out_of_range


func apply_knockback(direction: Vector2):
  spell_receiver.apply_knockback(direction)


func handle_spell(spell):
  enemy_tracker.handle_spell(spell)
  spell_receiver.handle_spell(spell)


func set_status_text(status):
  $"./StatusType".set_status_text(status)


func set_animation(name: String):
  var anim_player: AnimationPlayer = $"./AnimationPlayer"
  if anim_player.current_animation != name:
    anim_player.play(name)
