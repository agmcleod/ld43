extends Node

class_name Casting

const Constants = preload("res://Constants.gd")

onready var State = $"/root/state"
onready var craft: Craft = $"/root/game/UI/Inventory/TabContainer/Craft"

func _create_spell_type(spell_status_type, spell_type_name: String, spell_base: String, direction: Vector2) -> Spell:
  var spell_scene = load("res://spells/%s%s.tscn" % [spell_type_name, spell_base]).instance()
  spell_scene.set_status_type(spell_status_type)

  if spell_base == "shield":
    spell_scene.set_velocity(0)
  else:
    spell_scene.set_velocity(600)
    spell_scene.set_direction(direction)

  return spell_scene


func cast_spell(player: Node, spell_index: int, direction: Vector2):
  if State.bound_spells.has(spell_index):
    var spell_name: String = State.bound_spells[spell_index]
    var spell = craft.discovered_spells[spell_name]
    if spell.crafted_count > 0:
      spell.crafted_count -= 1
      craft.set_spell_crafted_count(spell_name)
      var spell_base_types := []

      # check for turtle (shield), and bird (wave)
      if spell.ingredients.has(Constants.INGREDIENT_TYPES.BIRD):
        spell_base_types = ["wave"]
      if spell.ingredients.has(Constants.INGREDIENT_TYPES.TURTLE):
        spell_base_types.append("shield")

      if spell_base_types.size() == 0:
        spell_base_types.append("ball")

      # We default to arcane
      var spell_type_name = "Arcane"
      var spell_status_type = Constants.SPELL_STATUS_TYPE.ARCANE
      if spell.ingredients.has(Constants.INGREDIENT_TYPES.RED) && spell.ingredients.has(Constants.INGREDIENT_TYPES.BLUE):
        spell_type_name = "Water"
        spell_status_type = Constants.SPELL_STATUS_TYPE.WET
      elif spell.ingredients.has(Constants.INGREDIENT_TYPES.RED):
        spell_type_name = "Fire"
        spell_status_type = Constants.SPELL_STATUS_TYPE.FIRE
      elif spell.ingredients.has(Constants.INGREDIENT_TYPES.BLUE):
        spell_type_name = "Frost"
        spell_status_type = Constants.SPELL_STATUS_TYPE.FROST

      var spells_to_spawn = []

      for spell_base in spell_base_types:
        var spell_scene: Spell = _create_spell_type(spell_status_type, spell_type_name, spell_base, direction)

        spells_to_spawn.append(spell_scene)

        if spell.ingredients.has(Constants.INGREDIENT_TYPES.FROG):
          if spell_base == "shield":
            spell_scene.position.x = -32
            spell_scene.position.y = 32
            for n in range(2):
              var other_spell: Spell = _create_spell_type(spell_status_type, spell_type_name, spell_base, direction)
              if n == 0:
                other_spell.position.x = 32
                other_spell.position.y = 32
              else:
                other_spell.position.y = -32

              spells_to_spawn.append(other_spell)
          else:
            spells_to_spawn[0].damage /= 2
            # create the adjacent spells
            for n in range(2):
              var other_spell: Spell = _create_spell_type(spell_status_type, spell_type_name, spell_base, direction)
              var deg25 := 0.4363323
              if n == 0:
                other_spell.direction = other_spell.direction.rotated(-deg25)
              else:
                other_spell.direction = other_spell.direction.rotated(deg25)

              other_spell.damage /= 2
              spells_to_spawn.append(other_spell)

        if spell.ingredients.has(Constants.INGREDIENT_TYPES.SQUIRREL):
          for spell in spells_to_spawn:
            spell.damage *= 1.25

      for spell in spells_to_spawn:
        spell.set_owner(player)
        # For when casting multiple types, duration lasts not as long
        if spells_to_spawn.size() > 1:
          spell.duration /= 2
        if spell.spell_type == Constants.SPELL_TYPE.SHIELD:
          # check if player as any shields already, if so, remove them
          for child in player.get_children():
            if child.get_groups().has("shields"):
              child.queue_free()
          spell.add_to_group("shields")
          player.add_child(spell)
        else:
          spell.position.x = player.position.x
          spell.position.y = player.position.y
          get_tree().get_root().add_child(spell)