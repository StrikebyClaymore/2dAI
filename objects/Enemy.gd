extends Sprite

onready var timer = get_node("Timer")

var _offset = Vector2(16, 16)

var life = false

var cell = null
var target_position = Vector2()
var path = []
var oldpath = path

var lock = false

var step = 1
var dir = 0
var stop_dist = 32

var move_coldown_time = 0.2
var move_coldown = true

var state = null
enum STATES { IDLE, FOLLOW }

func _ready():
	init()
	pass

func init():
	target_position = global.player.position
	z_index = 10
	timer.set_wait_time(move_coldown_time)
	life = true
	ChangeState(IDLE)

func _physics_process(delta):
	if life:
		AI(delta)
	pass

func AI(delta):
	if global.flag:
		ChangeState(IDLE)
		self.life = false
		return
	if state == FOLLOW && !global.flag:
		if move_coldown:
			move_coldown = false
			timer.start()
			MoveToTarget(delta)
	elif !global.flag && position.distance_to(target_position) > stop_dist:
		path = global.pathfinder_node.FindPath(position, target_position, self)
		#if path != null && !path.empty() && global.CheckPath(self) == false:
			#ChangeCell(path.front())
			#path = global.pathfinder_node.FindPath(position, target_position)
		#if path != null:
			#path.pop_front()
		#else:
		if path == null:
			global.flag = true
			self.life = false
			ChangeState(IDLE)
			return
		oldpath = path
		if path != null && !path.empty():
			ChangeState(FOLLOW)

func MoveToTarget(delta):
	for e in get_tree().get_nodes_in_group("enemy"):
		if e != self && global.map_node.point_to_global(path.front()) == e.position:
			path = global.pathfinder_node.FindPath(position, target_position, self)
			break
	if path == null:
		ChangeState(IDLE)
		return
	if path.has(global.pathfinder_node.GlobalToPoint(self.position)):
		path.erase(global.pathfinder_node.GlobalToPoint(self.position))
	if path.empty() || len(path) <= 1:
		path.clear()
		self.life = false
		ChangeState(IDLE)
	else:
		position = global.map_node.point_to_global(path.front())
		ChangeCell(position)
		path.pop_front()

func ChangeState(new_state):
	state = new_state 

func FindNeighbour():
	pass

func ChangeCell(pos):
	for cell in get_tree().get_nodes_in_group("floor"):
		if cell.position == pos:
			self.cell.open = true
			cell.open = false
			self.cell = cell
			break

func _on_Timer_timeout():
	if !move_coldown:
		move_coldown = true
