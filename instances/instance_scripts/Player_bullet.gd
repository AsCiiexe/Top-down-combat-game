extends Position2D

var speed = 1250
var direction = Vector2.ZERO
var lifespan = 2.5
var count = 0
var damage = 1

func _ready():
	$RayCast2D.cast_to = direction * speed * 0.0166 #the length of the raycast is the speed of the bullet

func _physics_process(delta):
	position += direction * speed * delta
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
