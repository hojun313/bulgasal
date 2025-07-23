extends BaseBoss

const MIN_JUMP_VERTICAL_VELOCITY = -1100.0 # 점프 시 최소 수직 속도
const MAX_JUMP_VERTICAL_VELOCITY = -500.0 # 점프 시 최대 수직 속도
const JUMP_HORIZONTAL_VELOCITY = 400.0 # 점프 시 수평 속도

@onready var jump_timer = Timer.new()

func boss_ready():
	# SlimeKing 전용 초기화
	boss_name = "SlimeKing"
	max_health = 100
	damage = 25
	
	randomize() # Initialize random number generator

	add_child(jump_timer)
	jump_timer.wait_time = 3.0
	jump_timer.autostart = true
	jump_timer.timeout.connect(_on_jump_timer_timeout)
	jump_timer.start() # Explicitly start the timer

func boss_physics_process(delta: float):

	var collided_with_side_wall = false
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		# Check if the collision normal is primarily horizontal
		if abs(collision.get_normal().x) > 0.1: 
			collided_with_side_wall = true
			break

	if collided_with_side_wall:
		velocity.x *= -1 # Reverse horizontal velocity

	# If on floor and not currently jumping and no side wall collision occurred in this frame
	if is_on_floor() and abs(velocity.y) < 10 and not collided_with_side_wall:
		velocity.x = 0.0

func _on_jump_timer_timeout():
	if is_on_floor() and player:
		var direction_to_player_x = sign(player.global_position.x - global_position.x)

		velocity.x = direction_to_player_x * JUMP_HORIZONTAL_VELOCITY
		
		# Set random vertical jump velocity
		velocity.y = randf_range(MIN_JUMP_VERTICAL_VELOCITY, MAX_JUMP_VERTICAL_VELOCITY)
	else:
		pass # Cannot jump condition (silent)

func on_damage_taken(damage_amount: int):
	# SlimeKing이 데미지를 받을 때의 반응
	current_state = BossState.IDLE # 데미지 받고 바로 다시 행동

func on_death():
	# SlimeKing이 죽을 때의 처리
	jump_timer.stop()