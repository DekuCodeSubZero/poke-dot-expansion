class_name MovementController
extends Node

var SeMueve: bool = false
var TargetDireccion: Vector2 = Vector2.ZERO
var DireccionActual: Vector2 = Vector2.DOWN
var EsPrimerPaso: bool = false

func AplicarMovimiento(character: Node2D, data: CharacterGame, direccion: Vector2, EstaCorriendo: bool, delta: float) -> Vector2:
	if(!SeMueve && direccion != Vector2.ZERO):
		DireccionActual = direccion
		TargetDireccion = character.position + (direccion * Globals.TILE_SIZE)
		SeMueve = true
		EsPrimerPaso = !EsPrimerPaso
	if(SeMueve):
		var speed: float = data.runSpeed if EstaCorriendo else data.walkSpeed
		var PixelSpeed: float = speed * Globals.TILE_SIZE
		var NuevaPos: Vector2 = character.position.move_toward(TargetDireccion, PixelSpeed * delta)
		if (NuevaPos.is_equal_approx(TargetDireccion)):
			NuevaPos = TargetDireccion
			SeMueve = false
		return NuevaPos
	return character.position
