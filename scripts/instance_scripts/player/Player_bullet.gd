extends Position2D

var speed = 1250
var direction = Vector2.ZERO
var lifespan = 2.5
var count = 0
var damage = 1.0

func _physics_process(delta):
	var movement = direction * speed * delta
	$RayCast2D.cast_to = movement
	position += movement
	
	if $RayCast2D.is_colliding():
		colliding()
	
	count += delta
	if count > lifespan:
		queue_free()


func colliding():
	var collided_node = $RayCast2D.get_collider()
	if collided_node.is_in_group("enemy"):
		collided_node.health -= damage
		queue_free()
	elif collided_node.is_in_group("obstacle"):
		queue_free()
