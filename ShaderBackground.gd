extends Sprite


func _physics_process(delta):
	self.material.set_shader_param("offset", DataManager.Player.global_position)

func _unhandled_input(event):
	var CC = DataManager.CurrentCamera
	if event.is_action_pressed("zoom_out"):
		if CC.zoom >= Vector2(0.5, 0.5):
			CC.zoom -= Vector2(0.15, 0.15)
		change_background_shape(CC)
	
	if event.is_action_pressed("zoom_in"):
		if CC.zoom <= Vector2(2, 2):
			CC.zoom += Vector2(0.15, 0.15)
		change_background_shape(CC)
	
	if event.is_action_pressed("reset_zoom"):
		CC.zoom = Vector2(1.0, 1.0)
		change_background_shape(CC)
	

func change_background_shape(CC):
	self.material.set_shader_param("zoom", -CC.zoom)
	self.material.set_shader_param("scroll_speed", CC.zoom.x)
