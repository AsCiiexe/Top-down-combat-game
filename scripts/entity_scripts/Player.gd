extends KinematicBody2D

#moving state allows to do basic attacks and move
#casting state only allows to continue combo
#on the future you may be able to interrupt a combo with certain moves
#dashing gives the player damage invulnerability and disables inputs
enum states{MOVING, CASTING, DASHING}
var state = states.MOVING

########## - MOVEMENT - ##########
var base_speed = 320.0
var speed = base_speed
var base_acceleration = 125.0 #the higher, the tighter it turns around
var acceleration = base_acceleration
var movement = Vector2.ZERO
var friction = 0.85 #the higher, the more slippery it will be
var movement_input = Vector2.ZERO
##################################

########## - DEFENSIVE STATS - ##########
var base_max_health = 200.0
var max_health = base_max_health
var health = max_health setget set_health
#########################################

var base_attack_damage = 10.0
var attack_damage = base_attack_damage

########## - BASIC ATTACKS - ##########
#basic shooting
var shooting_speed = 0.35
var shooting_cd = 0.0
var shooting_slow = 0.6 #while shooting the character moves slower for the duration of the shot cd
var bullet_damage = 1.0

#basic melee
var melee_cooldown = 0.38 #how fast the player attacks
var melee_cd = 0.0 #current attack cd
var combo_cd = 0.0 #the time in which if the player attacks again the combo will continue instead of starting again
var melee_damage = 1.8 #regular melee attack dmg
export var combo = 0.0 #current combo iteration, exported for the animation player to be able to continue the combo
var melee_slow = 0.65 #how slow the player moves while doing a melee attack
######################################

########## - ABILITIES - ##########
var casting_cd = 0.0
var casting_slow = 0.45 #how much the player gets slowed when casting and ability
var casting_duration = 0.0 #how long the slow lasts

#charged shot
var a1_cooldown = 3.5
var a1_cd = 0.0
var a1_cast_time = 0.4
var a1_damage = 6.0

#remote explosion
var a2_cooldown = 6.0
var a2_cd = 0.0
var a2_cast_time = 0.6
var a2_damage =  8.0
var a2_damage_variant = a2_damage * 0.45

#close blast
var a3_cooldown = 3.5
var a3_cd = 0.0
var a3_cast_time = 0.25
var a3_damage =  6.0

#strike barrage
var a4_cooldown = 6.0
var a4_cd = 0.0
var a4_cast_time = 1.0
var a4_damage = 1.8

#dash
var dash_target = Vector2.ZERO #dash target in global coords
var dash_direction = Vector2.ZERO #normalized dash_target direction in LOCAL coords
var min_dash_distance = 100.0
var max_dash_distance = 480.0
var dash_distance = 0.0
var dash_speed = 1430.0
var dash_cooldown = 1.85
var dash_cd = 0.0
###################################

########## - MODIFIERS - ##########
var mod_dict = {}
#hard mods
var stunned = false #this entity can't do anything while stunned
var silenced = false #this entity can't cast spells while silenced
var disarmed = false #this entity can't do basic attacks while disarmed
var rooted = false #this entity can't move or use movement spells while rooted

var cooldown_reduction = 1.0 #CDR is always multiplicative (NOTE: still not implemented)
var att_speed_mod = 1.0 #Same as cdr but for basic attacks, it applies equally and to both melee and ranged
###################################

#ITEM IDEAS:
#simple:
#	shoulder pauldrons for dmg reduction
#	fire ember for extra damage
#	electric spark for attack speed and cooldown reduction
#	winged boots for movespeed, tenacity, longer and faster dash
#	life seed for tiny amount of passive health regen and healing when killing enemies
#
#consumable:
#	red potion for health regen
#	green potion for throwing an area poison effect with slow
#	purple potion for health decay, attack damage buff, movespeed buff and damage reduction
#	orange potion for burning on attacks
#	blue potion for temporary time stop (stunning all enemies around), if an ability is used the effect stops aswell
#
#complex:
#	mage cape for ice mage, now abilities slow and freeze.
#		New ability: cone of cold, like blast but in a cone and freezes frostbite enemies. Replaces barrage
#		Blast is bigger, slows and applies frostbite
#		explosion is bigger, freezes enemies with frostbite and applies to those who don't have it
#		projectile deals extra damage to frostbite or frozen enemies
#		ranged attacks refresh frostbite
#	werewolf curse, now melee attacks heal.
#		New ability: bite leap. replaces explosion, dashes short distance, does healing dmg to first enemy hit, slows
#		barrage is faster
#		blast fears enemies away
#		missile applies bleeding and can only hit one enemy
#	gunslinger pistols:
#		higher ranged attack speed and slows less
#		new ability: blasting pistols. replaces barrage, shoots a barrage of bullets at half attack speed that slow
#		casting slow slows less
#		blast knocks back enemies
#		dash cooldown is shorter
#		explosion always stuns and 
#		missile does more damage
#		


func _physics_process(delta):
	print(delta)
	refresh_cooldowns(delta)
	get_input()
	match state:
		states.MOVING:
			if rooted:
				movement = Vector2.ZERO
			else:
				movement += movement_input * acceleration
				movement = movement.clamped(speed)
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
				movement = movement.clamped(speed)
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
	
	movement += $SoftCollisions.get_push_vector()
	movement = move_and_slide(movement)


