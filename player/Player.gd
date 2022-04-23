# Defines status & health
# extends "res://units/SpellReceiver.gd"
extends KinematicBody2D

var SpellReceiver = preload("res://units/SpellReceiver.gd")
const Constants = preload("res://Constants.gd")
onready var InventoryStorage = $"/root/InventoryStorage"
const FloatingTextService = preload("res://ui/FloatingTextService.gd")

onready var ingredient_item_list = get_tree().get_current_scene().get_ui().get_ingredient_item_list()

var player_left_walk_image = preload("res://images/player/playerleftwalk.png")
var player_left_image = preload("res://images/player/playerleft.png")
var player_right_walk_image = preload("res://images/player/playerrightwalk.png")
var player_right_image = preload("res://images/player/playerright.png")

class_name Player

onready var health_bar = $"./Sprite/HealthBar"
onready var casting: Casting = $"./Casting"
onready var attack_zone: Area2D = $AttackZone

var speed = 200
var velocity = Vector2()
var spell_receiver: SpellReceiver
var frame_time = 0.0
var floating_text_service: FloatingTextService

var animation_details: Dictionary = {
  'right_move': {
    'name': 'right_move',
    'frames': 12,
    'frame_time': 0.10,
    'texture': player_right_walk_image,
    'vframes': 2,
    'hframes': 8
  },
  'right': {
    'name': 'right',
    'frames': 4,
    'frame_time': 0.15,
    'texture': player_right_image,
    'vframes': 1,
    'hframes': 4
  },
  'left': {
    'name': 'left',
    'frames': 4,
    'frame_time': 0.15,
    'texture': player_left_image,
    'vframes': 1,
    'hframes': 4
  },
  'left_move': {
    'name': 'left_move',
    'frames': 14,
    'frame_time': 0.10,
    'texture': player_left_walk_image,
    'vframes': 2,
    'hframes': 8
  }
}

var current_anim = null

func _ready():
  spell_receiver = SpellReceiver.new(self, 50)
  floating_text_service = FloatingTextService.new()
  add_to_group("player")
  _set_current_anim('right')

  attack_zone.connect("body_entered", self, "_on_body_entered_attack_zone")
  attack_zone.connect("body_exited", self, "_on_body_exited_attack_zone")


func take_damage(amount: int):
  self.spell_receiver.take_damage(amount)
  if spell_receiver.health <= 0:
    get_tree().reload_current_scene()


func _process(delta):
  self.spell_receiver._process(delta)


func _physics_process(delta: float):
  if Input.is_action_just_pressed("ui_inventory"):
    var panel: WindowDialog = get_tree().get_current_scene().get_node('UI/Inventory')
    panel.popup()

    get_tree().paused = true

  if self.spell_receiver.is_knockedback():
    return

  velocity.x = 0
  velocity.y = 0
  var sprite: Sprite = _get_sprite()
  if spell_receiver.can_move():
    if Input.is_action_pressed('right'):
      velocity.x = 1
      if current_anim['name'] != 'right_move':
        _set_current_anim('right_move')
    elif Input.is_action_pressed('left'):
      velocity.x = -1
      if current_anim['name'] != 'left_move':
        _set_current_anim('left_move')

    if Input.is_action_pressed('down'):
      velocity.y = 1
    elif Input.is_action_pressed('up'):
      velocity.y = -1

  var resulting_speed = speed
  if self.spell_receiver.status == Constants.SPELL_STATUS_TYPE.FROST:
    resulting_speed /= 2

  move_and_slide(velocity.normalized() * resulting_speed)

  if velocity.x == 0 && velocity.y == 0:
    if current_anim['name'] == 'right_move':
      _set_current_anim('right')
    elif current_anim['name'] == 'left_move':
      _set_current_anim('left')

  frame_time += delta
  if frame_time >= current_anim.frame_time:
    sprite.frame += 1
    frame_time = 0.0
    if sprite.frame >= current_anim.frames - 1:
      sprite.frame = 0

  self._handle_spell_cast()

  pass


func _set_current_anim(name: String):
  current_anim = animation_details[name]
  var sprite = _get_sprite()
  sprite.frame = 0
  sprite.texture = current_anim.texture
  sprite.vframes = current_anim['vframes']
  sprite.hframes = current_anim['hframes']


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
  elif Input.is_action_just_pressed("cast_five"):
    spell_num = 5

  if spell_num != 0:
    casting.cast_spell(self, spell_num, _get_facing_direction())


func _get_sprite() -> Node:
  return self.get_node("Sprite")


func set_status_text(status):
  $"./StatusType".set_status_text(status)


func collect_ingredient(ingredient_type: int, amount: int):
  InventoryStorage.inventory_data[ingredient_type] += amount
  ingredient_item_list.update_resources()
  floating_text_service.initialize_ft(self, "%d" % amount, ingredient_type)


# This code here works with the assumption that the
# body is the root node of the enemy
func _on_body_entered_attack_zone(body):
  if body.get_groups().has("enemies"):
    body.emit_signal("entered_range_of_player")


func _on_body_exited_attack_zone(body):
  if body.get_groups().has("enemies"):
    body.emit_signal("exited_range_of_player")
