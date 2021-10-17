extends KinematicBody2D

enum states {IDLE, CHASE}
var state = states.IDLE

########## - MOVEMENT - ##########
var acceleration = 175 #the higher this is not only the faster it gets to max but the tighter the turns it takes are
var max_speed = 280
var movement = Vector2.ZERO
var friction = 0.85 #the higher, the more slippery it will be
##############################

########## - DEFENSIVE STATS - ##########
var max_health = 12
var health = max_health setget set_health
##############################

########## - DETECTION - ##########
var detection_range = 650
var player_distance = detection_range + 1 #so it always starts idle
var player_global_pos = Vector2.ZERO
##############################

########## - OFFENSIVE STATS - ##########
var damage = 7
##############################

########## - MODIFIERS - ##########
#hard mods
var stunned = false #this entity can't do anything while stunned
var silenced = false #this entity can't cast spells while silenced
var disarmed = false #this entity can't do basic attacks while disarmed
var rooted = false #this entity can't move or use movement spells while rooted

#stat mods
var cooldown_reduction = 0
var speed_mod = 0
var dmg_mod = 0

#stat multipliers
var att_speed_mult = 1
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
				movement = movement.clamped(max_speed + speed_mod)
			else:
				movement *= friction
			
			if player_distance > detection_range:
				state = states.IDLE
	
	movement = move_and_slide(movement)


func set_health(value):
	health = value
	$HealthbarControl.on_health_updated(health)
	if health > max_health:
		health = max_health
	
	if health <= 0:
		queue_free()


func _on_DamageArea_area_entered(area):
	if area.get_parent().is_in_group("player") and not stunned and not silenced:
		area.get_parent().health -= damage + dmg_mod
		var explode = DataManager.Explosion.instance()
		explode.position = global_position
		get_tree().get_root().call_deferred("add_child", explode)
		queue_free()
