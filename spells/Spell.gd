extends Area2D

# Based on Constants.gd. Setting a 1 here manually
export (int) var status = 1
# How long the status effect should last
export (int) var status_duration = 0
export (int) var status_damage = 0
export (int) var damage = 0
export (int) var velocity = 0
var direction = Vector2(0, 0)
# How long the spell itself lasts
export (float) var duration = 0
var time_alive = 0
export (bool) var dies_on_collision = false

var caster_id = -1

func _on_body_entered(other):
  if self.caster_id != other.get_instance_id():
    if (other.is_in_group("player") || other.is_in_group("enemy")):
      other.take_damage(damage)
      other.handle_spell(status, status_duration, status_damage)
      if dies_on_collision:
        queue_free()
    elif !other.is_in_group("spell") && dies_on_collision:
      queue_free()


func _ready():
  self.connect('body_entered', self, '_on_body_entered')
  self.add_to_group("spell")

func _process(delta):
  time_alive += delta
  if duration != 0 && time_alive > duration:
    queue_free()

  if velocity > 0:
    self.position.x += velocity * direction.x * delta
    self.position.y += velocity * direction.y * delta

func set_direction(x, y):
  direction.x = x
  direction.y = y

func set_caster_id(id):
  caster_id = id