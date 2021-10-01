extends KinematicBody2D

#moving state allows to shoot, move and start an attack combo
#attacking state only allows to continue combo
#on the future you may be able to interrupt a combo with certain moves
#dashing gives the player damage invulnerability and disables inputs
enum states{MOVING, ATTACKING, DASHING}
var state = states.MOVING
var asdasdasdasd
var acceleration = 100
var acceleration_buffs = 0 #temporary buffs that makes the player accelerate faster
var max_speed = 380
var speed_buffs = 0 #temporary buffs that give the player a higher max speed cap
var movement = Vector2.ZERO
var friction = 0.85 #the higher, the more slippery it will be
var movement_input = Vector2.ZERO

var max_health = 20
var health = max_health setget set_health

var shooting_speed = 0.35
var shooting_cd = 0

var melee_cooldown = 0.35
var melee_cd = 0
var combo_cd = 0
var melee_dmg = 2.5
var final_melee_dmg = 4
export var combo = 0

#charged shot
var a1_cooldown = 3.5
var a1_cd = 0

#ground explosion
var a2_cooldown = 6.0
var a2_cd = 0

var a3_cooldown = 5.0
var a3_cd = 0

var dash_target = Vector2.ZERO #dash_target in global coords
var dash_direction = Vector2.ZERO #dash_target direction in local coords
var min_dash_distance = 100
var max_dash_distance = 600
var dash_distance = 0
var dash_speed = 2000
var dash_cooldown = 0.8
var dash_cd = 0


func _physics_process(delta):
	shooting_cd -= delta
	melee_cd -= delta
	combo_cd -= delta
	dash_cd -= delta
	a1_cd -= delta
	a2_cd -= delta
	
	movement_input = Vector2.ZERO
	get_input()
	match state:
		states.MOVING:
			movement += movement_input * (acceleration + acceleration_buffs)
			movement = movement.clamped(max_speed + speed_buffs)
			if movement_input == Vector2.ZERO:
				movement *= friction
		states.ATTACKING:
			if melee_cd <= 0:
				state = states.MOVING
			movement *= friction
		
		states.DASHING:
			movement = dash_direction * dash_speed
			if movement.length() * delta > global_position.distance_to(dash_target) or get_slide_collision(0) != null:
				global_position = dash_target
				$Sprite.modulate.a = 1.0
				$HurtBox/CollisionShape2D.set_deferred("disabled", false) #stop invulnerability
				collision_layer = 2 #stop going through entities
				collision_mask = 3 #if either the layer OR mask collide with bodies they still count as collisions
				state = states.MOVING
	movement = move_and_slide(movement)


func get_input():
	if Input.is_action_pressed("ui_up"):
		movement_input.y -= 1
	if Input.is_action_pressed("ui_down"):
		movement_input.y += 1
	if Input.is_action_pressed("ui_left"):
		movement_input.x -= 1
	if Input.is_action_pressed("ui_right"):
		movement_input.x += 1
	
	if Input.is_action_pressed("shoot"):
		if shooting_cd <= 0 and state == states.MOVING:
			fire_bullet()
			shooting_cd = shooting_speed
	if Input.is_action_pressed("melee_attack"):
		if melee_cd <= 0 and state != states.DASHING:
			melee_attack()
			melee_cd = melee_cooldown
	if Input.is_action_just_released("dash"):
		if dash_cd <= 0:
			dash()
			dash_cd = dash_cooldown
			DataManager.Interface.set_ability_on_cooldown(-1)
	if Input.is_action_pressed("ability_1"):
		if a1_cd <= 0 and state == states.MOVING:
			ability_1()
			a1_cd = a1_cooldown
			DataManager.Interface.set_ability_on_cooldown(1)
	if Input.is_action_pressed("ability_2"):
		if a2_cd <= 0 and state == states.MOVING:
			ability_2()
			a2_cd = a2_cooldown
			DataManager.Interface.set_ability_on_cooldown(2)


func set_health(value):
	if health > value:#if the player is losing health
		$PlayerHitAnimator.play("player hit")#animationplayer can only play one animation at a time
	
	health = value
	$HealthbarControl.on_health_updated(health)
	if health <= 0:
		get_tree().reload_current_scene()


func dash():
	dash_distance = max(min_dash_distance, min(max_dash_distance, get_local_mouse_position().length()))
	dash_target = get_local_mouse_position().normalized() * dash_distance
	dash_direction = dash_target.normalized()
	validate_position()
	dash_target = to_global(dash_target)
	$Sprite.modulate.a = 0.25
	$HurtBox/CollisionShape2D.set_deferred("disabled", true)
	collision_layer = 0 #go through entities
	collision_mask = 1 #still collide with walls
	state = states.DASHING


func validate_position():
	$DashRayCast.cast_to = dash_target
	$DashRayCast.force_raycast_update()
	if $DashRayCast.is_colliding():
		dash_target = to_local($DashRayCast.get_collision_point())
		dash_target = dash_target.normalized() * (dash_target.length() - $CollisionShape2D.shape.extents.length())
		dash_distance = dash_target.length()


func fire_bullet():
	var bullet_instance = DataManager.PlayerBullet.instance()
	bullet_instance.position = global_position
	bullet_instance.direction = global_position.direction_to(get_global_mouse_position())
	DataManager.ObstaclesNode.call_deferred("add_child", bullet_instance)
	#if the bullet is a rigidbody use this instead vv
	#bullet_instance.apply_impulse(Vector2(), Vector2(0,0).rotated(rotation))


func melee_attack():
	if combo_cd <= 0:
		combo = 0
	
	if combo == 0:
		state = states.ATTACKING
		combo_cd = 0.75
		$AttackDirection.look_at(get_global_mouse_position())
		$MeleeAttackAnimator.play("melee combo 1")#animationplayer can only play one animation at a time
		movement += movement_input * (acceleration * 10)
		movement = movement.clamped(max_speed * 1.4)
	elif combo == 1:
		state = states.ATTACKING
		combo_cd = 0.75
		$AttackDirection.look_at(get_global_mouse_position())
		$MeleeAttackAnimator.play("melee combo 2")#animationplayer can only play one animation at a time
		movement += movement_input * (acceleration * 10)
		movement = movement.clamped(max_speed * 1.4)
	elif combo == 2:
		state = states.ATTACKING
		combo_cd = 0.75
		$AttackDirection.look_at(get_global_mouse_position())
		$MeleeAttackAnimator.play("melee combo 3")#animationplayer can only play one animation at a time
		movement += movement_input * (acceleration * 15)
		movement = movement.clamped(max_speed * 1.6)


func ability_1():
	var charged_bullet_instance = DataManager.PlayerChargedBullet.instance()
	charged_bullet_instance.position = global_position
	charged_bullet_instance.direction = get_local_mouse_position().normalized()
	charged_bullet_instance.look_at(get_global_mouse_position())
	DataManager.BulletsNode.call_deferred("add_child", charged_bullet_instance)


func ability_2():
	var explosion_instance = DataManager.PlayerExplosionAbility.instance()
	explosion_instance.position = get_global_mouse_position()
	DataManager.BulletsNode.call_deferred("add_child", explosion_instance)


func _on_MeleeHitbox_body_entered(body):
	if body.is_in_group("enemy"):
		body.health -= melee_dmg

func _on_CircularMeleeHitbox_body_entered(body):
	if body.is_in_group("enemy"):
		body.health -= final_melee_dmg
