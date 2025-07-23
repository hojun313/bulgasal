extends CanvasLayer

var test_label: Label

func _ready():
	# 테스트용 라벨 생성
	test_label = Label.new()
	test_label.text = "UI Working! Press Z to shoot"
	test_label.position = Vector2(50, 50)
	test_label.add_theme_font_size_override("font_size", 24)
	add_child(test_label)
	
	print("SimpleUI: Ready!")

func _process(delta):
	# 플레이어 찾기
	var player = get_tree().get_first_node_in_group("player")
	if player:
		test_label.text = "Player Health: " + str(player.current_health) + "/100"
	
	# 보스 찾기
	var bosses = get_tree().get_nodes_in_group("boss")
	if bosses.size() > 0:
		var boss = bosses[0]
		test_label.text += "\nBoss Health: " + str(boss.current_health) + "/" + str(boss.max_health)
	else:
		test_label.text += "\nNo Boss Found"
