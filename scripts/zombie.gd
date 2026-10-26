extends CharacterBody3D

@export var speed: float = 3.5
@export var health: float = 60.0
@export var coin_reward: int = 5

var player: CharacterBody3D = null
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
var nodes = get_tree().get_nodes_in_group("player")
if nodes.size() > 0:
player = nodes[0]

func _physics_process(delta: float) -> void:
if not is_on_floor():
velocity.y -= gravity * delta

if player:
var target_pos = player.global_transform.origin
var dir = (target_pos - global_transform.origin).normalized()
velocity.x = dir.x * speed
velocity.z = dir.z * speed
look_at(Vector3(target_pos.x, global_transform.origin.y, target_pos.z), Vector3.UP)

move_and_slide()

func take_damage(amount: float) -> void:
health -= amount
print("Zombie hit! Remaining HP: ", health)
if health <= 0:
if player and player.has_method("add_coins"):
player.add_coins(coin_reward)
queue_free()
