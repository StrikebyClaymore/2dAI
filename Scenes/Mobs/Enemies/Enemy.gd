extends KinematicBody2D

var ts: int = 32 # tile size
var size: Vector2
var dir: Vector2
var speed_scale: int = 8
var old_position: Vector2
var move_lock: = false
var collide: = false
var collider: Array

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

func _physics_process(delta):
	AI(delta)
	pass

func AI(dt: float):
	if path.size() > 1:
		if move_lock:
			move(dt)
		else:#elif dir == Vector2.ZERO:
			set_dir()
	pass

func set_dir():
	if path.size() < 1: return
	if path.size() == 1:
		dir = Vector2(path[0].x, path[0].y) - get_map_pos(position)
	else:
		dir = Vector2(path[1].x, path[1].y) - get_map_pos(position)
	match dir:
		Vector2.UP: $Animation.play("move_up")
		Vector2.LEFT: $Animation.play("move_left")
		Vector2.DOWN: $Animation.play("move_down")
		Vector2.RIGHT: $Animation.play("move_right")
	path.remove(0)

func move(dt: float):
	if collide: return
	var dist = old_position.distance_to(position)
	if dist >= 32: return
	if skip_step: return
	if !step_to_next_cell && dist > 16:
		step_to_next_cell = true
		cell_pos = get_map_pos(position)
		nav_2d.block_cell(cell_pos, true)
		nav_2d.block_cell(get_map_pos(old_position), false)
		for c in collider:
			if next_pos == c.next_pos:
				if funcs.bool_rand():
					skip_step = true
					return
		#for c in collider:
		#	if next_pos == c.next_pos:
		#		if step_priority < c.step_priority:
		#			skip_step = true
		#			print(1)
		#			return
		#		elif step_priority == c.step_priority:
		#			print(name, " ", step_priority, " ", c.name, " ", c.step_priority)
	var rel_vec: = Vector2(round((dir*ts*dt*speed_scale).x), round((dir*ts*dt*speed_scale).y))
	move_and_collide(rel_vec)
	move_and_slide(Vector2.ZERO)
	get_collider()
	#if is_on_wall():
	#	collide = true
	#	if get_cells_collider() != -1:
	#		print("Collide with some object")

func priority_distribution():
	if collider.has(self): collider.remove(collider.find(self))
	var priority_list: = [[position.distance_to(target.position), self]]
	for c in collider:
		priority_list.append([c.position.distance_to(c.target.position), c])
	priority_list.sort_custom(funcs.sort_by, "num")
	for i in priority_list.size():
		priority_list[i][1].step_priority = i
	for i in priority_list.size():
		if priority_list[i][1] == self:
			priority_list.remove(i)
			break
	print(priority_list)

func change_move_status(dir: = Vector2.ZERO):
	if dir != Vector2.ZERO:
		#priority_distribution()
		old_position = position
		next_pos = position + dir*ts
	else:
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
			#print(self.name + " collide with some object")
			pass
		elif collision.collider is KinematicBody2D:
			#print(self.name + " collided with: ", collision.collider.name)
			pass
		else:
			collide = false

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
	if body != self && body.is_in_group("enemy") && !collider.has(body):
		collider.append(body)

func _on_Area2D_body_exited(body):
	if body.is_in_group("enemy"):
		collider.remove(collider.find(body))
