extends KinematicBody2D

enum states {IDLE, CHASE}
var state = states.IDLE

########## - MOVEMENT - ##########
var base_speed = 290.0
var speed = base_speed
var base_acceleration = 175.0
var acceleration = base_acceleration #the higher, the tighter it turns around
var movement = Vector2.ZERO
var friction = 0.85 #the higher, the more slippery it will be
##############################

########## - DEFENSIVE STATS - ##########
var base_max_health = 120.0
var max_health = base_max_health
var health = max_health setget set_health
##############################

########## - DETECTION - ##########
var detection_range = 650.0
var player_distance = detection_range + 1 #so it always starts idle
var player_global_pos = Vector2.ZERO

var damaged_oor = false #when damaged out of range the enemy will chase the player
var d_oor_distance = detection_range * 0.75 #how far it will chase the player before regular distance checks come back
##############################

########## - OFFENSIVE STATS - ##########
var base_attack_damage = 75.0
var attack_damage = base_attack_damage
var explosion_distance = 50.0 #how far the player has to be for this enemy to detonate
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
	if DataManager.Player != null:
		player_global_pos = DataManager.Player.global_position
		player_distance = global_position.distance_to(player_global_pos)
	match state:
		states.IDLE:
			movement *= friction
			if player_distance < detection_range:
				state = states.CHASE
		
		states.CHASE:
			if not stunned and not rooted:
				movement += position.direction_to(player_global_pos) * acceleration
				movement = movement.clamped(speed)
			else:
				movement *= friction
			
			if player_distance > detection_range and damaged_oor == false:
				state = states.IDLE
			elif player_distance <= explosion_distance:
				explode()
	
	if damaged_oor == true:
		if player_distance < d_oor_distance:
			damaged_oor = false
	
	movement += $SoftCollisions.get_push_vector()
	movement = move_and_slide(movement)


func set_health(value):
	health = value
	$HealthbarControl.on_health_updated(health)
	if health > max_health:
		health = max_health
	
	if health <= 0:
		queue_free()
	
	if player_distance > detection_range:
		damaged_oor = true
		state = states.CHASE


func explode_no_check(): #will explode regardless of if the player is currently invulnerable
	if not stunned and not silenced:
		DataManager.Player.health -= attack_damage
		var explosion = DataManager.Explosion.instance()
		explosion.position = global_position
		get_tree().get_root().add_child(explosion)
		
		queue_free()

func explode(): #will only explode if the player is vulnerable
	if not stunned and not silenced:
		if DataManager.Player.get_node("PlayerHitAnimator").is_playing() == true:
			return
		DataManager.Player.health -= attack_damage
		var explosion = DataManager.Explosion.instance()
		explosion.position = global_position
		get_tree().get_root().add_child(explosion)
		
		queue_free()

