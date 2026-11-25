@tool
class_name CharacterGame
extends Resource

@export var charID: int = 0
@export var charName: String = ""
@export var charGraphic: ObjEvents.owID = ObjEvents.owID.OBJ_NONE:
	set(value):
		if charGraphic == value:
			return
		charGraphic = value
		emit_changed()
@export var charShadowGraphic: ObjEvents.owShadowID = ObjEvents.owShadowID.NONE:
	set(value):
		if charShadowGraphic == value:
			return
		charShadowGraphic = value
		emit_changed()
@export var walkSpeed: float = 3.0
@export var runSpeed: float = 6.0
