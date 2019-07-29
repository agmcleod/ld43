extends KinematicBody2D

class_name Arrow

var velocity := 350
var direction = Vector2(0, 0)
var damage = 5

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
  pass
  

func _physics_process(delta):
  var collision = move_and_collide(direction * velocity * delta)
  if collision:
    self.queue_free()
    var collider = collision.get_collider()
    if collider.name == "Player":
      collider.take_damage(damage)
      
    
  

func set_target(position: Vector2):
  direction = (position - self.position).normalized()
