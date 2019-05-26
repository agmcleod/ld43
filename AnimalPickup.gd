extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export var amount = 1
export var type_name = ""

func _ready():
  self.connect("body_entered", self, "_on_body_entered")
  pass

func _process(delta):
  # Called every frame. Delta is time since last frame.
  # Update game logic here.
  pass

func _on_body_entered(body):
  if body.name == "Player":
    self.get_parent().queue_free()
