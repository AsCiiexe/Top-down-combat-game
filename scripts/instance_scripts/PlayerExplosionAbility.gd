extends Area2D

var damage = 8.5
var flash_variant = false

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
			body.health -= damage * 0.5
			var stun_mod = DataManager.StunMod.instance()
			stun_mod.mod_duration = 2.25
			body.call_deferred("add_child", stun_mod)
