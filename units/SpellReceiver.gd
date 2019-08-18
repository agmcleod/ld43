extends KinematicBody2D

class_name SpellReceiver

const FloatingText = preload("res://ui/FloatingText.tscn")

export var health = 0
var status = 0
var effect_timer = 0
var damage_per_tick = 0
var tick_rate = 1.0

func _ready():
  add_to_group("spell_receiver")
  

func take_damage(amount: int):
  health -= amount
  var floating_text = FloatingText.instance()
  floating_text.text = "%d" % round(amount * -1)
  add_child(floating_text)
  if health <= 0:
    queue_free()


# Status Effect is actually a value from SPELL_STATUS_TYPE
func handle_spell(spell: Spell):
  self.take_damage(spell.damage)
  status = spell.status_type
  effect_timer = spell.status_duration
  if spell.status_duration > 0 && spell.status_damage > 0:
    damage_per_tick = spell.status_damage / spell.status_duration
  pass


func _handle_damage_per_tick(delta: float):
  tick_rate -= delta
  if tick_rate <= 0:
    tick_rate = 1.0
    take_damage(damage_per_tick)


func _process(delta: float):
  if effect_timer > 0:
    if damage_per_tick > 0:
      _handle_damage_per_tick(delta)
    effect_timer -= delta
    if effect_timer <= 0:
      status = 0