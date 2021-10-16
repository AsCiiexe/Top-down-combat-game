extends Node2D

var mod_duration = 7.5
var harming_tickrate = 0.37
var harming_amount = -0.36
#total damage = floor(mod_duration / tickrate) * amount

func _ready():
	if get_parent().is_in_group("entity"):
		$Tickrate.start(harming_tickrate)
	$DurationTimer.start(mod_duration)

func _on_Tickrate_timeout():
	get_parent().health += harming_amount

func _on_DurationTimer_timeout():
	queue_free()
