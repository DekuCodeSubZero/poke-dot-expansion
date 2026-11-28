class_name NpcController
extends Node

var DirElegida: Vector2 = Vector2.DOWN
var TiempoRestante: float = 0.0
var Rotando: bool = false
var DesplazamientoPasos: Vector2i = Vector2i.ZERO

func _ready() -> void:
	TiempoRestante = randf_range(0.0, 2.5)

func AplicarComportamiento(npc: Entity ,behaviourID: ObjEventMovement.MovementTypeID, delta: float) -> void:
	if npc.movementController == null or npc.animController == null:
		return
	if behaviourID == ObjEventMovement.MovementTypeID.NONE:
		return
	if ObjEventMovement.DIRECCIONES_PERMITIDAS.has(behaviourID):
		VerificarDireccionPermitida(npc, behaviourID, delta)
	elif ObjEventMovement.DIRECCION_HORARIA.has(behaviourID):
		VerificarRotacionHoraria(npc, behaviourID)
	elif ObjEventMovement.DIRECCIONES_WANDER.has(behaviourID):
		VerificarCaminarAleatoreamente(npc, behaviourID, delta)
	npc.animController.AplicarAnimacion(npc.AnimacionChar, npc.movementController.DireccionActual, npc.movementController.SeMueve, false, npc.movementController.EsPrimerPaso)


# --Helpers--
func VerificarDireccionPermitida(npc: Entity ,behaviourID: ObjEventMovement.MovementTypeID, delta: float) -> void:
	var Direcciones: Array = ObjEventMovement.DIRECCIONES_PERMITIDAS[behaviourID]
	if Direcciones.size() == 1:
		npc.movementController.DireccionActual = Direcciones[0]
	else:
		TiempoRestante -= delta
		if TiempoRestante <= 0.0:
			DirElegida = Direcciones.pick_random()
			npc.movementController.DireccionActual = DirElegida
			TiempoRestante = randf_range(0.8, 2.0)

func VerificarRotacionHoraria(npc: Entity ,behaviourID: ObjEventMovement.MovementTypeID) -> void:
	if Rotando:
		return
	Rotando = true
	var DireccionesHorarias: Array = ObjEventMovement.DIRECCION_HORARIA[behaviourID]
	for i in DireccionesHorarias:
			npc.movementController.DireccionActual = i
			await get_tree().create_timer(1.0).timeout
			if not is_instance_valid(npc):
				return
	Rotando = false

func VerificarCaminarAleatoreamente(npc: Entity, behaviourID: ObjEventMovement.MovementTypeID, delta: float) -> void:
	var DirPaso: Vector2 = Vector2.ZERO
	if not npc.movementController.SeMueve:
		TiempoRestante -= delta
		if TiempoRestante <= 0.0:
			var Dirs: Array = ObjEventMovement.DIRECCIONES_WANDER[behaviourID]
			var Candidata: Vector2 = Dirs.pick_random()
			var NuevoDesplazamiento: Vector2i = DesplazamientoPasos + Vector2i(Candidata)
			var Rango: Vector2i = (npc.character as NpcData).RangoMovimiento
			if abs(NuevoDesplazamiento.x) <= Rango.x and abs(NuevoDesplazamiento.y) <= Rango.y:
				DirPaso = Candidata
				DesplazamientoPasos = NuevoDesplazamiento
			else:
				npc.movementController.DireccionActual = Candidata
			TiempoRestante = randf_range(1.0, 2.5)
	npc.position = npc.movementController.AplicarMovimiento(npc, npc.character, DirPaso, false, delta)
