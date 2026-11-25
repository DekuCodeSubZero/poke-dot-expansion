@tool
class_name GraphicsController
extends Node

static var CacheFrames: Dictionary = {}

func AplicarGraficos(Animacion: AnimatedSprite2D, Sombra: Sprite2D, Datos: CharacterGame) -> void:
	if Datos == null:
		return

	CambiarSpritesheet(Animacion, Datos.charGraphic)
	AplicarSombra(Sombra, Datos.charShadowGraphic)

func CambiarSpritesheet(Animacion: AnimatedSprite2D, GraphicID: ObjEvents.owID) -> void:
	if Animacion == null:
		return

	var RutaChar: String = ObjEvents.owGraphics.get(GraphicID, "")

	if RutaChar == "" or not ResourceLoader.exists(RutaChar) or Animacion.sprite_frames == null:
		Animacion.visible = false
		return

	Animacion.visible = true

	if not Engine.is_editor_hint() and CacheFrames.has(GraphicID):
		Animacion.sprite_frames = CacheFrames[GraphicID]
		return

	var NuevosFrames: SpriteFrames = Animacion.sprite_frames.duplicate(true)
	var NuevaTextura: Texture2D = load(RutaChar)

	for NombreAnim in NuevosFrames.get_animation_names():
		for i in range(NuevosFrames.get_frame_count(NombreAnim)):
			var Textura = NuevosFrames.get_frame_texture(NombreAnim, i)
			if Textura is AtlasTexture:
				var NuevoAtlas := (Textura as AtlasTexture).duplicate() as AtlasTexture
				NuevoAtlas.atlas = NuevaTextura
				NuevosFrames.set_frame(NombreAnim, i, NuevoAtlas, NuevosFrames.get_frame_duration(NombreAnim, i))

	if not Engine.is_editor_hint():
		CacheFrames[GraphicID] = NuevosFrames

	var AnimActual = Animacion.animation
	var FrameActual = Animacion.frame

	Animacion.sprite_frames = null
	Animacion.sprite_frames = NuevosFrames
	Animacion.animation = AnimActual
	Animacion.frame = FrameActual
	Animacion.queue_redraw()

func AplicarSombra(Sombra: Sprite2D, ShadowID: ObjEvents.owShadowID) -> void:
	if Sombra == null:
		return

	var RutaSombra: String = ObjEvents.owShadowGraphics.get(ShadowID, "")

	if RutaSombra != "" and ResourceLoader.exists(RutaSombra):
		Sombra.texture = load(RutaSombra)
		Sombra.visible = true
	else:
		Sombra.texture = null
		Sombra.visible = false
