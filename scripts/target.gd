extends Area3D

@export var rotation_speed: float = 2.0

func _process(delta: float) -> void:
	# Spin the target continuously around the vertical axis
	rotate_y(rotation_speed * delta)

func _on_body_entered(body: Node3D) -> void:
	# Check if the colliding body belongs to the 'player' group 
	# or explicitly matches our character class structure
	if body.is_in_group("player") or body.name == "Hunter" or body is CharacterBody3D:
		# Trigger collection cleanup tracking safely on the next idle frame
		queue_free()
