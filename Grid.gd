extends TileMap

var computer_timer
var switch_timer
var rng

var connections = []

var last_frame_pointers = []
var selected_tiles_by_pointer = {}

var switches = []
var remaining_tiles = []

func transformToLocalPosition(globalPosition: Vector2):
	var globalOrigin = get_global_transform_with_canvas().get_origin()
	return (globalPosition - globalOrigin)

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
	
	_init_remaining_tiles()
	
	_on_computer_Timer_timeout()
	_on_switch_Timer_timeout()

func _init_remaining_tiles():
	for i in 16:
		for j in 9:
			remaining_tiles.append(Vector2(i,j))

func _physics_process(_delta):
	var touch_helper = get_node("/root/TouchHelper")
	for ptr_index in touch_helper.state.keys():
		var pos = touch_helper.state[ptr_index]
		
		if last_frame_pointers.has(ptr_index):			
			# equal to mouse_down	
			if (Global.pen):
				_select_tiles(pos, ptr_index)
			else:
				_delete_connection(pos)
		else:
			# equal to mouse_up
			_cancel_selection(ptr_index)

	last_frame_pointers = touch_helper.state.keys()
	
func _select_tiles(globalPosition: Vector2, pointer: int):
	var tile: Vector2 = world_to_map(transformToLocalPosition(globalPosition))
	# print(tile)
	if (!selected_tiles_by_pointer.has(pointer)):
		selected_tiles_by_pointer[pointer] = []

	if (!selected_tiles_by_pointer[pointer].has(tile)):
		if (selected_tiles_by_pointer[pointer].empty()): 
			if (_check_start_end_tile(get_cellv(tile))): #Start
				selected_tiles_by_pointer[pointer].append(tile)
		else:
			if (get_cellv(tile)==0): #NextTileToSelection
				var last = selected_tiles_by_pointer[pointer][selected_tiles_by_pointer[pointer].size()-1]
				var diff = tile-last
				if (diff==Vector2(1,0)||diff==Vector2(-1,0)||diff==Vector2(0,1)||diff==Vector2(0,-1)):
					selected_tiles_by_pointer[pointer].append(tile)
					set_cellv(tile, 1)
				else:
					_cancel_selection(pointer)
			if (_check_start_end_tile(get_cellv(tile))): #End
				selected_tiles_by_pointer[pointer].append(tile)
				_finish_selection(pointer)

func _check_start_end_tile(cellv):
	if (cellv==8||(cellv>=10&&cellv<=25)||cellv==27):
		return true;
	else:
		return false;

func _delete_connection(globalPosition: Vector2):
	var tile: Vector2 = world_to_map(transformToLocalPosition(globalPosition))
	if (get_cellv(tile)>=2&&get_cellv(tile)<=9):
		var cable_index = -1
		for i in connections.size():
			if (connections[i].has(tile)):
				cable_index = i
		if (cable_index!=-1):
			var cable = connections[cable_index]
			for i in cable.size():
				var rtile = cable[i]
				var cellv = get_cellv(rtile)
				if (cellv>1&&cellv<8): #Cable
					remaining_tiles.append(rtile)
					Global.remaining_tiles_count = remaining_tiles.size()
					set_cellv(rtile, 0)
				if (cellv==9): #Computer
					set_cellv(rtile,8)
				if (cellv==28): #Router
					set_cellv(rtile,27)
				if (cellv>=10&&cellv<=26): #Switch
					for switch in switches:
						if (rtile == Vector2(switch[0],switch[1])):
							var ports = switch[3]
							var diff = Vector2(0,0)
							if (i==0):
								diff = rtile-cable[1]
							if (i==cable.size()-1):
								diff = rtile-cable[cable.size()-2]
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

func _cancel_selection(pointer: int):
	if (!selected_tiles_by_pointer.has(pointer)):
		return
	for i in selected_tiles_by_pointer[pointer].size():
		if (!selected_tiles_by_pointer[pointer] || !selected_tiles_by_pointer[pointer][i]): 
			print(pointer)
			print(selected_tiles_by_pointer[pointer])
			continue
		if (get_cellv(selected_tiles_by_pointer[pointer][i])==1):
			set_cellv(selected_tiles_by_pointer[pointer][i], 0)
			selected_tiles_by_pointer[pointer].clear()

