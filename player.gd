extends CharacterBody2D

const WALK_SPEED := 130.0
const RUN_SPEED := 250.0
const JUMP_VELOCITY := -300.0

var is_attacking := false
var is_shooting := false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
@onready var bullet_spawn: Marker2D = $BulletSpawn  # Make sure this is a Marker2D in your scene

func _ready() -> void:
	if not animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		animated_sprite.play("attack")
		velocity.x = 0
		return

	if Input.is_action_just_pressed("fire") and not is_shooting:
		fire()

	var direction := Input.get_axis("move_left", "move_right")
	var speed := RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED

	if direction != 0:
		velocity.x = direction * speed
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0.0, WALK_SPEED)

	if not is_attacking and not is_shooting:
		if not is_on_floor():
			animated_sprite.play("jump")
		elif direction != 0:
			animated_sprite.play("run" if speed == RUN_SPEED else "walk")
		else:
			animated_sprite.play("idle")

	move_and_slide()

func fire() -> void:
	is_shooting = true
	animated_sprite.play("shot")

	var bullet = bullet_scene.instantiate()
	var facing_left = animated_sprite.flip_h

	bullet.pos = bullet_spawn.global_position
	bullet.dir = PI if facing_left else 0
	bullet.rota = PI if facing_left else 0
	bullet.facing_left = facing_left  # Bullet will visually flip based on this

	get_tree().current_scene.add_child(bullet)

func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false
	elif animated_sprite.animation == "shot":
		is_shooting = false
