extends Control

onready var healthbarOver = $HealthbarOver
onready var healthbarUnder = $HealthbarUnder
onready var updateTween = $UpdateTween
export(Color) var bar_color = Color.white
export(Color) var bar_critical_color = Color.darkgray
func _ready():
	healthbarOver.max_value = get_parent().max_health
	healthbarUnder.max_value = get_parent().max_health
	healthbarOver.modulate = bar_color

#healthbar over loses the health instantly
#healthbar under, colored red, loses it with a tween
#this is to add a cool effect while also still letting the player know their current health
func on_health_updated(health):
	healthbarOver.value = health
	
	if not updateTween.is_active():
		updateTween.interpolate_property(healthbarUnder, "value", healthbarUnder.value, health,
			0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.15)
		updateTween.start()
	else:
		updateTween.stop(healthbarUnder, "value")
		updateTween.interpolate_property(healthbarUnder, "value", healthbarUnder.value, health,
			0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.15)
		updateTween.start()

func on_max_health_updated(max_health):
	healthbarOver.max_value = max_health
	healthbarUnder.max_value = max_health
