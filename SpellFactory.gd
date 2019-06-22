extends Node

class_name SpellFactory

onready var Constants = $"/root/Constants"
onready var Inventory = $"/root/Inventory"

var discovered_spells: Dictionary = {}

func cast_spell(selected_ingredients: Array):
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
    Inventory.invetory_data[ingredient] -= 1
    ingredient_dictionary[ingredient] = true
    
  var spell_name := []
    
  if ingredient_dictionary[Constants.INGREDIENT_TYPES.FROG]:
    spell_name.append("Multi")
  if ingredient_dictionary[Constants.INGREDIENT_TYPES.SQUIRREL]:
    spell_name.append("Amplified")
    
  if ingredient_dictionary[Constants.INGREDIENT_TYPES.RED] && ingredient_dictionary[Constants.INGREDIENT_TYPES.BLUE]:
    spell_name.append("Water")
  elif ingredient_dictionary[Constants.INGREDIENT_TYPES.RED]:
    spell_name.append("Fire")
  elif ingredient_dictionary[Constants.INGREDIENT_TYPES.BLUE]:
    spell_name.append("Frost")
    
  if ingredient_dictionary[Constants.INGREDIENT_TYPES.SEED]:
    spell_name.append("Ball")
  if ingredient_dictionary[Constants.INGREDIENT_TYPES.TURTLE]:
    spell_name.append("Shield")
  if ingredient_dictionary[Constants.INGREDIENT_TYPES.BIRD]:
    spell_name.append("Blast Wave")
    
  var crafted_count = 1
  
  if discovered_spells.has(spell_name):
    crafted_count = discovered_spells[spell_name].crafted_count + 1
    
  discovered_spells[spell_name] = {
    spell_name: spell_name,
    ingredients: ingredient_dictionary.keys(),
    crafted_count: crafted_count
  }
  
  pass
