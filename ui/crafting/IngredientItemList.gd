extends ItemList

onready var Constants = $"/root/Constants"
onready var INGREDIENT_TYPES = Constants.INGREDIENT_TYPES
onready var Inventory = $"/root/Inventory"

class_name IngredientItemList

onready var DATA = [
  {
    "type": INGREDIENT_TYPES.RED,
    "texture": load("res://images/ingredients/redflower.png"),
    "label": str(Inventory.inventory_data[INGREDIENT_TYPES.RED])
  },
  {
    "type": INGREDIENT_TYPES.BLUE,
    "texture": load("res://images/ingredients/blueflower.png"),
    "label": str(Inventory.inventory_data[INGREDIENT_TYPES.BLUE])
  },
  {
    "type": INGREDIENT_TYPES.SQUIRREL,
    "texture": load("res://images/ingredients/squirrel.png"),
    "label": str(Inventory.inventory_data[INGREDIENT_TYPES.SQUIRREL])
  },
  {
    "type": INGREDIENT_TYPES.BIRD,
    "texture": load("res://images/ingredients/bird.png"),
    "label": str(Inventory.inventory_data[INGREDIENT_TYPES.BIRD])
  },
  {
    "type": INGREDIENT_TYPES.FROG,
    "texture": load("res://images/ingredients/frog.png"),
    "label": str(Inventory.inventory_data[INGREDIENT_TYPES.FROG])
  },
  {
    "type": INGREDIENT_TYPES.TURTLE,
    "texture": load("res://images/ingredients/turtle.png"),
    "label": str(Inventory.inventory_data[INGREDIENT_TYPES.TURTLE])
  }
]

# Called when the node enters the scene tree for the first time.
func _ready():
  for item in DATA:
    self.add_item(item.label, item.texture)


func update_resources():
  var i := 0
  for item in DATA:
    self.set_item_text(i, str(Inventory.inventory_data[item.type]))
    i += 1
    
