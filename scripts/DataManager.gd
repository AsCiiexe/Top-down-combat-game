extends Node

#this node should be where autoloads and node references are allocated
onready var PlayerBullet = preload("res://instances/attacks&explosions/player/PlayerBullet.tscn")
onready var PlayerChargedBullet = preload("res://instances/attacks&explosions/player/PlayerChargedBullet.tscn")
onready var PlayerExplosionAbility = preload("res://instances/attacks&explosions/player/PlayerExplosionAbility.tscn")
onready var PlayerBlastAbility = preload("res://instances/attacks&explosions/player/PlayerBlastAbility.tscn")
onready var PlayerStrikeBarrageAbility = preload("res://instances/attacks&explosions/player/PlayerStrikeBarrage.tscn")

onready var RangerBullet = preload("res://instances/attacks&explosions/RangerBullet.tscn")
onready var SniperBullet = preload("res://instances/attacks&explosions/SniperBullet.tscn")
onready var Explosion = preload("res://instances/attacks&explosions/Explosion.tscn")

onready var BoolMod = preload("res://instances/modifiers/BoolMod.tscn")
onready var SimpleMod = preload("res://instances/modifiers/SimpleMod.tscn")
onready var TickingMod = preload("res://instances/modifiers/TickingMod.tscn")

onready var HealSpr = preload("res://sprites/modifier_icons/healing.png")
onready var DropSpr = preload("res://sprites/modifier_icons/drop.png")
onready var SwirlSpr = preload("res://sprites/modifier_icons/stun.png")
onready var ChainSpr = preload("res://sprites/modifier_icons/root.png")
onready var HasteSpr = preload("res://sprites/modifier_icons/haste.png")
onready var SlowSpr = preload("res://sprites/modifier_icons/slow.png")

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

