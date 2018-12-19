extends Sprite

var map = global.map_node
var nav2d = global.pathfinder_node

var _offset = Vector2(16, 16)

var life = false

var target = global.cell
var target_position = Vector2()
var path = []
var oldpath = path
var tile_cell = null

var locked = false

var step = 1
var dir = 0
var dir_vec = Vector2(0, -1)
var oldpos = self.position
var stop_dist = 48
var closePoint = nav2d.GlobalToPoint(oldpos)

var move_coldown_time = 0.2
var move_coldown = true
var push_coldown_time = 0.4
var push_coldown = true

var state = null
enum STATES { IDLE, FOLLOW, ATTACK }

func _ready():
	init()
	pass

func init():
	target_position = global.player.position
	z_index = 10
	#timer.set_wait_time(move_coldown_time)
	life = true
	ChangeState(IDLE)

func _physics_process(delta):
	if life:
		AI(delta)
	pass

func AI(delta):
	if move_coldown && state == FOLLOW:
		MoveToTarget()
	elif state == ATTACK:
		pass
	elif state == IDLE && position.distance_to(target.position) > stop_dist:
		if global.CheckBlocked(target):
			var current = self
			var dist = current.position.distance_to(global.player.position)
			for e in get_tree().get_nodes_in_group("enemy"):
				if !global.CheckBlocked(e) && e.position.distance_to(global.player.position) < dist:
					current = e
					dist = current.position.distance_to(global.player.position)
			GetPosCell(current.position).get_node("Sprite").modulate.r8 = 155
			target = current
		path = nav2d.FindPath(position, target.position, target)
		if path == null:
			return
		ChangeState(FOLLOW)
		

func MoveToTarget():
	MoveColdown()
	if path.has(nav2d.GlobalToPoint(position)):
		path.erase(nav2d.GlobalToPoint(position))
	if CheckEnd(): return
	var body = Collide()
	if body != null:
		PushEnemy(body)
	position = map.point_to_global(path.front())
	LockCell(GetPosCell(position))
	path.pop_front()

func ChangeState(new_state):
	state = new_state 

func MoveColdown():
	if !move_coldown:
		move_coldown = true
	else:
		move_coldown = false
		timers.add_timer(str(get_name() + "move_coldown"), move_coldown_time, self, "MoveColdown")

func PushColdown():
	if !push_coldown:
		push_coldown = true
	else:
		push_coldown = false
		timers.add_timer(str(get_name() + "push_coldown"), push_coldown_time, self, "PushColdown")

func CheckEnd():
	if path.empty() || len(path) <= 1:
		ChangeState(IDLE)
		return true
	return false

func Collide():
	for e in get_tree().get_nodes_in_group("enemy"):
		if e != self && path.front() == nav2d.GlobalToPoint(e.position):
			return e
	return null

func PushEnemy(enemy):
	PushColdown()
	if move_coldown:
		MoveColdown()
	var point = nav2d.GlobalToPoint(position)
	var next_point = path[0]
	print(2)
	print(next_point + next_point - point)
	if GetPointCell(next_point + next_point - point).mob == null:#GetPointCell(path[0]).mob != global.player && 
		enemy.position = map.point_to_global(next_point + next_point - point)
		enemy.LockCell(enemy.position, enemy)
		#enemy.path.clear()
		#path.clear()
		

func DestroyWall():
	if target.wall != null:
		target.wall.queue_free()
		target.wall = null
		target.open = true
		target = null
	ChangeState(FOLLOW)
	pass

func LockCell(pos, enemy = self):
	enemy.tile_cell.open = true
	GetPosCell(position).open = false
	enemy.tile_cell.mob = null
	GetPosCell(position).mob = self
	enemy.tile_cell.cost -= 1
	GetPosCell(position).cost += 1
	enemy.tile_cell = GetPosCell(position)


func GetPointCell(point):
	return global.pathfinder_node.grid[global.map_node.calc_point_index(point)]

func GetPosCell(pos):
	var point = global.pathfinder_node.GlobalToPoint(pos)
	return global.pathfinder_node.grid[global.map_node.calc_point_index(point)]

