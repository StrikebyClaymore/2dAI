extends Node2D

var idx
var open = true
var cost = 1
var mob = null

func _ready():
	connect("input_event", self, "_on_body_input_event")

func _on_body_input_event(viewport, event, shape_idx):
	if open:
		if Input.is_action_pressed("r_click"):
			global.player.position = position
			open = false
			mob = global.player
			global.cell.open = true
			global.cell.mob = null
			global.cell = self
			#global.CheckBlocked()
			#global.flag = false
			global.UnlockEnemies()
		elif Input.is_action_pressed("l_click"):
			global.map_node.create_enemy(position, self)
		elif Input.is_action_pressed("middle_click"):
			global.map_node.add_tile(position, 2)
		elif Input.is_action_pressed("ui_select"):
			open = false
			#global.pathfinder_node.FindLockedPath(position, global.player.position, self))
			pass