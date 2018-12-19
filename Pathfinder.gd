extends Node

onready var map = global.map_node

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

func FindPath(start, end, enemy = null):
	if start == end:
		return []
	
	var openSet = []
	var closedSet = []
	
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
		
		for nc in GetNeighbours(currentCell, end, enemy):
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
	return null

func GetCost(point):
	return grid[global.map_node.calc_point_index(point)].cost

func GetHeuristicPathLength(pos1, pos2):
	return (abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y))

func GetNeighbours(cell, end, target = null):
	var neighbors = []
	var points = PoolVector2Array([cell.pos + Vector2(-1, 0), cell.pos + Vector2(1, 0),
								cell.pos + Vector2(0, -1), cell.pos + Vector2(0, 1),
								cell.pos + Vector2(-1, -1), cell.pos + Vector2(1, -1),
								cell.pos + Vector2(-1, 1), cell.pos + Vector2(1, 1) ])
	for point in points:
		var x = point.x
		var y = point.y
		if map.calc_point_index(point) > grid.size()-1:
			continue
		var tile = grid[map.calc_point_index(point)]
		if (x < 0 || x > global.map_node.map_size.x/global.map_node.ts - 1) || (y < 0 || y > global.map_node.map_size.y/global.map_node.ts - 1):
			continue
		if (target == global.cell && tile != global.cell) && !tile.open:
			continue
		if target != global.cell && tile != target.tile_cell && !tile.open:
			continue
		var nc = Cell.new()
		nc.init(point, cell.g + GetCost(point), GetHeuristicPathLength(point, GlobalToPoint(end)), cell)
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
