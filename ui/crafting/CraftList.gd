extends Control

class_name SpellRow

var spell_name := ""

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass

func set_values(spell: Dictionary):
  var label_node: Label = $"HBoxContainer/SpellName"
  label_node.text = spell.spell_name
  
  spell_name = spell.spell_name
  
  self.set_count(spell.crafted_count)


func set_count(count: int):
  var count_node: Label = $"HBoxContainer/Count"
  count_node.text = "x%d" % count
