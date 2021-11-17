extends Node2D

var mod_name = "NO_NAME_TICKING_MOD"
enum variable_stats{HEALTH, DAMAGE, SPEED, ATTACK_SPEED, UNASSIGNED}
var mod_type = variable_stats.UNASSIGNED

var mod_duration = 1.0 #how long it lasts in seconds
var mod_tickrate = 0.1 #how frequently it ticks in seconds

var max_ticks = 0 #if this is not 0 the tickrate will only tick this amount of times
var ticks = 0 #how many times has this modifier has ticked
var retick_on_refresh = false #if true, when refreshing the modifier the max_ticks will accumulate even more

var amount = 0.0 #flat amount of the stat that will be modified per tick
var percentage_amount = 0.0 #HOW MUCH of the stat % it will modify per tick (eg remove 0.1% per tick = -0.001)
var percent_toflat = 0.0 #temporary variable used for holding data during calculations
var original_stat = 0.0 #the number this stat was at before this modifier was applied

var starting_amount = 0.0 #if this is not 0, at the start this will be added/removed from the stat
var starting_percentage_amount = 0.0 #same but with a percentage of the stat

var give_back_on_end = true #if true the entity's stat gets back to its original amount when this modifier ends
var modified_amount = 0.0 #used for when give_back_on_end is true, the entity's stat amount will have this removed
var modified_percentage_amount = 0.0 #due to % being updateable this is stored in separate but has the same function


########## HOW TO USE THIS MODIFIER SYSTEM ##########
#This modifier type will modify a certain amount of an entity's stats repeatedly for its duration
#the example below will lower the entity's speed 20% on start
#then it will tick 50 times over 5 sec ticking down 50% of the entity speed (1% per tick)
#after ticking 50 times the entity will remain the last 2 sec with 30% of their original speed for a total of 7 sec
#
#var modifier = entity.mod_dict.get(>mod_name<) #if it has the mod, get path (dictionary key) else return null
#if modifier == null:
#	modifier = DataManager.TickingMod.instance() #if it doesn't have it, reuse this variable for managing the new mod
#	modifier.mod_type = modifier.variable_stats.SPEED
#	modifier.mod_name = >mod_name< #this will be the name in the mod dictionary of the entity
#	modifier.mod_duration = 7.0 #lasts 7 seconds
#	modifier.mod_tickrate = 0.1 #ticks 10 times per second
#	modifier.max_ticks = 50 #ticks a maximum of 50 times
#	modifier.amount = 0.0 #flat amount that is modified per second
#	modifier.percentage_amount = -0.01 #removes 1% per tick for a total of 50% of the player speed
#	modifier.starting_amount = 0.0 #flat speed that is removed on start
#	modifier.starting_percentage_amount = -0.2 #20% of the speed is lost on start
#	modifier.give_back_on_end = true #speed goes back to normal after the modifer ends
#	entity.add_child(modifier)
#else:
#	entity.get_node(modifier).refresh_modifier() #if it does already have the mod, refresh its effect
#####################################################


func _ready():
	if get_parent().is_in_group("entity"):
		get_parent().mod_dict[mod_name] = self.get_path()
		$Tickrate.start(mod_tickrate)
		
		if starting_amount == 0.0 and starting_percentage_amount == 0.0:
			$DurationTimer.start(mod_duration)
			return
		
		match mod_type:
			variable_stats.HEALTH:
				original_stat = get_parent().max_health #O_S instead of health it's gonna be max_health for better use
				#this check is so give_back won't harm when healing at max health
				if not get_parent().health == original_stat or amount < 0.0 or percentage_amount < 0.0:
					get_parent().health += starting_amount + original_stat * starting_percentage_amount
				
				if amount > 0 or percentage_amount > 0:
					$Sprite.texture = DataManager.HealSpr
					$Sprite.modulate = "ef3a3e"
				else:
					$Sprite.texture = DataManager.DropSpr
					$Sprite.modulate = "2c720c"
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

#this is for when the modifier is reapplied
func refresh_modifier():
	$DurationTimer.start(mod_duration)
	if retick_on_refresh:
		ticks -= max_ticks

#this is used for when older modifiers run out and suddenly the percentages need to be re-calculated
func update_modifier():
	if percentage_amount != 0.0:
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
			#this is so give_back won't harm when healing at max health
			if not get_parent().health == original_stat or amount < 0.0 or percentage_amount < 0.0:
				get_parent().health += amount + original_stat * percentage_amount
				modified_percentage_amount += original_stat * percentage_amount
				modified_amount += amount
		variable_stats.DAMAGE:
			get_parent().attack_damage += amount + original_stat * percentage_amount
			modified_percentage_amount += original_stat * percentage_amount
		variable_stats.SPEED:
			get_parent().speed += amount + original_stat * percentage_amount
			modified_percentage_amount += original_stat * percentage_amount
		variable_stats.ATTACK_SPEED:
			get_parent().att_speed += amount + original_stat * percentage_amount
			modified_percentage_amount += original_stat * percentage_amount
	
	if not mod_type == variable_stats.HEALTH: #see the match case up there to know why it's skipped
		modified_amount += amount

func _on_DurationTimer_timeout():
	if give_back_on_end:
		match mod_type:
			variable_stats.HEALTH:
				#WARNING: BE CAREFUL WITH GIVE_BACK ON HEALTH AS THE ENTITY SETGET MAY CAUSE UNINTENDED DEATHS
				#WHEN MULTIPLE MODS BUFFING AND DEBUFFING ARE STACKED AND SOME START RUNNING OUT
				get_parent().health -= modified_amount + modified_percentage_amount
			variable_stats.DAMAGE:
				get_parent().attack_damage -= modified_amount + modified_percentage_amount
			variable_stats.SPEED:
				get_parent().speed -= modified_amount + modified_percentage_amount
			variable_stats.ATTACK_SPEED:
				get_parent().att_speed_mod -= modified_percentage_amount
	get_parent().mod_dict.erase(mod_name)
	queue_free()




