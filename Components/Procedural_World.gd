extends TileMap
@onready var noise_image: Sprite2D = $Camera2D/CanvasLayer/Noise_Image

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var my_noise : FastNoiseLite

var floor_normal : Vector2i = Vector2i(0,0)
var floor_grass : Vector2i = Vector2i(5,4)
var floor_grass_short : Vector2i = Vector2i(8,0)
var black : Vector2i = Vector2i(0,9)
var wall : Vector2i = Vector2i(0,3)
var walls : Dictionary = {
	"down" : Vector2i(0, 3),
	"up" : Vector2i(4, 12),
	"left" : Vector2i(4,10),
	"right" : Vector2i(3,9),
	"left_up" : Vector2i(6, 12),
	"right_up" : Vector2i(5, 12),
}
var noise_point_value : float
var array : Array[float] = []
var follow : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if follow: camera_follow_cursor()
	pass


func create_noise_image() -> FastNoiseLite:
	var noise_texture : NoiseTexture2D = NoiseTexture2D.new()
	var noise : FastNoiseLite = FastNoiseLite.new()
	var number = rng.randi()
	print(number)
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	#noise.seed = number
	noise.seed = 2805919156
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_lacunarity = 1
	noise.fractal_octaves = 5
	noise.fractal_gain = 0.005
	noise.frequency = 0.05
	noise_texture.noise = noise
	noise_texture.width = 128
	noise_texture.height = 128
	noise_image.texture = noise_texture
	return noise
	


func _on_create_pressed() -> void:
	create_procedural_map()
pass


func create_procedural_map() -> void:
	my_noise = create_noise_image()
	var cell_selected : Vector2i
	var tile_point_position : Vector2i
	for i in range(0,255):
		for j in range(0,255):
			tile_point_position = Vector2i(i, j)
			noise_point_value = my_noise.get_noise_2d(i,j)
			cell_selected = select_cell_by_noise(noise_point_value)
			if cell_selected == wall:
				cell_selected = check_surrounding_cells(tile_point_position)
			set_my_cell(tile_point_position, cell_selected)
	pass


func camera_follow_cursor() -> void:
	$Camera2D.position = get_global_mouse_position()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("click_der"):
		if follow:
			follow = false
		else:
			follow = true
	elif Input.is_action_just_pressed("click_izq"):
		get_cell_in_mouse_position()

func get_cell_in_mouse_position() -> void:
	print(local_to_map(get_local_mouse_position()))
	print(get_cell_atlas_coords(0, local_to_map(get_local_mouse_position()), false))


func select_cell_by_noise(noise_position : float) -> Vector2i:
	var cell_selected : Vector2i = Vector2i.ZERO
	
	if noise_position >= 0.3:
		# Paredes
		cell_selected = wall
	
	elif noise_position < 0.3 and noise_position >= 0.2:
		cell_selected = floor_grass
	
	elif noise_position < 0.2 and noise_position >= 0.15:
		cell_selected = floor_grass_short
	
	elif noise_position < 0.15 and noise_position >= -0.8:
		cell_selected = floor_normal
	
	else:
		cell_selected = black
	
	return cell_selected


func check_surrounding_cells(cell_position : Vector2i) -> Vector2i:
	var tile : Vector2i = Vector2i.ZERO
	
	var up : Vector2i = Vector2i(cell_position.x, cell_position.y - 1)
	var down : Vector2i = Vector2i(cell_position.x, cell_position.y + 1)
	var left : Vector2i = Vector2i(cell_position.x - 1, cell_position.y)
	var right : Vector2i = Vector2i(cell_position.x + 1, cell_position.y)
	var up_left : Vector2i = Vector2i(cell_position.x - 1, cell_position.y - 1)
	var up_right : Vector2i = Vector2i(cell_position.x + 1, cell_position.y - 1)
	var down_left : Vector2i = Vector2i(cell_position.x - 1, cell_position.y + 1)
	var down_right : Vector2i = Vector2i(cell_position.x + 1, cell_position.y + 1)
	
	var noise_up : float = my_noise.get_noise_2d(up.x, up.y)
	var noise_down : float = my_noise.get_noise_2d(down.x, down.y)
	var noise_left : float = my_noise.get_noise_2d(left.x, left.y)
	var noise_right : float = my_noise.get_noise_2d(right.x, right.y)
	var noise_down_left : float = my_noise.get_noise_2d(down_left.x, down_left.y)
	var noise_down_right : float = my_noise.get_noise_2d(down_right.x, down_right.y)
	var noise_down_is_wall : bool = false
	if select_cell_by_noise(noise_down) == wall:
		noise_down_is_wall = true
	
	var noise_up_is_wall : bool = false
	if select_cell_by_noise(noise_up) == wall:
		noise_up_is_wall = true
	
	var noise_left_is_wall : bool = false
	if select_cell_by_noise(noise_left) == wall:
		noise_left_is_wall = true
	
	var noise_right_is_wall : bool = false
	if select_cell_by_noise(noise_right) == wall:
		noise_right_is_wall = true
	
	
	if get_cell_atlas_coords(0, up) == Vector2i(-1, -1):
		tile = walls["down"]
	
	elif (get_cell_atlas_coords(0, up) != wall
		  and get_cell_atlas_coords(0, up) != walls["up"]
		  and get_cell_atlas_coords(0, up) == black
		):
		tile = walls["up"]
	
	pass
	return tile


func set_my_cell(position : Vector2i, cell_selected : Vector2i) -> void:
	set_cell(0,position,0, cell_selected,0) 
	pass
