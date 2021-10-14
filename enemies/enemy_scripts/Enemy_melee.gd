extends KinematicBody2D

onready var attackHitbox = $AttackDirection/AttackHitbox/CollisionShape2D
onready var attackSprite = $AttackDirection/AttackPivot/AttackSprite
#this enemy will try to get in range of the player
#then it will attack with a white flash on top of the player position
#spawn a hitbox on the flash

enum states{IDLE, CHASE, MELEE}
var state = states.IDLE

var max_speed = 230
var acceleration = 80 #the higher this is not only the faster it gets to max but the tighter it turns
var movement = Vector2.ZERO
var friction = 0.45 #the higher, the more slippery it will be

var max_health = 22
var health = max_health setget set_health

var detection_range = 650
var attack_range = 60
var player_distance = detection_range + 1 #so it always starts idle
var player_global_pos = Vector2.ZERO

var damage = 2
var attack_speed = 1 #how frequently this enemy attacks
var attack_cd = 0 


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
			movement += position.direction_to(player_global_pos) * acceleration
			movement = movement.clamped(max_speed)
			
			if player_distance <= attack_range:
				state = states.MELEE
			elif player_distance > detection_range:
				state = states.IDLE
		
		states.MELEE:
			movement *= friction
			if attack_cd <= 0:
				$AttackDirection.look_at(player_global_pos)
				attack_cd = attack_speed
				$AnimationPlayer.play("attack")
			
			if player_distance > attack_range * 1.15:
				state = states.CHASE
	print(state)
	movement = move_and_slide(movement)


func set_health(value):
	health = value
	$HealthbarControl.on_health_updated(health)
	
	if health <= 0:
		queue_free()


func _on_AttackHitbox_area_entered(area):
	if area.get_parent().is_in_group("player"):
		area.get_parent().health -= damage
