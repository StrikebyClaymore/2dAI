extends Node

var nums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
#["!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "+"]
var chars = ["@"]

func _ready():
	randomize()

func round_rand(a, b):
	return round(rand_range(a, b))

func int_rand(a, b):
	return int(round(rand_range(a, b)))

func bool_rand():
	var r = round(rand_range(0, 1))
	if r == 0:
		return false
	else:
		return true

func selective_rand(a, b):
	return a if bool_rand() else b

func excluding_rand(a, b, c):
	var mas = []
	for i in range(a, b+1):
		if typeof(c) == TYPE_ARRAY and c.has(i):
			continue
		elif typeof(c) == TYPE_INT and c == i:
			continue
		else:
			mas.append(i)
	if mas.size()-1 < 0:
		return null
	return mas[int_rand(0, mas.size()-1)]

func clear_node_name(_name):
	var name = ""
	for c in _name.length():
		if _name[c] == chars[0]:
			continue
		elif _name[c] != chars[0]:
			name += _name[c]
			continue
	var name2 = ""
	for c in name.length():
		var count = int(0)
		for n in nums:
			if name[c] != str(n):
				count += 1
		if count == nums.size():
			name2 += name[c]
	return name2
	pass

func add_line(pos1, pos2, width = 2, node = global.current_scene, z_idx = 0, color = Color(0, 0, 0)):
	var line = Line2D.new()
	line.add_point(pos1)
	line.add_point(pos2)
	line.set_width(width)
	line.default_color = color
	line.z_index = z_idx
	node.add_child(line)
	return line

func check_collide(pos1, size1, pos2, size2):
	if pos1.x+size1.x > pos2.x && pos1.y+size1.y > pos2.y && pos1.x < pos2.x+size2.x && pos1.y < pos2.y+size2.y:
		return true
	return false

func update_texture(obj, img):
	var img_tex = ImageTexture.new()
	img_tex.create_from_image(img, 0)
	obj.texture = img_tex

func set_collision_size(coll, size):
	coll.get_shape().set_extents(size/2)

func set_circle_collision_size(coll, size):
	coll.get_shape().set_radius(size)

class sort_by:
	static func num(a, b):
		if a[0] < b[0]:
			return true
		return false

func dist_to(obj1: Node2D, obj2: Node2D):
	return obj1.position.distance_to(obj2.position)

func swap(obj1, obj2):
	var tmp = obj1
	obj1 = obj2
	obj2 = tmp


