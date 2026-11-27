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

const MARGEN_BORDE: int = 12
## Firma del estado anterior (mapSize + área usada de cada capa) para saber si algo cambió.
var _UltimaFirma: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		CambioEnAtributos()
		return
	if mapAttributes == null:
		return
	MusicManager.ReproducirMapa(mapAttributes.mapMusic)
	GenerarBordeInfinito()

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint() or mapAttributes == null:
		return
	var Firma: int = _calcular_firma()
	if Firma == _UltimaFirma:
		return
	_UltimaFirma = Firma
	update_configuration_warnings()

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
	return Firma

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
	return Avisos

# --- Dibujo -----------------------------------------------------------------

func _draw() -> void:
	if not Engine.is_editor_hint() or not _mapa_valido():
		return
	var TamanoPixeles: Vector2 = Vector2(mapAttributes.mapSize) * Globals.TILE_SIZE
	var ColorCuadricula: Color = Color(1.0, 1.0, 1.0, 0.15)
	for x in range(1, mapAttributes.mapSize.x):
		var pos_x: float = x * Globals.TILE_SIZE
		draw_line(Vector2(pos_x, 0), Vector2(pos_x, TamanoPixeles.y), ColorCuadricula, 1.0)
	for y in range(1, mapAttributes.mapSize.y):
		var pos_y: float = y * Globals.TILE_SIZE
		draw_line(Vector2(0, pos_y), Vector2(TamanoPixeles.x, pos_y), ColorCuadricula, 1.0)
	var Rect: Rect2 = Rect2(Vector2.ZERO, TamanoPixeles)
	draw_rect(Rect, Color.LIGHT_GREEN, false, 2.0)

func CambioEnAtributos() -> void:
	_UltimaFirma = 0 # fuerza a _process a recalcular avisos en el siguiente frame
	queue_redraw()
	update_configuration_warnings()
