const Constants = preload("res://Constants.gd")

class_name DiscoveredSpell

var spell_name: String
var ingredients: Dictionary
var spell_status_type: int
var spell_type_name: String

func _init(spell_name, ingredients, spell_status_type, spell_type_name):
  self.spell_name = spell_name
  self.ingredients = ingredients
  self.spell_status_type = spell_status_type
  self.spell_type_name = spell_type_name


func is_blast() -> bool:
  return (
    ingredients.has(Constants.INGREDIENT_TYPES.SQUIRREL) &&
    ingredients.has(Constants.INGREDIENT_TYPES.TURTLE) &&
    ingredients.has(Constants.INGREDIENT_TYPES.BIRD)
  )


func is_wall() -> bool:
  return is_blast() && ingredients.has(Constants.INGREDIENT_TYPES.FROG)