func refresh_cooldowns(delta):
	shooting_cd -= delta
	melee_cd -= delta
	combo_cd -= delta
	dash_cd -= delta
	a1_cd -= delta
	a2_cd -= delta
	a3_cd -= delta
	a4_cd -= delta
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
	
	if Input.is_action_pressed("dash"):
		if dash_cd <= 0 and state == states.MOVING and not silenced and not rooted:
			dash()
			#cooldown is applied when the dash ends instead of when it starts
	
	if Input.is_action_pressed("ability_1"):
		if a1_cd <= 0 and state == states.MOVING and not silenced:
			ability_1()
	
	if Input.is_action_pressed("ability_2"):
		if a2_cd <= 0 and state == states.MOVING and not silenced:
			if Input.is_action_pressed("variant"):#cooldowns applied in the functions
				ability_2_variant()
			else:
				ability_2()
	
	if Input.is_action_pressed("ability_3"):
		if a3_cd <= 0 and state == states.MOVING and not silenced:
			ability_3()
	
	if Input.is_action_pressed("ultimate"):
		if a4_cd <= 0 and state == states.MOVING and not silenced:
			ability_4()


func set_health(value):
	if health > value:#if the player is losing health
		health = value
		$HurtBox/CollisionShape2D.set_deferred("disabled", true)
		$PlayerHitAnimator.play("player hit")#animationplayer can only play one animation at a time
	elif value > max_health: #if the player is gaining health and it goes over the maximum
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
	bullet_instance.damage = attack_damage * bullet_damage
	DataManager.ObstaclesNode.add_child(bullet_instance)
	#if the bullet is a rigidbody use this instead vv
	#bullet_instance.apply_impulse(Vector2(), Vector2(0,0).rotated(rotation))
	shooting_cd = shooting_speed * att_speed_mod


func melee_attack():
	if combo_cd <= 0:
		combo = 0
	
	if combo == 0:
		melee_cd = (melee_cooldown * 0.85) * att_speed_mod
		#state = states.CASTING
		combo_cd = 0.88
		$MeleeDirection.look_at(get_global_mouse_position())
		$MeleeAttackAnimator.play("melee combo 1")#animationplayer can only play one animation at a time
		movement += movement_input * (acceleration * 10)
		movement = movement.clamped(base_speed * 1.4)
	elif combo == 1:
		melee_cd = melee_cooldown * att_speed_mod
		#state = states.CASTING
		combo_cd = 1.08
		$MeleeDirection.look_at(get_global_mouse_position())
		$MeleeAttackAnimator.play("melee combo 2")#animationplayer can only play one animation at a time
		movement += movement_input * (acceleration * 10)
		movement = movement.clamped(base_speed * 1.4)
	elif combo == 2:
		melee_cd = (melee_cooldown * 1.35) * att_speed_mod
		#state = states.CASTING
		combo_cd = 0
		$MeleeDirection.look_at(get_global_mouse_position())
		$MeleeAttackAnimator.play("melee combo 3")#animationplayer can only play one animation at a time
		movement += movement_input * (acceleration * 25)
		movement = movement.clamped(base_speed * 2.5)


func ability_1():
	var charged_bullet_instance = DataManager.PlayerChargedBullet.instance()
	charged_bullet_instance.position = global_position + (get_local_mouse_position().normalized() * 10)
	charged_bullet_instance.direction = get_local_mouse_position().normalized()
	charged_bullet_instance.look_at(get_global_mouse_position())
	charged_bullet_instance.damage = attack_damage * a1_damage
	DataManager.BulletsNode.add_child(charged_bullet_instance)
	state = states.CASTING
	
	a1_cd = a1_cooldown
	casting_duration = a1_cast_time
	DataManager.Interface.set_ability_on_cooldown(1, a1_cd)


func ability_2():
	var explosion_instance = DataManager.PlayerExplosionAbility.instance()
	explosion_instance.position = get_global_mouse_position()
	explosion_instance.damage = attack_damage * a2_damage
	DataManager.BulletsNode.add_child(explosion_instance)
	state = states.CASTING
	
	a2_cd = a2_cooldown
	casting_duration = a2_cast_time
	DataManager.Interface.set_ability_on_cooldown(2, a2_cd)

func ability_2_variant():
	var remote_explosion_instance = DataManager.PlayerExplosionAbility.instance()
	remote_explosion_instance.position = get_global_mouse_position()
	remote_explosion_instance.flash_variant = true
	remote_explosion_instance.damage = attack_damage * a2_damage_variant
	DataManager.BulletsNode.add_child(remote_explosion_instance)
	state = states.CASTING
	
	#sliced in half due to it being the variant
	a2_cd = a2_cooldown * 0.5
	casting_duration = a2_cast_time * 0.5
	DataManager.Interface.set_ability_on_cooldown(2, a2_cd)


func ability_3():
	var blast_instance = DataManager.PlayerBlastAbility.instance()
	blast_instance.damage = attack_damage * a3_damage
	add_child(blast_instance)
	state = states.CASTING
	
	a3_cd = a3_cooldown
	casting_duration = a3_cast_time
	DataManager.Interface.set_ability_on_cooldown(3, a3_cd)


func ability_4():
	var strike_barrage_instance = DataManager.PlayerStrikeBarrageAbility.instance()
	strike_barrage_instance.damage = attack_damage * a4_damage
	strike_barrage_instance.look_at(get_local_mouse_position())
	add_child(strike_barrage_instance)
	state = states.CASTING
	movement += movement_input * (acceleration * 10)
	movement = movement.clamped(base_speed * 1.4)
	
	a4_cd = a4_cooldown
	casting_duration = a4_cast_time
	DataManager.Interface.set_ability_on_cooldown(4, a4_cd)


func _on_MeleeHitbox_body_entered(body):
	if body.is_in_group("enemy"):
		body.health -= attack_damage * melee_damage

func _on_CircularMeleeHitbox_body_entered(body):
	if body.is_in_group("enemy"):
		body.health -= attack_damage * melee_damage * 1.25
