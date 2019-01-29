# Defines status & health
extends "res://units/SpellReceiver.gd"

export (int) var speed = 200

onready var resources_ui = get_tree().get_root().get_node("game/UI/Resources")

var velocity = Vector2()
var direction = Vector2(1, 0)

var fireball_scene = load("res://spells/FireBall.tscn")
var fire_shotgun_scene = load("res://spells/FireShotgun.tscn")
var fire_snipe_scene = load("res://spells/FireSnipe.tscn")
var frost_shotgun_scene = load("res://spells/FrostShotgun.tscn")
var frostball_scene = load("res://spells/FrostBall.tscn")
var frost_snipe_scene = load("res://spells/FrostSnipe.tscn")

func _ready():
  # Called when the node is added to the scene for the first time.
  # Initialization here
  pass

func _physics_process(delta):
  velocity.x = 0
  velocity.y = 0
  if status != Constants.SPELL_STATUS_TYPE.FROZEN:
    if Input.is_action_pressed('right'):
      velocity.x += 1
    if Input.is_action_pressed('left'):
      velocity.x -= 1
    if Input.is_action_pressed('down'):
      velocity.y += 1
    if Input.is_action_pressed('up'):
      velocity.y -= 1

  if velocity.x != 0 || velocity.y != 0:
    direction.x = velocity.x
    direction.y = velocity.y

  var resulting_speed = speed
  if status == Constants.SPELL_STATUS_TYPE.SLOWED:
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
      elif ingredients.cow:
        resources_ui.add_resource(-1, "cow")
        return fire_shotgun_scene.instance()
      elif ingredients.pig:
        resources_ui.add_resource(-1, "pig")
        return fire_snipe_scene.instance()
  elif ingredients.blue_bird:
    resources_ui.add_resource(-1, "blue_bird")
    if ingredients.chicken:
      resources_ui.add_resource(-1, "chicken")
      return frostball_scene.instance()
    elif ingredients.cow:
      resources_ui.add_resource(-1, "cow")
      return frost_shotgun_scene.instance()
    elif ingredients.pig:
      resources_ui.add_resource(-1, "pig")
      return frost_snipe_scene.instance()
    pass
  else:
    pass

func _on_cast_pressed():
  if status == Constants.SPELL_STATUS_TYPE.FROZEN:
    return

  resources_ui.get_node("cast").hide()
  var spell = _get_spell()
  # this shouldnt be needed when all spells are implemented
  if spell:
    spell.set_caster_id(self.get_instance_id())
    spell.position.x = self.position.x
    spell.position.y = self.position.y
    get_tree().get_root().add_child(spell)
    spell.set_direction(direction.x, direction.y)

  resources_ui.reset_active_count()
