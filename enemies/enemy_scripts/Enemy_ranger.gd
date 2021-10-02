extends KinematicBody2D

enum states{IDLE, CHASE, STAND}
var state = states.IDLE

var acceleration = 100 #the higher this is not only the faster it gets to max but the tighter it turns
var max_speed = 270
var movement = Vector2.ZERO
var friction = 0.85
var player = null
var max_health = 16
var health = max_health setget set_health

var player_distance
var min_distance = 180
var rechase_distance = 300
var attack_speed = 0.85
var attack_cd = 0



func _physics_process(delta):
	attack_cd -= delta
	
	if player != null:
		player_distance = global_position.distance_to(player.global_position)
	
	match state:
		states.IDLE:
			movement *= friction
		
		states.CHASE:
			movement += position.direction_to(player.global_position) * acceleration
			movement = movement.clamped(max_speed)
			
			if player_distance <= min_distance:
				state = states.STAND
			
			#this enemy shoots while moving
			if attack_cd <= 0:
				attack_cd = attack_speed
				var bullet_instance = DataManager.RangerBullet.instance()
				bullet_instance.position = global_position
				bullet_instance.direction = global_position.direction_to(player.global_position)
				DataManager.BulletsNode.call_deferred("add_child", bullet_instance)
				#if the bullet was a rigidbody use this instead vv
				#bullet_instance.apply_impulse(Vector2(), Vector2(0,0).rotated(rotation))
		
		states.STAND:
			movement *= friction
			if attack_cd <= 0:
				attack_cd = attack_speed
				var bullet_instance = DataManager.RangerBullet.instance()
				bullet_instance.position = global_position
				bullet_instance.direction = global_position.direction_to(player.global_position)
				DataManager.BulletsNode.call_deferred("add_child", bullet_instance)
			if player_distance >= rechase_distance:
				state = states.CHASE
	
	movement = move_and_slide(movement)



func set_health(value):
	health = value
	$HealthbarControl.on_health_updated(health)
	
	if health <= 0:
		queue_free()



func _on_DetectionRange_area_entered(area):
	if area.owner.is_in_group("player"):
		player = area.owner
		state = states.CHASE

func _on_DetectionRange_area_exited(area):
	if area.owner.is_in_group("player"):
		player = null
		state = states.IDLE
