extends KinematicBody2D

onready var attackHitbox = $AttackDirection/AttackHitbox/CollisionShape2D
onready var attackSprite = $AttackDirection/AttackPivot/AttackSprite
#this enemy will try to get in range of the player
#then it will attack with a white flash on top of the player position
#spawn a hitbox on the flash

enum states{IDLE, CHASE, MELEE}
var state = states.IDLE

########## - MOVEMENT - ##########
var max_speed = 230
var acceleration = 80 #the higher this is not only the faster it gets to max but the tighter it turns
var movement = Vector2.ZERO
var friction = 0.45 #the higher, the more slippery it will be
##############################

########## - DEFENSIVE STATS - ##########
var max_health = 22
var health = max_health setget set_health
##############################

########## - DETECTION - ##########
var detection_range = 650
var attack_range = 60
var player_distance = detection_range + 1 #so it always starts idle
var player_global_pos = Vector2.ZERO

var damaged_oor = false #when damaged out of range the enemy will chase the player
var d_oor_distance = detection_range * 0.75 #how far it will chase the player before regular distance checks come back
##############################

########## - OFFENSIVE STATS - ##########
var damage = 2
var attack_speed = 1 #how frequently this enemy attacks
var attack_cd = 0
##############################

########## - MODIFIERS - ##########
#hard mods
var stunned = false #this entity can't do anything while stunned
var silenced = false #this entity can't cast spells while silenced
var disarmed = false #this entity can't do basic attacks while disarmed
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
			
			if player_distance <= attack_range:
				state = states.MELEE
			elif player_distance > detection_range and damaged_oor == false:
				state = states.IDLE
		
		states.MELEE:
			movement *= friction
			if attack_cd <= 0 and not stunned and not disarmed:
				$AttackDirection.look_at(player_global_pos)
				attack_cd = attack_speed * att_speed_mod
				$AnimationPlayer.play("attack")
			
			if player_distance > attack_range * 1.15:
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


func _on_AttackHitbox_area_entered(area):
	if area.get_parent().is_in_group("player"):
		area.get_parent().health -= damage + dmg_mod
