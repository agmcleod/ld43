class_name DiscoveredSpell

var spell_name: String
var ingredients: Dictionary
var crafted_count: int
var spell_status_type: int
var spell_type_name: String

func _init(spell_name, ingredients, crafted_count, spell_status_type, spell_type_name):
  self.spell_name = spell_name
  self.ingredients = ingredients
  self.crafted_count = crafted_count
  self.spell_status_type = spell_status_type
  self.spell_type_name = spell_type_name

