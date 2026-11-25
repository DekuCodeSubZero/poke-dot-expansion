class_name ObjEvents
extends Resource

enum owID {
	OBJ_NONE,
	OBJ_KAEL_NORMAL,
	OBJ_KAEL_RUN,
	OBJ_KAIDA_NORMAL,
	OBJ_KAIDA_RUN,
}

enum owShadowID {
	NONE,
	S,
	M,
	L,
	XL
}

const owGraphics: Dictionary = {
	owID.OBJ_NONE: "",
	owID.OBJ_KAEL_NORMAL: "res://graphics/obj_event/kael/normal.png",
	owID.OBJ_KAIDA_NORMAL: "res://graphics/obj_event/kaida/normal.png"
}

const owShadowGraphics: Dictionary = {
	owShadowID.NONE: "",
	owShadowID.S: "res://graphics/obj_event/shadow/shadow_small.png",
	owShadowID.M: "res://graphics/obj_event/shadow/shadow_medium.png",
	owShadowID.L: "res://graphics/obj_event/shadow/shadow_large.png",
	owShadowID.XL: "res://graphics/obj_event/shadow/shadow_extra_large.png",
}
