extends Sprite

func _unhandled_input(event):
	if Input.is_action_just_released("melee_attack"):
		position = get_parent().get_node("Entities/Player").dash_target
