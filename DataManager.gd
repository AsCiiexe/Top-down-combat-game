extends Node

#this node should be where autoloads and node references are allocated
onready var PlayerBullet = preload("res://Instances/PlayerBullet.tscn")
onready var RangerBullet = preload("res://Instances/RangerBullet.tscn")
onready var SniperBullet = preload("res://Instances/SniperBullet.tscn")
onready var Explosion = preload("res://Instances/Explosion.tscn")
onready var Player = get_tree().get_root().get_node("World/Entities/Player")
onready var BulletsNode = get_tree().get_root().get_node("World/Bullets")
onready var CurrentCamera = get_tree().get_root().get_node("World/Camera2D") 

func reset_vars():#when the scene is reloaded this has to be reset
	Player = get_tree().get_root().get_node("World/Entities/Player")
	BulletsNode = get_tree().get_root().get_node("World/Bullets")
	CurrentCamera = get_tree().get_root().get_node("World/Camera2D")

func _unhandled_input(event):
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
