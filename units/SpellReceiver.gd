extends KinematicBody2D

class_name SpellReceiver

onready var Constants = $"/root/Constants"
onready var health_bar = $"./Sprite/HealthBar"
const FloatingText = preload("res://ui/FloatingText.tscn")

export var health: float = 0.0
var max_health
var status = 0
var effect_timer = 0
var damage_per_tick = 0
var damage_tick_rate = 1.0
var knocked_back_vector := Vector2(0, 0)
var knocked_back_tick := 0.0

func _ready():
  max_health = health
  print(get_name(), " ", health, " ", max_health)
  add_to_group("spell_receiver")
  

func take_damage(amount: int):
  health -= amount
  var floating_text = FloatingText.instance()
  floating_text.text = "%d" % round(amount * -1)
  add_child(floating_text)
  if health_bar != null:
    print(health, " / ", max_health)
    health_bar.set_width_from_percent(health / max_health)
  if health <= 0:
    queue_free()


func apply_knockback(vector: Vector2):
  knocked_back_tick = 0.15
  knocked_back_vector = vector


func is_knockedback():
  return knocked_back_tick > 0
  

# Status Effect is actually a value from SPELL_STATUS_TYPE
func handle_spell(spell: Spell):
  self.take_damage(spell.damage)
  status = spell.status_type
  effect_timer = spell.status_duration
  if spell.status_duration > 0 && spell.status_damage > 0:
    damage_per_tick = spell.status_damage / spell.status_duration
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
    move_and_slide(knocked_back_vector * 200)
  elif effect_timer > 0:
    if damage_per_tick > 0:
      _handle_damage_per_tick(delta)
    effect_timer -= delta
    if effect_timer <= 0:
      status = 0