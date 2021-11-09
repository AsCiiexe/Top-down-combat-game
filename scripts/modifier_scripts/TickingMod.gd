extends Node2D

var mod_name = "NO_NAME_TICKING_MOD"
enum variable_stats{HEALTH, DAMAGE, SPEED, ATTACK_SPEED, UNASSIGNED}
var mod_type = variable_stats.UNASSIGNED

var mod_duration = 1.0 #how long it lasts in seconds
var mod_tickrate = 0.1 #how frequently it ticks in seconds

var max_ticks = 0 #if this is not 0 the tickrate will only tick this amount of times
var ticks = 0 #how many times has this modifier has ticked

var amount = 0.0 #flat amount of the stat that will be modified per tick
var percentage_amount = 0.0 #HOW MUCH of the stat % it will modify per tick (eg remove 0.1% per tick = -0.001)
var percent_toflat = 0.0 #temporary variable used for holding data during calculations
var original_stat = 0.0 #the number this stat was at before this modifier was applied

var starting_amount = null #if this is not null, at the start this will be added/removed from the stat
var starting_percentage_amount = null #same but with a percentage of the stat

var give_back_on_end = true #if true the entity's stat gets back to its original amount when this modifier ends
var modified_amount = 0.0 #used for when give_back_on_end is true, the entity's stat amount will have this removed
var modified_percentage_amount = 0.0 #due to % being updateable this is stored in separate but has the same function


########## HOW TO USE THIS MODIFIER SYSTEM ##########
#This modifier type will modify a certain amount of an entity's stats repeatedly for its duration
#the example below will lower the entity's speed 20% on start
#then it will tick 50 times over 5 sec ticking down 50% of the entity speed (1% per tick)
#after ticking 50 times the entity will remain the last 2 sec with 30% of their original speed for a total of 7 sec
#
#var modifier = other_node.mod_dict.get(>mod_name<) #if has the mod it returns its path(key), else it returns null
#if modifier == null:
#	modifier = DataManager.TickingMod.instance() #if it doesn't have it, reuse this variable for managing the new mod
#	modifier.mod_type = modifier.variable_stats.SPEED
#	modifier.mod_duration = 7.0 #lasts 7 seconds
#	modifier.mod_tickrate = 0.1 #ticks 10 times per second
#	modifier.max_ticks = 50 #ticks a maximum of 50 times
#	modifier.amount = 0.0 #no flat amount is modified per second
#	modifier.percentage_amount = -0.01 #removes 1% per tick for a total of 50% of the player speed
#	modifier.starting_amount = 0.0 #no flat speed is removed on start
#	modifier.starting_percentage_amount = -0.2 #20% of the speed is lost on start
#	modifier.give_back_on_end = true #speed goes back to normal after the modifer ends
#	other_node.call_deferred("add_child", modifier)
#else:
#	get_node(modifier).refresh_modifier() #if it does already have the mod simply refresh its effect
#####################################################


func _ready():
	if get_parent().is_in_group("entity"):
		get_parent().mod_dict[mod_name] = self.get_path()
		$Tickrate.start(mod_tickrate)
		
		if starting_amount == -1:
			$DurationTimer.start(mod_duration)
			return
		
		match mod_type:
			variable_stats.HEALTH:
				original_stat = get_parent().max_health
				get_parent().health += starting_amount + original_stat * starting_percentage_amount
			variable_stats.DAMAGE:
				original_stat = get_parent().attack_damage
				get_parent().attack_damage += starting_amount + original_stat * starting_percentage_amount
			variable_stats.SPEED:
				original_stat = get_parent().speed
				get_parent().speed += starting_amount + original_stat * starting_percentage_amount
			variable_stats.ATTACK_SPEED:#WARNING: ATTACK SPEED SHOULD ALWAYS BE PERCENTAGE
				original_stat = get_parent().att_speed_mod
				get_parent().att_speed_mod += original_stat * starting_percentage_amount
			variable_stats.UNASSIGNED:
				print("UNASSIGNED TICKING MOD TYPE")
				queue_free()
		
		modified_amount += starting_amount
		modified_percentage_amount += original_stat * starting_percentage_amount
	
	$DurationTimer.start(mod_duration)


func refresh_modifier():
	$DurationTimer.start(mod_duration)

#this is used for when older modifiers run out and suddenly the percentages need to be recalculated
func update_modifier():
	if percentage_amount != 0:
		match mod_type:
			variable_stats.HEALTH:
			#this one is different, if the same was done with health it may go on the negative triggering setget death
				original_stat = get_parent().max_health
				modified_percentage_amount = original_stat * (percentage_amount * ticks)
			variable_stats.DAMAGE:
				get_parent().attack_damage -= modified_percentage_amount
				original_stat = get_parent().attack_damage
				modified_percentage_amount = original_stat * (percentage_amount * ticks)
				get_parent().attack_damage += modified_percentage_amount
			variable_stats.SPEED:
				get_parent().speed -= modified_percentage_amount
				original_stat = get_parent().speed
				modified_percentage_amount = original_stat * (percentage_amount * ticks)
				get_parent().speed += modified_percentage_amount
			variable_stats.ATTACK_SPEED:
				get_parent().attack_speed -= modified_percentage_amount
				original_stat = get_parent().attack_speed
				modified_percentage_amount = original_stat * (percentage_amount * ticks)
				get_parent().attack_speed += modified_percentage_amount


func _on_Tickrate_timeout():
	if max_ticks != 0 and ticks >= max_ticks:
		return
	ticks += 1
	
	match mod_type:
		variable_stats.HEALTH:
			get_parent().health += amount + original_stat * percentage_amount
			modified_percentage_amount += original_stat * percentage_amount
		variable_stats.DAMAGE:
			get_parent().attack_damage += amount + original_stat * percentage_amount
			modified_percentage_amount += original_stat * percentage_amount
		variable_stats.SPEED:
			get_parent().speed += amount + original_stat * percentage_amount
			modified_percentage_amount += original_stat * percentage_amount
		variable_stats.ATTACK_SPEED:
			get_parent().att_speed += amount + original_stat * percentage_amount
			modified_percentage_amount += original_stat * percentage_amount
	
	modified_amount += amount
	print("tick ", ticks, " ", get_parent().health)

func _on_DurationTimer_timeout():
	if give_back_on_end:
		match mod_type:
			variable_stats.HEALTH:
				get_parent().health -= modified_amount + modified_percentage_amount
			variable_stats.DAMAGE:
				get_parent().attack_damage -= modified_amount + modified_percentage_amount
			variable_stats.SPEED:
				get_parent().speed -= modified_amount + modified_percentage_amount
			variable_stats.ATTACK_SPEED:
				get_parent().att_speed_mod -= modified_percentage_amount
	get_parent().mod_dict.erase(mod_name)
	queue_free()
	print(get_parent().health)




