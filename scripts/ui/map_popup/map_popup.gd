extends CanvasLayer

@onready var MapName: Label = $BG_Primary/Map_Name
@onready var Hora: Label = $BG_Secondary/Time
@onready var AnimPopUp: AnimationPlayer = $Popup_Anim

func _ready() -> void:
	visible = false

func IniciarPopUp(mapName: String) -> void:
	visible = true
	MapName.text = mapName
	Hora.text = _obtener_hora()
	AnimPopUp.play("Entrada")
	await AnimPopUp.animation_finished
	await get_tree().create_timer(2.0).timeout
	AnimPopUp.play("Salida")
	await AnimPopUp.animation_finished
	visible = false

func _obtener_hora() -> String:
	var ahora: Dictionary = Time.get_time_dict_from_system()
	var hora_12: int = ahora.hour % 12
	if hora_12 == 0:
		hora_12 = 12
	var periodo: String = "AM" if ahora.hour < 12 else "PM"
	return "%02d:%02d %s" % [hora_12, ahora.minute, periodo]
