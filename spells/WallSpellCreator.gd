extends Node2D

const Constants = preload("res://Constants.gd")
const Spell = preload("res://spells/Spell.gd")

class_name WallSpellCreator

var tracked_spells = []
var extra_nodes = []
var created_nav_mesh_ids = []

func build_spells(base_scene: Spell, wall_target: Sprite):
  tracked_spells.append(base_scene)
  # adjust the base scene to be 1/2 width in, so it starts inset from the wall target
  base_scene.position += Vector2(cos(wall_target.rotation), sin(wall_target.rotation)) * 32
  get_tree().get_root().add_child(base_scene)
  var distance = 0
  for _n in range(3):
    distance += 64
    var other = base_scene.duplicate()
    other.spell_owner = base_scene.spell_owner
    other.is_environmental = true
    other.position += Vector2(cos(wall_target.rotation), sin(wall_target.rotation)) * distance
    tracked_spells.append(other)
    get_tree().get_root().add_child(other)

  # When the first spell in the array finishes, we assume all of them finish.
  # A signal per each one would be nice,
  # but we lose the context as to which animation player it was for
  tracked_spells[0].get_animation_player().connect('animation_finished', self, '_on_animation_finished')
  # Also assuming when one leaves, the rest do
  tracked_spells[0].connect('tree_exited', self, '_on_spells_removed')

  if base_scene.status_type == Constants.SPELL_STATUS_TYPE.FROST:
    # Create collision rect
    var w = wall_target.texture.get_width()
    var h = wall_target.texture.get_height()

    var body = StaticBody2D.new()
    var shape = CollisionShape2D.new()

    var polygon = ConvexPolygonShape2D.new()
    var points = PoolVector2Array([
      Vector2(-w / 2, - h / 2).rotated(wall_target.rotation),
      Vector2(w / 2, - h / 2).rotated(wall_target.rotation),
      Vector2(w / 2, h / 2).rotated(wall_target.rotation),
      Vector2(- w / 2, h / 2).rotated(wall_target.rotation),
    ])
    polygon.set_points(points)
    shape.set_shape(polygon)

    body.add_child(shape)
    body.position = wall_target.position
    body.add_to_group("blocker")
    get_tree().get_root().add_child(body)
    extra_nodes.append(body)

    pass


func _on_animation_finished(anim_finished):
  if anim_finished == 'default':
    for spell in tracked_spells:
      if spell != null:
        var player: AnimationPlayer = spell.get_animation_player()
        player.play('Loop')


func _on_spells_removed():
  for n in extra_nodes:
    n.queue_free()

  self.queue_free()
