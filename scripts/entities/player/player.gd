@tool
class_name Player
extends Node2D

@export var character: CharacterGame:
	set(value):
		if character != null and character.changed.is_connected(_actualizar_vista_editor):
			character.changed.disconnect(_actualizar_vista_editor)
		character = value
		if character != null and not character.changed.is_connected(_actualizar_vista_editor):
			character.changed.connect(_actualizar_vista_editor)
		_actualizar_vista_editor()
@export_group("Controladores")
@export var movementController: MovementController:
	set(value):
		movementController = value
		_actualizar_vista_editor()
@export var animController: AnimController:
	set(value):
		animController = value
		_actualizar_vista_editor()
@export var graphicsController: GraphicsController:
	set(value):
		graphicsController = value
		_actualizar_vista_editor()
@onready var AnimacionChar: AnimatedSprite2D = $Sprite
@onready var ShadowSprite: Sprite2D = $Shadow

var EstaCorriendo: bool = false

func _ready() -> void:
	if character != null and not character.changed.is_connected(_actualizar_vista_editor):
		character.changed.connect(_actualizar_vista_editor)
	_actualizar_vista_editor()

func _actualizar_vista_editor() -> void:
	if not is_inside_tree() or not is_node_ready():
		return
	if character != null and graphicsController != null:
		graphicsController.AplicarGraficos(AnimacionChar, ShadowSprite, character.charGraphic, character.charShadowGraphic)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if (character == null):
		printerr("character esta vacio, debes ingresar un tipo de recurso desde el inspector.")
		return
	var direccion: Vector2 = Vector2.ZERO
	if (Input.is_action_pressed("buttonDown")):
		direccion = Vector2.DOWN
	elif (Input.is_action_pressed("buttonLeft")):
		direccion = Vector2.LEFT
	elif (Input.is_action_pressed("buttonRight")):
		direccion = Vector2.RIGHT
	elif (Input.is_action_pressed("buttonUp")):
		direccion = Vector2.UP
	EstaCorriendo = ((direccion != Vector2.ZERO) && (Input.is_action_pressed("buttonB")))
	position = movementController.AplicarMovimiento(self, character, direccion, EstaCorriendo, delta)
	animController.AplicarAnimacion(AnimacionChar, movementController.DireccionActual, movementController.SeMueve, EstaCorriendo, movementController.EsPrimerPaso)
