extends Node

#types: 0 - space, 1 - floor, 2 - wall
var Floor = preload("res://objects/Floor.tscn")
var Wall = preload("res://objects/Wall.tscn")
var Enemy = preload("res://objects/Enemy.tscn")

var map_size = OS.window_size
var ts = 32
var offset = Vector2(16, 16)
var zeroVector = Vector2(0, 0)

var static_map = []

var walkable = [0]

func _ready():
	pass

func init():
	generate()

func generate():
	for i in map_size.y/ts:
		var row = []
		for j in map_size.x/ts:
			var pos = Vector2(j*ts, i*ts)
			if i == 0 && j == 0:
				var tile = Floor.instance()
				tile.position = pos+offset
				global.current_scene.add_child(tile)
				global.cell = tile
				row.append(1)
				continue
			add_tile(pos+offset, 1)
			row.append(1)
		static_map.append(row)
	pass

func add_tile(pos, type):
	var tile
	if type == 1:
		tile = Floor.instance()
	elif type == 2:
		tile = Wall.instance()
		global.pathfinder_node.grid[calc_cell_index(pos)].open = false
	tile.position = pos
	tile.idx = calc_cell_index(pos)
	global.current_scene.add_child(tile)
	if type == 2:
		global.pathfinder_node.grid[calc_cell_index(pos)].wall = tile
		global.pathfinder_node.grid[calc_cell_index(pos)].cost = global.pathfinder_node.grid[calc_cell_index(pos)].wall.cost

func create_enemy(pos, cell):
	cell.open = false
	var e = Enemy.instance()
	e.tile_cell = cell
	e.position = pos
	global.current_scene.add_child(e)
	e.tile_cell.mob = e
	print("Spawn " + e.get_name())
	pass

func point_to_global(point):
	return (Vector2(point.x*ts, point.y*ts) + offset)

func calc_cell_index(pos):
	var point = global.pathfinder_node.GlobalToPoint(pos)
	return calc_point_index(point)

func calc_point_index(point):
	return (point.y*map_size.x/ts + point.x)