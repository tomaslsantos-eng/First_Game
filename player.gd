extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -250.0
const GRAVITY = 800.0
const KICK_FORCE = 250.0

@onready var sprite = $Sprite2D   # 👈 ligar ao Sprite2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0

	
	if Input.is_action_pressed("rotate"):
		sprite.rotation_degrees = 180 * delta
	else:
		sprite.rotation_degrees = 0

	move_and_slide()

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var obj = collision.get_collider()

		if obj.name == "Bola":
			if position.x < obj.position.x:
				obj.velocity.x = KICK_FORCE
			else:
				obj.velocity.x = -KICK_FORCE
