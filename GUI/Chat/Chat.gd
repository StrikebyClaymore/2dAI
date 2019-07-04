extends CanvasLayer

var style_visible = preload("res://GUI/Chat/chat_visible_style.tres")
var style_invisible = preload("res://GUI/Chat/chat_invisible_style.tres")

var visible: = false

func _ready():
	pass

func set_visible(value):
	if value:
		visible = false
		#$Text.set("custom_styles/focus", style_invisible)
		$Text.set("custom_styles/normal", style_invisible)
		$Text.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Text.rect_position = Vector2(96, 544)
		$Text.rect_size = Vector2(736, 96)
		$Text.scroll_active = false
		$LineEdit.visible = false
		$LineEdit.clear()
	else:
		visible = true
		#$Text.set("custom_styles/focus", style_visible)
		$Text.set("custom_styles/normal", style_visible)
		$Text.mouse_filter = Control.MOUSE_FILTER_STOP
		$Text.rect_position = Vector2(96, 448)
		$Text.rect_size = Vector2(736, 163)
		$LineEdit.visible = true
		$Text.scroll_active = true
		$LineEdit.clear()
		#yield(get_tree(), "idle_frame")
		$LineEdit.grab_focus()

func send_message(t):
	if t != "":
		if $Text.bbcode_text != "":
			$Text.bbcode_text += "\n"
		$Text.bbcode_text += t
	$LineEdit.clear()

func _on_LineEdit_text_entered(new_text):
	var msg = "None: " + new_text
	send_message(msg)
	pass
