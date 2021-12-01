extends Node2D

var harm_reduction = -0.3
var pickup_distance = 40.0
var in_inventory = false

func _physics_process(delta):
	if not in_inventory and global_position.distance_to(DataManager.Player.global_position) < pickup_distance:
		#draw "press c to pick up" and display item name
		if Input.is_action_just_pressed("interact"):
			DataManager.Player.add_child(self)
			DataManager.Player.wounding_modifier += harm_reduction
			DataManager.Interface.add_item(DataManager.BlueShieldSpr)
			visible = false
			
			in_inventory = true
