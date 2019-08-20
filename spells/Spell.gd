extends Area2D

class_name Spell

onready var Constants = $"/root/Constants"

export (Constants.SPELL_TYPE) var spell_type
export (Constants.SPELL_STATUS_TYPE) var status_type = Constants.SPELL_STATUS_TYPE.ARCANE
export (int) var damage;
export (int) var status_duration = 10
export (int) var status_damage = 0
export (float) var duration = 0.5

var direction = Vector2()
var default_direction = Vector2(1, 0)
var velocity = 0
var time_alive: float = 0
var spell_owner :Node = null


func _ready():
  self.connect("body_entered", self, "_on_body_entered")


func _process(delta):
  time_alive += delta
  if velocity != 0:
    self.position += direction.normalized() * velocity * delta

  if time_alive >= duration:
    queue_free()


func set_owner(node: Node):
  spell_owner = node


func set_direction(dir: Vector2):
  direction = dir
  rotate(default_direction.angle_to(dir))


func set_status_type(new_status_type):
  status_type = new_status_type


func set_velocity(vel: int):
  velocity = vel


func _on_body_entered(body: PhysicsBody2D):
  if body != spell_owner && body.get_groups().has("spell_receiver"):
    queue_free()
    body.handle_spell(self)
    print(position, " ", body.position, " ", (position - body.position).normalized())
