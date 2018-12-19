extends Node

onready var current_scene = get_node("/root/World")
onready var map_node = current_scene.get_node("Map")
onready var pathfinder_node = current_scene.get_node("Pathfinder")
onready var player = current_scene.get_node("Player")

var cell = null
var locked = false

var flag = false

var closedCells = []
var enemies_paths = []

func _ready():
	current_scene.init()
	map_node.init()

func UnlockEnemies():
	for e in get_tree().get_nodes_in_group("enemy"):
		#e.timer.start()
		e.target = cell
		#closedCells.clear()
		#e.life = true
		#e.cell = e.cell
		#e.ChangeState(e.IDLE)

func CheckPath(enemy):
	for e in get_tree().get_nodes_in_group("enemy"):
		if enemy == e:
			continue
		if enemy.path == null || e.path == null:
			continue
		if enemy.path.front() == e.path.front():
			return false
	return true

func CheckBlocked(obj, flag = false):
	var pos 
	if typeof(obj) != TYPE_VECTOR2:
		pos = pathfinder_node.GlobalToPoint(obj.position)
	else:
		pos = obj
	var points = PoolVector2Array([pos + Vector2(-1, 0), pos + Vector2(1, 0),
								pos + Vector2(0, -1), pos + Vector2(0, 1),
								pos + Vector2(-1, -1), pos + Vector2(1, -1),
								pos + Vector2(-1, 1), pos + Vector2(1, 1) ])
	var count = 0
	var mas = []
	for point in points:
		var x = point.x
		var y = point.y
		if (x < 0 || x > map_node.map_size.x/global.map_node.ts - 1) || (y < 0 || y > map_node.map_size.y/global.map_node.ts - 1):
			count += 1
			continue
		if map_node.calc_point_index(point) > pathfinder_node.grid.size()-1:
			count += 1
			continue
		if (!pathfinder_node.grid[map_node.calc_point_index(point)].open && pathfinder_node.grid[map_node.calc_point_index(point)].wall == null) && pathfinder_node.grid[map_node.calc_point_index(point)] != cell:
			count += 1
			continue
		if pathfinder_node.grid[map_node.calc_point_index(point)] == cell:
			count += 1
			continue
		if closedCells.has(point):
			count += 1
			continue
		if flag:
			mas.append(point)
	if flag:
		return mas
	elif count == points.size():
		return true
	return false



