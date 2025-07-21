extends CharacterBody2D

const SPEED = 100.0

var player = null

func _ready():
	# Find the player in the scene
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("Player not found in group 'player'. Make sure your player node is in this group.")

func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()
