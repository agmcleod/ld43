extends Area2D

onready var constants = get_tree().get_root().get_node("Constants")
export (int) var status = constants.SPELL_STATUS_TYPE.BURNING
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

func _on_area_entered(other):
  if (self.group_name == "player" && other.group_name == "enemy") || (self.group_name == "enemy" && other.group_name == "player"):
    other.take_damage(damage)
    other.handle_spell(status, status_duration, status_damage)

  if other.group_name != "spell" && dies_on_collision:
    queue_free()


func _ready():
  self.connect('area_entered', self, '_on_area_entered')
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
