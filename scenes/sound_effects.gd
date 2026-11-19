extends AudioStreamPlayer

@export var audiolist: Array[AudioStream] 
# Called when the node enters the scene tree for the first time.

func finished():
	play()

func changeaudio(index: int):
	stream = audiolist[index]
	
