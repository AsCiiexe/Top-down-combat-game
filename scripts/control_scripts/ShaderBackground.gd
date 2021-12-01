extends Sprite


func _physics_process(delta):
	var CC = DataManager.CurrentCamera
	self.material.set_shader_param("offset", CC.global_position)

#currently this is not used as it isn't really working well
func change_background_shape(CC):
	self.material.set_shader_param("zoom", -CC.zoom)
	self.material.set_shader_param("scroll_speed", CC.zoom.x)
