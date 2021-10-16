extends Node

#this node should be where autoloads and node references are allocated
onready var PlayerBullet = preload("res://instances/attacks&explosions/PlayerBullet.tscn")
onready var PlayerChargedBullet = preload("res://instances/attacks&explosions/PlayerChargedBullet.tscn")
onready var PlayerExplosionAbility = preload("res://instances/attacks&explosions/PlayerExplosionAbility.tscn")
onready var RangerBullet = preload("res://instances/attacks&explosions/RangerBullet.tscn")
onready var SniperBullet = preload("res://instances/attacks&explosions/SniperBullet.tscn")
onready var Explosion = preload("res://instances/attacks&explosions/Explosion.tscn")

onready var StunMod = preload("res://instances/modifiers/StunMod.tscn")
onready var HealthRegenMod = preload("res://instances/modifiers/HealthRegenMod.tscn")

onready var Player = get_tree().get_root().get_node("World/Entities/Player")
onready var BulletsNode = get_tree().get_root().get_node("World/Bullets")
onready var ObstaclesNode = get_tree().get_root().get_node("World/Obstacles")
onready var CurrentCamera = get_tree().get_root().get_node("World/Camera2D") 
onready var Interface = get_tree().get_root().get_node("World/Foreground/Interface")


func reset_addresses():#when the scene is reloaded these have to be reset
	Player = get_tree().get_root().get_node("World/Entities/Player")
	BulletsNode = get_tree().get_root().get_node("World/Bullets")
	ObstaclesNode = get_tree().get_root().get_node("World/Obstacles")
	CurrentCamera = get_tree().get_root().get_node("World/Camera2D")
	Interface = get_tree().get_root().get_node("World/Foreground/Interface")


func _unhandled_input(event):
	if event.is_action_pressed("restart"):
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
	
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

