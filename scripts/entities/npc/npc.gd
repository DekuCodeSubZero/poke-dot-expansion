@tool
class_name Npc
extends Entity

func _ready() -> void:
	super._ready()
	# Un solo aviso al iniciar (antes era un printerr en cada physics frame).
	# En el editor ya lo cubre _get_configuration_warnings() de Entity.
	if not Engine.is_editor_hint() and character == null:
		push_error("Npc: 'character' está vacío; asígnale un CharacterGame desde el Inspector.")
