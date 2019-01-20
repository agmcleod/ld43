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

func get_selected_ingredients():
  return ingredients

func get_active_count():
  return active_count

func reset_active_count():
  active_count = 0
  for name in ["blue_bird", "red_bird", "chicken", "pig", "cow"]:
    _mark_ingredient_as_inactive(name)

func _mark_ingredient_as_inactive(name):
  for child in get_children():
    if child.get_name() == name:
      ingredients[name] = false
      child.position.y += 30

func _ready():
  pass

func _toggle_ingredient(name):
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
    self._toggle_ingredient("blue_bird")
  if Input.is_action_just_pressed("ingredient_2"):
    self._toggle_ingredient("red_bird")
  if Input.is_action_just_pressed("ingredient_3"):
    self._toggle_ingredient("chicken")
  if Input.is_action_just_pressed("ingredient_4"):
    self._toggle_ingredient("pig")
  if Input.is_action_just_pressed("ingredient_5"):
    self._toggle_ingredient("cow")
  pass
