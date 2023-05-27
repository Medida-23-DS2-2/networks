extends TileMap

var computer_timer
var switch_timer
var rng

var selected_tiles = []
# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	
	computer_timer = Timer.new()
	add_child(computer_timer)
	computer_timer.connect("timeout", self,"_on_computer_Timer_timeout")
	computer_timer.set_wait_time(20.0)
	computer_timer.set_one_shot(false)
	computer_timer.start()
	
	switch_timer = Timer.new()
	add_child(switch_timer)
	switch_timer.connect("timeout", self,"_on_switch_Timer_timeout")
	switch_timer.set_wait_time(20.0)
	switch_timer.set_one_shot(false)
	switch_timer.start()
	
	_on_computer_Timer_timeout()
	_on_switch_Timer_timeout()

func _physics_process(delta):
	if(Input.is_action_pressed("mb_left")):
		var tile: Vector2 = world_to_map(get_global_mouse_position())
		if (!selected_tiles.has(tile)):
			#print(get_cellv(tile))
			if (get_cellv(tile)==5):
				set_cellv(tile, 6)
			selected_tiles.append(tile)
	if(Input.is_action_just_released("mb_left")):
		var start = selected_tiles[0]
		var end = selected_tiles[selected_tiles.size()-1]
		if (get_cellv(start)==13&&get_cellv(end)==14):
			for i in selected_tiles.size():
				print(selected_tiles[i])
				if (i!=0 && i!=selected_tiles.size()-1):
					var dir =  selected_tiles[i]-selected_tiles[i-1]
					var diff = selected_tiles[i+1]-selected_tiles[i-1]
					print("diff:",diff)
					if (diff==Vector2(2,0)||diff==Vector2(-2,0)):
						set_cellv(selected_tiles[i], 7)
					if (diff==Vector2(0,2)||diff==Vector2(0,-2)):
						set_cellv(selected_tiles[i], 8)
					if (dir==Vector2(1,0)): #East
						if (diff==Vector2(1,1)):
							set_cellv(selected_tiles[i], 11)	
						if (diff==Vector2(1,-1)):
							set_cellv(selected_tiles[i], 10)
					if (dir==Vector2(-1,0)): #West
						if (diff==Vector2(-1,1)):
							set_cellv(selected_tiles[i], 12)	
						if (diff==Vector2(-1,-1)):
							set_cellv(selected_tiles[i], 9)
					if (dir==Vector2(0,1)): #South
						if (diff==Vector2(1,1)):
							set_cellv(selected_tiles[i], 9)	
						if (diff==Vector2(-1,1)):
							set_cellv(selected_tiles[i], 10)
					if (dir==Vector2(0,-1)): #North
						if (diff==Vector2(1,-1)):
							set_cellv(selected_tiles[i], 12)	
						if (diff==Vector2(-1,-1)):
							set_cellv(selected_tiles[i], 11)
		else:
			for i in selected_tiles.size():
				if (get_cellv(selected_tiles[i])==6):
					set_cellv(selected_tiles[i], 5)
		selected_tiles.clear()
	if(Input.is_action_pressed("mb_right")):
		var tile: Vector2 = world_to_map(get_global_mouse_position())
		set_cellv(tile, 5)
func _on_computer_Timer_timeout():
	var rngPos = Vector2(rng.randi_range(0,13), rng.randi_range(0,7))
	print("placing Computer at ",rngPos)
	if(get_cellv(rngPos)==5):
		set_cellv(rngPos, 13)
		
func _on_switch_Timer_timeout():
	var rngPos = Vector2(rng.randi_range(0,13), rng.randi_range(0,7))
	print("placing Switch at ",rngPos)
	if(get_cellv(rngPos)==5):
		set_cellv(rngPos, 14)
