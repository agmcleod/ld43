# Defines status & health
extends "res://units/SpellReceiver.gd"

class_name Player

export (int) var speed = 200

var velocity = Vector2()
var direction = Vector2(1, 0)

func _ready():
  # Called when the node is added to the scene for the first time.
  # Initialization here
  print(self.get_path())
  pass


func _physics_process(delta):
  if Input.is_action_just_pressed("ui_inventory"):
    var panel = get_node("/root/game/UI/Inventory")
    if !panel.visible:
      panel.visible = true

  velocity.x = 0
  velocity.y = 0
  var moving = false
  var animation_player: AnimationPlayer = _get_animation_player()
  var sprite: Sprite = _get_sprite()
  if status != Constants.SPELL_STATUS_TYPE.FROZEN:
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

  if velocity.x != 0 || velocity.y != 0:
    direction.x = velocity.x
    direction.y = velocity.y

  var resulting_speed = speed
  if status == Constants.SPELL_STATUS_TYPE.SLOWED:
    resulting_speed /= 2

  move_and_slide(velocity.normalized() * resulting_speed)

  pass


func _get_animation_player() -> Node:
  return self.get_node("AnimationPlayer")


func _get_sprite() -> Node:
  return self.get_node("Sprite")


func add_resource(name, type_name):
  assert(false)
