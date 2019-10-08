extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var bodies := []

# Called when the node enters the scene tree for the first time.
func _ready():
  connect("body_shape_entered", self, "_on_body_shape_entered")
  connect("body_shape_exited", self, "_on_body_shape_exited")


func _on_body_shape_entered(id, body: KinematicBody2D, body_shape, area_shape):
  if body != null:
    bodies.append(body)
    print(id, " ", body_shape, " ", area_shape, " ", body.get_shape(body_shape))


func _on_body_shape_exited(id, exited_body):
  var index = -1
  var i = 0
  for body in bodies:
    if body.get_instance_id() == exited_body.get_instance_id():
      index = i
    i += 1
    
  if index > -1:
    bodies.remove(index)


func _process(delta):
  #for body in bodies:
  #  body.get_cont
  pass
