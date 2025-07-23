extends CanvasLayer

@onready var boss_health_bar = $Control/BossHealthContainer/BossHealthBar
@onready var boss_health_label = $Control/BossHealthContainer/BossHealthLabel
@onready var boss_health_container = $Control/BossHealthContainer

@onready var player_health_bar = $Control/PlayerHealthContainer/PlayerHealthBar
@onready var player_health_label = $Control/PlayerHealthContainer/PlayerHealthLabel

var current_boss = null
var player: CharacterBody2D = null

func _ready():
	# 플레이어 찾기
	player = get_tree().get_first_node_in_group("player")
	
	# 테스트용: 보스 체력바 항상 표시
	boss_health_container.visible = true
	
	# 기본값 설정
	boss_health_bar.value = 100
	player_health_bar.value = 100
	boss_health_label.text = "Boss: 100 / 100"
	player_health_label.text = "Player: 100 / 100"

func _process(delta):
	update_player_health()
	update_boss_health()

func update_player_health():
	if player:
		var health_percentage = float(player.current_health) / float(player.max_health)
		player_health_bar.value = health_percentage * 100
		player_health_label.text = "Player: " + str(player.current_health) + " / " + str(player.max_health)

func update_boss_health():
	# 현재 보스가 없으면 새로 찾기
	if current_boss == null or not is_instance_valid(current_boss):
		find_current_boss()
	
	if current_boss and is_instance_valid(current_boss):
		boss_health_container.visible = true
		var health_percentage = float(current_boss.current_health) / float(current_boss.max_health)
		boss_health_bar.value = health_percentage * 100
		boss_health_label.text = current_boss.boss_name + ": " + str(current_boss.current_health) + " / " + str(current_boss.max_health)
	else:
		boss_health_container.visible = false

func find_current_boss():
	# 보스 그룹에서 찾기
	var bosses = get_tree().get_nodes_in_group("boss")
	if bosses.size() > 0:
		current_boss = bosses[0]
