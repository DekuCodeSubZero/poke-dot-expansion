Poke-Dot-Expansion:
	es un proyecto hecho en Godot 4.7 (renderer GL Compatibility) que busca
	recrear en 2D la experiencia de un juego Pokémon al estilo de la GBA,
	tomando como referencia la organización de pokeemerald (ids con prefijo,
	tilesets primary y secondary, capas de mapa). Todo se hace a mano y cada
	sistema que se termina se documenta en la carpeta document/, el estado de lo
	que ya funciona y lo que falta está en document/estado.txt.

Como correrlo:
	abrir el proyecto con Godot 4.7, abrir la escena scenes/game/game_start.tscn
	y ejecutarla con F6 (ejecutar escena actual). Todavía no hay una escena
	principal definida en project.godot, por eso F5 pregunta cuál usar, si se
	elige game_start.tscn queda guardada. El mapa inicial y la casilla de inicio
	se cambian desde los exports MapaInicial y Spawn del nodo GameStart.

Estructura de carpetas:
	default_bus_layout.tres      buses de audio Music y SFX
	project.godot
	data/font/                   fuentes
	document/                    esta documentación
	graphics/
		obj_event/               spritesheets de personajes y sombras
		tileset/                 primary, secondary y collisions
	scenes/
		entities/player/         escena del Player
		game/                    game_start.tscn
		map/                     map_base.tscn y un mapa por carpeta
	scripts/
		core/music/              MusicID y MusicManager
		entities/                Entity, controladores, Player y recursos
		game/                    GameStart
		map/                     GameMap, MapAttributes y MapSection
	sfx/
		bgm/  me/  se/           audio en .ogg

Flujo general:
	1) GameStart._ready convierte el export Spawn de casillas a píxeles y llama
	a CargarMapa.
	2) CargarMapa busca la escena del mapa en MapSection.mapScene, la instancia
	dentro de MapContainer y ahí el mapa corre su _ready (GameMap), que reproduce
	su música con MusicManager y genera el borde.
	3) El Player se mueve al nodo EventObj del mapa y se coloca en el punto de inicio.
	4) En cada physics frame el Player lee el input, MovementController calcula
	la nueva posición y AnimController elige la animación, mientras que los
	gráficos se aplican con GraphicsController desde los datos del CharacterGame.

Documentos:
	gamestart.txt (GameStart), global.txt (Globals, pantalla e input),
	core/musicmanager.txt (MusicManager), core/musicid.txt (MusicID),
	entities/controllers/controllers.txt (los tres controladores, Entity y
	Player), map/gamemap.txt (GameMap), map/mapattributes.txt (MapAttributes y
	MapSection), resources/resources.txt (CharacterGame, PlayerData y ObjEvents,
	incluye como agregar un personaje), guias.txt (como agregar un mapa y como
	agregar audio), convenciones.txt (reglas de nombres y de enums) y estado.txt
	(que funciona y que falta).
