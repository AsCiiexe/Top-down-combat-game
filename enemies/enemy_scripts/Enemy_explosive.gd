extends KinematicBody2D

enum states {IDLE, CHASE}
var state = states.IDLE

var acceleration = 175 #the higher this is not only the faster it gets to max but the tighter the turns it takes are
var max_speed = 320
var movement = Vector2.ZERO
var friction = 0.85
var player = null
var max_health = 12
var health = max_health setget set_health
var damage = 7



func _physics_process(delta):
	match state:
		states.IDLE:
			movement *= friction
		
		states.CHASE:
			movement += position.direction_to(player.position) * acceleration
			movement = movement.clamped(max_speed)
	
	movement = move_and_slide(movement)



func set_health(value):
	health = value
	$HealthbarControl.on_health_updated(health)
	
	if health <= 0:
		queue_free()



func _on_DamageArea_area_entered(area):
	if area.get_parent().is_in_group("player"):
		area.get_parent().health -= damage
		var explode = DataManager.Explosion.instance()
		explode.position = global_position
		get_tree().get_root().call_deferred("add_child", explode)
		queue_free()


func _on_DetectionRange_area_entered(area):
	if area.owner.is_in_group("player"):
		player = area.owner
		state = states.CHASE

func _on_DetectionRange_area_exited(area):
	if area.owner.is_in_group("player"):
		player = null
		state = states.IDLE
