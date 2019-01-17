extends KinematicBody2D

export (int) var speed = 200
var velocity = Vector2()

var resources = {
  blue_bird = 0,
  red_bird = 0,
  chicken = 0,
  cow = 0,
  pig = 0
}

func _ready():
  # Called when the node is added to the scene for the first time.
  # Initialization here
  pass

func _physics_process(delta):
  velocity.x = 0
  velocity.y = 0
  if Input.is_action_pressed('right'):
    velocity.x += 1
  if Input.is_action_pressed('left'):
    velocity.x -= 1
  if Input.is_action_pressed('down'):
    velocity.y += 1
  if Input.is_action_pressed('up'):
    velocity.y -= 1

  move_and_slide(velocity.normalized() * speed)

  pass

func _on_cast_pressed():
  print("cast")


func add_resource(amount, type_name):
  resources[type_name] += amount
  get_tree().get_root().get_node("root/UI/Resources/%s/text" % type_name).text = "%d" % resources[type_name]
