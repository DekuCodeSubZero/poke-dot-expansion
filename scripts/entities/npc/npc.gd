@tool
class_name Npc
extends Entity

@export var npcController: NpcController

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		return
	if character == null:
		push_error("Npc: 'character' está vacío; asígnale un NpcData desde el Inspector.")
		return
	if not character is NpcData:
		push_error("Npc: 'character' no es un NpcData.")

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var Datos:NpcData = character as NpcData
	if Datos == null or npcController == null:
		return
	npcController.AplicarComportamiento(self, Datos.npcBehaviour, delta)
