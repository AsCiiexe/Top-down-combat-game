extends Area2D

var damage = 85.0
var flash_variant = false
var flash_stun_duration = 2.0

func _ready():
	if flash_variant:
		$AnimationPlayer.play("flash explosion")
	else:
		$AnimationPlayer.play("explosion")

func _on_PlayerExplosion_body_entered(body):
	if body.is_in_group("enemy"):
		if not flash_variant:
			body.health -= damage
		else:
			body.health -= damage
			
			var stun_explosion = body.mod_dict.get("stun_explosion")
			if stun_explosion == null:
				stun_explosion = DataManager.BoolMod.instance()
				stun_explosion.mod_type = stun_explosion.variable_stats.STUN
				stun_explosion.mod_duration = flash_stun_duration
				body.add_child(stun_explosion)
			else:
				get_node("stun_explosion").refresh_modifier()
