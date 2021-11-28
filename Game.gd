extends Node

const Constants = preload("res://Constants.gd")

func _ready():
  # fixes window appearing off screen on hidpi
  OS.center_window()

  var pf = $"./PathFinding"
  if pf:
    print(pf.get_path(Vector2(60, 60), Vector2(150, 150)))
  else:
    print("No pf found")
  pass # Replace with function body.


func get_ui():
  return $"./UI"


func get_asset_name_from_status_type(spell_status_type: int) -> String:
  if spell_status_type == Constants.SPELL_STATUS_TYPE.FIRE:
    return "Fire"
  elif spell_status_type == Constants.SPELL_STATUS_TYPE.FROST:
    return "Frost"
  elif spell_status_type == Constants.SPELL_STATUS_TYPE.WET:
    return "Water"

  return "Arcane"

