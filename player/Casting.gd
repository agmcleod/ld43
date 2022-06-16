extends Node

class_name Casting

const Constants = preload("res://Constants.gd")
const SpellTargetCircle = preload("res://ui/SpellTargetCircle.tscn")
const WallSpellTarget = preload("res://ui/WallSpellTarget.tscn")
const DiscoveredSpell = preload("res://types/DiscoveredSpell.gd")
const WallSpellCreatorScene = preload("res://spells/WallSpellCreator.tscn")

enum CASTING_STATE {
  IDLE,
  CASTING,
  TARGETING,
  WALL_TARGET,
}

onready var ui = get_tree().get_current_scene().get_ui()
onready var State = $"/root/state"
onready var Game = get_tree().get_current_scene()

var casting_state = CASTING_STATE.IDLE
var prepared_spell = null
var spell_target_node = null
var wall_target_node = null

func _create_spell_type(spell_status_type, spell_base: String, direction: Vector2) -> Spell:
  # We default to arcane
  var spell_status_type_name = Game.get_asset_name_from_status_type(spell_status_type)
  # print("Creating spell: %s%s.tscn" % [spell_status_type_name, spell_base])
  var spell_scene = load("res://spells/%s%s.tscn" % [spell_status_type_name, spell_base]).instance()
  spell_scene.set_status_type(spell_status_type)

  if spell_base == "shield" || spell_base == "blast" || spell_base == "wall":
    spell_scene.set_velocity(0)
  else:
    spell_scene.set_velocity(600)
    spell_scene.set_direction(direction)

  return spell_scene


func _fire_spell(caster: Node2D, spell: DiscoveredSpell, direction: Vector2, target: Vector2):
  var spell_base_types := []
  casting_state = CASTING_STATE.CASTING

  var is_blast_spell = spell.is_blast()
  var is_wall_spell = spell.is_wall()

  if is_wall_spell:
    is_blast_spell = false

  if is_wall_spell:
    spell_base_types.append("wall")
  elif is_blast_spell:
    spell_base_types.append("blast")
  else:
    if spell.ingredients.has(Constants.INGREDIENT_TYPES.BIRD):
      spell_base_types.append("wave")
    if spell.ingredients.has(Constants.INGREDIENT_TYPES.TURTLE):
      spell_base_types.append("shield")

    if spell_base_types.size() == 0:
      spell_base_types.append("ball")

  var spells_to_spawn = []

  for spell_base in spell_base_types:
    var spell_scene: Spell = _create_spell_type(spell.spell_status_type, spell_base, direction)

    if is_blast_spell || is_wall_spell:
      spell_scene.position = target
      spell_scene.is_environmental = true

    spells_to_spawn.append(spell_scene)

    # Frog causes spell to split
    if spell.ingredients.has(Constants.INGREDIENT_TYPES.FROG):
      if spell_base == "shield":
        _split_shield_spell(spells_to_spawn, spell_scene, spell, spell_base, direction)
      elif spell_base == "blast":
        assert("Blast was split!")
      elif spell_base != "wall":
        _split_other_spell_type(spells_to_spawn, spell, spell_base, direction)

    if spell.ingredients.has(Constants.INGREDIENT_TYPES.SQUIRREL) && !is_blast_spell && !is_wall_spell:
      for spell in spells_to_spawn:
        spell.amplified = true
        spell.damage *= 1.25
        if spell_base == "shield":
          spell.duration *= 1.5

  var has_removed_old_shields = false

  for spell in spells_to_spawn:
    # For when casting multiple types, duration lasts not as long
    if spells_to_spawn.size() > 1:
      spell.duration /= 2
    if spell.spell_type == Constants.SPELL_TYPE.SHIELD:
      # check if caster as any shields already, if so, remove them
      if !has_removed_old_shields:
        for child in caster.get_children():
          if child.get_groups().has("shields"):
            child.finish_spell()
        has_removed_old_shields = true
      spell.add_to_group("shields")
      caster.add_child(spell)
    elif spell.spell_type == Constants.SPELL_TYPE.BLAST:
      get_tree().get_root().add_child(spell)
    elif spell.spell_type == Constants.SPELL_TYPE.WALL:
      var wall_spell_creator = WallSpellCreatorScene.instance()
      get_tree().get_root().add_child(wall_spell_creator)
      wall_spell_creator.build_spells(spell, wall_target_node)
    else:
      spell.position.x = caster.position.x
      spell.position.y = caster.position.y
      get_tree().get_root().add_child(spell)

    spell.set_owner(caster)

  casting_state = CASTING_STATE.IDLE
  prepared_spell = null


