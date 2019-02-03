extends "res://spells/Spell.gd"

var center = Vector2()
var start_position = Vector2()

func _ready():
  center.x = position.x
  center.y = position.y
  position.x += 80
  start_position.x = position.x
  start_position.y = position.y


func _process(delta):
  ._process(delta)
  var angle = deg2rad(lerp(0, 360, time_alive / duration))
  rotate_around_point_highperf(angle, center)


func rotate_around_point_highperf(radians, around):
  var offset_x = around.x
  var offset_y = around.y
  var adjusted_x = (start_position.x - offset_x)
  var adjusted_y = (start_position.y - offset_y)
  var cos_rad = cos(radians)
  var sin_rad = sin(radians)
  var qx = offset_x + cos_rad * adjusted_x + sin_rad * adjusted_y
  var qy = offset_y + sin_rad * adjusted_x + cos_rad * adjusted_y

  position.x = qx
  position.y = qy

  # print("%d around %s, resulting %s" % [radians, around, position])