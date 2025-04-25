extends CharacterBody2D

var pos: Vector2
var rota: float
var dir: float
var facing_left: bool = false  # For flipping the sprite

@export var speed: float = 600.0

@onready var sprite: Sprite2D = $Sprite2D  # Make sure your bullet has a Sprite2D as a child

func _ready() -> void:
	global_position = pos
	rotation = rota
	sprite.flip_h = facing_left

func _physics_process(delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(dir)
	move_and_slide()
