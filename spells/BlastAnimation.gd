extends Sprite

class_name BlastAnimation

var frame_time: float = 0.0
export var total_frame_count: int = 0
export var frame_speed: float = 0.0
# when true, should be cleaned up another way
export var stay_alive: bool = false

func _ready():
  pass


func _process(delta: float):
  frame_time += delta
  if frame_time >= frame_speed:
    frame_time = 0.0
    # Incrments animation frame.
    # Only do so when animation is not complete, or blast needs to be freed
    if frame < total_frame_count - 1 || !stay_alive:
      frame += 1
    if frame >= total_frame_count - 1 && !stay_alive:
      get_parent().finish_spell()
