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

var resource_storage = {
  blue_bird = 2,
  red_bird = 2,
  chicken = 2,
  cow = 2,
  pig = 2
}

var active_count = 0

func _ready():
  get_node("blue_bird/text").text = "%d" % resource_storage.blue_bird
  get_node("red_bird/text").text = "%d" % resource_storage.red_bird
  get_node("chicken/text").text = "%d" % resource_storage.chicken
  get_node("cow/text").text = "%d" % resource_storage.cow
  get_node("pig/text").text = "%d" % resource_storage.pig
  pass

func get_selected_ingredients():
  return ingredients

func get_active_count():
  return active_count

func get_resource_storage():
  resource_storage

func reset_active_count():
  active_count = 0
  for child in get_children():
    if ingredients.has(child.get_name()) && ingredients[child.get_name()]:
      ingredients[child.get_name()] = false
      child.position.y += 30

func add_resource(amount, type_name):
  resource_storage[type_name] += amount
  get_node("%s/text" % type_name).text = "%d" % resource_storage[type_name]


func _toggle_ingredient(name):
  for child in get_children():
    if child.get_name() == name:
      if resource_storage[name] > 0:
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
