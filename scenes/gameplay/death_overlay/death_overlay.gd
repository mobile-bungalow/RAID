extends Control

export var score = 0;
export var max_combo = 0;
export var kills = 0;

func show_self():
	$AnimationPlayer.queue("fade_in")
	$ColorRect/CenterContainer/VBoxContainer/Score.set_text(str("Score  ", score))
	$ColorRect/CenterContainer/VBoxContainer/Kills.set_text(str("Kills  ", kills))
	$ColorRect/CenterContainer/VBoxContainer/Combo.set_text(str("Top Combo  ", max_combo, "X"))

func make_clear():
	$ColorRect.color = Color("00FFFFFF")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_opaque():
	$ColorRect.color = Color("8dd6cbcb")

func _on_Reset_Button_button_down():
	Game.get_active_scene().reset()
	pass # Replace with function body.

