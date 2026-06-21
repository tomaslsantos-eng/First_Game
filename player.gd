extends CharacterBody2D

# --- Constantes de Física (As tuas originais) ---
const SPEED = 200.0
const JUMP_VELOCITY = -250.0
const GRAVITY = 800.0
const KICK_FORCE = 250.0        # Força ao empurrar a bola a caminhar

# --- Configurações do Remate Forte (Tecla X) ---
const REMATE_FORCE_X = 600.0    # Força horizontal do chute forte
const REMATE_FORCE_Y = -350.0   # Força vertical (negativo para a bola subir)
const KICK_DISTANCE = 70.0      # Distância máxima em píxeis para o chute acertar
const KICK_DURATION = 0.3       # Tempo que a imagem "kick" fica no ecrã

# --- Nós do Godot ---
@onready var sprite = $AnimatedSprite2D  

# --- Referência para a Bola ---
@export var ball: CharacterBody2D        # 👈 Arrastar a Bola para aqui no Inspector do Player

# --- Estados do Jogador ---
var is_kicking: bool = false


func _physics_process(delta: float) -> void:
	# 1. Aplicar Gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# 2. Lógica do Salto (Barra de Espaço / Enter)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Input de Chute Forte (Tecla X)
	if Input.is_action_just_pressed("chutar") and not is_kicking and ball:
		executar_remate_forte()

	# 4. Movimento Horizontal (Esquerda / Direita)
	if not is_kicking:
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction != 0:
			velocity.x = direction * SPEED
			sprite.flip_h = direction < 0
		else:
			velocity.x = 0
	else:
		velocity.x = 0

	# 5. O Teu Código de Rotação (De volta e intacto!)
	if Input.is_action_pressed("rotate"):
		sprite.rotation_degrees = 180 * delta
	else:
		sprite.rotation_degrees = 0

	# 6. Aplicar o Movimento do Jogador
	move_and_slide()

	# 7. Detetar Colisões Físicas (Empurrar a bola ao caminhar)
	verificar_colisoes_caminhar()


# --- Funções do Chute e Colisões ---

func executar_remate_forte() -> void:
	is_kicking = true
	sprite.play("kick") # Muda para a imagem da perna estendida
	
	# Calcula a distância entre o Player e a Bola
	var distancia = global_position.distance_to(ball.global_position)
	if distancia <= KICK_DISTANCE:
		# Define se a bola voa para a direita ou esquerda baseado na posição
		var direcao_chute = 1 if ball.global_position.x > global_position.x else -1
		
		# Aplica as forças diretamente na velocidade da bola
		ball.velocity.x = direcao_chute * REMATE_FORCE_X
		ball.velocity.y = REMATE_FORCE_Y

	# Espera 0.3 segundos para conseguires ver o boneco a chutar
	await get_tree().create_timer(KICK_DURATION).timeout
	sprite.play("default") # Volta ao boneco normal
	is_kicking = false


func verificar_colisoes_caminhar() -> void:
	# Lógica original para empurrar a bola só de caminhar contra ela
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var obj = collision.get_collider()

		if obj and obj.name == "Bola" and not is_kicking:
			if position.x < obj.position.x:
				obj.velocity.x = KICK_FORCE
			else:
				obj.velocity.x = -KICK_FORCE
