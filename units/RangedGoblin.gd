extends KinematicBody2D

var Arrow = load("res://units/Arrow.tscn")
const Constants = preload("res://Constants.gd")
const EnemyTracker = preload("res://units/EnemyTracker.gd")
const SpellReceiver = preload("res://units/SpellReceiver.gd")
const UnitDrops = preload("res://units/UnitDrops.gd")
const Drainable = preload("res://units/Drainable.gd")

onready var vision_area: Area2D = $Vision
onready var nav_2d: Navigation2D = get_tree().get_current_scene().get_node("Navigation2D")
onready var health_bar = $"./Sprite/HealthBar"
onready var player: Player = get_tree().get_current_scene().get_node("Player")

export (float) var fire_rate = 1.5

var attack_ticker := 0.0
var spell_receiver: SpellReceiver
var enemy_tracker: EnemyTracker
var speed := 120
var drainable

signal entered_range_of_player
signal extited_range_of_player

func _ready():
  attack_ticker = 0.0
  spell_receiver = SpellReceiver.new(self, 30)
  enemy_tracker = EnemyTracker.new(self, nav_2d, 400, vision_area)
  self.drainable = Drainable.new(self, player, UnitDrops.new({
    Constants.INGREDIENT_TYPES.RED: 5,
    Constants.INGREDIENT_TYPES.BLUE: 5
  }, player))


func take_damage(amount: int):
  self.spell_receiver.take_damage(amount)


func _process(delta):
  self.spell_receiver._process(delta)


func _physics_process(delta: float):
  if (self.spell_receiver.is_knockedback() ||
    !spell_receiver.can_move() ||
    self.drainable.draining):
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
      get_tree().get_current_scene().add_child(arrow_scene)

  var distance: float = self.speed * delta
  if self.spell_receiver.status == Constants.SPELL_STATUS_TYPE.FROST:
    distance /= 2
  if self.enemy_tracker.tracked_node == null:
    self.enemy_tracker.move_towards_target(distance)


func handle_spell(spell):
  enemy_tracker.handle_spell(spell)
  spell_receiver.handle_spell(spell)


func apply_knockback(direction: Vector2):
  spell_receiver.apply_knockback(direction)


func set_status_text(status):
  $"./StatusType".set_status_text(status)


func set_animation(name: String):
  var anim_player: AnimationPlayer = $"./AnimationPlayer"
  if anim_player.current_animation != name:
    anim_player.play(name)


func _input(event):
  if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
    if event.pressed:
      self.drainable.drain()
    else:
      self.drainable.stop()
