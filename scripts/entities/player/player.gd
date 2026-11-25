@tool
class_name Player
extends Entity

var EstaCorriendo: bool = false

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if character == null:
		printerr("character esta vacio, debes ingresar un tipo de recurso desde el inspector.")
		return
	var Direccion: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("buttonDown"):
		Direccion = Vector2.DOWN
	elif Input.is_action_pressed("buttonLeft"):
		Direccion = Vector2.LEFT
	elif Input.is_action_pressed("buttonRight"):
		Direccion = Vector2.RIGHT
	elif Input.is_action_pressed("buttonUp"):
		Direccion = Vector2.UP
	EstaCorriendo = Direccion != Vector2.ZERO and Input.is_action_pressed("buttonB")
	position = movementController.AplicarMovimiento(self, character, Direccion, EstaCorriendo, delta)
	animController.AplicarAnimacion(AnimacionChar, movementController.DireccionActual, movementController.SeMueve, EstaCorriendo, movementController.EsPrimerPaso)
