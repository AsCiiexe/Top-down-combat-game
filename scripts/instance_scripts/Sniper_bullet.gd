extends Position2D

var speed = 2800
var direction = Vector2.ZERO
var lifespan = 2.25
var count = 0
var damage = 50.0
var deleted = false

func _ready():
	$Line2D.add_point(global_position) 

func _physics_process(delta):
	var movement = direction * speed * delta
	
	if deleted:
		if $Line2D.get_point_count() != 0:
			$Line2D.remove_point(0)
			return
		else:
			queue_free()
			#this is done this way so the line doesn't instantly disappear when the bullet collides
			#it would probably be MUCH better to use a shader, but I don't know how to use shaders
	
	$RayCast2D.cast_to = movement
	if $RayCast2D.is_colliding():
		colliding()
		return#return so the position is not updated later
	
	position += movement
	count += delta
	if count > lifespan:
		deleted = true
		$Sprite.visible = false
	
	$Line2D.global_position = Vector2(0, 0)
	$Line2D.add_point(global_position)
	while($Line2D.get_point_count() > 24):
		$Line2D.remove_point(0)


func colliding():
	if deleted:
		return
	
	global_position = $RayCast2D.get_collision_point()
	$Line2D.add_point(global_position)
	
	if $RayCast2D.get_collider().owner.is_in_group("player"):
		$RayCast2D.get_collider().owner.health -= damage
		$Sprite.visible = false
		deleted = true
	elif $RayCast2D.get_collider().is_in_group("obstacle"):
		$Sprite.visible = false
		deleted = true
