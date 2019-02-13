extends "res://spells/Spell.gd"

var cold_short_explosion_scene = load("res://spells/ColdShortExplosion.tscn")

func _create_explosion():
  var explosion = cold_short_explosion_scene.instance()
  explosion.position.x = self.position.x
  explosion.position.y = self.position.y
  get_tree().get_root().add_child(explosion)


func _on_body_entered(other):
  if ._on_body_entered(other):
    _create_explosion()


func on_end():
  _create_explosion()
  queue_free()


