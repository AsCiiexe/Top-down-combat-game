extends KinematicBody2D

enum states {IDLE, CHASE}
var state = states.IDLE

var acceleration = 175 #the higher this is not only the faster it gets to max but the tighter the turns it takes are
var max_speed = 280
var movement = Vector2.ZERO
var friction = 0.85 #the higher, the more slippery it will be

var max_health = 12
var health = max_health setget set_health

var detection_range = 650
var player_distance = detection_range + 1 #so it always starts idle
var player_global_pos = Vector2.ZERO

var damage = 7



func _physics_process(delta):
	if DataManager.Player != null:
		player_global_pos = DataManager.Player.global_position
		player_distance = global_position.distance_to(player_global_pos)
	
	match state:
		states.IDLE:
			movement *= friction
			if player_distance < detection_range:
				state = states.CHASE
		
		states.CHASE:
			movement += position.direction_to(player_global_pos) * acceleration
			movement = movement.clamped(max_speed)
			
			if player_distance > detection_range:
				state = states.IDLE
	
	movement = move_and_slide(movement)


func set_health(value):
	health = value
	$HealthbarControl.on_health_updated(health)
	
	if health <= 0:
		queue_free()


func _on_DamageArea_area_entered(area):
	if area.get_parent().is_in_group("player"):
		area.get_parent().health -= damage
		var explode = DataManager.Explosion.instance()
		explode.position = global_position
		get_tree().get_root().call_deferred("add_child", explode)
		queue_free()


func _on_DetectionRange_area_entered(area):
	if area.owner.is_in_group("player"):
		state = states.CHASE

func _on_DetectionRange_area_exited(area):
	if area.owner.is_in_group("player"):
		state = states.IDLE
