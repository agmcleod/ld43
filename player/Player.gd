# Defines status & health
# extends "res://units/SpellReceiver.gd"
extends KinematicBody2D

var SpellReceiver = preload("res://units/SpellReceiver.gd")
const Constants = preload("res://Constants.gd")

class_name Player

onready var health_bar = $"./Sprite/HealthBar"
onready var casting: Casting = $"./Casting"

var speed = 200
var velocity = Vector2()
var spell_receiver: SpellReceiver

func _ready():
  spell_receiver = SpellReceiver.new(self, 50)
  add_to_group("player")


func take_damage(amount: int):
  self.spell_receiver.take_damage(amount)
  if spell_receiver.health <= 0:
    get_tree().reload_current_scene()


func _process(delta):
  self.spell_receiver._process(delta)


func _physics_process(_delta: float):
  if Input.is_action_just_pressed("ui_inventory"):
    var panel: WindowDialog = get_node("/root/game/UI/Inventory")
    panel.popup()

    get_tree().paused = true

  if self.spell_receiver.is_knockedback():
    return

  velocity.x = 0
  velocity.y = 0
  var moving = false
  var animation_player: AnimationPlayer = _get_animation_player()
  var sprite: Sprite = _get_sprite()
  if spell_receiver.can_move():
    if Input.is_action_pressed('right'):
      velocity.x = 1
      sprite.set_flip_h(false)
      if animation_player.current_animation != "Right":
        animation_player.play("Right")
      moving = true
    elif Input.is_action_pressed('left'):
      velocity.x = -1
      moving = true
      if animation_player.current_animation != "Right":
        animation_player.play("Right")
        sprite.set_flip_h(true)
    elif Input.is_action_pressed('down'):
      moving = true
      velocity.y = 1
      if animation_player.current_animation != "Down":
        animation_player.play("Down")
        sprite.set_flip_h(false)
    elif Input.is_action_pressed('up'):
      velocity.y = -1
      if animation_player.current_animation != "Up":
        animation_player.play("Up")
        sprite.set_flip_h(false)
      moving = true


  if moving && !animation_player.is_playing():
    animation_player.play()
  elif !moving && animation_player.is_playing():
    animation_player.stop()

  var resulting_speed = speed
  if self.spell_receiver.status == Constants.SPELL_STATUS_TYPE.FROST:
    resulting_speed /= 2

  move_and_slide(velocity.normalized() * resulting_speed)

  self._handle_spell_cast()

  pass


func _input(event):
  if event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.pressed:
    self.casting.handle_mouse_click(_get_facing_direction(), get_global_mouse_position())


func _get_facing_direction() -> Vector2:
  return (get_global_mouse_position() - position).normalized()


func _handle_spell_cast():
  var spell_num := 0
  if Input.is_action_just_pressed("cast_one"):
    spell_num = 1
  elif Input.is_action_just_pressed("cast_two"):
    spell_num = 2
  elif Input.is_action_just_pressed("cast_three"):
    spell_num = 3
  elif Input.is_action_just_pressed("cast_four"):
    spell_num = 4
  elif Input.is_action_just_pressed("cast_fice"):
    spell_num = 5

  if spell_num != 0:
    casting.cast_spell(self, spell_num, _get_facing_direction())


func _get_animation_player() -> Node:
  return self.get_node("AnimationPlayer")


func _get_sprite() -> Node:
  return self.get_node("Sprite")


func add_resource(name, type_name):
  assert(false)


func set_status_text(status):
  $"./StatusType".set_status_text(status)
