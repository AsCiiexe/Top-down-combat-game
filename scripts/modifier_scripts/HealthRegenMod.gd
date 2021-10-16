extends Node2D

var mod_duration = 5.0
var healing_tickrate = 0.05
var healing_amount = 0.25
#total damage = floor(mod_duration / tickrate) * amount

func _ready():
	if get_parent().is_in_group("entity"):
		$Tickrate.start(healing_tickrate)
	$DurationTimer.start(mod_duration)

func _on_Tickrate_timeout():
	get_parent().health += healing_amount

func _on_DurationTimer_timeout():
	queue_free()
