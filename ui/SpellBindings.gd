extends Node2D

onready var Game = get_tree().get_current_scene()
onready var default_texture = load("res://images/ui/SpellSlot.png")

func set_images_for_bindings(bound_spells: Dictionary):
  var children = self.get_children()
  for num in range(1, 6):
    var child = children[num - 1]
    var sprite = child.get_node('Sprite')
    if bound_spells.has(num):
      var spell = bound_spells[num]
      var spell_status_type_name = Game.get_asset_name_from_status_type(spell.spell_status_type)
      sprite.texture = load("res://images/ui/ss%s%s.png" % [spell_status_type_name, spell.spell_type_name])
    else:
      sprite.texture = default_texture

