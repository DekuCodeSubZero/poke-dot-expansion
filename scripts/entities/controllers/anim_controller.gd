class_name AnimController
extends Node

func AplicarAnimacion(Animacion: AnimatedSprite2D, Direccion: Vector2, SeMueve: bool, EstaCorriendo: bool, EsPrimerPaso: bool) -> void:
	var Estado: String = "idle"
	if SeMueve:
		var Paso:String = "first_step" if EsPrimerPaso else "second_step"
		Estado = Paso
	var SufijoDir: String = ObtenerNombre(Direccion)
	var NombreAnim: String = Estado + "_" + SufijoDir
	if Animacion.animation != NombreAnim:
		Animacion.play(NombreAnim)

func ObtenerNombre(Direccion: Vector2) -> String:
	if Direccion == Vector2.UP: return "up"
	if Direccion == Vector2.DOWN: return "down"
	if Direccion == Vector2.LEFT: return "left"
	return "right"
