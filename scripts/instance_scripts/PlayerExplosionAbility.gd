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
			body.health -= damage
			
			var stun_mod = body.mod_dict.get("flash_stun")
			if stun_mod == null:
				stun_mod = DataManager.BoolMod.instance()
				stun_mod.mod_type = stun_mod.mod.STUN
				stun_mod.mod_duration = 2.0
				stun_mod.mod_name = "flash_stun"
				body.call_deferred("add_child", stun_mod)
