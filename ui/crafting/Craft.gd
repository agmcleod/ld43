extends Node

class_name Craft

const DiscoveredSpell = preload("res://types/DiscoveredSpell.gd")
const Constants = preload("res://Constants.gd")
const BoundSpell = preload("res://types/BoundSpell.gd")

onready var InventoryStorage = $"/root/InventoryStorage"
onready var State = $"/root/state"

onready var ingredient_item_list: IngredientItemList = $"../Discover/IngredientItemList"
onready var crafted_spells_vbox = $"ScrollContainer/VBoxContainer"

const spell_row_scene = preload("res://ui/crafting/SpellRow.tscn")

var discovered_spells: Dictionary = {}

func set_spell_crafted_count(spell_name: String):
  for child in crafted_spells_vbox.get_children():
    if child.spell_name == spell_name:
      child.set_count(discovered_spells[spell_name].crafted_count)


func discover(selected_ingredients: Array):
  for ingredient in selected_ingredients:
    if InventoryStorage.inventory_data[ingredient] == 0:
      return

  var ingredient_dictionary := {}
  # do another pass to remove ingredients, and take stock
  for ingredient in selected_ingredients:
    InventoryStorage.inventory_data[ingredient] -= 1
    ingredient_dictionary[ingredient] = true

  ingredient_item_list.update_resources()

  var spell_name = []
  var spell_type_name = []
  var spell_status_type = Constants.SPELL_STATUS_TYPE.ARCANE

  var is_blast_spell = (
    ingredient_dictionary.has(Constants.INGREDIENT_TYPES.SQUIRREL) &&
    ingredient_dictionary.has(Constants.INGREDIENT_TYPES.TURTLE) &&
    ingredient_dictionary.has(Constants.INGREDIENT_TYPES.BIRD)
  )

  var is_wall_spell = (
    is_blast_spell && ingredient_dictionary.has(Constants.INGREDIENT_TYPES.FROG)
  )

  if is_wall_spell:
    is_blast_spell = false

  # Cant have multi wall or blast spells
  if !is_wall_spell && !is_blast_spell && ingredient_dictionary.has(Constants.INGREDIENT_TYPES.FROG):
    spell_name.append("Multi")
  if !is_blast_spell && !is_wall_spell && ingredient_dictionary.has(Constants.INGREDIENT_TYPES.SQUIRREL):
    spell_name.append("Amplified")

  if ingredient_dictionary.has(Constants.INGREDIENT_TYPES.RED) && ingredient_dictionary.has(Constants.INGREDIENT_TYPES.BLUE):
    spell_name.append("Water")
    spell_status_type = Constants.SPELL_STATUS_TYPE.WET
  elif ingredient_dictionary.has(Constants.INGREDIENT_TYPES.RED):
    spell_name.append("Fire")
    spell_status_type = Constants.SPELL_STATUS_TYPE.FIRE
  elif ingredient_dictionary.has(Constants.INGREDIENT_TYPES.BLUE):
    spell_name.append("Frost")
    spell_status_type = Constants.SPELL_STATUS_TYPE.FROST
  else:
    spell_name.append("Arcane")

  if is_wall_spell:
    spell_type_name.append("Wall")
  elif is_blast_spell:
    spell_type_name.append("Blast")
  else:
    if ingredient_dictionary.has(Constants.INGREDIENT_TYPES.TURTLE):
      spell_type_name.append("Shield")
    # Wave and shield can be together
    if ingredient_dictionary.has(Constants.INGREDIENT_TYPES.BIRD):
      spell_type_name.append("Wave")

  if spell_type_name.size() == 0:
    spell_type_name.append("Ball")

  # flattent the type name, add to spell name
  spell_type_name = PoolStringArray(spell_type_name).join(" ")
  spell_name.append(spell_type_name)
  # then flatten the full spell name
  spell_name = PoolStringArray(spell_name).join(" ")

  if discovered_spells.has(spell_name):
    discovered_spells[spell_name].crafted_count += 1
    set_spell_crafted_count(spell_name)
  else:
    discovered_spells[spell_name] = DiscoveredSpell.new(
      spell_name, ingredient_dictionary, 1, spell_status_type, spell_type_name
    )

    var row: SpellRow = spell_row_scene.instance()
    row.set_values(discovered_spells[spell_name])
    row.connect("item_selected", self, "_on_spell_binding_changed")
    row.connect("spell_name_crafted", self, "_on_spell_name_crafted")
    crafted_spells_vbox.add_child(row)


func _on_spell_binding_changed(spell_name: String, selected_node_index: int, num: int):
  if discovered_spells.has(spell_name):
    for child in crafted_spells_vbox.get_children():
      var option_button: OptionButton = child.get_option_button()
      if option_button.selected == num && child.get_index() != selected_node_index:
        option_button.select(0)

    for num in State.bound_spells:
      # Unbind the current spell
      if State.bound_spells[num].spell_name == spell_name:
        State.bound_spells.erase(num)

    var spell = discovered_spells[spell_name]
    State.bound_spells[num] = BoundSpell.new(spell.spell_name, spell.spell_status_type, spell.spell_type_name)

    var spell_bindings = get_tree().get_current_scene().get_ui().get_spell_bindings()
    spell_bindings.set_images_for_bindings(State.bound_spells)



func _on_spell_name_crafted(spell_name: String):
  # if the user is triggering this, they should have a spell
  if discovered_spells.has(spell_name):
    discovered_spells[spell_name].crafted_count += 1
    set_spell_crafted_count(spell_name)
