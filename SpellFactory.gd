extends Node

class_name SpellFactory

onready var Constants = $"/root/Constants"
onready var Inventory = $"/root/Inventory"

onready var ingredient_item_list: IngredientItemList = $"../Discover/IngredientItemList"
onready var crafted_spells_vbox = $"ScrollContainer/VBoxContainer"

const SpellRow = preload("res://ui/crafting/SpellRow.tscn")

var discovered_spells: Dictionary = {}
var bound_spells: Dictionary = {}

func cast_spell(spell_index: int):
  if bound_spells.has(spell_index):
    var spell_name: String = bound_spells[spell_index]
    var spell = discovered_spells[spell_name]
    if spell.crafted_count > 0:
      var spells_to_spawn = []
      
  
  # if user has enough of the ingredients:
    # instances to track
    # spells = []
    # check for seed in list
      # spells.push(ball_scene)
    # check for turtle (shield), and bird (wave)
      # spells.push(scene based on type)
    # if red, apply fire status to spells[]
    # if blue, apply frost status to spells[]
    # if both red & blue? dont know

    # check for squirrel (amplify)
      # modify damage accordingly
    # check for frog (split)
      # split spell, and create two adjacent ones on different angle
  pass


func discover(selected_ingredients: Array):
  for ingredient in selected_ingredients:
    if Inventory.inventory_data[ingredient] == 0:
      return
      
  var ingredient_dictionary := {}
  # do another pass to remove ingredients, and take stock
  for ingredient in selected_ingredients:
    Inventory.inventory_data[ingredient] -= 1
    ingredient_dictionary[ingredient] = true
    
  ingredient_item_list.update_resources()
    
  var spell_name = []
    
  if ingredient_dictionary.has(Constants.INGREDIENT_TYPES.FROG):
    spell_name.append("Multi")
  if ingredient_dictionary.has(Constants.INGREDIENT_TYPES.SQUIRREL):
    spell_name.append("Amplified")
    
  if ingredient_dictionary.has(Constants.INGREDIENT_TYPES.RED) && ingredient_dictionary.has(Constants.INGREDIENT_TYPES.BLUE):
    spell_name.append("Water")
  elif ingredient_dictionary.has(Constants.INGREDIENT_TYPES.RED):
    spell_name.append("Fire")
  elif ingredient_dictionary.has(Constants.INGREDIENT_TYPES.BLUE):
    spell_name.append("Frost")
    
  if ingredient_dictionary.has(Constants.INGREDIENT_TYPES.SEED):
    spell_name.append("Ball")
  if ingredient_dictionary.has(Constants.INGREDIENT_TYPES.TURTLE):
    spell_name.append("Shield")
  if ingredient_dictionary.has(Constants.INGREDIENT_TYPES.BIRD):
    spell_name.append("Blast Wave")
    
  spell_name = PoolStringArray(spell_name).join(" ")
  
  if discovered_spells.has(spell_name):
    discovered_spells[spell_name].crafted_count += 1
    for child in crafted_spells_vbox.get_children():
      if child.spell_name == spell_name:
        child.set_count(discovered_spells[spell_name].crafted_count)
        
  else:
    discovered_spells[spell_name] = {
      "spell_name": spell_name,
      "ingredients": ingredient_dictionary.keys(),
      "crafted_count": 1
    }
  
    var row := SpellRow.instance()
    row.set_values(discovered_spells[spell_name])
    row.connect("item_selected", self, "_on_spell_binding_changed")
    crafted_spells_vbox.add_child(row)
  
  pass


func _on_spell_binding_changed(spell_name: String, selected_node_index: int, num: int):
  if discovered_spells.has(spell_name):
    for child in crafted_spells_vbox.get_children():
      var option_button: OptionButton = child.get_option_button()
      if option_button.selected == num && child.get_index() != selected_node_index:
        option_button.select(0)
        
    bound_spells[num] = spell_name