extends KinematicBody2D

enum states{IDLE, CHASE, SHOOT, FLEE}
var state = states.IDLE

var acceleration = 180 #the higher this is not only the faster it gets to max but the tighter it turns
var max_speed = 300
var movement = Vector2.ZERO
var friction = 0.85
var player = null
var max_health = 16
var health = max_health setget set_health

onready var detection_range = $DetectionRange/CollisionShape2D.shape.radius
#when the player is at more than 70% distance, chase them
#at 70% distance, aim at them
#	if they get closer than 20% distance, flee from them
#	if they get further than 80% distance, chase them
#		this makes it so there's a buffer distance so the enemy doesn't "jitter" when the player is on the edge
#these could also all be hard numbers instead of varying on detection_range
onready var shooting_distance = detection_range * 0.75
onready var rechase_distance = detection_range * 0.88
onready var flee_distance = 200 #the other two may vary but this one is better if it's fixed
var player_distance
var attack_speed = 1
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
			if player_distance <= shooting_distance:
				attack_cd = attack_speed
				state = states.SHOOT
		
		states.SHOOT:
			update()
			movement *= friction
			if attack_cd <= 0:
				var bullet_instance = DataManager.SniperBullet.instance()
				bullet_instance.position = global_position
				bullet_instance.direction = global_position.direction_to(player.global_position)
				DataManager.BulletsNode.call_deferred("add_child", bullet_instance)
				attack_cd = attack_speed
			if player_distance <= flee_distance:
				state = states.FLEE
			if player_distance >= rechase_distance:
				state = states.CHASE
		
		states.FLEE:
			movement += position.direction_to(player.position) * -acceleration
			movement = movement.clamped(max_speed)
			if player_distance >= flee_distance * 1.12:#some 12% margin
				state = states.SHOOT
	
	movement = move_and_slide(movement)

func _draw():
	if state == states.SHOOT:
		draw_line(Vector2(0, 0), player.global_position - global_position, Color.red, 1.25)
		draw_circle(player.global_position - global_position, 2.0, Color.red)


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
