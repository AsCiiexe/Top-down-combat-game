extends Node2D

########## HOW TO USE THIS MODIFIER SYSTEM ##########
#this mod will turn on or off a certain boolean modifier of the entity
#
#example of a mod applying object instancing this into an entity:
#var modifier = collided_node.mod_dict.get(>mod name<) #if has the mod it returns its path(key), else it returns null
#if modifier == null:
#	modifier = DataManager.BoolMod.instance() #if it doesn't have it, reuse this variable for managing the new mod
#	modifier.mod_type = modifier.mod.SILENCE
#	collided_node.call_deferred("add_child", modifier)
#else:
#	get_node(mod).refresh_modifier() #if it does have the mod simply refresh its effect
#####################################################

var mod_name = "NO_NAME_BOOL_MOD"
enum variable_stats {STUN, ROOT, SILENCE, DISARM, UNASSIGNED}
var mod_type = variable_stats.UNASSIGNED
var mod_duration = 1.0


func _ready():
	if get_parent().is_in_group("entity"):
		get_parent().mod_dict[mod_name] = self.get_path()
		
		match mod_type:
			variable_stats.STUN:
				get_parent().stunned = true
			variable_stats.ROOT:
				get_parent().rooted = true
			variable_stats.SILENCE:
				get_parent().silenced = true
			variable_stats.DISARM:
				get_parent().disarmed = true
			variable_stats.UNASSIGNED:
				print("UNASSIGNED MOD TYPE")
				queue_free()
	
	$DurationTimer.start(mod_duration)


#this is here so applying mods multiple times may have multiple effects like stacking or modifying the duration
func refresh_modifier():
	$DurationTimer.start(mod_duration)


func _on_DurationTimer_timeout():
	if get_parent().is_in_group("entity"):
		match mod_type:
			variable_stats.STUN:
				get_parent().stunned = false
			variable_stats.ROOT:
				get_parent().rooted = false
			variable_stats.SILENCE:
				get_parent().silenced = false
			variable_stats.DISARM:
				get_parent().disarmed = false
		
		get_parent().mod_dict.erase(mod_name)
	
	queue_free()
