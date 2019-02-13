# Defines status & health
extends "res://units/SpellReceiver.gd"

export (int) var speed = 200

onready var resources_ui = get_tree().get_root().get_node("game/UI/Resources")

var velocity = Vector2()
var direction = Vector2(1, 0)

var fireball_scene = load("res://spells/FireBall.tscn")
var fire_shotgun_scene = load("res://spells/FireShotgun.tscn")
var fire_snipe_scene = load("res://spells/FireSnipe.tscn")
var fire_ball_trigger_scene = load("res://spells/FireBallTrigger.tscn")
var fire_ball_short_trigger_scene = load("res://spells/FireBallShortTrigger.tscn")
var frost_shotgun_scene = load("res://spells/FrostShotgun.tscn")
var frostball_scene = load("res://spells/FrostBall.tscn")
var cold_ball_trigger_scene = load("res://spells/ColdBallTrigger.tscn")
var cold_ball_short_trigger_scene = load("res://spells/ColdBallShortTrigger.tscn")
var frost_snipe_scene = load("res://spells/FrostSnipe.tscn")
var arcane_ball_scene = load("res://spells/ArcaneBall.tscn")
var arcane_short_ball_scene = load("res://spells/ArcaneShortBall.tscn")
var arcane_self_explosion_scene = load("res://spells/ArcaneSelfExplosion.tscn")
var confused_scene = load("res://spells/ConfusedSpell.tscn")

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
  var to_remove = {}
  var spell
  if ingredients.red_bird:
    to_remove["red_bird"] = -1
    if active_count == 2:
      if ingredients.chicken:
        to_remove["chicken"] = -1
        spell = fireball_scene.instance()
      elif ingredients.cow:
        to_remove["cow"] = -1
        spell = fire_shotgun_scene.instance()
      elif ingredients.pig:
        to_remove["pig"] = -1
        spell = fire_snipe_scene.instance()
    elif active_count == 3:
      if ingredients.chicken && ingredients.pig:
        to_remove["pig"] = -1
        to_remove["chicken"] = -1
        spell = confused_scene.instance()
      elif ingredients.cow && ingredients.pig:
        to_remove["pig"] = -1
        to_remove["cow"] = -1
        spell = fire_ball_trigger_scene.instance()
      elif ingredients.cow && ingredients.chicken:
        to_remove["chicken"] = -1
        to_remove["cow"] = -1
        spell = fire_ball_short_trigger_scene.instance()
  elif ingredients.blue_bird:
    to_remove["blue_bird"] = -1
    if active_count == 2:
      if ingredients.chicken:
        to_remove["chicken"] = -1
        spell = frostball_scene.instance()
      elif ingredients.cow:
        to_remove["cow"] = -1
        spell = frost_shotgun_scene.instance()
      elif ingredients.pig:
        to_remove["pig"] = -1
        spell = frost_snipe_scene.instance()
    elif active_count == 3:
      if ingredients.chicken && ingredients.pig:
        to_remove["chicken"] = -1
        to_remove["pig"] = -1
        spell = confused_scene.instance()
      elif ingredients.cow && ingredients.pig:
        to_remove["pig"] = -1
        to_remove["cow"] = -1
        spell = cold_ball_trigger_scene.instance()
      elif ingredients.cow && ingredients.chicken:
        to_remove["chicken"] = -1
        to_remove["cow"] = -1
        spell = cold_ball_short_trigger_scene.instance()
  elif active_count == 2:
    if ingredients.cow && ingredients.pig:
      to_remove["pig"] = -1
      to_remove["cow"] = -1
      spell = arcane_ball_scene.instance()
    if ingredients.cow && ingredients.chicken:
      to_remove["chicken"] = -1
      to_remove["cow"] = -1
      spell = arcane_short_ball_scene.instance()
    if ingredients.chicken && ingredients.pig:
      to_remove["chicken"] = -1
      to_remove["pig"] = -1
      spell = confused_scene.instance()
  elif active_count == 3:
    to_remove["chicken"] = -1
    to_remove["cow"] = -1
    to_remove["pig"] = -1
    spell = arcane_self_explosion_scene.instance()


  if spell:
    for key in to_remove:
      resources_ui.add_resource(to_remove[key], key)

  return spell


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
