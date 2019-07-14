extends Area2D

onready var Constants = $"/root/Constants"

export (Constants.SPELL_TYPE) var spell_type
export (int) var damage;

onready var status_type = Constants.SPELL_STATUS_TYPE.ARCANE

var direction = Vector2()
var default_direction = Vector2(1, 0)
var velocity = 0
var duration: float = 100
var time_alive: float = 0

func _process(delta):
  time_alive += delta
  if velocity != 0:
    self.position.x += direction.x * velocity * delta
    self.position.y += direction.y * velocity * delta

  if time_alive >= duration:
    queue_free()


func set_direction(dir: Vector2):
  direction = dir
  rotate(default_direction.angle_to(dir))


func set_status_type(new_status_type):
  status_type = new_status_type


func set_velocity(vel: int):
  velocity = vel

