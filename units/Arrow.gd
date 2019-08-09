extends KinematicBody2D

class_name Arrow

var velocity := 5
var direction = Vector2(0, 0)
var damage = 5

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
  add_to_group("enemies")
  pass
  

func _physics_process(delta):
  var collision = move_and_collide(direction * velocity)
  if collision:
    var collider = collision.get_collider()
    var groups = collider.get_groups()
    if collider.name == "Player":
      collider.take_damage(damage)
      self.queue_free()
    elif !groups.has("enemies"):
      self.queue_free()


func set_direction(dir: Vector2):
  direction = dir
