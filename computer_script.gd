extends Area2D

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var rpos = Vector2(rng.randi_range(0,13),rng.randi_range(0,7))
	print(rpos)
	position_in_grit(rpos)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func position_in_grit(pos: Vector2):
	var gridPos: Vector2
	gridPos[0] = pos[0]*64+32
	gridPos[1] = pos[1]*64+32
	self.position = gridPos

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			var rpos = Vector2(rng.randi_range(0,13),rng.randi_range(0,7))
			position_in_grit(rpos)
