extends KinematicBody2D

var ts: int = 32 # tile size
var size: Vector2
var dir: Vector2
var speed_scale: int = 8
var old_position: Vector2
var move_lock: = false
var collide: = false
var collider: = []

var z_level: int = 0
var floor_node: TileMap
var walls_node: TileMap

var nav_2d: Node
var target: Node2D
var path: PoolVector3Array
var cell_pos: Vector2
var next_pos: Vector2
var step_to_next_cell: = false
var step_priority: int = 0
var skip_step: = false
var stack_num: int = 0

var life: = false

func _ready():
	size = $Sprite.texture.get_data().get_size()*$Sprite.scale
	init()

func init():
	floor_node = global.current_scene.floor_container.get_child(z_index)
	walls_node = global.current_scene.walls_container.get_child(z_index)
	nav_2d = global.current_scene.get_node("Nav_2d")
	cell_pos = get_map_pos(position)
	nav_2d.block_cell(cell_pos, true)
	set_life()
	set_label_text()
	set_target(global.player)
	get_node("Priority").set_text(str(step_priority))

func _physics_process(delta):
	AI(delta)
	pass

func AI(dt: float):
	if path.size() > 1:
		if skip_step: return
		if move_lock:
			move(dt)
		else:#elif dir == Vector2.ZERO:
			set_dir()
	pass

func set_dir():
	if path.size() < 1: return
	
	if cell_pos == get_map_pos(old_position):
		stack_num += 1
	if stack_num > 1:
		stack_num = 0
		break_move()
		return
	
	if path.size() == 1:
		dir = Vector2(path[0].x, path[0].y) - get_map_pos(position)
	else:
		dir = Vector2(path[1].x, path[1].y) - get_map_pos(position)
	match dir:
		Vector2.UP: $Animation.play("move_up")
		Vector2.LEFT: $Animation.play("move_left")
		Vector2.DOWN: $Animation.play("move_down")
		Vector2.RIGHT: $Animation.play("move_right")
	#if step_priority == 0:
	#	print(path.size(), " ", cell_pos, " ", get_map_pos(old_position))
	path.remove(0)

func move(dt: float):
	#if collide:
		#collide = false
		#change_move_status(Vector2.ZERO)
		#find_path()
		#return
	#if collide: print(1)
	var dist = old_position.distance_to(position)
	if dist >= 32: return
	if !step_to_next_cell && dist > 16:
		step_to_next_cell = true
		cell_pos = get_map_pos(position)
		nav_2d.block_cell(cell_pos, true)
		nav_2d.block_cell(get_map_pos(old_position), false)
		
	if need_skip_step(): return
	
	var rel_vec: = Vector2(round((dir*ts*dt*speed_scale).x), round((dir*ts*dt*speed_scale).y))
	move_and_collide(rel_vec)
	move_and_slide(Vector2.ZERO)
	get_collider()

func break_move():
	change_move_status(Vector2.ZERO)
	find_path()
	move_lock = false

func need_skip_step():
	if collide:
		$Animation.play("skip_step")
		return true
	for c in collider:
		if next_pos == c.next_pos:
			if step_priority < c.step_priority:
				$Animation.play("skip_step")
				return true
	return false

func set_skip_step():
	skip_step != skip_step
	if !skip_step:
		break_move()

func change_move_status(dir: = Vector2.ZERO):
	if dir != Vector2.ZERO:
		old_position = position
		next_pos = position + dir*ts
	else:
		#skip_step = false
		step_to_next_cell = false
		collide = false
		position = get_map_pos()*ts + size/2
		set_label_text()
		#dir = Vector2.ZERO
		#set_dir()
	move_lock = !move_lock

func get_collider():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		collide = true
		if collision.collider is TileMap:
			unstack()
			#print(self.name + " collide with some object")
		elif collision.collider is KinematicBody2D:
			unstack()
			#print(self.name + " collided with: ", collision.collider.name)
		else:
			collide = false

func unstack():
	position = get_map_pos()*ts + size/2

func get_cells_collider():
	return walls_node.get_cellv(walls_node.world_to_map(old_position+dir*32))

func set_label_text():
	$Label.set_text("x: " + str(get_map_pos().x) + " y: " + str(get_map_pos().y))
	pass

func get_map_pos(pos: = position):
	return floor_node.world_to_map(pos)

func set_life():
	life = !life

func set_target(target: Node2D):
	self.target = target
	target.connect("change_pos", self, "_on_Player_change_pos") 

func _on_Player_change_pos():
	find_path()
	pass

func find_path():
	var self_pos: = Vector3(get_map_pos(position).x, get_map_pos(position).y, 0)
	var target_pos: = Vector3(get_map_pos(target.position).x, get_map_pos(target.position).y, 0)
	path = nav_2d._get_path(self_pos, target_pos)
	#path.remove(0)

func _on_Area2D_body_entered(body):
	if body != self && body.is_in_group("enemy"):
		collider.append(body)

func _on_Area2D_body_exited(body):
	if body.is_in_group("enemy"):
		collider.remove(collider.find(body))

func _on_Enemy_mouse_entered():
	var info: = ("Skip_step: " + str(skip_step) + "; Move_lock: " + str(move_lock) +
				"; Stack_num: " + str(stack_num))
	global.current_scene.get_node("GUI/Panel/Label").set_text(info)
	modulate.r8 = 0

func _on_Enemy_mouse_exited():
	modulate.r8 = 255
	global.current_scene.get_node("GUI/Panel/Label").set_text("")
