extends Node2D

onready var State = $"/root/state"
onready var Game = get_tree().get_current_scene()
onready var default_texture = load("res://images/ui/SpellSlot.png")

func _ready():
  set_images_for_bindings()


func set_images_for_bindings():
  var children = self.get_children()
  for num in range(1, 6):
    var child = children[num - 1]
    var sprite = child.get_node('Sprite')
    if State.bound_spells.has(num):
      var spell = State.bound_spells[num]
      var spell_status_type_name = Game.get_asset_name_from_status_type(spell.spell_status_type)
      sprite.texture = load("res://images/ui/ss%s%s.png" % [spell_status_type_name, spell.spell_type_name])
    else:
      sprite.texture = default_texture

