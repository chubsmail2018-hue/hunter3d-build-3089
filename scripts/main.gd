extends Node3D

@export var target_scene: PackedScene
@export var spawn_count: int = 15
@export var spawn_radius: float = 20.0

func _ready() -> void:
	# Initialize the random number generator seed
	randomize()
	
	# Validate if the scene reference is configured in the inspector
	if target_scene == null:
		push_error("Error: 'target_scene' is not assigned in the Main scene inspector layout.")
		return
		
	# Execute structural generation loop
	for i in range(spawn_count):
		spawn_target()

func spawn_target() -> void:
	var target_instance = target_scene.instantiate()
	
	# Generate balanced horizontal coordinate points across the terrain area
	var random_x = randf_range(-spawn_radius, spawn_radius)
	var random_z = randf_range(-spawn_radius, spawn_radius)
	
	# Set position coordinates clear of the ground plane floor boundaries
	target_instance.transform.origin = Vector3(random_x, 1.5, random_z)
	
	# Anchor the instance node directly to the active scene loop domain
	add_child(target_instance)
