extends Node2D

onready var chat = $BottomPanel/Chat

func _ready():
	pass

func _on_Chat_pressed():
	chat.set_visible(chat.visible)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("l_click"):
		print(1)
	pass



