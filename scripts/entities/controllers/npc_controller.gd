class_name NpcController
extends Node

var DirElegida: Vector2 = Vector2.DOWN
var TiempoRestante: float = 0.0

func AplicarComportamiento(npc: Entity ,behaviourID: ObjEventMovement.MovementTypeID, delta: float) -> void:
	if npc.movementController == null or npc.animController == null:
		return
	if behaviourID == ObjEventMovement.MovementTypeID.NONE:
		print("sin comportamientos")
		return
	VerificarDireccionPermitida(npc, behaviourID, delta)
	match (behaviourID):
		ObjEventMovement.MovementTypeID.WANDER_AROUND:
			print("caminando aleatoreamente")
	npc.animController.AplicarAnimacion(npc.AnimacionChar, npc.movementController.DireccionActual, npc.movementController.SeMueve, false, npc.movementController.EsPrimerPaso)


# --Helpers--
func VerificarDireccionPermitida(npc: Entity ,behaviourID: ObjEventMovement.MovementTypeID, delta: float) -> void:
	if ObjEventMovement.DIRECCIONES_PERMITIDAS.has(behaviourID):
		var Direcciones: Array = ObjEventMovement.DIRECCIONES_PERMITIDAS[behaviourID]
		if Direcciones.size() == 1:
			npc.movementController.DireccionActual = Direcciones[0]
		else:
			TiempoRestante -= delta
			if TiempoRestante <= 0.0:
				DirElegida = Direcciones.pick_random()
				npc.movementController.DireccionActual = DirElegida
				TiempoRestante = randf_range(0.8, 2.0)
