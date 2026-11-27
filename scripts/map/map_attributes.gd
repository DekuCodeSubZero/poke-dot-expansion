@tool
class_name MapAttributes
extends Resource

@export var mapName: String = ""
@export var mapID: MapSection.mapID = MapSection.mapID.MAPSEC_NONE
@export var mapRegionID: MapSection.mapRegionID = MapSection.mapRegionID.REGION_NONE
@export var mapSize: Vector2i = Vector2i.ZERO:
	set(valor):
		mapSize = valor
		emit_changed()
@export var mapScripts: String ## --para más adelante--
@export var mapConnection: String ## --para más adelante--
@export var mapMusic: MusicID.MapMusicID = MusicID.MapMusicID.BGM_NONE
@export var mapWeather: String ## --para más adelante--
@export var mapBattleType: String ## --para más adelante--
@export var mapWildEncounter: String ## --para más adelante--

@export var showLocationName: bool = false
@export var isIndoor: bool = false
@export var allowDigEscapeRope: bool = false
@export var allowFly: bool = false
@export var requiresFlash: bool = false
