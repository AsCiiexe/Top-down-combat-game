extends Node

var mod_duration = 3.0
var speed_mod = -0.35 #this is HOW MUCH of the speed % this mod will add or substract (negative for debuff)
var mod_quantity = 0 #this is the total amount of speed that will be added (and substracted once finished)

#the way this works is the mod will get the current entity speed + any mod and calculate the percentage of that
#add it at the start, then once it ends substract it
#this makes it so more recent mods are more impactful as they will calculate w previous mods taken into account
#also makes stacking multiple speed debuffs follow a more logarithmic scale instead of a linear one

func _ready():
	if get_parent().is_in_group("entity"):
		mod_quantity = (get_parent().speed + get_parent().speed_mod) * speed_mod
		get_parent().speed_mod += mod_quantity
	$DurationTimer.start(mod_duration)

func _on_DurationTimer_timeout():
	if get_parent().is_in_group("entity"):
		get_parent().speed_mod -= mod_quantity
	queue_free()
