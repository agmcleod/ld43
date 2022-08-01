class_name EnvironmentalEffect

var texture: Texture
var status_type: int
var vframes: int
var hframes: int

func _init(texture, status_type, vframes, hframes):
  self.texture = texture
  self.status_type = status_type
  self.vframes = vframes
  self.hframes = hframes
