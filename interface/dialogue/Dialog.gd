extends CanvasLayer


# Declare member variables here. Examples:

signal dialogueNodeDeleted


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_text(input):
	$NinePatchRect/Message.text = input
	$NinePatchRect2/Message.text = input


func _on_ToolButton_pressed():
	Global.progress_count += 1
	queue_free()
	emit_signal("dialogueNodeDeleted")
