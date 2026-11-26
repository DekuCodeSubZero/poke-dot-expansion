@tool
class_name ObjEvents
extends Resource

## IMPORTANTE: estos enums se guardan como ENTEROS dentro de los .tscn / .tres
## (por ejemplo `charGraphic = 1` en player.tscn).
## - NUNCA cambies el valor de un ID existente.
## - NUNCA insertes uno nuevo en medio: agrégalo siempre al final con el siguiente número.
## Si no, los datos ya guardados cambian de significado sin ningún error.
enum owID {
	OBJ_NONE = 0,
	OBJ_KAEL_NORMAL = 1,
	OBJ_KAEL_RUN = 2,
	OBJ_KAIDA_NORMAL = 3,
	OBJ_KAIDA_RUN = 4,
}

enum owShadowID {
	NONE = 0,
	S = 1,
	M = 2,
	L = 3,
	XL = 4,
}

## OBJ_NONE se deja vacío a propósito (= "sin gráfico").
## OBJ_KAEL_RUN y OBJ_KAIDA_RUN NO están aquí todavía porque aún no existen sus PNG.
## Cuando los agregues, ponlos en este diccionario; mientras tanto el juego avisa.
const owGraphics: Dictionary = {
	owID.OBJ_NONE: "",
	owID.OBJ_KAEL_NORMAL: "res://graphics/obj_event/kael/normal.png",
	owID.OBJ_KAIDA_NORMAL: "res://graphics/obj_event/kaida/normal.png",
}

const owShadowGraphics: Dictionary = {
	owShadowID.NONE: "",
	owShadowID.S: "res://graphics/obj_event/shadow/shadow_small.png",
	owShadowID.M: "res://graphics/obj_event/shadow/shadow_medium.png",
	owShadowID.L: "res://graphics/obj_event/shadow/shadow_large.png",
	owShadowID.XL: "res://graphics/obj_event/shadow/shadow_extra_large.png",
}

## true si el ID tiene una entrada en owGraphics (aunque sea vacía, como OBJ_NONE).
static func TieneGrafico(ID: owID) -> bool:
	return owGraphics.has(ID)

static func TieneSombra(ID: owShadowID) -> bool:
	return owShadowGraphics.has(ID)
