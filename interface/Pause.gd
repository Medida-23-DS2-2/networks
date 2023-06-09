extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var pause = $HBoxContainer/Button
onready var root = get_node("/root/Node2D")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Global.pen):
		$HBoxContainer/Eraser.DRAW_NORMAL
	else:
		$HBoxContainer/Pen.DRAW_NORMAL
		$HBoxContainer/Eraser.DRAW_HOVER

func _on_pause_button_pressed():
	if (!get_tree().paused):
		# show menu
		var pause_menu = load("res://interface/PauseMenu.tscn")
		var pause_instance = pause_menu.instance()
		root.add_child(pause_instance)




func _on_Pen_pressed():
	Global.pen = true


func _on_Eraser_pressed():
	Global.pen = false
