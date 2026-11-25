@tool
class_name GraphicsController
extends Node

static var _cache_frames: Dictionary = {}

func AplicarGraficos(Animacion: AnimatedSprite2D, SpriteShadow: Sprite2D, GraphicID: ObjEvents.owID, ShadowID: ObjEvents.owShadowID) -> void:
	if Animacion == null:
		return
	CambiarSpritesheet(Animacion, GraphicID)
	if SpriteShadow == null:
		return
	var ruta_shadow: String = ObjEvents.owShadowGraphics.get(ShadowID, "")
	if ruta_shadow != "" and ResourceLoader.exists(ruta_shadow):
		SpriteShadow.texture = load(ruta_shadow)
		SpriteShadow.visible = true
	else:
		SpriteShadow.texture = null
		SpriteShadow.visible = false

func CambiarSpritesheet(Animacion: AnimatedSprite2D, GraphicID: ObjEvents.owID) -> void:
	var ruta_char: String = ObjEvents.owGraphics.get(GraphicID, "")
	if ruta_char == "" or not ResourceLoader.exists(ruta_char) or Animacion.sprite_frames == null:
		Animacion.visible = false
		return
	Animacion.visible = true
	if not Engine.is_editor_hint() and _cache_frames.has(GraphicID):
		Animacion.sprite_frames = _cache_frames[GraphicID]
		return
	var nuevos_frames: SpriteFrames = Animacion.sprite_frames.duplicate(true)
	var nueva_textura: Texture2D = load(ruta_char)
	for anim_name in nuevos_frames.get_animation_names():
		for i in range(nuevos_frames.get_frame_count(anim_name)):
			var tex = nuevos_frames.get_frame_texture(anim_name, i)
			if tex is AtlasTexture:
				var nuevo_atlas := (tex as AtlasTexture).duplicate() as AtlasTexture
				nuevo_atlas.atlas = nueva_textura
				nuevos_frames.set_frame(anim_name, i, nuevo_atlas, nuevos_frames.get_frame_duration(anim_name, i))
	if not Engine.is_editor_hint():
		_cache_frames[GraphicID] = nuevos_frames
	Animacion.sprite_frames = nuevos_frames
	if Engine.is_editor_hint():
		Animacion.queue_redraw()
	var anim_actual = Animacion.animation
	var frame_actual = Animacion.frame

	Animacion.sprite_frames = null
	Animacion.sprite_frames = nuevos_frames
	Animacion.animation = anim_actual
	Animacion.frame = frame_actual
	Animacion.queue_redraw()
