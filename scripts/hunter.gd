extends CharacterBody3D

@export var speed: float = 7.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003

var coins: int = 0
enum Weapon { SWORD, GUN }
var current_weapon: Weapon = Weapon.SWORD

var sword_damage: float = 25.0
var sword_level: int = 1
var gun_damage: float = 15.0
var gun_level: int = 1

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# CORRECTED: Fully closed string nodes with zero missing parentheses
@onready var camera: Camera3D = get_node("Camera3D")
@onready var raycast: RayCast3D = get_node("Camera3D/RayCast3D")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_weapon_1"):
		current_weapon = Weapon.SWORD
		print("Equipped: Sword")
	elif Input.is_action_just_pressed("ui_weapon_2"):
		current_weapon = Weapon.GUN
		print("Equipped: Gun")

	if Input.is_action_just_pressed("ui_attack"):
		execute_attack()

	if Input.is_action_just_pressed("ui_shop"):
		toggle_shop_cheat()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func execute_attack() -> void:
	if current_weapon == Weapon.GUN:
		print("Firing Weapon (Gun)...")
		if raycast.is_colliding():
			var enemy = raycast.get_collider()
			if enemy.has_method("take_damage"):
				enemy.take_damage(gun_damage)
	elif current_weapon == Weapon.SWORD:
		print("Swinging Weapon (Sword)...")
		if raycast.is_colliding() and raycast.get_distance() < 3.5:
			var enemy = raycast.get_collider()
			if enemy.has_method("take_damage"):
				enemy.take_damage(sword_damage)

func add_coins(amount: int) -> void:
	coins += amount
	print("Coins Harvested: ", coins)

func toggle_shop_cheat() -> void:
	var cost = sword_level * 10
	if coins >= cost:
		coins -= cost
		sword_level += 1
		sword_damage += 15.0
		gun_level += 1
		gun_damage += 10.0
		print("Upgraded Weapons! Current Gold: ", coins)
	else:
		print("Insufficient coins. Need: ", cost)
