@tool
class_name GameMap
extends Node2D

@export var mapAttributes: MapAttributes:
	set(valor):
		if is_instance_valid(mapAttributes) and mapAttributes.changed.is_connected(CambioEnAtributos):
			mapAttributes.changed.disconnect(CambioEnAtributos)
		mapAttributes = valor
		if is_instance_valid(mapAttributes) and not mapAttributes.changed.is_connected(CambioEnAtributos):
			mapAttributes.changed.connect(CambioEnAtributos)
		CambioEnAtributos()

## Borra las celdas pintadas fuera de mapSize. Es DESTRUCTIVO y no se puede deshacer
## con Ctrl+Z, por eso solo se ejecuta cuando pulsas este botón.
@export_tool_button("Limpiar tiles fuera del mapa", "Clear")
var BotonLimpiar: Callable = _limpiar_todos_los_tiles

## Si está activo, en el editor los ObjEvents (hijos de EventObj) se alinean solos a la
## cuadrícula de 16x16. En juego nunca actúa, ahí las entidades se mueven libremente.
@export var AlinearObjEventsEnEditor: bool = true

## Alinea de una vez todos los ObjEvents, útil si desactivaste la opción de arriba.
@export_tool_button("Alinear ObjEvents a la cuadrícula", "SnapGrid")
var BotonAlinear: Callable = _alinear_obj_events_manual

const MARGEN_BORDE: int = 12
## Firma del estado anterior (mapSize + área usada de cada capa) para saber si algo cambió.
var _UltimaFirma: int = 0

func _ready() -> void:
	AsegurarGrilla()
	if Engine.is_editor_hint():
		CambioEnAtributos()
		return
	if mapAttributes == null:
		return
	MusicManager.ReproducirMapa(mapAttributes.mapMusic)
	MapPopup.IniciarPopUp(mapAttributes.mapName)
	GenerarBordeInfinito()

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	if AlinearObjEventsEnEditor:
		_alinear_obj_events()
	if mapAttributes == null:
		return
	var Firma: int = _calcular_firma()
	if Firma == _UltimaFirma:
		return
	_UltimaFirma = Firma
	update_configuration_warnings()
	_redibujar_grilla()

# --- Utilidades -------------------------------------------------------------

func _mapa_valido() -> bool:
	return mapAttributes != null and mapAttributes.mapSize.x > 0 and mapAttributes.mapSize.y > 0

func _obtener_limite() -> Rect2i:
	return Rect2i(Vector2i.ZERO, mapAttributes.mapSize)

## Devuelve solo los hijos que realmente son TileMapLayer (ignora cualquier otro nodo).
func _obtener_capas() -> Array[TileMapLayer]:
	var Capas: Array[TileMapLayer] = []
	var Contenedor: Node = get_node_or_null("TileSet")
	if Contenedor == null:
		return Capas
	for Hijo in Contenedor.get_children():
		if Hijo is TileMapLayer:
			Capas.append(Hijo as TileMapLayer)
	return Capas

func _calcular_firma() -> int:
	var Firma: int = hash(mapAttributes.mapSize)
	for Capa in _obtener_capas():
		Firma = Firma * 31 + hash(Capa.get_used_rect())
	for Obj in ObtenerObjEvents():
		Firma = Firma * 31 + hash(Obj.position)
	return Firma

# --- ObjEvents sobre la cuadrícula -------------------------------------------

## Devuelve los Node2D hijos de EventObj (los ObjEvents del mapa).
func ObtenerObjEvents() -> Array[Node2D]:
	var Lista: Array[Node2D] = []
	var Contenedor: Node = get_node_or_null("EventObj")
	if Contenedor == null:
		return Lista
	for Hijo in Contenedor.get_children():
		if Hijo is Node2D:
			Lista.append(Hijo as Node2D)
	return Lista

## Casilla (en coordenadas de mapa) en la que está una posición en píxeles.
func CeldaDe(pos: Vector2) -> Vector2i:
	return Vector2i((pos / float(Globals.TILE_SIZE)).floor())

## Posición en píxeles de la esquina de la casilla más cercana.
func PosicionAlineada(pos: Vector2) -> Vector2:
	return pos.snapped(Vector2(Globals.TILE_SIZE, Globals.TILE_SIZE))

