extends Area2D

var damage = 8.5

func _on_PlayerExplosion_body_entered(body):
	if body.is_in_group("enemy"):
		body.health -= damage
