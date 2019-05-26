extends ItemList

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum INGREDIENT_TYPES {
  RED,
  BLUE,
  SEED,
  BIRD,
  FROG,
  SQUIRREL,
  TURTLE
}

var DATA = [
  {
    "type": INGREDIENT_TYPES.RED,
    "texture": load("res://images/ingredients/redflower.png")
  },
  {
    "type": INGREDIENT_TYPES.BLUE,
    "texture": load("res://images/ingredients/blueflower.png")
  },
  {
    "type": INGREDIENT_TYPES.SEED,
    "texture": load("res://images/ingredients/seed.png")
  },
  {
    "type": INGREDIENT_TYPES.SQUIRREL,
    "texture": load("res://images/ingredients/squirrel.png")
  },
  {
    "type": INGREDIENT_TYPES.BIRD,
    "texture": load("res://images/ingredients/bird.png")
  },
  {
    "type": INGREDIENT_TYPES.FROG,
    "texture": load("res://images/ingredients/frog.png")
  },
  {
    "type": INGREDIENT_TYPES.TURTLE,
    "texture": load("res://images/ingredients/turtle.png")
  }
]

# Called when the node enters the scene tree for the first time.
func _ready():
  for item in DATA:
    self.add_item("", item.texture)

