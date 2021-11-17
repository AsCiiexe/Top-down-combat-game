extends Area2D

var speed = 1150
var direction = Vector2.ZERO
var lifespan = 3.5
var count = 0
var damage = 7.0

func _physics_process(delta):
	position += direction * speed * delta
	
	count += delta
	if count >= lifespan:
		queue_free()

func _on_Area2D_body_entered(body):
	if body.is_in_group("obstacle"):
		queue_free()
	elif body.is_in_group("enemy"):
		body.health -= damage
