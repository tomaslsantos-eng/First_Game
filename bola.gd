extends CharacterBody2D

const GRAVITY = 800.0
const FRICTION = 500.0
const WALL_BOUNCE = 0.8
const MIN_SPEED = 10.0

func _physics_process(delta: float) -> void:
	# gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# atrito no movimento horizontal
	if velocity.x > 0:
		velocity.x -= FRICTION * delta
		if velocity.x < 0:
			velocity.x = 0
	elif velocity.x < 0:
		velocity.x += FRICTION * delta
		if velocity.x > 0:
			velocity.x = 0

	move_and_slide()

	# colisões
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()

		# só inverter em paredes laterais
		if abs(normal.x) > 0.9:
			velocity.x = -velocity.x * WALL_BOUNCE

	# parar de vez se já estiver muito lenta
	if abs(velocity.x) < MIN_SPEED:
		velocity.x = 0
