# Defines status & health
extends "res://units/SpellReceiver.gd"

export (int) var speed = 200

onready var constants = get_node("/root/Constants")

var velocity = Vector2()

var resources = {
  blue_bird = 0,
  red_bird = 0,
  chicken = 0,
  cow = 0,
  pig = 0
}

func _ready():
  health = 500
  # Called when the node is added to the scene for the first time.
  # Initialization here
  pass

func _physics_process(delta):
  velocity.x = 0
  velocity.y = 0
  if status != constants.SPELL_STATUS_TYPE.FROZEN:
    if Input.is_action_pressed('right'):
      velocity.x += 1
    if Input.is_action_pressed('left'):
      velocity.x -= 1
    if Input.is_action_pressed('down'):
      velocity.y += 1
    if Input.is_action_pressed('up'):
      velocity.y -= 1

  var resulting_speed = speed
  if status == constants.SPELL_STATUS_TYPE.SLOWED:
    resulting_speed /= 2

  move_and_slide(velocity.normalized() * resulting_speed)

  pass

func _on_cast_pressed():
  if status == constants.SPELL_STATUS_TYPE.FROZEN:
    return
  print("cast")


func add_resource(amount, type_name):
  resources[type_name] += amount
  get_tree().get_root().get_node("root/UI/Resources/%s/text" % type_name).text = "%d" % resources[type_name]
