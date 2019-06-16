tool
extends Control

signal pressed()

var locked = false

export (Texture) var texture = null setget set_texture
export (Texture) var texture_selected = null setget set_texture_hover
var enabled = true

func set_texture(t):
	texture = t
	self.rect_size = texture.get_size()
	$Label.rect_size = self.rect_size
	if has_node("Sprite"):
		$Sprite.texture = t
	$Sprite.rotation = self.rect_rotation
	self.rect_rotation = 0

func set_texture_hover(t):
	texture_selected = t
	if has_node("Sprite_selected"):
		$Sprite_selected.texture = t

export var text = "" setget set_text
func set_text(value):
	text = value
	if has_node("Label"):
		$Label.text = value

var selected = false setget set_selected
func set_selected(value):
	if value:
		if has_node("Sprite"):
			$Sprite.visible = false
		if has_node("Sprite_selected"):
			$Sprite_selected.visible = true
		selected = true
	else:
		if has_node("Sprite"):
			$Sprite.visible = true
		if has_node("Sprite_selected"):
			$Sprite_selected.visible = false
		selected = false

func unselect():
	self.selected = false

func _ready():
	if texture != null:
		if has_node("Sprite"):
			$Sprite.texture = texture
		self.rect_size = texture.get_size()
		$Sprite.global_position = rect_global_position + texture.get_size()/2
	if texture_selected != null:
		if has_node("Sprite_selected"):
			$Sprite_selected.texture = texture_selected
			$Sprite_selected.global_position = rect_global_position + texture.get_size()/2
			#$Sprite_selected.position += texture_selected.get_size()/2
	pass

func _on_Button_gui_input(ev):
	if !locked && enabled and (ev is InputEventMouseButton or ev is InputEventScreenTouch) and ev.is_pressed():
		#self.selected = false
		self.locked = true
		emit_signal("pressed")
	elif locked && enabled and (ev is InputEventMouseButton or ev is InputEventScreenTouch):
		if ev.pressed:
			self.locked = false

func _on_Button_mouse_entered():
	if !locked:
		self.selected = true

func _on_Button_mouse_exited():
	if !locked:
		self.selected = false
