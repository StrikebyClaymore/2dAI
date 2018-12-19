extends "res://objects/StaticClass.gd"

func _ready():
	init()
	pass

func init():
	open = false
	global.pathfinder_node.locked.append(self)
	cost = 20