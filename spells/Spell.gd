extends Area2D

class_name Spell

const Constants = preload("res://Constants.gd")
const EnvironmentalEffectScene = preload("res://spells/environmental_effects/EnvironmentalEffect.tscn")

export (Constants.SPELL_TYPE) var spell_type
var status_type = Constants.SPELL_STATUS_TYPE.ARCANE
export (int) var damage;
export (int) var status_duration
export (int) var status_damage
export (float) var duration

var direction = Vector2()
var default_direction = Vector2(1, 0)
var velocity = 0
var time_alive: float = 0
var spell_owner :Node = null


func _ready():
  self.connect("body_entered", self, "_on_body_entered")
  if spell_type != Constants.SPELL_TYPE.SHIELD:
    add_to_group("projectiles")
  add_to_group("spell")


func _process(delta):
  time_alive += delta
  if velocity != 0:
    self.position += direction.normalized() * velocity * delta

  if time_alive >= duration:
    queue_free()


func set_owner(node: Node):
  spell_owner = node


func set_direction(dir: Vector2):
  direction = dir
  rotate(default_direction.angle_to(dir))


func set_status_type(new_status_type):
  status_type = new_status_type


func set_velocity(vel: int):
  velocity = vel


func _on_body_entered(body: Node2D):
  if body != spell_owner:
    var groups = body.get_groups()
    if groups.has("spell_receiver"):
      # non shield logic
      if spell_type != Constants.SPELL_TYPE.SHIELD:
        queue_free()
        if status_type == Constants.SPELL_STATUS_TYPE.FIRE || status_type == Constants.SPELL_STATUS_TYPE.WET:
          var env_effect = EnvironmentalEffectScene.instance()
          if status_type == Constants.SPELL_STATUS_TYPE.FIRE:
            env_effect.set_sprite_texture("fire")
          elif status_type == Constants.SPELL_STATUS_TYPE.WET:
            env_effect.set_sprite_texture("wet")

          env_effect.status_duration = self.status_duration
          env_effect.status_damage = self.status_damage

          env_effect.position = self.position
          env_effect.spell_status_type = status_type
          $"/root/game/GroundLevel".add_child(env_effect)
      body.handle_spell(self)
      if spell_type == Constants.SPELL_TYPE.WAVE:
        body.apply_knockback(direction)
    elif groups.has("enemies") && groups.has("projectiles") && spell_type == Constants.SPELL_TYPE.SHIELD:
      # destroy the it if its a projectile hitting a shield
      body.queue_free()
