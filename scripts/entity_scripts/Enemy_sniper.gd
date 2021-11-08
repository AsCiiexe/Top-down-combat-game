extends KinematicBody2D

enum states{IDLE, CHASE, SHOOT, FLEE}
var state = states.IDLE

########## - MOVEMENT - ##########
var acceleration = 50 #the higher this is not only the faster it gets to max but the tighter it turns
var max_speed = 160
var movement = Vector2.ZERO
var friction = 0.88 #the higher, the more slippery it will be
##############################

########## - DEFENSIVE STATS - ##########
var max_health = 16
var health = max_health setget set_health
##############################

########## - DETECTION - ##########
#when the player is at more than 70% distance, chase them
#at 70% distance, aim at them
#	if they get closer than 20% distance, flee from them
#	if they get further than 80% distance, chase them
#		this makes it so there's a buffer distance so the enemy doesn't "jitter" when the player is on the edge
var detection_range = 1000
onready var shooting_distance = detection_range * 0.70
onready var rechase_distance = detection_range * 0.80
onready var flee_distance = 160 #the other two may vary but this one is better if it's fixed

var player_distance = detection_range + 1 #so it always starts idle
var player_global_pos = Vector2.ZERO

var damaged_oor = false #when damaged out of range the enemy will chase the player
##############################

########## - OFFENSIVE STATS - ##########
var attack_speed = 1.35
var attack_cd = 0
##############################

########## - MODIFIERS - ##########
#hard mods
var stunned = false #this entity can't do anything while stunned
var silenced = false #this entity can't cast spells while silenced
var disarmed = false setget set_disarmed #disarming this enemy is a special case
var rooted = false #this entity can't move or use movement spells while rooted

#stat mods
var cooldown_reduction = 1.0
var att_speed_mod = 1.0
var speed_mod = 0
var dmg_mod = 0
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
				movement = movement.clamped(max_speed + speed_mod)
			else:
				movement *= friction
			
			if player_distance <= shooting_distance:
				attack_cd = attack_speed * att_speed_mod
				state = states.SHOOT
			elif player_distance > detection_range and damaged_oor == false:
				attack_cd = attack_speed * att_speed_mod
				state = states.IDLE
		
		states.SHOOT:
			update()
			movement *= friction
			
			if attack_cd <= 0 and not stunned and not disarmed:
				var bullet_instance = DataManager.SniperBullet.instance()
				bullet_instance.position = global_position
				bullet_instance.direction = global_position.direction_to(player_global_pos)
				bullet_instance.damage += dmg_mod
				DataManager.BulletsNode.call_deferred("add_child", bullet_instance)
				attack_cd = attack_speed * att_speed_mod
			
			if player_distance <= flee_distance:
				state = states.FLEE
			if player_distance >= rechase_distance:
				state = states.CHASE
		
		states.FLEE:
			if not stunned and not rooted:
				movement += position.direction_to(player_global_pos) * -acceleration
				movement = movement.clamped(max_speed + speed_mod)
			else:
				movement *= friction
			
			if player_distance >= flee_distance * 1.12:#some 12% margin
				attack_cd = attack_speed * att_speed_mod
				state = states.SHOOT
	
	if damaged_oor == true:
		if state == states.SHOOT:
			damaged_oor = false
	
	movement = move_and_slide(movement)

func _draw():
	if state == states.SHOOT and not stunned:
		if not disarmed:
			draw_line(Vector2(0, 0), player_global_pos - global_position, Color.red, 1.25)
			draw_circle(player_global_pos - global_position, 2.0, Color.red)
		else:
			draw_line(Vector2(0, 0), player_global_pos - global_position, Color.white, 1.25)
			draw_circle(player_global_pos - global_position, 2.0, Color.white)


func set_health(value):
	health = value
	$HealthbarControl.on_health_updated(health)
	
	if health <= 0:
		queue_free()
	
	if player_distance > detection_range:
		damaged_oor = true
		state = states.CHASE

func set_disarmed(value : bool):
	disarmed = value
	if disarmed == false:
		attack_cd = attack_speed


