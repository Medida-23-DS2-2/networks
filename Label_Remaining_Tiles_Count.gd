extends Label

func _process(delta):
	self.text = str("Verbleibende Felder: ",Global.remaining_tiles_count)
