extends TileMap

var computer_timer
var switch_timer
var rng

var connections = []
var selected_tiles = []

var switches = []


func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	computer_timer = Timer.new()
	add_child(computer_timer)
	computer_timer.connect("timeout", self,"_on_computer_Timer_timeout")
	computer_timer.set_wait_time(5.0)
	computer_timer.set_one_shot(false)
	computer_timer.start()
	
	switch_timer = Timer.new()
	add_child(switch_timer)
	switch_timer.connect("timeout", self,"_on_switch_Timer_timeout")
	switch_timer.set_wait_time(15.0)
	switch_timer.set_one_shot(false)
	switch_timer.start()
	
	_on_computer_Timer_timeout()
	_on_switch_Timer_timeout()

func _physics_process(delta):
	if(Input.is_action_pressed("mb_left")):
		_select_tiles()
	if(Input.is_action_just_released("mb_left")):
		_cancel_selection()
	if(Input.is_action_just_pressed("mb_right")):
		_delete_connection()

func _select_tiles():
	var tile: Vector2 = world_to_map(get_global_mouse_position())
	if (!selected_tiles.has(tile)):
		if (selected_tiles.empty()): 
			if (get_cellv(tile)==8): #Start
				selected_tiles.append(tile)
		else:
			if (get_cellv(tile)==0): #NextTileToSelection
				var last = selected_tiles[selected_tiles.size()-1]
				var diff = tile-last
				if (diff==Vector2(1,0)||diff==Vector2(-1,0)||diff==Vector2(0,1)||diff==Vector2(0,-1)):
					selected_tiles.append(tile)
					set_cellv(tile, 1)
				else:
					_cancel_selection()
			if (get_cellv(tile)>=10&&get_cellv(tile)<=25): #End
				selected_tiles.append(tile)
				_finish_selection()

func _delete_connection():
	var tile: Vector2 = world_to_map(get_global_mouse_position())
	if (get_cellv(tile)>=2&&get_cellv(tile)<=9):
		var cable_index = -1
		for i in connections.size():
			if (connections[i].has(tile)):
				cable_index = i
		if (cable_index!=-1):
			var cable = connections[cable_index]
			for rtile in cable:
				if (get_cellv(rtile)>1&&get_cellv(rtile)<8):
					set_cellv(rtile, 0)
					set_cellv(cable[0],8)
					var end = cable[cable.size()-1]
					for switch in switches:
						if (end == Vector2(switch[0],switch[1])):
							var ports = switch[3]
							var diff = end-cable[cable.size()-2]
							if (diff==Vector2(0,1)): #North
								ports[0] = 0
							if (diff==Vector2(-1,0)): #East
								ports[1] = 0
							if (diff==Vector2(0,-1)): #South
								ports[2] = 0
							if (diff==Vector2(1,0)): #West
								ports[3] = 0
							_update_switch_sprites()
			connections.remove(cable_index)
			_update_score()

func _cancel_selection():
	for i in selected_tiles.size():
		if (get_cellv(selected_tiles[i])==1):
			set_cellv(selected_tiles[i], 0)
	selected_tiles.clear()

func _finish_selection():
	if(!selected_tiles.empty()):
		var start = selected_tiles[0]
		var end = selected_tiles[selected_tiles.size()-1]
		if (get_cellv(start)==8&&get_cellv(end)>=10&&get_cellv(end)<=25):
			for i in selected_tiles.size():
				if (i==0):
					set_cellv(selected_tiles[0],9)
				if (i==selected_tiles.size()-1):
					var tile = selected_tiles[i]
					for switch in switches:
						if (Vector2(switch[0],switch[1])==tile):
							var ports = switch[3]
							var diff = tile-selected_tiles[i-1]
							if(diff==Vector2(0,1)): #North port
								ports[0] = 1
							if(diff==Vector2(-1,0)): #East
								ports[1] = 1
							if(diff==Vector2(0,-1)): #South
								ports[2] = 1
							if(diff==Vector2(1,0)): #West
								ports[3] = 1
							_update_switch_sprites()
				if (i!=0 && i!=selected_tiles.size()-1):
					var dir =  selected_tiles[i]-selected_tiles[i-1]
					var diff = selected_tiles[i+1]-selected_tiles[i-1]
					if (diff==Vector2(2,0)||diff==Vector2(-2,0)):
						set_cellv(selected_tiles[i], 2)
					if (diff==Vector2(0,2)||diff==Vector2(0,-2)):
						set_cellv(selected_tiles[i], 3)
					if (dir==Vector2(1,0)): #East
						if (diff==Vector2(1,1)):
							set_cellv(selected_tiles[i], 6)	
						if (diff==Vector2(1,-1)):
							set_cellv(selected_tiles[i], 5)
					if (dir==Vector2(-1,0)): #West
						if (diff==Vector2(-1,1)):
							set_cellv(selected_tiles[i], 7)	
						if (diff==Vector2(-1,-1)):
							set_cellv(selected_tiles[i], 4)
					if (dir==Vector2(0,1)): #South
						if (diff==Vector2(1,1)):
							set_cellv(selected_tiles[i], 4)	
						if (diff==Vector2(-1,1)):
							set_cellv(selected_tiles[i], 5)
					if (dir==Vector2(0,-1)): #North
						if (diff==Vector2(1,-1)):
							set_cellv(selected_tiles[i], 7)	
						if (diff==Vector2(-1,-1)):
							set_cellv(selected_tiles[i], 6)
			connections.append(selected_tiles.duplicate())
			_update_score()
			selected_tiles.clear()
		else:
			_cancel_selection()

func _update_switch_sprites():
	for switch in switches:
		var tile = Vector2(switch[0],switch[1])
		var ports = switch[3]
		if (ports==[0,0,0,0]):
			set_cellv(tile, 10)
		if (ports==[1,0,0,0]):
			set_cellv(tile, 12)
		if (ports==[0,1,0,0]):
			set_cellv(tile, 13)
		if (ports==[0,0,1,0]):
			set_cellv(tile, 14)
		if (ports==[0,0,0,1]):
			set_cellv(tile, 11)
			
		if (ports==[1,0,1,0]):
			set_cellv(tile, 16)
		if (ports==[0,1,0,1]):
			set_cellv(tile, 15)
			
		if (ports==[1,1,0,0]):
			set_cellv(tile, 19)
		if (ports==[0,1,1,0]):
			set_cellv(tile, 20)
		if (ports==[0,0,1,1]):
			set_cellv(tile, 18)
		if (ports==[1,0,0,1]):
			set_cellv(tile, 17)
			
		if (ports==[1,1,1,0]):
			set_cellv(tile, 25)
		if (ports==[0,1,1,1]):
			set_cellv(tile, 24)
		if (ports==[1,0,1,1]):
			set_cellv(tile, 23)
		if (ports==[1,1,0,1]):
			set_cellv(tile, 22)
			
		if (ports==[1,1,1,1]):
			set_cellv(tile, 26)

func _on_computer_Timer_timeout():
	var pos = _get_random_pos()
	set_cellv(pos, 8)

func _on_switch_Timer_timeout():
	var pos = _get_random_pos()
	set_cellv(pos, 10)
	switches.append([pos[0],pos[1], 0, [0,0,0,0]])

func _get_random_pos():
	var rngPos
	while(true):
		rngPos = Vector2(rng.randi_range(0,15), rng.randi_range(0,8))
		if (get_cellv(rngPos)==0):
			break
	return rngPos
	
func _update_score():
	Global.score = connections.size()
