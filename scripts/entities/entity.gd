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
	z_as_relative = true
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
	# Refresca el triángulo amarillo del árbol de escena (solo hace algo en el editor).
	update_configuration_warnings()
	if character == null or graphicsController == null or AnimacionChar == null:
		return
	UltimaVersionGrafica = int(character.charGraphic) * 1000 + int(character.charShadowGraphic)
	graphicsController.AplicarGraficos(AnimacionChar, SombraChar, character)

## Avisos visibles en el editor: reemplazan al printerr que se repetía 60 veces por segundo.
func _get_configuration_warnings() -> PackedStringArray:
	var Avisos: PackedStringArray = PackedStringArray()
	if character == null:
		Avisos.append("Falta asignar un CharacterGame en 'character'.")
	elif not ObjEvents.TieneGrafico(character.charGraphic):
		Avisos.append("charGraphic no tiene ruta en ObjEvents.owGraphics; el sprite se ocultará.")
	if movementController == null:
		Avisos.append("Falta asignar movementController.")
	if animController == null:
		Avisos.append("Falta asignar animController.")
	if graphicsController == null:
		Avisos.append("Falta asignar graphicsController.")
	return Avisos
