class_name GameStart
extends Node

@export var EscenaPlayer: Player
@export var MapaInicial: MapSection.mapID = MapSection.mapID.MAPSEC_NONE
@export var Spawn: Vector2i = Vector2i.ZERO

@onready var MapContainer: Node2D = $MapContainer

var MapaActual: GameMap

func _ready() -> void:
	var PosPixeles: Vector2 = Vector2(Spawn) * Globals.TILE_SIZE
	CargarMapa(MapaInicial, PosPixeles)

func CargarMapa(IDmap: MapSection.mapID, PosicionDestino: Vector2) -> void:
	if EscenaPlayer == null:
		push_error("GameStart: No hay una escena Player asignada.")
		return
	if EscenaPlayer.get_parent() != self:
		EscenaPlayer.reparent(self)
	if MapaActual != null:
		MapaActual.queue_free()
		MapaActual = null
	var RutaMapa: String = MapSection.mapScene.get(IDmap, "")
	if RutaMapa.is_empty() or not ResourceLoader.exists(RutaMapa):
		push_error("GameStart: No se encontró el mapa con ID %s" % IDmap)
		return
	var NuevaEscena: PackedScene = load(RutaMapa) as PackedScene
	MapaActual = NuevaEscena.instantiate() as GameMap
	MapContainer.add_child(MapaActual)
	var ContenedorEventos: Node = MapaActual.get_node_or_null("EventObj")
	if ContenedorEventos != null:
		EscenaPlayer.reparent(ContenedorEventos)
	EscenaPlayer.position = PosicionDestino
