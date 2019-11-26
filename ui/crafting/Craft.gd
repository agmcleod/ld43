extends Node

class_name SpellFactory

onready var Constants = $"/root/Constants"
onready var InventoryStorage = $"/root/InventoryStorage"

onready var ingredient_item_list: IngredientItemList = $"../Discover/IngredientItemList"
onready var crafted_spells_vbox = $"ScrollContainer/VBoxContainer"

const SpellRow = preload("res://ui/crafting/SpellRow.tscn")

var discovered_spells: Dictionary = {}
var bound_spells: Dictionary = {}

func _create_spell_type(spell_status_type, spell_type_name: String, spell_base: String, direction: Vector2) -> Node:
  var spell_scene = load("res://spells/%s%s.tscn" % [spell_type_name, spell_base]).instance()
  spell_scene.set_status_type(spell_status_type)
  
  if spell_base == "shield":
    spell_scene.set_velocity(0)
  else:
    spell_scene.set_velocity(600)
    spell_scene.set_direction(direction)
    
  return spell_scene
  

func _set_spell_crafted_count(spell_name: String):
  for child in crafted_spells_vbox.get_children():
    if child.spell_name == spell_name:
      child.set_count(discovered_spells[spell_name].crafted_count)
  

func cast_spell(player: Node, spell_index: int, direction: Vector2):
  if bound_spells.has(spell_index):
    var spell_name: String = bound_spells[spell_index]
    var spell = discovered_spells[spell_name]
    if spell.crafted_count > 0:
      spell.crafted_count -= 1
      _set_spell_crafted_count(spell_name)
      var spell_base := "ball"

      # check for turtle (shield), and bird (wave)
      if spell.ingredients.has(Constants.INGREDIENT_TYPES.TURTLE):
        spell_base = "shield"
      if spell.ingredients.has(Constants.INGREDIENT_TYPES.BIRD):
        spell_base = "wave"

      # Since removing seed as a thing, arcane ball no longer exists
      # Need to figure out how to make this work
      
      # Selecting a spell without seed doesnt seem useful, unless i want
      # spell craft fail states, like cooking in BOTW
      var spell_type_name = "Arcane"
      var spell_status_type = Constants.SPELL_STATUS_TYPE.ARCANE
      if spell.ingredients.has(Constants.INGREDIENT_TYPES.RED) && spell.ingredients.has(Constants.INGREDIENT_TYPES.BLUE):
        spell_type_name = "Water"
        assert("Water not supported yet")
      elif spell.ingredients.has(Constants.INGREDIENT_TYPES.RED):
        spell_type_name = "Fire"
        spell_status_type = Constants.SPELL_STATUS_TYPE.FIRE
      elif spell.ingredients.has(Constants.INGREDIENT_TYPES.BLUE):
        spell_type_name = "Frost"
        spell_status_type = Constants.SPELL_STATUS_TYPE.FROST
        
      print("Creating res://spells/%s%s.tscn" % [spell_type_name, spell_base])
      var spell_scene = _create_spell_type(spell_status_type, spell_type_name, spell_base, direction)
      var spells_to_spawn = [spell_scene]
  
      if spell.ingredients.has(Constants.INGREDIENT_TYPES.FROG):
        if spell_base == "shield":
          spell_scene.position.x = -32
          spell_scene.position.y = 32
          for n in range(2):
            var other_spell = _create_spell_type(spell_status_type, spell_type_name, spell_base, direction)
            if n == 0:
              other_spell.position.x = 32
              other_spell.position.y = 32
            else:
              other_spell.position.y = -32

            spells_to_spawn.append(other_spell)
        else:
          spells_to_spawn[0].damage /= 2
          # create the adjacent spells
          var base_angle = direction.angle()
          for n in range(2):
            var other_spell = _create_spell_type(spell_status_type, spell_type_name, spell_base, direction)
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
        if spell_base == "shield":
          player.add_child(spell)
        else:
          spell.position.x = player.position.x
          spell.position.y = player.position.y
          get_tree().get_root().add_child(spell)


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
    
  if ingredient_dictionary.has(Constants.INGREDIENT_TYPES.TURTLE):
    spell_name.append("Shield")
  if ingredient_dictionary.has(Constants.INGREDIENT_TYPES.BIRD):
    spell_name.append("Blast Wave")
  if !ingredient_dictionary.has(Constants.INGREDIENT_TYPES.BIRD) && !ingredient_dictionary.has(Constants.INGREDIENT_TYPES.TURTLE):
    spell_name.append("Ball")
    
  spell_name = PoolStringArray(spell_name).join(" ")
  
  if discovered_spells.has(spell_name):
    discovered_spells[spell_name].crafted_count += 1
    _set_spell_crafted_count(spell_name)
        
  else:
    discovered_spells[spell_name] = {
      "spell_name": spell_name,
      "ingredients": ingredient_dictionary,
      "crafted_count": 1
    }
  
    var row := SpellRow.instance()
    row.set_values(discovered_spells[spell_name])
    row.connect("item_selected", self, "_on_spell_binding_changed")
    row.connect("spell_name_crafted", self, "_on_spell_name_crafted")
    crafted_spells_vbox.add_child(row)
  
  pass


func _on_spell_binding_changed(spell_name: String, selected_node_index: int, num: int):
  if discovered_spells.has(spell_name):
    for child in crafted_spells_vbox.get_children():
      var option_button: OptionButton = child.get_option_button()
      if option_button.selected == num && child.get_index() != selected_node_index:
        option_button.select(0)
        
    bound_spells[num] = spell_name
    

func _on_spell_name_crafted(spell_name: String):
  # if the user is triggering this, they should have a spell
  if discovered_spells.has(spell_name):
    discovered_spells[spell_name].crafted_count += 1
    _set_spell_crafted_count(spell_name)