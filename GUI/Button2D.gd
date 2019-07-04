tool
extends Area2D

export var sprite: Texture setget set_texture
export var selected_sprite: Texture setget set_selected_texture
export var shape: Shape2D setget set_shape

var selected: = false
var item: Node2D
var lock: = false

func set_texture(value):
	sprite = value
	if has_node("Sprite"):
		$Sprite.texture = sprite

func set_selected_texture(value):
	selected_sprite = value

func set_shape(value):
	shape = value
	if has_node("CollisionShape2D"):
		$CollisionShape2D.shape = shape

func _ready():
	pass

func _on_Button2D_input_event(viewport, ev, shape_idx):
	if lock: return
	if ev is InputEventMouseButton && ev.pressed:
		set_selected(true)

func set_selected(type):
	selected = type
	if type:
		$Sprite.texture = selected_sprite
	else:
		$Sprite.texture = sprite

func set_lock(type):
	lock = type


