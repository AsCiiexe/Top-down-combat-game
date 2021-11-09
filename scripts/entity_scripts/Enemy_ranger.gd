extends KinematicBody2D

enum states{IDLE, CHASE, STAND}
var state = states.IDLE

########## - MOVEMENT - ##########
var base_speed = 230
var speed = base_speed
var base_acceleration = 100
var acceleration = base_acceleration #the higher, the tighter it turns around
var movement = Vector2.ZERO
var friction = 0.85 #the higher, the more slippery it will be
##############################

########## - DEFENSIVE STATS - ##########
var base_max_health = 16
var max_health = base_max_health
var health = max_health setget set_health
##############################

########## - DETECTION - ##########
var detection_range = 700
var min_distance = 180
var rechase_distance = 300

var player_distance = detection_range + 1 #so it always starts idle
var player_global_pos = Vector2.ZERO

var damaged_oor = false #when damaged out of range the enemy will chase the player
var d_oor_distance = detection_range * 0.75 #how far it will chase the player before regular distance checks come back
##############################

########## - OFFENSIVE STATS - ##########
var attack_speed = 0.85
var attack_cd = 0
var attack_damage = 1
##############################

########## - MODIFIERS - ##########
var mod_dict = {}
#hard mods
var stunned = false #this entity can't do anything while stunned
var silenced = false #this entity can't cast spells while silenced
var disarmed = false #this entity can't do basic attacks while disarmed
var rooted = false #this entity can't move or use movement spells while rooted

var cooldown_reduction = 1.0
var att_speed_mod = 1.0
##############################


func _physics_process(delta):
	attack_cd -= delta
	
	if DataManager.Player != null:
		player_global_pos = DataManager.Player.global_position
		player_distance = global_position.distance_to(player_global_pos)
	
	match state:
		states.IDLE:
			movement *= friction
			if player_distance <= detection_range:
				state = states.CHASE
		
		states.CHASE:
			if not stunned and not rooted:
				movement += position.direction_to(player_global_pos) * acceleration
				movement = movement.clamped(speed)
			else:
				movement *= friction
			
			if player_distance <= min_distance:
				state = states.STAND
			elif player_distance > detection_range and damaged_oor == false:
				state = states.IDLE
			
			#this enemy shoots while moving
			if attack_cd <= 0 and not stunned and not disarmed:
				attack_cd = attack_speed * att_speed_mod
				var bullet_instance = DataManager.RangerBullet.instance()
				bullet_instance.position = global_position
				bullet_instance.direction = global_position.direction_to(player_global_pos)
				DataManager.BulletsNode.call_deferred("add_child", bullet_instance)
				#if the bullet was a rigidbody use this instead vv
				#bullet_instance.apply_impulse(Vector2(), Vector2(0,0).rotated(rotation))
		
		states.STAND:
			movement *= friction
			if attack_cd <= 0 and not stunned and not disarmed:
				attack_cd = attack_speed * att_speed_mod
				var bullet_instance = DataManager.RangerBullet.instance()
				bullet_instance.position = global_position
				bullet_instance.direction = global_position.direction_to(player_global_pos)
				bullet_instance.damage += attack_damage
				DataManager.BulletsNode.call_deferred("add_child", bullet_instance)
			if player_distance >= rechase_distance:
				state = states.CHASE
	
	if damaged_oor == true:
		if player_distance < d_oor_distance:
			damaged_oor = false
	
	movement = move_and_slide(movement)



func set_health(value):
	health = value
	$HealthbarControl.on_health_updated(health)
	
	if health <= 0:
		queue_free()
	
	if player_distance > detection_range:
		damaged_oor = true
		state = states.CHASE
