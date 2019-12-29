extends Sprite

const Constants = preload("res://Constants.gd")
const EnvironmentalEffectData = preload("res://types/EnvironmentalEffectData.gd")

var textures: Dictionary = {
  "fire": EnvironmentalEffectData.new(
    preload("res://images/environmental_effects/fire.png"),
    Constants.SPELL_STATUS_TYPE.FIRE
  ),
  "frozen": EnvironmentalEffectData.new(
    preload("res://images/environmental_effects/frozen.png"),
    Constants.SPELL_STATUS_TYPE.FROZEN
  ),
  "wet": EnvironmentalEffectData.new(
    preload("res://images/environmental_effects/wet.png"),
    Constants.SPELL_STATUS_TYPE.WET
  )
}

var spell_type = Constants.SPELL_STATUS_TYPE.ARCANE
var time_alive := 30.0

func _ready():
  var area = _get_area2d()
  self.connect("body_entered", area, "_on_body_entered")


func _process(delta: float):
  time_alive -= delta
  if time_alive <= 0:
    queue_free()


func _get_area2d() -> Area2D:
  return $"./Area2D" as Area2D


func _on_body_entered(body: KinematicBody2D):
  print("body entered ", body)


func set_sprite_texture(texture_name: String) -> bool:
  if !textures.has(texture_name):
    return false

  set_texture(textures[texture_name].texture)
  spell_type = textures[texture_name].status_type

  return true