extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ResumeButton_pressed():
	get_tree().paused = false
	queue_free()


func _on_BackToMain_pressed():
	get_tree().change_scene("res://interface/Title.tscn")
	get_tree().paused = false
