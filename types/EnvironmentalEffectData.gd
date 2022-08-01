class_name EnvironmentalEffect

var texture: Texture
var status_type: int
var vframes: int
var hframes: int
var frame_count: int

func _init(texture, status_type, vframes, hframes):
  self.texture = texture
  self.status_type = status_type
  self.vframes = vframes
  self.hframes = hframes
  self.frame_count = hframes * vframes
