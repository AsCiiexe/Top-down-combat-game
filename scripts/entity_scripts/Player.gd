extends KinematicBody2D

#moving state allows to do basic attacks and move
#casting state only allows to continue combo
#on the future you may be able to interrupt a combo with certain moves
#dashing gives the player damage invulnerability and disables inputs
enum states{MOVING, CASTING, DASHING}
var state = states.MOVING

########## - MOVEMENT - ##########
var acceleration = 125
var max_speed = 320
var movement = Vector2.ZERO
var friction = 0.85 #the higher, the more slippery it will be
var movement_input = Vector2.ZERO
##############################

########## - DEFENSIVE STATS - ##########
var max_health = 20
var health = max_health setget set_health
######################################

########## - BASIC ATTACKS - ##########
#basic shooting
var shooting_speed = 0.35
var shooting_cd = 0
var shooting_slow = 0.65 #while shooting the character moves slower for the duration of the shot cd

#basic melee
var melee_cooldown = 0.48 #how fast the player attacks
var melee_cd = 0 #current attack cd
var combo_cd = 0 #the time in which if the player attacks again the combo will continue instead of starting again
var melee_dmg = 2.5 #regular melee attack dmg
var final_melee_dmg = 4 #final melee attack dmg
export var combo = 0 #current combo iteration, exported for the animation player to be able to continue the combo
var melee_slow = 0.4 #how slow the player moves while doing a melee attack
##############################

########## - ABILITIES - ##########
var casting_cd = 0
var casting_slow = 0.45 #how much the player gets slowed when casting and ability
var casting_duration = 0 #how long the slow lasts

#charged shot
var a1_cooldown = 3.5
var a1_cd = 0
var a1_cast_time = 0.4

#ground explosion
var a2_cooldown = 6.0
var a2_cd = 0
var a2_cast_time = 0.6

#nothing for now
var a3_cooldown = 5.0
var a3_cd = 0

#dash
var dash_target = Vector2.ZERO #dash target in global coords
var dash_direction = Vector2.ZERO #normalized dash_target direction in LOCAL coords
var min_dash_distance = 100
var max_dash_distance = 420
var dash_distance = 0
var dash_speed = 1250
var dash_cooldown = 1.85
var dash_cd = 0
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
	refresh_cooldowns(delta)
	get_input()
	
	match state:
		states.MOVING:
			if rooted:
				movement = Vector2.ZERO
			else:
				movement += movement_input * acceleration
				movement = movement.clamped(max_speed + speed_mod)
				if movement_input == Vector2.ZERO:
					movement *= friction
				elif melee_cd > 0.1:
					movement *= melee_slow
				elif shooting_cd > 0:
					movement *= shooting_slow
		
		states.CASTING:
			if rooted:
				movement = Vector2.ZERO
			else:
				movement += movement_input * acceleration
				movement = movement.clamped(max_speed + speed_mod)
				if movement_input == Vector2.ZERO:
					movement *= friction
				else:
					movement *= casting_slow
			
			if casting_duration <= 0:
				state = states.MOVING
		
		states.DASHING:
			movement = dash_direction * dash_speed
			if movement.length() * delta > global_position.distance_to(dash_target) or get_slide_collision(0) != null:
				dash_cd = dash_cooldown
				DataManager.Interface.set_ability_on_cooldown(-1, dash_cd)
				$Sprite.modulate.a = 1.0
				$HurtBox/CollisionShape2D.set_deferred("disabled", false) #stop invulnerability
				collision_layer = 2 #stop going through entities
				collision_mask = 3 #if either the layer OR mask collides with bodies still counted as collisions
				state = states.MOVING
	
	movement = move_and_slide(movement)

func refresh_cooldowns(delta):
	shooting_cd -= delta
	melee_cd -= delta
	combo_cd -= delta
	dash_cd -= delta
	a1_cd -= delta
	a2_cd -= delta
	casting_duration -= delta


