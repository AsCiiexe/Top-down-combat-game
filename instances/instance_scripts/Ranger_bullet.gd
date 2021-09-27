extends Position2D

var speed = 1250
var direction = Vector2.ZERO
var lifespan = 2.25
var count = 0
var damage = 1

func _ready():
	$RayCast2D.cast_to = direction * speed * 0.0166 #the length of the raycast is the speed of the bullet

func _physics_process(delta):
	if $RayCast2D.is_colliding():
		colliding()
	
	position += direction * speed * delta
	count += delta
	if count > lifespan:
		queue_free()


func colliding():
	var collided_node = $RayCast2D.get_collider().owner
	if $RayCast2D.get_collider().owner.is_in_group("player"):
		collided_node.health -= damage
		queue_free()
	elif $RayCast2D.get_collider().is_in_group("obstacle"):
		queue_free()
