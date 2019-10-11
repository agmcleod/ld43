extends Area2D

func _ready():
  connect("body_shape_entered", self, "_on_body_shape_entered")


func _on_body_shape_entered(id, body, body_shape, area_shape):
  if body != null && (body.get_groups().has("player") || body.get_groups().has("enemies")):
    body.take_damage(10)
    var body_shape2d: Shape2D = body.shape_owner_get_shape(body_shape, 0)
    var area_shape2d: Shape2D = shape_owner_get_shape(area_shape, 0)
    var body_shape2d_transform = body.shape_owner_get_owner(body_shape).get_global_transform()
    var area_shape2d_transform = shape_owner_get_owner(area_shape).get_global_transform()
    
    var collision_points = area_shape2d.collide_and_get_contacts(area_shape2d_transform, body_shape2d, body_shape2d_transform)
    var w = 0
    var h = 0
    var last_point = null
    for point in collision_points:
      if last_point != null:
        if last_point[0] - point[0] != 0:
          w = last_point[0] - point[0]
        if last_point[1] - point[1] != 0:
          h = last_point[1] - point[1]
      
      last_point = point
    
    if abs(w) > abs(h):
      var y = 30
      if w < 0:
        y *= -1
      body.move_and_collide(Vector2(0, y))
    else:
      var x = 30
      if h > 0:
        x *= -1
      body.move_and_collide(Vector2(x, 0))


func _process(delta):
  #for body in bodies:
  #  body.get_cont
  pass
