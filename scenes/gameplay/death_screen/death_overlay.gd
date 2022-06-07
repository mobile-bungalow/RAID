extends Control

func _ready():
	add_to_group("overlay")


func _on_Button_pressed():
	get_parent().reset()
