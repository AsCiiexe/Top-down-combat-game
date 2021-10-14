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
var friction = 0.92
var player = null
var max_health = 22
var health = max_health setget set_health

var damage = 2
var attack_speed = 1 #how frequently this enemy attacks
var attack_cd = 0 

func _physics_process(delta):
	attack_cd -= delta
	
	match state:
		states.IDLE:
			movement *= friction
		
		states.CHASE:
			movement += position.direction_to(player.position) * acceleration
			movement = movement.clamped(max_speed)
		
		states.MELEE:
			movement *= friction /1.25
			if attack_cd <= 0:
				$AttackDirection.look_at(player.global_position)
				attack_cd = attack_speed
				$AnimationPlayer.play("attack")
	
	movement = move_and_slide(movement)

func set_health(value):
	health = value
	$HealthbarControl.on_health_updated(health)
	
	if health <= 0:
		queue_free()


func _on_DetectionRange_body_entered(body):
	if body.is_in_group("player"):
		player = body
		state = states.CHASE

func _on_DetectionRange_body_exited(body):
	if body.is_in_group("player"):
		player = null
		state = states.IDLE

func _on_AttackRange_body_entered(body):
	if body.is_in_group("player"):
		state = states.MELEE

func _on_AttackRange_body_exited(body):
	if body.is_in_group("player"):
		state = states.CHASE

func _on_AttackHitbox_area_entered(area):
	if area.get_parent().is_in_group("player"):
		area.get_parent().health -= damage


func _on_DetectionRange_area_entered(area):
	if area.owner.is_in_group("player"):
		player = area.owner
		state = states.CHASE

func _on_DetectionRange_area_exited(area):
	if area.owner.is_in_group("player"):
		player = null
		state = states.IDLE
