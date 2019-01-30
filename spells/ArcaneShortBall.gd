extends "res://spells/Spell.gd"

var arcane_short_explosion_scene = load("res://spells/ArcaneShortExplosion.tscn")

func _create_explosion():
  var explosion = arcane_short_explosion_scene.instance()
  explosion.position.x = self.position.x
  explosion.position.y = self.position.y
  get_tree().get_root().add_child(explosion)


func _on_body_entered(other):
  if ._on_body_entered(other):
    _create_explosion()


func _process(delta):
  ._process(delta)
  if duration != 0 && time_alive > duration:
    _create_explosion()