extends Node2D

const selected_color: = Color(1, 0.05, 0.05)

onready var selected: Area2D = $head/head
var selected_label: Label = null

func _ready():
	selected_label = get_parent().get_node("Part_selected_text")
	select(selected)

func select(part):
	unselect()
	selected = part
	selected.set_modulate(selected_color)
	selected_label.set_text("Selected - " + selected.name)

func unselect():
	selected.set_modulate(Color(1, 1, 1, 1))

### ### HEAD ### ####

### scalp ###
func _on_scalp_mouse_entered():
	pass
func _on_scalp_mouse_exited():
	pass
func _on_scalp_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($head/scalp)
	pass

### head ###
func _on_head_mouse_entered():
	pass
func _on_head_mouse_exited():
	pass
func _on_head_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($head/head)

### left_eye ###
func _on_left_eye_mouse_entered():
	pass
func _on_left_eye_mouse_exited():
	pass
func _on_left_eye_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($head/left_eye)
	
### right_eye ###
func _on_right_eye_mouse_entered():
	pass
func _on_right_eye_mouse_exited():
	pass
func _on_right_eye_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($head/right_eye)

### left_ear ###
func _on_left_ear_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($head/left_ear)

### right_ear ###
func _on_right_ear_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($head/right_ear)

### nose ###
func _on_nose_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($head/nose)

###  mouth ###
func _on_mouth_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($head/mouth)

### ### BODY ### ####

###  neck ###
func _on_neck_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($body/neck)

### left_lung ###
func _on_left_lung_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($body/left_lung)

### right_lung ###
func _on_right_lung_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($body/right_lung)

### heart ###
func _on_heart_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($body/heart)
	
### tors ###
func _on_tors_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($body/tors)

### groin ###
func _on_groin_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($body/groin)

### ### ARMS ### ####

### left_shoulder ###
func _on_left_shoulder_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($arms/left_shoulder)

### right_shoulder ###
func _on_right_shoulder_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($arms/right_shoulder)

### left_forearm ###
func _on_left_forearm_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($arms/left_forearm)

### right_forearm ###
func _on_right_forearm_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($arms/right_forearm)

### left_hand ###
func _on_left_hand_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($arms/left_hand)

### right_hand ###
func _on_right_hand_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($arms/right_hand)

### ### LEGS ### ####

### left_hip ###
func _on_left_hip_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($legs/left_hip)

### right_hip ###
func _on_right_hip_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($legs/right_hip)

### left_shin ###
func _on_left_shin_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($legs/left_shin)

### right_shin ###
func _on_right_shin_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($legs/right_shin)

### left_foot ###
func _on_left_foot_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($legs/left_foot)

### right_foot ###
func _on_right_foot_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		select($legs/right_foot)
