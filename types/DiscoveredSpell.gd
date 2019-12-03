class_name DiscoveredSpell

var spell_name: String
var ingredients: Dictionary
var crafted_count: int

func _init(spell_name, ingredients, crafted_count):
  self.spell_name = spell_name
  self.ingredients = ingredients
  self.crafted_count = crafted_count

