extends KinematicBody2D

var ts: int = 32 # tile size
var size: Vector2
var dir: Vector2
var speed_scale: int = 8
var old_position: Vector2
var move_lock: = true
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

###
var points: = Array()

func _ready():
	size = $Sprite.texture.get_data().get_size()*$Sprite.scale
	init()

func _draw():
	for p in points:
		draw_rect(Rect2(p.x, p.y, 1, 1), Color(1, 0.5, 0.5), false)
	pass

func add_points(pos: = Vector2.ZERO):
	if pos != Vector2.ZERO:
		pos = position - pos
	else:
		pos = Vector2(16, 16)
	for y in ts:
		for x in ts:
			if y == 0 || y == ts-1:
				points.append(Vector2(x-pos.x, y-pos.y))
			elif x == 0 || x == ts-1:
				points.append(Vector2(x-pos.x, y-pos.y))

func clear_points():
	points.clear()

func init():
	floor_node = global.current_scene.floor_container.get_child(z_index)
	walls_node = global.current_scene.walls_container.get_child(z_index)
	nav_2d = global.current_scene.get_node("Nav_2d")
	cell_pos = get_map_pos()
	old_position = position
	
	nav_2d.block_cell(cell_pos, true)
	
	#nav_2d.set_cell_weight(cell_pos, 200)
	add_points()
	set_life()
	set_label_text()
	set_target(global.player)
	get_node("Priority").set_text(str(step_priority))

func _physics_process(delta):
	AI(delta)
	pass

func AI(dt: float):
	if not move_lock && not skip_step:
		move(dt)
	#elif not $Animation.is_playing() && path.size() > 0:
		#start_move()

func move(dt: float):
	
	var dist = old_position.distance_to(position)
	if dist >= 32: return
	
	var rel_vec: = Vector2(round((dir*ts*dt*speed_scale).x), round((dir*ts*dt*speed_scale).y))
	move_and_collide(rel_vec)
	move_and_slide(Vector2.ZERO)
	
	pass

func start_move():
	if path.size() == 0: return
	
	set_dir()
	
	if need_skip_step(): return
	
	match dir:
		Vector2.UP: $Animation.play("move_up")
		Vector2.LEFT: $Animation.play("move_left")
		Vector2.DOWN: $Animation.play("move_down")
		Vector2.RIGHT: $Animation.play("move_right")
	
	unstack()
	path.remove(0)

func set_dir():
	set_next_pos()
	dir = next_pos - get_map_pos()
	cell_pos = get_map_pos()
	old_position = position
	find_path()

func change_move_status(dir: Vector2):
	cell_pos = get_map_pos()
	if move_lock:
		
		nav_2d.block_cell(next_pos, true)
		
		clear_points()
		add_points(next_pos*ts)
		update()
		move_lock = false # unlock move
	else:
		move_lock = true # lock move
		set_label_text()
		
		nav_2d.block_cell(get_map_pos(old_position), false)
		
		clear_points()
		#add_points(get_map_pos(old_position)*ts)
		add_points()
		update()
		if path.size() > 0:
			start_move()

func need_skip_step():
	get_collider()
	if collide:
		$Animation.play("skip_step")
		return true
	for c in collider:
		if next_pos == c.cell_pos:
			$Animation.play("skip_step")
			return true
		if next_pos == c.next_pos:
			#if not c.move_lock:
			#	$Animation.play("skip_step")
			#	return true
			if position.distance_to(target.position) > c.position.distance_to(target.position):
				move_lock = true
				$Animation.play("skip_step")
				return true
			elif step_priority < c.step_priority:
				move_lock = true
				$Animation.play("skip_step")
				return true
			else:
				c.move_lock = true
				c.get_node("Animation").play("skip_step")
	return false

func set_skip_step():
	if not skip_step:
		skip_step = true
		collide = false
		
		nav_2d.block_cell(next_pos, false)
		
		clear_points()
		#for c in collider:
		#	c.nav_2d.block_cell(next_pos, false)
	else:
		find_path()

		clear_points()
		add_points(next_pos*ts)
		
		skip_step = false
		start_move()

func set_next_pos():
	if path.size() == 0: 
		next_pos = get_map_pos()
	else:
		next_pos = Vector2(path[0].x, path[0].y)

func change_cell():
	#nav_2d.set_cell_weight(get_map_pos(next_pos), 200)
	#nav_2d.block_cell(get_map_pos(next_pos), true)
	#nav_2d.set_cell_weight(get_map_pos(old_position), 1)
	#nav_2d.block_cell(get_map_pos(old_position), false)
	pass

func get_collider():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		collide = true
		if collision.collider is TileMap:
			unstack()
			return collision.collider
			#print(self.name + " collide with some object")
		elif collision.collider is KinematicBody2D:
			unstack()
			return collision.collider
			#print(self.name + " collided with: ", collision.collider.name)
		else:
			collide = false
			return null

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
	start_move()
	pass

func find_path():
	var self_pos: = Vector3(get_map_pos(position).x, get_map_pos(position).y, 0)
	var target_pos: = Vector3(get_map_pos(target.position).x, get_map_pos(target.position).y, 0)
	path = nav_2d._get_path(self_pos, target_pos)
	if path.size() >= 2:
		path.remove(0)
		path.resize(path.size()-1)
	elif path.size() == 1:
		path.remove(0)

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