func _finish_selection(pointer):
	if (!selected_tiles_by_pointer.has(pointer)):
		selected_tiles_by_pointer[pointer] = []

	if(!selected_tiles_by_pointer[pointer].empty()):
		var start = selected_tiles_by_pointer[pointer][0]
		var end = selected_tiles_by_pointer[pointer][selected_tiles_by_pointer[pointer].size()-1]
		if (_check_start_end_tile(get_cellv(start))&&_check_start_end_tile(get_cellv(end))):
			for i in selected_tiles_by_pointer[pointer].size():
				remaining_tiles.remove(remaining_tiles.find(selected_tiles_by_pointer[pointer][i]))
				Global.remaining_tiles_count = remaining_tiles.size()
				if (i==0 || i==selected_tiles_by_pointer[pointer].size()-1):
					if (get_cellv(selected_tiles_by_pointer[pointer][i])==8): #Computer
						set_cellv(selected_tiles_by_pointer[pointer][i],9)
					if (get_cellv(selected_tiles_by_pointer[pointer][i])==27): #Router
						set_cellv(selected_tiles_by_pointer[pointer][i],28)
					if (get_cellv(selected_tiles_by_pointer[pointer][i])>=10&&get_cellv(selected_tiles_by_pointer[pointer][i])<=25): #Switches
						var tile = selected_tiles_by_pointer[pointer][i]
						for switch in switches:
							if (Vector2(switch[0],switch[1])==tile):
								var ports = switch[3]
								var diff=Vector2(0,0);
								if (i==0):
									diff = tile-selected_tiles_by_pointer[pointer][1]
								if (i==selected_tiles_by_pointer[pointer].size()-1):
									diff = tile-selected_tiles_by_pointer[pointer][i-1]
								if(diff==Vector2(0,1)): #North port
									ports[0] = 1
								if(diff==Vector2(-1,0)): #East
									ports[1] = 1
								if(diff==Vector2(0,-1)): #South
									ports[2] = 1
								if(diff==Vector2(1,0)): #West
									ports[3] = 1
								_update_switch_sprites()
				if (i!=0 && i!=selected_tiles_by_pointer[pointer].size()-1):
					var dir =  selected_tiles_by_pointer[pointer][i]-selected_tiles_by_pointer[pointer][i-1]
					var diff = selected_tiles_by_pointer[pointer][i+1]-selected_tiles_by_pointer[pointer][i-1]
					if (diff==Vector2(2,0)||diff==Vector2(-2,0)):
						set_cellv(selected_tiles_by_pointer[pointer][i], 2)
					if (diff==Vector2(0,2)||diff==Vector2(0,-2)):
						set_cellv(selected_tiles_by_pointer[pointer][i], 3)
					if (dir==Vector2(1,0)): #East
						if (diff==Vector2(1,1)):
							set_cellv(selected_tiles_by_pointer[pointer][i], 6)	
						if (diff==Vector2(1,-1)):
							set_cellv(selected_tiles_by_pointer[pointer][i], 5)
					if (dir==Vector2(-1,0)): #West
						if (diff==Vector2(-1,1)):
							set_cellv(selected_tiles_by_pointer[pointer][i], 7)	
						if (diff==Vector2(-1,-1)):
							set_cellv(selected_tiles_by_pointer[pointer][i], 4)
					if (dir==Vector2(0,1)): #South
						if (diff==Vector2(1,1)):
							set_cellv(selected_tiles_by_pointer[pointer][i], 4)	
						if (diff==Vector2(-1,1)):
							set_cellv(selected_tiles_by_pointer[pointer][i], 5)
					if (dir==Vector2(0,-1)): #North
						if (diff==Vector2(1,-1)):
							set_cellv(selected_tiles_by_pointer[pointer][i], 7)	
						if (diff==Vector2(-1,-1)):
							set_cellv(selected_tiles_by_pointer[pointer][i], 6)
			connections.append(selected_tiles_by_pointer[pointer].duplicate())
			_update_score()
			selected_tiles_by_pointer[pointer].clear()
		else:
			_cancel_selection(pointer)

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
	if (remaining_tiles.empty()):
		print("finish")
		return Vector2(0,0)
	else:
		var random = rng.randi_range(0,remaining_tiles.size()-1)
		var rngPos = remaining_tiles[random]
		remaining_tiles.remove(random)
		Global.remaining_tiles_count = remaining_tiles.size()
		return rngPos
	
func _update_score():
	Global.score = connections.size()
		
