extends Sprite

class_name BlastAnimation

var frame_time: float = 0.0
export var total_frame_count: int = 0

func _ready():
  pass


func _process(delta: float):
  frame_time += delta
  if frame_time >= 0.1:
    frame_time = 0.0
    texture.frame += 1
    if texture.frame > total_frame_count:
      get_parent().queue_free()