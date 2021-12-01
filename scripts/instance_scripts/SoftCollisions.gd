extends Area2D

export var mass = 1.0
onready var rad = $CollisionShape2D.shape.radius

func colliding():
	var areas = get_overlapping_areas()
	return areas.size() > 0


func get_push_vector(strength = 80.0):
	var areas = get_overlapping_areas()
	var push_vector = Vector2.ZERO
	if areas.size() > 0:
		for area in areas:
			#this is the direction FROM THE OTHER area's position to THIS area
			var vector = area.global_position.direction_to(global_position)
			#then if the other area's mass is higher than this one's, raise the strength of the push vector
			#then the closer the center areas are the stronger the push vector becomes
			vector *= strength * max(0.0, 1.0 - (mass - area.mass)) * ((rad + area.rad) / (global_position.distance_to(area.global_position) + 0.01))#+0.01 to avoid division by 0
			push_vector += vector
		push_vector /= areas.size()
	return push_vector

#only calculates one area overlap even if there's multiple ones, but it can do the job in small amounts of entities
func get_push_vector_simple(strength = 80.0):
	var areas = get_overlapping_areas()
	var push_vector = Vector2.ZERO
	if areas.size() > 0:
		var area = areas[0]
		#this is the direction FROM THE OTHER area's position to THIS area
		push_vector = area.global_position.direction_to(global_position)
		#then if the other area's mass is higher than this one's, raise the strength of the push vector
		#then the closer the center areas are the stronger the push vector becomes
		push_vector *= strength * max(0.0, 1.0 - (mass - area.mass)) * ((rad + area.rad) / (global_position.distance_to(area.global_position) + 0.01))#+0.01 to avoid division by 0
	return push_vector
