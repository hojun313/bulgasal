extends Node

func goto_scene(path: String):
	get_tree().change_scene_to_file(path)
