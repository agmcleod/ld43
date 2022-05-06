class_name Drainable

const Player = preload("res://player/Player.gd")
const AuraShader = preload("res://shaders/aura.tres")

var owner: Node
var in_range_of_player := false
var mouse_entered := false
var player

func _init(owner: Node, player: Player):
  self.owner = owner
  self.player = player

  owner.connect("mouse_entered", self, "_on_mouse_entered")
  owner.connect("mouse_exited", self, "_on_mouse_exited")

  owner.connect("entered_range_of_player", self, "_on_entered_range_of_player")
  owner.connect("exited_range_of_player", self, "_on_exited_range_of_player")


func _on_mouse_entered():
  mouse_entered = true
  handle_in_range_focusin()


func _on_mouse_exited():
  handle_in_range_focusout()
  mouse_entered = false


func _on_entered_range_of_player():
  in_range_of_player = true
  handle_in_range_focusin()


func _on_exited_range_of_player():
  handle_in_range_focusout()
  in_range_of_player = false


func handle_in_range_focusin():
  if in_range_of_player && mouse_entered:
    owner.get_node("Sprite").set_material(AuraShader)
    Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func handle_in_range_focusout():
  if in_range_of_player && mouse_entered:
    owner.get_node("Sprite").set_material(null)
    Input.set_default_cursor_shape(Input.CURSOR_ARROW)
