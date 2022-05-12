class_name UnitDrops

var ingredients_to_drop: Dictionary
var player: Node

func _init(ingredients_to_drop, player: Node):
  self.ingredients_to_drop = ingredients_to_drop
  self.player = player


func trigger_collection():
  for ingredient in ingredients_to_drop:
    player.collect_ingredient(ingredient, ingredients_to_drop[ingredient])
