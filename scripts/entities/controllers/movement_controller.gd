class_name MovementController
extends Node

var SeMueve: bool = false
## Posición (en píxeles) a la que debe llegar la entidad al terminar el paso actual.
var TargetPosicion: Vector2 = Vector2.ZERO
var DireccionActual: Vector2 = Vector2.DOWN
var EsPrimerPaso: bool = false

func AplicarMovimiento(character: Node2D, data: CharacterGame, direccion: Vector2, EstaCorriendo: bool, delta: float) -> Vector2:
	var speed: float = data.runSpeed if EstaCorriendo else data.walkSpeed
	# "Presupuesto" = píxeles que podemos avanzar en este tick.
	var Presupuesto: float = speed * Globals.TILE_SIZE * delta
	var Pos: Vector2 = character.position
	# 1) Si hay un paso en curso, avanzamos. Si llegamos, sobra presupuesto
	#    que se aprovecha para encadenar el siguiente paso en este mismo tick.
	if SeMueve:
		var Distancia: float = Pos.distance_to(TargetPosicion)
		if Presupuesto >= Distancia:
			Pos = TargetPosicion
			Presupuesto -= Distancia
			SeMueve = false
		else:
			Pos = Pos.move_toward(TargetPosicion, Presupuesto)
			Presupuesto = 0.0
	# 2) Si estamos quietos y hay input, iniciamos un paso nuevo. Esto ocurre en el
	#    MISMO tick en que terminó el anterior, así SeMueve nunca queda en false
	#    entre casillas (era lo que causaba el frame de idle / parpadeo).
	if not SeMueve and direccion != Vector2.ZERO:
		DireccionActual = direccion
		TargetPosicion = Pos + (direccion * Globals.TILE_SIZE)
		SeMueve = true
		EsPrimerPaso = not EsPrimerPaso
		Pos = Pos.move_toward(TargetPosicion, Presupuesto)
	return Pos