func _split_shield_spell(spells_to_spawn: Array, spell_scene: Spell, spell: DiscoveredSpell, spell_base: String, direction: Vector2):
  # place bottom left of caster
  spell_scene.position.x = -32
  spell_scene.position.y = 32
  for n in range(2):
    var other_spell: Spell = _create_spell_type(spell.spell_status_type, spell_base, direction)
    if n == 0:
      # place bottom right of character
      other_spell.position.x = 32
      other_spell.position.y = 32
    else:
      # place above cahracter
      other_spell.position.y = -32

    spells_to_spawn.append(other_spell)


func _split_other_spell_type(spells_to_spawn: Array, spell: DiscoveredSpell, spell_base: String, direction: Vector2):
  spells_to_spawn[0].damage /= 2
  # create the adjacent spells
  for n in range(2):
    var other_spell: Spell = _create_spell_type(spell.spell_status_type, spell_base, direction)
    var deg25 := 0.4363323
    if n == 0:
      other_spell.direction = other_spell.direction.rotated(-deg25)
    else:
      other_spell.direction = other_spell.direction.rotated(deg25)

    other_spell.damage *= 0.8
    spells_to_spawn.append(other_spell)


func _setup_spell_target(caster: Node):
  spell_target_node = SpellTargetCircle.instance()
  spell_target_node.set_owner(caster)
  get_tree().get_root().add_child(spell_target_node)


func _setup_wall_target(caster: Node, click_target: Vector2):
  wall_target_node = WallSpellTarget.instance()
  wall_target_node.set_owner(caster)
  wall_target_node.click_target.x = click_target.x
  wall_target_node.click_target.y = click_target.y
  get_tree().get_root().add_child(wall_target_node)


func _process(_delta: float):
  if casting_state == CASTING_STATE.TARGETING || casting_state == CASTING_STATE.WALL_TARGET:
    if Input.is_action_just_pressed('escape'):
      casting_state = CASTING_STATE.IDLE
      if spell_target_node != null:
        spell_target_node.queue_free()
      elif wall_target_node != null:
        wall_target_node.queue_free()

  pass


func handle_mouse_click(direction: Vector2, target: Vector2):
  if casting_state == CASTING_STATE.TARGETING:
    var owner = spell_target_node.target_owner
    # create the wall target now
    if prepared_spell.is_wall():
      _setup_wall_target(owner, target)
      spell_target_node.queue_free()
      casting_state = CASTING_STATE.WALL_TARGET
    else:
      _fire_spell(owner, prepared_spell, direction, target)
      spell_target_node.queue_free()
  elif casting_state == CASTING_STATE.WALL_TARGET:
    var owner = wall_target_node.target_owner
    _fire_spell(owner, prepared_spell, direction, wall_target_node.click_target)
    wall_target_node.queue_free()
    casting_state = CASTING_STATE.IDLE


func cast_spell(caster: Node, spell_index: int, direction: Vector2):
  if State.bound_spells.has(spell_index):
    var spell_name: String = State.bound_spells[spell_index].spell_name
    var discover_button = ui.get_discover_button()
    var spell = discover_button.discovered_spells[spell_name]
    # If an ingredient is spent, don't cast
    for ingredient in spell.ingredients:
      if InventoryStorage.inventory_data[ingredient] == 0:
        caster.floating_text_service.initialize_ft(caster, "Missing ingredients", null)
        return

    # Go through again to remove
    for ingredient in spell.ingredients:
      InventoryStorage.inventory_data[ingredient] -= 1

    ui.get_ingredient_item_list().update_resources()

    if spell.is_blast() || spell.is_wall():
      casting_state = CASTING_STATE.TARGETING
      prepared_spell = spell
      # This really only applies for player
      _setup_spell_target(caster)
    else:
      _fire_spell(caster, spell, direction, Vector2.ZERO)

