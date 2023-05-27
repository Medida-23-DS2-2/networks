extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if(Input.is_action_just_pressed("mb_left")):
		var tile: Vector2 = world_to_map(get_global_mouse_position())
		print(self.get_cellv(tile))
		set_cellv(tile, 6)
	if(Input.is_action_just_pressed("mb_right")):
		var tile: Vector2 = world_to_map(get_global_mouse_position())
		set_cellv(tile, 5)
		
