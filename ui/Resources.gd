extends Container

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var ingredients = {
  blue_bird = false,
  red_bird = false,
  chicken = false,
  pig = false,
  cow = false
}

var active_count = 0

func get_ingredients():
  return ingredients

func _ready():
  pass

func _mark_ingredient_as_active(name):
  for child in get_children():
    if child.get_name() == name:
      if ingredients[name]:
        child.position.y += 30
        active_count -= 1
        ingredients[name] = false
      elif !ingredients[name] && active_count < 3:
        active_count += 1
        child.position.y -= 30
        ingredients[name] = true

  if active_count <= 1:
    get_node("cast").hide()
  else:
    get_node("cast").show()

func _process(delta):
  if Input.is_action_just_pressed("ingredient_1"):
    self._mark_ingredient_as_active("blue_bird")
  if Input.is_action_just_pressed("ingredient_2"):
    self._mark_ingredient_as_active("red_bird")
  if Input.is_action_just_pressed("ingredient_3"):
    self._mark_ingredient_as_active("chicken")
  if Input.is_action_just_pressed("ingredient_4"):
    self._mark_ingredient_as_active("pig")
  if Input.is_action_just_pressed("ingredient_5"):
    self._mark_ingredient_as_active("cow")
  pass
