extends Node

var timers_activated = []

var timers_lock = {
}
var timers_mas = {
}
var timers_func = {
	
}

func add_timer(_name, time = 0.2, _node = global.current_scene, _func = null):
	timers_lock[_name] = true
	var t = Timer.new()
	t.set_wait_time(time)
	t.set_one_shot(true)
	t.connect("timeout", self, "timer_out")
	t.add_to_group("timer")
	_node.add_child(t)
	timers_mas[_name] = t
	timers_func[_name] = { node = _node, tfunc = _func}
	timers_activated.append(_name)
	t.start()

func timer_out():
	var timer
	var i = 0
	for t in timers_mas.values():
		if t != null && t.is_stopped():
			timer = t
			break
		i += 1

	if timers_func[timers_activated[i]].tfunc != null:
		timers_func[timers_activated[i]].node.call_deferred(timers_func[timers_activated[0]].tfunc)
	timers_lock[timers_activated[i]] = false
	timers_mas[timers_activated[i]].queue_free()
	
	timers_mas.erase(timers_activated[i])
	timers_lock.erase(timers_activated[i])
	timers_activated.erase(timers_activated[i])
