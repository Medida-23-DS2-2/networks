extends TileMap

var connections = []
var selected_tiles = []

var switches = []
var remaining_tiles = []

var stage1_completed
var stage2_completed

onready var root = get_node("/root/Node2D")

var dialogue_data = []
var dialogue = null

var pen_tl
var pen_tr
var pen_bl
var pen_br

func _ready():
	stage1_completed = false
	stage2_completed = false
	
	Global.pen = true
	
	pen_tl = true
	pen_tr = true
	pen_bl = true
	pen_br = true
	
	dialogue_data = load_dialogue()
	
	_init_remaining_tiles()

func _process(_delta):
	pass

func _init_remaining_tiles():
	for i in 16:
		for j in 9:
			remaining_tiles.append(Vector2(i,j))
	_init_stage1()

func _init_stage1():
	var tutorial_tiles = []
	
	#Tutorial Walls
	for i in 9:
		set_cellv(Vector2(7,i),1)
		tutorial_tiles.append(Vector2(7,i))
		set_cellv(Vector2(8,i),1)
		tutorial_tiles.append(Vector2(8,i))
	
	for i in 16:
		set_cellv(Vector2(i,3),1)
		tutorial_tiles.append(Vector2(i,3))
		set_cellv(Vector2(i,4),1)
		tutorial_tiles.append(Vector2(i,4))
		set_cellv(Vector2(i,5),1)
		tutorial_tiles.append(Vector2(i,5))
	
	#Tutorial Computer
	set_cellv(Vector2(5,2),8)
	tutorial_tiles.append(Vector2(5,2))
	
	set_cellv(Vector2(10,2),8)
	tutorial_tiles.append(Vector2(10,2))
	
	set_cellv(Vector2(5,6),8)
	tutorial_tiles.append(Vector2(5,6))
	
	set_cellv(Vector2(10,6),8)
	tutorial_tiles.append(Vector2(10,6))
	
	# dialog: das ist ein PC
	# wird iwie 2x instanziiert?
	if Global.progress_count == 0:
		play_dialogue(Global.progress_count)
		yield(dialogue, "dialogueNodeDeleted")
	
	#Tutorial Router
	set_cellv(Vector2(0,0),27)
	tutorial_tiles.append(Vector2(0,0))
	
	set_cellv(Vector2(15,0),27)
	tutorial_tiles.append(Vector2(15,0))
	
	set_cellv(Vector2(0,8),27)
	tutorial_tiles.append(Vector2(0,8))
	
	set_cellv(Vector2(15,8),27)
	tutorial_tiles.append(Vector2(15,8))
	
	# dialog: PC muss an Router angeschlossen werden
	if Global.progress_count == 1:
		play_dialogue(1)
		yield(dialogue, "dialogueNodeDeleted")
	
	for tile in tutorial_tiles:
		remaining_tiles.remove(remaining_tiles.find(tile))
	
	if Global.progress_count == 2:
		play_dialogue(2)
		yield(dialogue, "dialogueNodeDeleted")
	

func _init_stage2():
	#Delete Walls
	for i in 16:
		if (i!=7&&i!=8):
			set_cellv(Vector2(i,3),0)
			remaining_tiles.append(Vector2(i,3))
			set_cellv(Vector2(i,5),0)
			remaining_tiles.append(Vector2(i,5))
	
	
	var tutorial_tiles = []
	
	#Tutorial Computer 2
	set_cellv(Vector2(5,3),8)
	tutorial_tiles.append(Vector2(5,3))
	set_cellv(Vector2(10,3),8)
	tutorial_tiles.append(Vector2(10,3))
	set_cellv(Vector2(5,5),8)
	tutorial_tiles.append(Vector2(5,5))
	set_cellv(Vector2(10,5),8)
	tutorial_tiles.append(Vector2(10,5))
	
	# dialog: PC nur 1 Port
	if Global.progress_count == 4:
		play_dialogue(4)
		yield(dialogue, "dialogueNodeDeleted")
	
	#Tutorial Switches
	set_cellv(Vector2(1,3),10)
	tutorial_tiles.append(Vector2(1,3))
	switches.append([1,3,0,[0,0,0,0]])
	set_cellv(Vector2(14,3),10)
	tutorial_tiles.append(Vector2(14,3))
	switches.append([14,3,0,[0,0,0,0]])
	set_cellv(Vector2(1,5),10)
	tutorial_tiles.append(Vector2(1,5))
	switches.append([1,5,0,[0,0,0,0]])
	set_cellv(Vector2(14,5),10)
	tutorial_tiles.append(Vector2(14,5))
	switches.append([14,5,0,[0,0,0,0]])
	
	# dialog: switches
	if Global.progress_count == 5:
		play_dialogue(5)
		yield(dialogue, "dialogueNodeDeleted")
	
	for tile in tutorial_tiles:
		remaining_tiles.remove(remaining_tiles.find(tile))
		
	if Global.progress_count == 6:
		play_dialogue(6)
		yield(dialogue, "dialogueNodeDeleted")

