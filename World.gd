extends Node2D

func _ready():
	DataManager.reset_vars()#vars that need to be reloaded when reloading the scene will do so
