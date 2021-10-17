extends Node2D

var mod_duration = 3.0

func _ready():
	if get_parent().is_in_group("entity"):
		get_parent().rooted = true
	$DurationTimer.start(mod_duration)

func _on_DurationTimer_timeout():
	if get_parent().is_in_group("entity"):
		get_parent().rooted = false
	
	queue_free()
