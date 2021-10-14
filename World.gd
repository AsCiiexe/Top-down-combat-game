extends Node2D

var camera = DataManager.CurrentCamera
var player = DataManager.Player

var mouse = Vector2.ZERO
var camera_distance = 0 #length of the camera distance
var max_camera_distance = Vector2.ZERO #area limits for the camera distance
var camera_position = Vector2.ZERO

func _ready():
	DataManager.reset_addresses()#addresses that need to be reloaded when reloading the scene will do so

func _physics_process(delta):
	player = DataManager.Player
	camera = DataManager.CurrentCamera
	
	if player != null:
		max_camera_distance = get_viewport_rect().size / 2.5
		camera_position = player.get_local_mouse_position() / 2.25
		camera_position.x = clamp(camera_position.x, -max_camera_distance.x, max_camera_distance.x)
		camera_position.y = clamp(camera_position.y, -max_camera_distance.y, max_camera_distance.y)
		camera_position = player.to_global(camera_position)
		camera.position = lerp(camera.position, camera_position, 0.10)
