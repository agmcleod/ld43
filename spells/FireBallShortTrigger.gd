extends "res://spells/Spell.gd"

var fire_short_explosion_scene = load("res://spells/FireShortExplosion.tscn")

func _create_explosion():
  var explosion = fire_short_explosion_scene.instance()
  explosion.position.x = self.position.x
  explosion.position.y = self.position.y
  get_tree().get_root().add_child(explosion)


func _on_body_entered(other):
  if ._on_body_entered(other):
    _create_explosion()


func _process(delta):
  time_alive += delta
  if duration != 0 && time_alive > duration:
    _create_explosion()
    queue_free()

  if velocity > 0:
    self.position.x += velocity * direction.x * delta
    self.position.y += velocity * direction.y * delta

