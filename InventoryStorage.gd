extends Node

const Constants = preload("res://Constants.gd")
onready var INGREDIENT_TYPES = Constants.INGREDIENT_TYPES

onready var inventory_data := {
  INGREDIENT_TYPES.RED: 10,
  INGREDIENT_TYPES.BLUE: 10,
  INGREDIENT_TYPES.BIRD: 0,
  INGREDIENT_TYPES.FROG: 0,
  INGREDIENT_TYPES.SQUIRREL: 0,
  INGREDIENT_TYPES.TURTLE: 0
}
