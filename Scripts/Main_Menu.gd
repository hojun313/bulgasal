extends Control

func _ready():
	$StartButton.pressed.connect(on_start_button_pressed)

func on_start_button_pressed():
	Game_Manager.goto_scene("res://Scenes/Boss_Battle_1.tscn")
