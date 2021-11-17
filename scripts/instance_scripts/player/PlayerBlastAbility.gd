extends Area2D

var damage = 35.0

func _on_Area2D_body_entered(body):
	if body.is_in_group("enemy"):
		body.health -= damage
		
		var blast_slow = body.mod_dict.get("blast_slow")
		if blast_slow == null:
			blast_slow = DataManager.SimpleMod.instance()
			blast_slow.mod_type = blast_slow.variable_stats.SPEED
			blast_slow.mod_name = "blast_slow"
			blast_slow.mod_duration = 1.75
			blast_slow.amount = 0.0
			blast_slow.percentage_amount = -0.75
			body.add_child(blast_slow)
		else:
			body.get_node(blast_slow).refresh_modifier()
