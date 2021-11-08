extends Node2D

var mod_duration = 2.0

func _ready():
	if get_parent().is_in_group("entity"):
		get_parent().silenced = true
	$DurationTimer.start(mod_duration)

func _on_DurationTimer_timeout():
	if get_parent().is_in_group("entity"):
		get_parent().silenced = false
	
	queue_free()
