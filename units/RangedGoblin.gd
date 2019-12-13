extends KinematicBody2D

const Arrow = preload("res://units/Arrow.tscn")
var EnemyTracker = preload("res://units/EnemyTracker.gd")
var SpellReceiver = preload("res://units/SpellReceiver.gd")

onready var vision_area: Area2D = $Vision
onready var nav_2d: Navigation2D = $"/root/game/Navigation2D"
onready var health_bar = $"./Sprite/HealthBar"

export (float) var fire_rate = 1.5

var attack_ticker := 0.0
var spell_receiver: SpellReceiver
var enemy_tracker: EnemyTracker
var speed := 120

# Called when the node enters the scene tree for the first time.
func _ready():
  attack_ticker = 0.0
  spell_receiver = SpellReceiver.new(self, 30)
  enemy_tracker = EnemyTracker.new(self, nav_2d, 400, vision_area)


func take_damage(amount: int):
  self.spell_receiver.take_damage(amount)


func _physics_process(delta: float):
  self.spell_receiver._process(delta)
  if self.spell_receiver.is_knockedback() || !spell_receiver.can_move():
    return
  if self.enemy_tracker.tracked_node != null:
    var tracked_node = self.enemy_tracker.tracked_node
    attack_ticker += delta
    if attack_ticker > fire_rate:
      attack_ticker = 0.0
      var arrow_scene = Arrow.instance()
      var direction :Vector2 = (tracked_node.position - self.position).normalized()
      arrow_scene.position = self.position + direction * 5
      arrow_scene.set_direction(direction)
      $"/root/game".add_child(arrow_scene)

  var distance: float = self.speed * delta
  if self.spell_receiver.status == Constants.SPELL_STATUS_TYPE.FROST:
    distance /= 2
  self.enemy_tracker._physics_process(distance)


func handle_spell(spell):
  enemy_tracker.handle_spell(spell)
  spell_receiver.handle_spell(spell)


func apply_knockback(direction: Vector2):
  spell_receiver.apply_knockback(direction)