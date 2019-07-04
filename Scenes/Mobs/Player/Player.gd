extends KinematicBody2D

var ts: int = 32 # tile size
var size: = Vector2.ZERO
var dir: = Vector2.ZERO
var speed_scale: int = 8
var old_position: = Vector2.ZERO
var move_lock: = false
var collide: = false

var z_level: int = 0
var floor_node: TileMap = null
var walls_node: TileMap = null
var nav_2d: Node
var cell_pos: Vector2
var step_to_next_cell: = false

signal change_pos()

func _ready():
	size = $Sprite.texture.get_data().get_size()*$Sprite.scale
	global.player = self
	init()

func init():
	floor_node = global.current_scene.floor_container.get_child(z_index)
	walls_node = global.current_scene.walls_container.get_child(z_index)
	nav_2d = global.current_scene.get_node("Nav_2d")
	#cell_pos = get_map_pos(position)
	#nav_2d.block_cell(cell_pos, true)
	set_label_text()

func _physics_process(delta):
	get_input()
	if move_lock:
		move(delta)
	pass

func move(dt: float):
	if collide: return
	
	var dist = old_position.distance_to(position)
	if dist >= 32: return
	
	#if !step_to_next_cell && dist > 16:
	#	step_to_next_cell = true
	#	cell_pos = get_map_pos(position)
	#	nav_2d.block_cell(cell_pos, true)
	#	nav_2d.block_cell(get_map_pos(old_position), false)
	
	var rel_vec: = Vector2(round((dir*ts*dt*speed_scale).x), round((dir*ts*dt*speed_scale).y))
	move_and_collide(rel_vec)
	move_and_slide(Vector2.ZERO)
	
	get_collider()
	
	#if is_on_wall():
	#	collide = true
	#	if get_cells_collider() != -1:
	#		print("Collide with some object")

func get_collider():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		collide = true
		if collision.collider is TileMap:
			print(self.name + " collide with some object")
		else:
			print(self.name + " collided with: ", collision.collider.name)

func change_move_status(dir: Vector2 = Vector2.ZERO):
	self.dir = dir
	if dir != Vector2.ZERO:
		old_position = position
	else:
		step_to_next_cell = false
		collide = false
		position = get_map_pos()*ts + size/2
		set_label_text()
	move_lock = !move_lock
	pass

func get_cells_collider():
	var walls = walls_node
	return walls.get_cellv(walls.world_to_map(old_position+dir*32))

func set_label_text():
	$Label.set_text("x: " + str(get_map_pos().x) + " y: " + str(get_map_pos().y))

func get_map_pos(pos: = position):
	return floor_node.world_to_map(pos)

func get_input():
	#if Input.is_action_just_pressed("l_click"):
	#	position = get_map_pos(get_global_mouse_position())*ts + size/2
	#if Input.is_action_just_pressed("r_click"):
	#	global.current_scene.add_enemy(0, get_map_pos(get_global_mouse_position())*ts + size/2)
	if move_lock: return
	if Input.is_action_pressed("w"):
		$Animation.play("move_up")
	elif Input.is_action_pressed("a"):
		$Animation.play("move_left")
	elif Input.is_action_pressed("s"):
		$Animation.play("move_down")
	elif Input.is_action_pressed("d"):
		$Animation.play("move_right")


