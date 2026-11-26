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
		_limpiar_todos_los_tiles()
		queue_redraw()

func _ready() -> void:
	if Engine.is_editor_hint():
		if is_instance_valid(mapAttributes) and not mapAttributes.changed.is_connected(CambioEnAtributos):
			mapAttributes.changed.connect(CambioEnAtributos)
		_limpiar_todos_los_tiles()
		queue_redraw()

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint() or mapAttributes == null:
		return
	if mapAttributes.mapSize.x <= 0 or mapAttributes.mapSize.y <= 0:
		return
	var contenedor:Node = get_node_or_null("TileSet")
	if contenedor == null:
		return
	var limite:Rect2i = Rect2i(Vector2i.ZERO, mapAttributes.mapSize)
	for hijo: TileMapLayer in contenedor.get_children():
		if hijo is TileMapLayer:
			var usado: Rect2i = hijo.get_used_rect()
			if usado.has_area() and not limite.encloses(usado):
				_limpiar_capa(hijo, limite)

func _limpiar_todos_los_tiles() -> void:
	if not Engine.is_editor_hint() or mapAttributes == null:
		return
	if mapAttributes.mapSize.x <= 0 or mapAttributes.mapSize.y <= 0:
		return
	var contenedor:Node = get_node_or_null("TileSet")
	if contenedor == null:
		return
	var limite: Rect2i = Rect2i(Vector2i.ZERO, mapAttributes.mapSize)
	for hijo: TileMapLayer in contenedor.get_children():
		if hijo is TileMapLayer:
			_limpiar_capa(hijo, limite)

func _limpiar_capa(capa: TileMapLayer, limite: Rect2i) -> void:
	for celda: Vector2i in capa.get_used_cells():
		if not limite.has_point(celda):
			capa.erase_cell(celda)

func _draw() -> void:
	if not Engine.is_editor_hint() or mapAttributes == null:
		return
	if mapAttributes.mapSize.x <= 0 or mapAttributes.mapSize.y <= 0:
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
	_limpiar_todos_los_tiles()
	queue_redraw()