## Alinea cada ObjEvent a su casilla más cercana y regresa cuántos tuvo que mover.
func _alinear_obj_events() -> int:
	var Movidos: int = 0
	for Obj in ObtenerObjEvents():
		var Alineada: Vector2 = PosicionAlineada(Obj.position)
		if not Obj.position.is_equal_approx(Alineada):
			Obj.position = Alineada
			Movidos += 1
	if Movidos > 0:
		_marcar_escena_modificada()
	return Movidos

func _alinear_obj_events_manual() -> void:
	if not Engine.is_editor_hint():
		return
	var Movidos: int = _alinear_obj_events()
	print("GameMap: se alinearon %d ObjEvents a la cuadrícula." % Movidos)

## Un cambio hecho por script no marca la escena como modificada, así que se lo avisamos
## al editor para que Ctrl+S realmente guarde la posición corregida.
func _marcar_escena_modificada() -> void:
	if not Engine.has_singleton("EditorInterface"):
		return
	var Interfaz: Object = Engine.get_singleton("EditorInterface")
	if Interfaz.has_method("mark_scene_as_unsaved"):
		Interfaz.call("mark_scene_as_unsaved")

func _redibujar_grilla() -> void:
	var Grilla: Node = get_node_or_null("GrillaEditor")
	if Grilla != null:
		Grilla.queue_redraw()

func GenerarBordeInfinito() -> void:
	if not _mapa_valido():
		return
	var CapaBorde: TileMapLayer = get_node_or_null("Behaviour/Borde") as TileMapLayer
	if CapaBorde == null:
		return
	CapaBorde.visible = false
	var RectPatron: Rect2i = CapaBorde.get_used_rect()
	if not RectPatron.has_area():
		return
	var VisualBorde: TileMapLayer = TileMapLayer.new()
	VisualBorde.name = "BordeGenerado"
	VisualBorde.tile_set = CapaBorde.tile_set
	VisualBorde.z_index = CapaBorde.z_index
	add_child(VisualBorde)
	var LimiteMapa: Rect2i = Rect2i(Vector2i.ZERO, mapAttributes.mapSize)
	var MinX: int = -MARGEN_BORDE
	var MaxX: int = mapAttributes.mapSize.x + MARGEN_BORDE
	var MinY: int = -MARGEN_BORDE
	var MaxY: int = mapAttributes.mapSize.y + MARGEN_BORDE
	for x in range(MinX, MaxX):
		for y in range(MinY, MaxY):
			var CeldaDestino: Vector2i = Vector2i(x, y)
			if LimiteMapa.has_point(CeldaDestino):
				continue
			var PatronX: int = RectPatron.position.x + posmod(x, RectPatron.size.x)
			var PatronY: int = RectPatron.position.y + posmod(y, RectPatron.size.y)
			var CeldaOrigen: Vector2i = Vector2i(PatronX, PatronY)
			var SourceID: int = CapaBorde.get_cell_source_id(CeldaOrigen)
			if SourceID != -1:
				var AtlasCoords: Vector2i = CapaBorde.get_cell_atlas_coords(CeldaOrigen)
				var Alternative: int = CapaBorde.get_cell_alternative_tile(CeldaOrigen)
				VisualBorde.set_cell(CeldaDestino, SourceID, AtlasCoords, Alternative)

# --- Limpieza (solo bajo demanda) ------------------------------------------

func _limpiar_todos_los_tiles() -> void:
	if not Engine.is_editor_hint() or not _mapa_valido():
		return
	var Limite: Rect2i = _obtener_limite()
	var Borradas: int = 0
	for Capa in _obtener_capas():
		Borradas += _limpiar_capa(Capa, Limite)
	print("GameMap: se borraron %d celdas fuera del mapa." % Borradas)
	update_configuration_warnings()

func _limpiar_capa(capa: TileMapLayer, limite: Rect2i) -> int:
	var Borradas: int = 0
	for Celda: Vector2i in capa.get_used_cells():
		if not limite.has_point(Celda):
			capa.erase_cell(Celda)
			Borradas += 1
	return Borradas

