@tool
class_name MapSection
extends RefCounted

enum mapID {
	MAPSEC_NONE,
	MAPSEC_PRADO_NATAL,
	MAPSEC_PUEBLO_ALBA,
}

enum mapRegionID {
	REGION_NONE,
	REGION_VALTHERION
}

const mapScene: Dictionary = {
	mapID.MAPSEC_NONE: "",
}
