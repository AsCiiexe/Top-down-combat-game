extends Control

onready var dash_cd_bar = $Skillbar/Dash/TextureProgress
onready var ability1_cd_bar = $Skillbar/Ability1/TextureProgress
onready var ability2_cd_bar = $Skillbar/Ability2/TextureProgress
onready var ability3_cd_bar = $Skillbar/Ability3/TextureProgress
onready var ability4_cd_bar = $Skillbar/Ability4/TextureProgress

onready var item1_spr = $Inventory/Item1/TextureRect
onready var item2_spr = $Inventory/Item2/TextureRect
onready var item3_spr = $Inventory/Item3/TextureRect
onready var item4_spr = $Inventory/Item4/TextureRect


func _ready():
	DataManager.reset_addresses()
	dash_cd_bar.max_value = DataManager.Player.dash_cooldown
	ability1_cd_bar.max_value = DataManager.Player.a1_cooldown
	ability2_cd_bar.max_value = DataManager.Player.a2_cooldown
	ability3_cd_bar.max_value = DataManager.Player.a3_cooldown
	ability4_cd_bar.max_value = DataManager.Player.a4_cooldown


func _physics_process(delta):
	dash_cd_bar.value -= delta
	ability1_cd_bar.value -= delta
	ability2_cd_bar.value -= delta
	ability3_cd_bar.value -= delta
	ability4_cd_bar.value -= delta


func set_ability_on_cooldown(ability, cooldown):
	if ability == -1: #dash
		dash_cd_bar.max_value = cooldown
		dash_cd_bar.value = cooldown
	elif ability == 1: #charged shot
		ability1_cd_bar.max_value = cooldown
		ability1_cd_bar.value = cooldown
	elif ability == 2: #remote explosion
		ability2_cd_bar.max_value = cooldown
		ability2_cd_bar.value = cooldown
	elif ability == 3: #remote explosion
		ability3_cd_bar.max_value = cooldown
		ability3_cd_bar.value = cooldown
	elif ability == 4: #strike barrage
		ability4_cd_bar.max_value = cooldown
		ability4_cd_bar.value = cooldown

#temporary variable
#automatically adds an item to lowest empty spot, if they are all full the first one is replaced
func add_item(item):
	if item1_spr.texture == null:
		item1_spr.texture = item
	elif item2_spr.texture == null:
		item2_spr.texture = item
	elif item3_spr.texture == null:
		item3_spr.texture = item
	elif item4_spr.texture == null:
		item4_spr.texture = item
	else:
		print("MAXIMUM ITEM SLOTS")


func set_item(slot, item):
	pass



