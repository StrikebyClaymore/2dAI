extends Node

class Cell:
	var pos = Vector2(0, 0)
	var g = 0
	var h = 0
	var f = g + h
	var cameFrom
	func init(pos, g, h, c):
		self.pos = pos
		self.g = g
		self.h = h
		self.cameFrom = c
		self.f = g + h

onready var grid = get_tree().get_nodes_in_group("floor")
var obstacle_types = [0, 2]
var locked = []

func _ready():
	pass

func FindPath(start, end, enemy):
	if start == end:
		return []
	
	var openSet = []
	var closedSet = []
	
	var closeCells = []
	
	var startCell = Cell.new()
	startCell.init(GlobalToPoint(start), 0, GetHeuristicPathLength(GlobalToPoint(start), GlobalToPoint(end)), null)
	openSet.append(startCell)
	
	while !openSet.empty():
		var currentCell = openSet[0]
		
		for c in openSet:
			if c.f < currentCell.f:
				currentCell = c
		if currentCell.pos == GlobalToPoint(end):
			return GetPathForCell(currentCell)
		
		openSet.erase(currentCell)
		closedSet.append(currentCell)
		
		for nc in GetNeighbours(currentCell, end, enemy, closeCells):
			var count = 0
			for c in closedSet:
				if c.pos == nc.pos:
					count += 1
			if count > 0:
				continue
			var openCell
			for c in openSet:
				if c.pos == nc.pos:
					openCell = nc
					break
			if openCell == null:
				openSet.append(nc)
			elif openCell.g > nc.g:
				openCell.cameFrom = nc.cameFrom
				openCell.g == nc.g
	
	var current = closedSet[0]
	
	for c in closedSet:
		if global.map_node.point_to_global(c.pos).distance_to(end) < global.map_node.point_to_global(current.pos).distance_to(end):
			current = c
			pass
	#grid[global.map_node.calc_point_index(current.pos)].get_node("Sprite").modulate.r8 = 155
	#enemy.target_position = global.map_node.point_to_global(current.pos)
	var path = FindPath(start, global.map_node.point_to_global(current.pos), enemy)
	if !path.empty():
		path.append(path.front())
	return path

func FindLockedPath(start, end, enemy):
	print(enemy.get_name())
	GetCell(start).get_node("Sprite").modulate.r8 = 155
	pass

func PathForObstacles(enemy):
	var dists_to_target = []
	var dists_to_enemy = []
	var current = null
	if !locked.empty():
		current = locked[0]
	for c in locked:
		dists_to_target.append(c.position.distance_to(enemy.target_position))
		dists_to_enemy.append(c.position.distance_to(enemy.position))
	var c_idx = 0
	var c_dist = dists_to_target[0] + dists_to_enemy[0]
	for i in range(1, locked.size()-1):
		if dists_to_target[i] + dists_to_enemy[i] < c_dist:
			c_idx = i 
			#c_dist = dists_to_target[i] + dists_to_enemy[i]
	locked[c_idx].open = true
	grid[global.map_node.calc_point_index(GlobalToPoint(locked[c_idx].position))].open = true
	return FindPath(enemy.position, locked[c_idx].position, enemy, true)

func GetCost():
	return 1

func GetHeuristicPathLength(pos1, pos2):
	return (abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y))

func GetNeighbours(cell, end, enemy, closeCells):
	var neighbors = []
	var points = PoolVector2Array([cell.pos + Vector2(-1, 0), cell.pos + Vector2(1, 0),
								cell.pos + Vector2(0, -1), cell.pos + Vector2(0, 1),
								cell.pos + Vector2(-1, -1), cell.pos + Vector2(1, -1),
								cell.pos + Vector2(-1, 1), cell.pos + Vector2(1, 1) ])
	for point in points:
		var x = point.x
		var y = point.y
		if (x < 0 || x > global.map_node.map_size.x/global.map_node.ts - 1) || (y < 0 || y > global.map_node.map_size.y/global.map_node.ts - 1):
			continue
		if global.map_node.calc_point_index(point) > grid.size():
			continue
		if !grid[global.map_node.calc_point_index(point)].open && grid[global.map_node.calc_point_index(point)] != global.cell:
			closeCells.append(grid[global.map_node.calc_point_index(point)])
			continue
		#for e in get_tree().get_nodes_in_group("enemy"):
		#	if enemy == e || point == GlobalToPoint(e.position):
		#		continue
		#	if e.path != null && !e.path.empty():
		#		for c in e.path:
		#			if c == point:
		#				continue	
		var nc = Cell.new()
		nc.init(point, cell.g + GetCost(), GetHeuristicPathLength(point, GlobalToPoint(end)), cell)
		neighbors.append(nc)
	return neighbors

func GetPathForCell(cell):
	var path = []
	var currentCell = cell
	while currentCell != null:
		path.append(currentCell.pos)
		currentCell = currentCell.cameFrom
	var j = path.size()-1
	for i in path.size():
		if i == j || i > j:
			break
		var tmp = path[i]
		path[i] = path[j]
		path[j] = tmp
		j -= 1
	return path

func GlobalToPoint(pos):
	var point = Vector2(floor(pos.x/global.map_node.ts), floor(pos.y/global.map_node.ts))
	return point

func IndexToPoint(index):
	var x = int(index)%int(global.map_node.map_size.x/global.map_node.ts)
	var y = floor(index/(global.map_node.map_size.x/global.map_node.ts))
	var point = Vector2(int(x), int(y))
	return point

func sortPointsMas(mas):
	for i in mas.size():
		mas.insert(i, global.map_node.calc_point_index(mas[i]))
		mas.remove(i+1)
	mas.sort()
	for i in mas.size():
		mas.insert(i, IndexToPoint(mas[i]))
		mas.remove(i+1)

func SwapVectorMas(mas):
	for i in mas.size():
		var vec = SwapVector(mas[i])
		mas.insert(i, vec)
		mas.remove(i+1)

func SwapVector(v):
	var vec = Vector2(v.y, v.x)
	return vec

func GetCell(pos):
	return grid[global.map_node.calc_point_index(GlobalToPoint(pos))]
