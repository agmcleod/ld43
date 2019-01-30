extends "res://spells/Spell.gd"

var arcane_explosion_scene = load("res://spells/ArcaneExplosion.tscn")

func _on_body_entered(other):
  if ._on_body_entered(other):
    var explosion = arcane_explosion_scene.instance()
    explosion.position.x = self.position.x
    explosion.position.y = self.position.y
    get_tree().get_root().add_child(explosion)
