# Defines status & health
extends "res://units/SpellReceiver.gd"

export (int) var speed = 200

onready var constants = get_tree().get_root().get_node("Constants")
onready var resources_ui = get_tree().get_root().get_node("game/UI/Resources")

var velocity = Vector2()
var direction = Vector2(1, 0)

var fireball_scene = load("res://spells/FireBall.tscn")

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

  if velocity.x != 0 && velocity.y != 0:
    direction.x = velocity.x
    direction.y = velocity.y

  var resulting_speed = speed
  if status == constants.SPELL_STATUS_TYPE.SLOWED:
    resulting_speed /= 2

  move_and_slide(velocity.normalized() * resulting_speed)

  pass

func _get_spell():
  var ingredients = resources_ui.get_selected_ingredients()
  var active_count = resources_ui.get_active_count()
  if ingredients.red_bird:
    resources_ui.add_resource(-1, "red_bird")
    if active_count == 2:
      if ingredients.chicken:
        resources_ui.add_resource(-1, "chicken")
        return fireball_scene.instance()
  elif ingredients.blue_bird:
    pass
  else:
    pass

func _on_cast_pressed():
  if status == constants.SPELL_STATUS_TYPE.FROZEN:
    return

  var spell = _get_spell()
  # this shouldnt be needed when all spells are implemented
  if spell:
    get_tree().get_root().add_child(spell)
    spell.set_direction(direction.x, direction.y)

  resources_ui.reset_active_count()
