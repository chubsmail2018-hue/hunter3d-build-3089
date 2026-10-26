extends Node

@export var canvas_texture_size: int = 512
@export var paint_brush_radius: int = 4
@export var paint_color: Color = Color(0.8, 0.1, 0.1, 1.0) # Default dark red paint

var dynamic_image: Image
var dynamic_texture: ImageTexture
var material_override: StandardMaterial3D

func _ready() -> void:
	# 1. Initialize a blank, high-performance image canvas in memory
	dynamic_image = Image.create(canvas_texture_size, canvas_texture_size, false, Image.FORMAT_RGBA8)
	dynamic_image.fill(Color(1.0, 1.0, 1.0, 0.0)) # Transparent background initial canvas
	
	# 2. Wrap the pixel layer into an engine texture wrapper
	dynamic_texture = ImageTexture.create_from_image(dynamic_image)
	
	# 3. Form a programmatic material to overlay onto your 3D target models
	material_override = StandardMaterial3D.new()
	material_override.albedo_texture = dynamic_texture
	material_override.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	material_override.roughness = 0.9

## Call this function from your hunter weapon raycast to draw on an object at runtime
func paint_at_uv(uv_coordinates: Vector2) -> void:
	if uv_coordinates == null:
		return
		
	# Map relative 0.0-1.0 coordinate spaces directly to integer pixel points
	var pixel_x: int = int(uv_coordinates.x * canvas_texture_size)
	var pixel_y: int = int(uv_coordinates.y * canvas_texture_size)
	
	# Safety bounding check to prevent writing memory outside the canvas dimensions
	if pixel_x < 0 or pixel_x >= canvas_texture_size or pixel_y < 0 or pixel_y >= canvas_texture_size:
		return
		
	# Draw a pixel cluster brush radius circle on the memory texture map
	for local_x in range(-paint_brush_radius, paint_brush_radius):
		for local_y in range(-paint_brush_radius, paint_brush_radius):
			# Use Pythagorean theorem formula to guarantee a smooth circular brush shape
			if (local_x * local_x) + (local_y * local_y) <= (paint_brush_radius * paint_brush_radius):
				var target_x: int = pixel_x + local_x
				var target_y: int = pixel_y + local_y
				
				# Ensure individual brush fragments do not clip off the image borders
				if target_x >= 0 and target_x < canvas_texture_size and target_y >= 0 and target_y < canvas_texture_size:
					dynamic_image.set_pixel(target_x, target_y, paint_color)
					
	# 4. Push the freshly altered pixel changes directly to your active GPU video memory
	dynamic_texture.update(dynamic_image)

## Helper utility to quickly attach this dynamic painting material to any 3D node model
func apply_to_mesh(mesh_instance: MeshInstance3D) -> void:
	if mesh_instance != null:
		mesh_instance.material_override = material_override
