extends Node

const Constants = preload("res://Constants.gd")

func _ready():
  # fixes window appearing off screen on hidpi
  OS.center_window()
  pass # Replace with function body.


func get_spell_bindings_ui():
  return $"./UI/SpellBindings"


func get_asset_name_from_status_type(spell_status_type: int) -> String:
  if spell_status_type == Constants.SPELL_STATUS_TYPE.FIRE:
    return "Fire"
  elif spell_status_type == Constants.SPELL_STATUS_TYPE.FROST:
    return "Frost"
  elif spell_status_type == Constants.SPELL_STATUS_TYPE.WET:
    return "Water"

  return "Arcane"