# --- Avisos en el editor (triángulo amarillo en el árbol de escena) ---------

func _get_configuration_warnings() -> PackedStringArray:
	var Avisos: PackedStringArray = PackedStringArray()
	if mapAttributes == null:
		Avisos.append("Falta asignar un MapAttributes.")
		return Avisos
	if not _mapa_valido():
		Avisos.append("mapSize debe ser mayor que cero en X e Y.")
		return Avisos
	var Limite: Rect2i = _obtener_limite()
	for Capa in _obtener_capas():
		var Usado: Rect2i = Capa.get_used_rect()
		if Usado.has_area() and not Limite.encloses(Usado):
			Avisos.append("%s tiene celdas fuera del mapa. Usa el botón 'Limpiar tiles fuera del mapa' si quieres borrarlas." % Capa.name)
	for Obj in ObtenerObjEvents():
		var Celda: Vector2i = CeldaDe(Obj.position)
		if not Limite.has_point(Celda):
			Avisos.append("%s está fuera del mapa (casilla %s)." % [Obj.name, Celda])
		elif not AlinearObjEventsEnEditor and not Obj.position.is_equal_approx(PosicionAlineada(Obj.position)):
			Avisos.append("%s no está alineado a la cuadrícula (posición %s). Usa el botón 'Alinear ObjEvents a la cuadrícula'." % [Obj.name, Obj.position])
	return Avisos

# --- Dibujo -----------------------------------------------------------------

func AsegurarGrilla() -> void:
	if get_node_or_null("GrillaEditor") != null:
		return
	var Grilla: Node2D = GrillaEditor.new()
	Grilla.name = "GrillaEditor"
	Grilla.z_as_relative = false
	Grilla.z_index = 100
	add_child(Grilla)

func CambioEnAtributos() -> void:
	_UltimaFirma = 0
	_redibujar_grilla()
	update_configuration_warnings()

class GrillaEditor extends Node2D:
	const COLOR_OBJ_DENTRO: Color = Color(0.2, 0.6, 1.0, 0.35)
	const COLOR_OBJ_FUERA: Color = Color(1.0, 0.2, 0.2, 0.45)

	func _draw() -> void:
		var Mapa:GameMap = get_parent() as GameMap
		if Mapa == null or not Engine.is_editor_hint():
			return
		if Mapa.mapAttributes == null:
			return
		if Mapa.mapAttributes.mapSize.x <= 0 or Mapa.mapAttributes.mapSize.y <= 0:
			return
		var TamanoPixeles: Vector2 = Vector2(Mapa.mapAttributes.mapSize) * Globals.TILE_SIZE
		var ColorCuadricula: Color = Color(1.0, 1.0, 1.0, 0.15)
		for x in range(1, Mapa.mapAttributes.mapSize.x):
			var pos_x: float = x * Globals.TILE_SIZE
			draw_line(Vector2(pos_x, 0), Vector2(pos_x, TamanoPixeles.y), ColorCuadricula, 1.0)
		for y in range(1, Mapa.mapAttributes.mapSize.y):
			var pos_y: float = y * Globals.TILE_SIZE
			draw_line(Vector2(0, pos_y), Vector2(TamanoPixeles.x, pos_y), ColorCuadricula, 1.0)
		draw_rect(Rect2(Vector2.ZERO, TamanoPixeles), Color.LIGHT_GREEN, false, 1.0)
		# Casilla que ocupa cada ObjEvent: azul si está dentro del mapa, roja si está fuera.
		var Limite: Rect2i = Rect2i(Vector2i.ZERO, Mapa.mapAttributes.mapSize)
		for Obj in Mapa.ObtenerObjEvents():
			var Celda: Vector2i = Mapa.CeldaDe(Obj.position)
			var Relleno: Color = COLOR_OBJ_DENTRO if Limite.has_point(Celda) else COLOR_OBJ_FUERA
			var Rect: Rect2 = Rect2(Vector2(Celda * Globals.TILE_SIZE), Vector2(Globals.TILE_SIZE, Globals.TILE_SIZE))
			draw_rect(Rect, Relleno)
			draw_rect(Rect, Relleno.lightened(0.4), false, 1.0)
