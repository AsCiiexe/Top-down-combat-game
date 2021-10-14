extends KinematicBody2D

var acceleration = 100
var acceleration_mods = 0
var max_speed = 100
var speed_mods = 0
var movement = Vector2.ZERO
var friction = 0.85
var max_health = 10
var health = max_health setget set_health

func set_health(value):
	health = value
	$HealthbarControl.on_health_updated(health)
	if health <= 0:
		queue_free()
