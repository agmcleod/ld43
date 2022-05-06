extends KinematicBody2D

const Constants = preload("res://Constants.gd")
const EnemyTracker = preload("res://units/EnemyTracker.gd")
const SpellReceiver = preload("res://units/SpellReceiver.gd")
const Drainable = preload("res://units/Drainable.gd")
const UnitDrops = preload("res://units/UnitDrops.gd")

onready var vision_area: Area2D = $Vision
onready var nav_2d: Navigation2D = get_tree().get_current_scene().get_node("Navigation2D")
onready var attack_zone: Area2D = $AttackZone
onready var player: Player = get_tree().get_current_scene().get_node("Player")
onready var health_bar = $"./Sprite/HealthBar"
onready var sprite: Sprite = $"./Sprite"

const DEFAULT_AR := 1.5
export (float) var attack_rate := DEFAULT_AR

var out_of_range = true
var last_target: Vector2 = Vector2(0, 0)

var attack_ticker := 0.0
var spell_receiver
var enemy_tracker
var speed := 120
var drainable
var unit_drops: UnitDrops

signal entered_range_of_player
signal exited_range_of_player

func _ready():
  attack_ticker = 0.0
  if attack_rate == null:
    attack_rate = DEFAULT_AR
  self.spell_receiver = SpellReceiver.new(self, 40)
  self.enemy_tracker = EnemyTracker.new(self, nav_2d, 600, vision_area)
  self.drainable = Drainable.new(self, player)
  attack_zone.connect("body_entered", self, "_on_body_entered_attack_zone")
  attack_zone.connect("body_exited", self, "_on_body_exited_attack_zone")
  unit_drops = UnitDrops.new({
    Constants.INGREDIENT_TYPES.RED: 5,
    Constants.INGREDIENT_TYPES.BLUE: 5
  }, player)


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


func on_death():
  unit_drops.trigger_drop()


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
