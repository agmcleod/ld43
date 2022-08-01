extends Sprite

const Constants = preload("res://Constants.gd")
const EnvironmentalEffectData = preload("res://types/EnvironmentalEffectData.gd")

var textures: Dictionary = {
  "fire": EnvironmentalEffectData.new(
    preload("res://images/environmental_effects/fire.png"),
    Constants.SPELL_STATUS_TYPE.FIRE,
    1,
    2
  ),
  "frozen": EnvironmentalEffectData.new(
    preload("res://images/environmental_effects/frozen.png"),
    Constants.SPELL_STATUS_TYPE.FROZEN,
    1,
    1
  ),
  "wet": EnvironmentalEffectData.new(
    preload("res://images/environmental_effects/wet.png"),
    Constants.SPELL_STATUS_TYPE.WET,
    1,
    1
  )
}

# these are set by the casting spell when instance is created
var spell_status_type = Constants.SPELL_STATUS_TYPE.ARCANE
var status_duration = 0
var status_damage = 0

var time_alive := 30.0
var entered_bodies: Dictionary = {}
var frame_time = 0
const ANIMATION_FRAME_RATE = 0.2
var current_frames_count = 1

func _ready():
  var area = _get_area2d()
  area.connect("area_entered", self, "_on_area_entered")
  area.connect("body_entered", self, "_on_body_entered")
  area.connect("body_exited", self, "_on_body_exited")


func _process(delta: float):
  time_alive -= delta
  if time_alive <= 0:
    queue_free()
  else:
    for body in entered_bodies.values():
      if body.get_groups().has("spell_receiver"):
        var spell_receiver = body.spell_receiver
        if spell_receiver.status == 0:
          spell_receiver.apply_status_effect(spell_status_type, status_duration, status_damage)

    frame_time += delta
    if frame_time >= ANIMATION_FRAME_RATE:
      if self.frame + 1 >= current_frames_count:
        set_frame(0)
      else:
        set_frame(self.frame + 1)
      frame_time = 0.0


func _get_area2d() -> Area2D:
  return $"./Area2D" as Area2D


func _on_area_entered(area: Area2D):
  if area.get_groups().has("spell"):
    # incoming spell is frost type, and current is wet
    if area.status_type == Constants.SPELL_STATUS_TYPE.FROST && spell_status_type == Constants.SPELL_STATUS_TYPE.WET:
      spell_status_type = Constants.SPELL_STATUS_TYPE.FROST
      set_sprite_texture("frozen")

      # set tracked entities to frozen
      for body in entered_bodies.values():
        if body.get_groups().has("spell_receiver"):
          var spell_receiver = body.spell_receiver
          if spell_receiver.status == Constants.SPELL_STATUS_TYPE.NONE:
            spell_receiver.apply_status_effect(spell_status_type, status_duration, status_damage)


func _on_body_entered(body: KinematicBody2D):
  if body != null:
    entered_bodies[body.get_instance_id()] = body


func _on_body_exited(body: KinematicBody2D):
  if body != null:
    entered_bodies.erase(body.get_instance_id())


func set_sprite_texture(texture_name: String) -> bool:
  if !textures.has(texture_name):
    return false

  var texture_data = textures[texture_name]
  current_frames_count = texture_data.frame_count
  set_texture(texture_data.texture)
  set_vframes(texture_data.vframes)
  set_hframes(texture_data.hframes)
  spell_status_type = textures[texture_name].status_type

  return true