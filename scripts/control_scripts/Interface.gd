extends Control

onready var dash_cd_bar = $ColorRect/Dash/TextureProgress
onready var ability1_cd_bar = $ColorRect/Ability1/TextureProgress
onready var ability2_cd_bar = $ColorRect/Ability2/TextureProgress

func _ready():
	DataManager.reset_addresses()
	dash_cd_bar.max_value = DataManager.Player.dash_cooldown
	ability1_cd_bar.max_value = DataManager.Player.a1_cooldown
	ability2_cd_bar.max_value = DataManager.Player.a2_cooldown

func _physics_process(delta):
	dash_cd_bar.value -= delta
	ability1_cd_bar.value -= delta
	ability2_cd_bar.value -= delta


func set_ability_on_cooldown(ability, cooldown):
	if ability == -1: #dash
		dash_cd_bar.max_value = cooldown
		dash_cd_bar.value = cooldown
	elif ability == 1: #charged shot
		ability1_cd_bar.max_value = cooldown
		ability1_cd_bar.value = cooldown
	elif ability == 2: #ground explosion
		ability2_cd_bar.max_value = cooldown
		ability2_cd_bar.value = cooldown
