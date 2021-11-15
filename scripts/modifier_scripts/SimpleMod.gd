extends Node2D

#health is NOT ALLOWED as a temporary mod as it is tied to a setget on entities there are ways for unintended deaths
#if you want it just create health shields as a stat and forget about modifying health
var mod_name = "NO_NAME_TICKING_MOD"
enum variable_stats{DAMAGE, SPEED, ATTACK_SPEED, UNASSIGNED}
var mod_type = variable_stats.UNASSIGNED

var mod_duration = 1.0 #how long it lasts in seconds
var amount = 0.0 #flat amount of the stat that will be modified per tick
var percentage_amount = 0.0 #HOW MUCH of the stat % it will modify per tick (eg remove 0.1% per tick = -0.001)

var original_stat = 0.0 #the number this stat was at before this modifier was applied

########## HOW TO USE THIS MODIFIER SYSTEM ##########
#This modifier type will modify a certain amount of an entity's stat and then ALWAYS give it back when it runs out
#
#var modifier = entity.mod_dict.get(>mod_name<) #if it has the mod, get path (dictionary key) else return null
#if modifier == null:
#	modifier = DataManager.SimpleMod.instance() #if it doesn't have it, reuse this variable for managing the new mod
#	modifier.mod_type = modifier.variable_stats.SPEED
#	modifier.mod_name = >mod_name< #this will be the name in the mod dictionary of the entity
#	modifier.mod_duration = 7.0 #lasts 7 seconds
#	modifier.amount = 0.0 #flat amount that is modified
#	modifier.percentage_amount = 0.2 #percentage amount that is modified
#	entity.call_deferred("add_child", modifier)
#else:
#	entity.get_node(modifier).refresh_modifier() #if it does already have the mod, refresh its effect
#####################################################


func _ready():
	if get_parent().is_in_group("entity"):
		get_parent().mod_dict[mod_name] = self.get_path()
		
		match mod_type:
			variable_stats.DAMAGE:
				original_stat = get_parent().attack_damage
				get_parent().attack_damage += amount + original_stat * percentage_amount
			variable_stats.SPEED:
				original_stat = get_parent().speed
				get_parent().speed += amount + original_stat * percentage_amount
			variable_stats.ATTACK_SPEED:
				original_stat = get_parent().attack_speed
				get_parent().attack_speed += original_stat * percentage_amount
			variable_stats.UNASSIGNED:
				print("UNASSIGNED MOD TYPE")
				queue_free()
	
	$DurationTimer.start(mod_duration)

#this is for when the modifier is reapplied
func refresh_modifier():
	$DurationTimer.start(mod_duration)

#this is used for when older modifiers run out and suddenly the percentages need to be re-calculated
func update_modifier():
	if percentage_amount != 0.0:
		match mod_type:
			variable_stats.DAMAGE:
				get_parent().attack_damage -= amount + original_stat * percentage_amount
				original_stat = get_parent().attack_damage
				get_parent().attack_damage += amount + original_stat * percentage_amount
			variable_stats.SPEED:
				get_parent().speed -= amount + original_stat * percentage_amount
				original_stat = get_parent().speed
				get_parent().speed += amount + original_stat * percentage_amount
			variable_stats.ATTACK_SPEED:
				get_parent().attack_speed -= amount + original_stat * percentage_amount
				original_stat = get_parent().attack_speed
				get_parent().attack_speed += amount + original_stat * percentage_amount

func _on_DurationTimer_timeout():
	match mod_type:
		variable_stats.DAMAGE:
			get_parent().attack_damage -= amount + original_stat * percentage_amount
		variable_stats.SPEED:
			get_parent().speed -= amount + original_stat * percentage_amount
		variable_stats.ATTACK_SPEED:
			get_parent().attack_speed -= original_stat * -percentage_amount
	
	get_parent().mod_dict.erase(mod_name)
	queue_free()
