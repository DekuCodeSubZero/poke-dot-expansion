@tool
class_name Entity
extends Node2D

@export var character: CharacterGame:
	set(value):
		if character != null and character.changed.is_connected(AlCambiarCharacter):
			character.changed.disconnect(AlCambiarCharacter)
		character = value
		if character != null and not character.changed.is_connected(AlCambiarCharacter):
			character.changed.connect(AlCambiarCharacter)
		ActualizarGraficos()

@export_group("Controladores")
@export var movementController: MovementController
@export var animController: AnimController
@export var graphicsController: GraphicsController

@onready var AnimacionChar: AnimatedSprite2D = $Sprite
@onready var SombraChar: Sprite2D = $Sprite/Shadow

var UltimaVersionGrafica: int = -1

func _ready() -> void:
	if character != null and not character.changed.is_connected(AlCambiarCharacter):
		character.changed.connect(AlCambiarCharacter)
	ActualizarGraficos()

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint() or character == null:
		return
	var Version: int = int(character.charGraphic) * 1000 + int(character.charShadowGraphic)
	if Version == UltimaVersionGrafica:
		return
	UltimaVersionGrafica = Version
	ActualizarGraficos()

func AlCambiarCharacter() -> void:
	ActualizarGraficos()

func ActualizarGraficos() -> void:
	if not is_inside_tree():
		return
	if character == null or graphicsController == null or AnimacionChar == null:
		return
	UltimaVersionGrafica = int(character.charGraphic) * 1000 + int(character.charShadowGraphic)
	graphicsController.AplicarGraficos(AnimacionChar, SombraChar, character)
