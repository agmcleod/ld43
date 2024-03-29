extends Control

class_name SpellRow

const DiscoveredSpell = preload("res://types/DiscoveredSpell.gd")

signal item_selected

var spell_name := ""

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
  var option_button: OptionButton = $"HBoxContainer/OptionButton"
  option_button.add_item("Unbound")
  for n in range(5):
    option_button.add_item(str(n + 1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass

func set_values(spell: DiscoveredSpell):
  var label_node: Label = $"HBoxContainer/SpellName"
  label_node.text = spell.spell_name

  spell_name = spell.spell_name


func _on_OptionButton_item_selected(id: int):
  emit_signal("item_selected", spell_name, self.get_index(), id)


func get_option_button() -> Node:
  return $"HBoxContainer/OptionButton"
