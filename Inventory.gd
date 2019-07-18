extends Node

onready var Constants = $"/root/Constants"
onready var INGREDIENT_TYPES = Constants.INGREDIENT_TYPES

onready var inventory_data := {
  INGREDIENT_TYPES.RED: 999, 
  INGREDIENT_TYPES.BLUE: 999,
  INGREDIENT_TYPES.BIRD: 999,
  INGREDIENT_TYPES.FROG: 999,
  INGREDIENT_TYPES.SQUIRREL: 999,
  INGREDIENT_TYPES.TURTLE: 999
}

onready var crafted_spells := []
