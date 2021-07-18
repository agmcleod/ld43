extends Node2D

const Constants = preload("res://Constants.gd")
const Spell = preload("res://spells/Spell.gd")

class_name WallSpellCreator

var tracked_spells = []

func build_spells(base_scene: Spell, wall_target: Sprite):
  var distance = 0
  tracked_spells.append(base_scene)
  get_tree().get_root().add_child(base_scene)
  for _n in range(3):
    distance += 64
    var other = base_scene.duplicate()
    other.spell_owner = base_scene.spell_owner
    other.is_environmental = true
    other.position += Vector2(cos(wall_target.rotation), sin(wall_target.rotation)) * distance
    tracked_spells.append(other)
    get_tree().get_root().add_child(other)

  # When one finishes, we assume all of them finish.
  # A signal per each one would be nice,
  # but we lose the context as to which animation player it was for
  tracked_spells[0].get_animation_player().connect('animation_finished', self, '_on_animation_finished')
  # Also assuming when one leaves, the rest do
  tracked_spells[0].connect('tree_exited', self, '_on_spells_removed')

  if base_scene.spell_status_type == Constants.SPELL_STATUS_TYPE.FROST:
    # Create collision rect
    var w = wall_target.texture.get_width()
    var h = wall_target.texture.get_height()

    # StatitcBody2D.

    pass


func _on_animation_finished(anim_finished):
  if anim_finished == 'default':
    for spell in tracked_spells:
      if spell != null:
        var player: AnimationPlayer = spell.get_animation_player()
        player.play('Loop')


func _on_spells_removed():
  self.queue_free()
