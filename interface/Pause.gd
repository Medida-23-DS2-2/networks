extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var pause = $HSplitContainer/Button
onready var brightness = get_node("/root/Node2D/DarkOverlay")

# Called when the node enters the scene tree for the first time.
func _ready():
	brightness.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_pause_button_pressed():
	if (get_tree().paused):
		# if game is already paused:
		# remove all pause menus, options etc
		pause.text = "Pause"
		# set brightness to 100%
		brightness.hide()
		# resume game
		get_tree().paused = false
	else:
		# brightness = 50%
		brightness.show()
		# show menu
		pause.text = "Weiter"
		# pause all other actions
		get_tree().paused = true


