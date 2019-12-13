extends Control

const Constants = preload("res://Constants.gd")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# actually is using enum type
func set_status_text(status_type: int):
  var label: Label = $"./Label"
  var text = ""
  if status_type == Constants.SPELL_STATUS_TYPE.FROZEN:
    text = "Frozen"
  elif status_type == Constants.SPELL_STATUS_TYPE.FIRE:
    text = "Fire"
  elif status_type == Constants.SPELL_STATUS_TYPE.FROST:
    text = "Cold"
  label.text = text