func get_input():
	movement_input = Vector2.ZERO
	
	if stunned: #it may be better to still be able to do input checks while stunned but this is gonna be here for now
		return
	
	if Input.is_action_pressed("ui_up"):
		movement_input.y -= 1
	if Input.is_action_pressed("ui_down"):
		movement_input.y += 1
	if Input.is_action_pressed("ui_left"):
		movement_input.x -= 1
	if Input.is_action_pressed("ui_right"):
		movement_input.x += 1
	
	
	#the player can either shoot, do a melee attack or cast a spell but not more than one at the same time
	
	if Input.is_action_pressed("shoot"):
		if shooting_cd <= 0 and state == states.MOVING and melee_cd <= 0 and not disarmed:
			fire_bullet()
	
	if Input.is_action_pressed("melee_attack"):
		if melee_cd <= 0 and state == states.MOVING and shooting_cd <= 0 and not disarmed:
			melee_attack()
	
	if Input.is_action_just_released("dash"):
		if dash_cd <= 0 and state == states.MOVING and not silenced and not rooted:
			dash()
			#cooldown is applied when the dash ends instead of when it starts
	
	if Input.is_action_pressed("ability_1"):
		if a1_cd <= 0 and state == states.MOVING and not silenced:
			ability_1()
			a1_cd = a1_cooldown
			casting_duration = a1_cast_time
			DataManager.Interface.set_ability_on_cooldown(1, a1_cd)
	
	if Input.is_action_pressed("ability_2"):
		if a2_cd <= 0 and state == states.MOVING and not silenced:
			if Input.is_action_pressed("variant"):
				ability_2_variant()
			else:
				ability_2()


func set_health(value):
	health = value
	if health > value:#if the player is losing health
		$PlayerHitAnimator.play("player hit")#animationplayer can only play one animation at a time
	elif health > max_health: #if the player is gaining health and it goes over the maximum
		health = max_health
	
	$HealthbarControl.on_health_updated(health)
	if health <= 0:
# warning-ignore:return_value_discarded
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
	shooting_cd = shooting_speed * att_speed_mult


func melee_attack():
	if combo_cd <= 0:
		combo = 0
	
	if combo == 0:
		melee_cd = (melee_cooldown * 0.85) * att_speed_mult
		#state = states.CASTING
		combo_cd = 0.88
		$MeleeDirection.look_at(get_global_mouse_position())
		$MeleeAttackAnimator.play("melee combo 1")#animationplayer can only play one animation at a time
		movement += movement_input * (acceleration * 10)
		movement = movement.clamped(max_speed * 1.4)
	elif combo == 1:
		melee_cd = melee_cooldown * att_speed_mult
		#state = states.CASTING
		combo_cd = 1.08
		$MeleeDirection.look_at(get_global_mouse_position())
		$MeleeAttackAnimator.play("melee combo 2")#animationplayer can only play one animation at a time
		movement += movement_input * (acceleration * 10)
		movement = movement.clamped(max_speed * 1.4)
	elif combo == 2:
		melee_cd = (melee_cooldown * 1.35) * att_speed_mult
		#state = states.CASTING
		combo_cd = 0
		$MeleeDirection.look_at(get_global_mouse_position())
		$MeleeAttackAnimator.play("melee combo 3")#animationplayer can only play one animation at a time
		movement += movement_input * (acceleration * 25)
		movement = movement.clamped(max_speed * 2.5)


func ability_1():
	var charged_bullet_instance = DataManager.PlayerChargedBullet.instance()
	charged_bullet_instance.position = global_position
	charged_bullet_instance.direction = get_local_mouse_position().normalized()
	charged_bullet_instance.look_at(get_global_mouse_position())
	DataManager.BulletsNode.call_deferred("add_child", charged_bullet_instance)
	state = states.CASTING


func ability_2():
	var explosion_instance = DataManager.PlayerExplosionAbility.instance()
	explosion_instance.position = get_global_mouse_position()
	DataManager.BulletsNode.call_deferred("add_child", explosion_instance)
	state = states.CASTING
	
	a2_cd = a2_cooldown
	casting_duration = a2_cast_time
	DataManager.Interface.set_ability_on_cooldown(2, a2_cd)

func ability_2_variant():
	var explosion_instance = DataManager.PlayerExplosionAbility.instance()
	explosion_instance.position = get_global_mouse_position()
	explosion_instance.flash_variant = true
	DataManager.BulletsNode.call_deferred("add_child", explosion_instance)
	state = states.CASTING
	
	a2_cd = a2_cooldown * 0.5
	casting_duration = a2_cast_time * 0.5
	DataManager.Interface.set_ability_on_cooldown(2, a2_cd)

func _on_MeleeHitbox_body_entered(body):
	if body.is_in_group("enemy"):
		body.health -= melee_dmg

func _on_CircularMeleeHitbox_body_entered(body):
	if body.is_in_group("enemy"):
		body.health -= final_melee_dmg
