extends CharacterBody2D
class_name BaseBoss

# 공통 보스 속성들
@export var max_health: int = 100
@export var damage: int = 20
@export var boss_name: String = "Boss"

var current_health: int
var player: Node = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# 히트박스
var hitbox_area: Area2D

# 보스 상태
enum BossState {
	IDLE,
	ATTACKING,
	DAMAGED,
	DEAD
}

var current_state: BossState = BossState.IDLE

func _ready():
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	
	# 보스를 "boss" 그룹에 추가
	add_to_group("boss")
	
	# 히트박스 생성
	create_hitbox()
	
	# 자식 클래스에서 오버라이드할 수 있도록 호출
	boss_ready()

func _physics_process(delta):
	if current_state == BossState.DEAD:
		return
		
	# 중력 적용
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 자식 클래스에서 구현할 물리 처리
	boss_physics_process(delta)
	
	move_and_slide()

# 데미지 받기 (모든 보스 공통)
func take_damage(damage_amount: int):
	if current_state == BossState.DEAD:
		return
		
	current_health -= damage_amount
	print(boss_name, " took ", damage_amount, " damage! Current health: ", current_health)
	
	# 데미지 받을 때 상태 변경
	current_state = BossState.DAMAGED
	on_damage_taken(damage_amount)
	
	if current_health <= 0:
		die()

# 죽음 처리 (모든 보스 공통)
func die():
	current_state = BossState.DEAD
	print(boss_name, " has been defeated!")
	on_death()
	
	# 죽음 애니메이션이나 이펙트 후 제거
	await get_tree().create_timer(1.0).timeout
	queue_free()

# 플레이어와의 거리 계산
func get_distance_to_player() -> float:
	if player:
		return global_position.distance_to(player.global_position)
	return 0.0

# 플레이어 방향 벡터 계산
func get_direction_to_player() -> Vector2:
	if player:
		return (player.global_position - global_position).normalized()
	return Vector2.ZERO

# 플레이어가 오른쪽에 있는지 확인
func is_player_to_right() -> bool:
	if player:
		return player.global_position.x > global_position.x
	return false

# 히트박스 생성
func create_hitbox():
	hitbox_area = Area2D.new()
	hitbox_area.add_to_group("boss_hitbox")
	add_child(hitbox_area)
	
	# 기본 히트박스 콜리전 생성
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(64, 64) # 기본 크기, 자식 클래스에서 수정 가능
	collision_shape.shape = shape
	hitbox_area.add_child(collision_shape)

# 자식 클래스에서 오버라이드할 가상 함수들
func boss_ready():
	# 자식 클래스에서 구체적인 초기화 구현
	pass

func boss_physics_process(delta: float):
	# 자식 클래스에서 구체적인 물리 처리 구현
	pass

func on_damage_taken(damage_amount: int):
	# 자식 클래스에서 데미지 받을 때의 반응 구현
	pass

func on_death():
	# 자식 클래스에서 죽을 때의 처리 구현
	pass