func _physics_process(_delta):
	if(Input.is_action_pressed("mb_left") && Global.pen):
		_select_tiles()
	if(Input.is_action_just_released("mb_left")):
		_cancel_selection()
	if(Input.is_action_just_pressed("mb_left") && !Global.pen):
		_delete_connection()

func _select_tiles():
	var tile: Vector2 = world_to_map(get_global_mouse_position())
	if (!selected_tiles.has(tile)):
		if (selected_tiles.empty()): 
			if (_check_start_end_tile(get_cellv(tile))): #Start
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
			if (_check_start_end_tile(get_cellv(tile))): #End
				selected_tiles.append(tile)
				_finish_selection()

func _select_tiles_multitouch():
	if pen_tl:
		_select_tiles()
	
	if pen_tr:
		_select_tiles()
	
	if pen_bl:
		_select_tiles()
	
	if pen_br:
		_select_tiles()

func _check_start_end_tile(cellv):
	if (cellv==8||(cellv>=10&&cellv<=25)||cellv==27):
		return true;
	else:
		return false;

func _delete_connection():
	var tile: Vector2 = world_to_map(get_global_mouse_position())
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

func _cancel_selection():
	for i in selected_tiles.size():
		if (get_cellv(selected_tiles[i])==1):
			set_cellv(selected_tiles[i], 0)
	selected_tiles.clear()

func _finish_selection():
	if(!selected_tiles.empty()):
		var start = selected_tiles[0]
		var end = selected_tiles[selected_tiles.size()-1]
		if (_check_start_end_tile(get_cellv(start))&&_check_start_end_tile(get_cellv(end))):
			for i in selected_tiles.size():
				remaining_tiles.remove(remaining_tiles.find(selected_tiles[i]))
				Global.remaining_tiles_count = remaining_tiles.size()
				if (i==0 || i==selected_tiles.size()-1):
					if (get_cellv(selected_tiles[i])==8): #Computer
						set_cellv(selected_tiles[i],9)
					if (get_cellv(selected_tiles[i])==27): #Router
						set_cellv(selected_tiles[i],28)
					if (get_cellv(selected_tiles[i])>=10&&get_cellv(selected_tiles[i])<=25): #Switches
						var tile = selected_tiles[i]
						for switch in switches:
							if (Vector2(switch[0],switch[1])==tile):
								var ports = switch[3]
								var diff=Vector2(0,0);
								if (i==0):
									diff = tile-selected_tiles[1]
								if (i==selected_tiles.size()-1):
									diff = tile-selected_tiles[i-1]
								print(diff);
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
	
func _update_score():
	Global.score = connections.size()
	_check_tutorial_checkpoints()

func _check_tutorial_checkpoints():
	if (Global.score==4 && stage1_completed == false):
		stage1_completed = true
		
		print("Stage 1 completed!")
		if Global.progress_count == 3:
			play_dialogue(3) # works
			yield(dialogue, "dialogueNodeDeleted")
		
		
		_init_stage2()
	
	if (Global.score==4 && stage1_completed == true && stage2_completed == false):
		if Global.progress_count == 7:
			play_dialogue(7)
			yield(dialogue, "dialogueNodeDeleted")
		
	if (Global.score==12 && stage1_completed == true && stage2_completed == false):
		stage2_completed = true
		
		print("Stage 2 completed!")
		if Global.progress_count == 8:
			play_dialogue(8)
			yield(dialogue, "dialogueNodeDeleted")
		
		var victory_screen = load("res://interface/Victory.tscn")
		var victory_instance = victory_screen.instance()
		root.add_child(victory_instance)

func load_dialogue():
	var file = File.new()
	file.open("res://interface/dialogue/dialog-data.json", file.READ)
	return parse_json(file.get_as_text())

func play_dialogue(input):
	dialogue = load("res://interface/dialogue/Dialog.tscn").instance()
	add_child(dialogue)
	dialogue.connect("dialogueNodeDeleted", self, "_on_DialogueNodeDeleted")
	dialogue.update_text(dialogue_data[input]["text"])
	yield(dialogue, "dialogueNodeDeleted")

func _on_DialogueNodeDeleted():
	pass
