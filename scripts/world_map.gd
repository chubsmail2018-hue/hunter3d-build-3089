extends Node3D

@export var zombie_scene: PackedScene
func _ready() -> void:
randomize()
for i in range(10):
var z = zombie_scene.instantiate()
z.transform.origin = Vector3(randf_range(-30, 30), 2.0, randf_range(-30, 30))
add_child(z)
