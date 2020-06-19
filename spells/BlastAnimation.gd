extends Sprite

class_name BlastAnimation

var frame_time: float = 0.0
export var total_frame_count: int = 0

func _ready():
  pass


func _process(delta: float):
  frame_time += delta
  if frame_time >= 0.017:
    frame_time = 0.0
    frame += 1
    if frame >= total_frame_count - 1:
      print('should free')
      get_parent().queue_free()
