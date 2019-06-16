extends Node

var MainMenu: = preload("res://Scenes/MainMenu.tscn")
var GameScene: = preload("res://Scenes/GameScene/GameScene.tscn")

var current_scene

var tile_size: int = 32
var map_size: = OS.window_size/tile_size

var player: KinematicBody2D
var GUI: CanvasLayer

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	#OS.window_fullscreen = true
	#current_scene.init()

func goto_scene(scene):
	call_deferred("_deferred_goto_scene", scene)

func _deferred_goto_scene(scene):
	current_scene.free()
	current_scene = scene.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)