class_name SpellReceiver

const FloatingText = preload("res://ui/FloatingText.tscn")
const HealthBar = preload("res://ui/HealthBar.gd")

const Constants = preload("res://Constants.gd")

# is status type, but can just default to zero
var status = 0
var effect_timer = 0
var damage_per_tick = 0
var damage_tick_rate = 1.0
var knocked_back_vector := Vector2(0, 0)
var knocked_back_tick := 0.0
var health
var max_health
var owner

func _init(owner: KinematicBody2D, health: float):
  self.health = health
  self.max_health = health
  self.owner = owner
  owner.add_to_group("spell_receiver")


func can_move():
  return status != Constants.SPELL_STATUS_TYPE.FROZEN


func take_damage(amount: int):
  health -= amount
  if health > max_health:
    health = max_health
  var floating_text = FloatingText.instance()
  self.owner.add_child(floating_text)
  floating_text.set_text("%d" % round(amount * -1))
  self.owner.health_bar.set_width_from_percent(health / max_health)
  if health <= 0:
    if self.owner.has_method('on_death'):
      self.owner.on_death()
    self.owner.queue_free()



func apply_knockback(vector: Vector2):
  knocked_back_tick = 0.15
  knocked_back_vector = vector


func is_knockedback():
  return knocked_back_tick > 0


func _set_status(status_type):
  status = status_type
  owner.set_status_text(status)


func handle_spell(spell: Spell):
  self.take_damage(spell.damage)
  self.apply_status_effect(spell.status_type, spell.status_duration, spell.status_damage)


func apply_status_effect(status_type: int, status_duration: int, status_damage: int):
  if self.status == Constants.SPELL_STATUS_TYPE.WET && status_type == Constants.SPELL_STATUS_TYPE.FROST:
    _set_status(Constants.SPELL_STATUS_TYPE.FROZEN)
  else:
    _set_status(status_type)

  effect_timer = status_duration
  if status_duration > 0 && status_damage > 0:
    damage_per_tick = status_damage
  else:
    damage_per_tick = 0


func _handle_damage_per_tick(delta: float):
  damage_tick_rate -= delta
  if damage_tick_rate <= 0:
    damage_tick_rate = 1.0
    take_damage(damage_per_tick)


func _process(delta: float):
  if is_knockedback():
    knocked_back_tick -= delta
    owner.move_and_slide(knocked_back_vector * 200)
  elif effect_timer > 0:
    if damage_per_tick > 0:
      _handle_damage_per_tick(delta)
    effect_timer -= delta
    if effect_timer <= 0:
      _set_status(0)
