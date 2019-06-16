extends Node

###      ### Grass TileSet ###      ###
###  0 - Grass, 1 - Blocked grass, 2 - Earth, 3 - Blocked earth
onready var floor_node: = get_parent().get_node("Floor")
onready var walls_node: = get_parent().get_node("Walls")

func _ready():
	pass

func init():
	generate_map()

func generate_map():
	gen_level(0)
	pass

func gen_level(level):
	var floor_map: = floor_node.get_child(level)
	var walls_map: = walls_node.get_child(level)
	var noise: = OpenSimplexNoise.new()
	var sprite: = Sprite.new()
	var size: Vector2 = global.map_size
	var ts: int = global.tile_size
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 10.0
	#noise.lacunarity = 1.5
	noise.persistence = 0.4
	var img: = noise.get_image(size.x, size.y)
	#img.create(OS.window_size.x, OS.window_size.y, false, Image.FORMAT_RGBA8)
	img.lock()
	for y in size.y:
		for x in size.x:
			#if funcs.bool_rand():
				#var color = noise.get_noise_2d(float(y), float(x))
				#img.set_pixel(x, y, Color(color, color, color, 1))
			if img.get_pixel(x, y).r > 0.60:
				if img.get_pixel(x, y).r > 0.65:
					walls_map.set_cell(x, y, 0)
					floor_map.set_cell(x, y, 3)
					continue
				floor_map.set_cell(x, y, 2)
			else:
				floor_map.set_cell(x, y, 0)
	img.unlock()
	
	#funcs.update_texture(sprite, img)
	#sprite.position += sprite.texture.get_size()/2
	#global.current_scene.add_child(sprite)


