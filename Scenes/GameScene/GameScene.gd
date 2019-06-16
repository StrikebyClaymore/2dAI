extends Node2D

var Player_tscn: = preload("res://Scenes/Mobs/Player/Player.tscn")
var Enemy_tscn: = preload("res://Scenes/Mobs/Enemies/Enemy.tscn")

onready var floor_container: = $Floor
onready var walls_container: = $Walls

func _ready():
	#$GenTerrain.init()
	$Nav_2d.init()
	add_player(Vector2(-16, -16))
	pass

func add_player(pos: = Vector2(0, 0)):
	var p = Player_tscn.instance()
	p.position = pos
	add_child(p)
	pass

func add_enemy(type: = 0, pos: = Vector2(0, 0)):
	var e: Node2D
	match type:
		0: e = Enemy_tscn.instance()
	e.position = pos
	e.step_priority = global.enemies
	add_child(e)
	global.enemies += 1

func world_to_map(pos: Vector2):
	return floor_container.world_to_map(pos)


