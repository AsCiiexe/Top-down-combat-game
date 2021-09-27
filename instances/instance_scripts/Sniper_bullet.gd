extends Position2D

var speed = 3500
var direction = Vector2.ZERO
var lifespan = 2.25
var count = 0
var damage = 2
var deleted = false

func _ready():
	$Line2D.add_point(global_position) 
	$RayCast2D.cast_to = direction * speed * 0.0166 #the length of the raycast is the speed of the bullet

func _physics_process(delta):
	if deleted:
		if $Line2D.get_point_count() != 0:
			$Line2D.remove_point(0)
			return
		else:
			queue_free()
			#this is done this way so the line doesn't instantly disappear when the bullet collides
			#it would probably be MUCH better to use a shader, but I don't know how to use shaders
	
	if $RayCast2D.is_colliding():
		colliding()
		return#return so the position is not updated later
	
	position += direction * speed * delta
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
		deleted = true
		$Sprite.visible = false
	elif $RayCast2D.get_collider().is_in_group("obstacle"):
		deleted = true
		$Sprite.visible = false
