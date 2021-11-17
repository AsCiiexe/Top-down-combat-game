extends Area2D

#number of strikes: 8 (THIS MAY BE OUTDATED)
var damage = 8.0

func look_at_mouse():
	self.look_at(get_global_mouse_position())

func _on_PlayerStrikeBarrageAbility_body_entered(body):
	if body.is_in_group("enemy"):
		body.health -= damage
