extends Node

onready var astar: = AStar.new()

func init():
	set_level_grid(0)
	pass

func _get_path(start, end):
	start = get_point_index(start)
	end = get_point_index(end)
	var new_path: = astar.get_point_path(start, end)
	return new_path

func remove_point(id, points):
	for p in points:
		astar.disconnect_points(p, id)
	astar.remove_point(id)

func reset_point(id:int, pos: Vector3, connections: PoolIntArray):
	astar.add_point(id, pos)
	for c in connections:
		astar.connect_points(id, c)
		astar.connect_points(c, id)

func block_cell(point: Vector2, disabled: bool):
	astar.set_point_disabled(get_point_index(point), disabled)

func set_cell_weight(point: Vector2, weight: int = 1):
	astar.set_point_weight_scale(get_point_index(point), weight)

func set_level_grid(num: int = 0):
	var grid: PoolVector2Array = get_parent().floor_container.get_child(num).get_used_cells()
	var obstacles = get_parent().floor_container.get_child(num).get_used_cells_by_id(3)
	for i in grid.size():
		astar.add_point(i, Vector3(grid[i].x, grid[i].y, 0))
	var dirs: PoolVector2Array = ([Vector2(-1, 0), Vector2(0, -1),
								  Vector2(1, 0), Vector2(0, 1)])
	for i in grid.size():
		for c in dirs:
			var point: = Vector3(grid[i].x+c.x, grid[i].y+c.y, 0)
			if point_in_grid(point):
				var idx: int = get_point_index(point)
				astar.connect_points(i, idx)
		var point: = Vector2(grid[i].x, grid[i].y)
		if obstacles.has(point):
			var idx: int = get_point_index(point)
			astar.set_point_weight_scale(idx, 100)
			#astar.set_point_disabled(idx, true)
		

func point_in_grid(point: Vector3):
	if point.x < 0 || point.x > global.map_size.x-1 || point.y < 0 || point.y > global.map_size.y-1:
		return false
	return true

func get_point_index(point):
	if point is Vector2:
		return astar.get_closest_point(Vector3(point.x, point.y, 0))
	return astar.get_closest_point(point)

func get_closet_point(point):
	if point is Vector2:
		return astar.get_closest_position_in_segment(Vector3(point.x, point.y, 0))
	return astar.get_closest_position_in_segment(point)