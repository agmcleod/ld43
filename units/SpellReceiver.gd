extends KinematicBody2D

export var health = 0
var status = 0
var effect_timer = 0
var damage_per_tick = 0
var tick_rate = 1.0

func take_damage(amount):
  health -= amount
  if health <= 0:
    queue_free()


func handle_spell(status_effect, status_duration, status_damage):
  status = status_effect
  effect_timer = status_duration
  damage_per_tick = status_damage / status_duration
  pass


func _handle_damage_per_tick(delta):
  tick_rate -= delta
  if tick_rate <= 0:
    tick_rate = 1.0
    take_damage(damage_per_tick)


func _process(delta):
  if effect_timer > 0:
    if damage_per_tick > 0:
      _handle_damage_per_tick(delta)
    effect_timer -= delta
    if effect_timer <= 0:
      status = 0