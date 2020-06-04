extends Node

class_name Casting

const Constants = preload("res://Constants.gd")
const SpellTargetCircle = preload("res://ui/SpellTargetCircle.tscn")

enum CASTING_STATE {
  IDLE,
  CASTING,
  TARGETING
}

onready var State = $"/root/state"
onready var Game = $"/root/game"
onready var craft: Craft = $"/root/game/UI/Inventory/TabContainer/Craft"


var casting_state = CASTING_STATE.IDLE
var prepared_spell = null
var target_scene = null

func _create_spell_type(spell_status_type, spell_base: String, direction: Vector2) -> Spell:
  # We default to arcane
  var spell_status_type_name = Game.get_asset_name_from_status_type(spell_status_type)
  var spell_scene = load("res://spells/%s%s.tscn" % [spell_status_type_name, spell_base]).instance()
  spell_scene.set_status_type(spell_status_type)

  if spell_base == "shield" || spell_base == "blast":
    spell_scene.set_velocity(0)
  else:
    spell_scene.set_velocity(600)
    spell_scene.set_direction(direction)

  return spell_scene


func _fire_spell(caster, spell, direction: Vector2, target: Vector2):
  var spell_base_types := []
  casting_state = CASTING_STATE.CASTING

  var is_blast_spell = (
    spell.ingredients.has(Constants.INGREDIENT_TYPES.SQUIRREL) &&
    spell.ingredients.has(Constants.INGREDIENT_TYPES.TURTLE) &&
    spell.ingredients.has(Constants.INGREDIENT_TYPES.BIRD)
  )

  # check for turtle (shield), and bird (wave)
  if is_blast_spell:
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

    if is_blast_spell:
      spell_scene.position = target
      spell_scene.is_blast = true

    spells_to_spawn.append(spell_scene)

    # Frog causes spell to split
    if spell.ingredients.has(Constants.INGREDIENT_TYPES.FROG):
      if spell_base == "shield":
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
      elif spell_base == "blast":
        for n in range(2):
          var other_spell: Spell = _create_spell_type(spell.spell_status_type, spell_base, direction)
          other_spell.position = spell_scene.position
          other_spell.is_blast = true
          var angle = -90
          if n == 1:
            angle = 90

          var modified_pos = direction.rotated(deg2rad(angle)) * 64
          other_spell.position.x += modified_pos.x
          other_spell.position.y += modified_pos.y
          other_spell.damage /= 2
          spells_to_spawn.append(other_spell)
      else:
        spells_to_spawn[0].damage /= 2
        # create the adjacent spells
        for n in range(2):
          var other_spell: Spell = _create_spell_type(spell.spell_status_type, spell_base, direction)
          var deg25 := 0.4363323
          if n == 0:
            other_spell.direction = other_spell.direction.rotated(-deg25)
          else:
            other_spell.direction = other_spell.direction.rotated(deg25)

          other_spell.damage /= 2
          spells_to_spawn.append(other_spell)

    if spell.ingredients.has(Constants.INGREDIENT_TYPES.SQUIRREL):
      for spell in spells_to_spawn:
        spell.amplified = true
        spell.damage *= 1.25

  for spell in spells_to_spawn:
    spell.set_owner(caster)
    # For when casting multiple types, duration lasts not as long
    if spells_to_spawn.size() > 1:
      spell.duration /= 2
    if spell.spell_type == Constants.SPELL_TYPE.SHIELD:
      # check if caster as any shields already, if so, remove them
      for child in caster.get_children():
        if child.get_groups().has("shields"):
          child.queue_free()
      spell.add_to_group("shields")
      caster.add_child(spell)
    elif spell.spell_type == Constants.SPELL_TYPE.BLAST:
      get_tree().get_root().add_child(spell)
    else:
      spell.position.x = caster.position.x
      spell.position.y = caster.position.y
      get_tree().get_root().add_child(spell)

  casting_state = CASTING_STATE.IDLE
  prepared_spell = null


func _setup_spell_target(caster: Node):
  target_scene = SpellTargetCircle.instance()
  target_scene.set_owner(caster)
  get_tree().get_root().add_child(target_scene)


func _process(_delta: float):
  if casting_state == CASTING_STATE.TARGETING:
    if Input.is_action_just_pressed('escape'):
      casting_state = CASTING_STATE.IDLE
      target_scene.queue_free()
      craft.discovered_spells[prepared_spell.spell_name].crafted_count += 1
      craft.set_spell_crafted_count(prepared_spell.spell_name)

  pass


func handle_mouse_click(direction: Vector2, target: Vector2):
  if casting_state == CASTING_STATE.TARGETING:
    var owner = target_scene.target_owner
    _fire_spell(owner, prepared_spell, direction, target)
    target_scene.queue_free()


func cast_spell(caster: Node, spell_index: int, direction: Vector2):
  if State.bound_spells.has(spell_index):
    var spell_name: String = State.bound_spells[spell_index].spell_name
    var spell = craft.discovered_spells[spell_name]
    if spell.crafted_count > 0:
      spell.crafted_count -= 1
      craft.set_spell_crafted_count(spell_name)

      var is_blast_spell = (
        spell.ingredients.has(Constants.INGREDIENT_TYPES.SQUIRREL) &&
        spell.ingredients.has(Constants.INGREDIENT_TYPES.TURTLE) &&
        spell.ingredients.has(Constants.INGREDIENT_TYPES.BIRD)
      )

      if is_blast_spell:
        casting_state = CASTING_STATE.TARGETING
        prepared_spell = spell
        # This really only applies for player
        _setup_spell_target(caster)
      else:
        _fire_spell(caster, spell, direction, Vector2.ZERO)

