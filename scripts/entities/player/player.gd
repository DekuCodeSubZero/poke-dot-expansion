@tool
class_name Player
extends Node2D

@export var character: CharacterGame:
	set(value):
		if character != null and character.changed.is_connected(_on_character_changed):
			character.changed.disconnect(_on_character_changed)
		character = value
		if character != null and not character.changed.is_connected(_on_character_changed):
			character.changed.connect(_on_character_changed)
		_actualizar_graficos()

@export_group("Controladores")
@export var movementController: MovementController
@export var animController: AnimController
@export var graphicsController: GraphicsController

@onready var AnimacionChar: AnimatedSprite2D = $Sprite
@onready var ShadowSprite: Sprite2D = $Sprite/Shadow

var EstaCorriendo: bool = false
var _ultimo_graphic: int = -1
var _ultimo_shadow: int = -1

func _ready() -> void:
	if character != null and not character.changed.is_connected(_on_character_changed):
		character.changed.connect(_on_character_changed)
	_actualizar_graficos()

func _process(_delta: float) -> void:
	# Solo en el editor: detecta cambios aunque la señal falle
	if not Engine.is_editor_hint():
		return
	if character == null:
		return
	if character.charGraphic != _ultimo_graphic or character.charShadowGraphic != _ultimo_shadow:
		_actualizar_graficos()

func _on_character_changed() -> void:
	_actualizar_graficos()

func _actualizar_graficos() -> void:
	if not is_inside_tree():
		return
	if character == null or graphicsController == null:
		return
	if AnimacionChar == null:
		return

	_ultimo_graphic = character.charGraphic
	_ultimo_shadow = character.charShadowGraphic

	graphicsController.AplicarGraficos(
		AnimacionChar,
		ShadowSprite,
		character.charGraphic,
		character.charShadowGraphic
	)

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
