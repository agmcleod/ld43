extends Control

const Constants = preload("res://Constants.gd")
const SpellRowScene = preload("res://ui/crafting/SpellRow.tscn")
const IngredientItemList = preload("res://ui/crafting/IngredientItemList.gd")
onready var discover_button = $Button
onready var item_list: IngredientItemList = $IngredientItemList
onready var spell_bindings = $"../Bindings"

var discovered_spells: Dictionary = {}

func get_spell_details_for_ingredients(selected_ingredients: Array):
  for ingredient in selected_ingredients:
    if InventoryStorage.inventory_data[ingredient] == 0:
      return

  var ingredient_dictionary := {}
  # Map ingredients to a dictionary
  for ingredient in selected_ingredients:
    ingredient_dictionary[ingredient] = true

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
  return DiscoveredSpell.new(
    PoolStringArray(spell_name).join(" "), ingredient_dictionary, spell_status_type, spell_type_name
  )


func discover(selected_ingredients: Array):
  var details = get_spell_details_for_ingredients(selected_ingredients)
  var spell_name = details.spell_name
  if discovered_spells.has(spell_name):
    # Shouldn't rediscover existing spells
    return
  else:
    discovered_spells[details.spell_name] = details

    var row: SpellRow = SpellRowScene.instance()
    row.set_values(discovered_spells[spell_name])
    spell_bindings.add_spell_binding(row)


func get_selected_items():
  var items = item_list.get_selected_items()
  var ingredient_types = []
  for item in items:
    ingredient_types.append(item_list.current_ingredients[item])

  return ingredient_types


func _on_ItemList_multi_selected(item, selected):
  var selected_spell = get_spell_details_for_ingredients(get_selected_items())
  discover_button.disabled = item_list.get_selected_items().size() == 0 || discovered_spells.has(selected_spell.spell_name)

# discover the ingredients and create a new crafted spell
func _on_Button_pressed():
  var ingredient_types = get_selected_items()
  discover(ingredient_types)
  item_list.unselect_all()
