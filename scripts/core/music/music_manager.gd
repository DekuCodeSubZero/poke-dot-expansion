@tool
extends Node

const SFX_POOL_SIZE: int = 4
const BUS_MUSIC: StringName = &"Music"
const BUS_SFX: StringName = &"SFX"

var Bgm: AudioStreamPlayer
var Me: AudioStreamPlayer
var SfxPlayers: Array[AudioStreamPlayer] = []

var rutaActual: String = ""
var BgmPosicionGuardada: float = 0.0
var BgmPausadaPorMe: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Bgm = AudioStreamPlayer.new()
	Bgm.name = "BGMPlayer"
	Bgm.bus = ResolverBus(BUS_MUSIC)
	Bgm.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(Bgm)
	Me = AudioStreamPlayer.new()
	Me.name = "MEPlayer"
	Me.bus = ResolverBus(BUS_MUSIC)
	Me.process_mode = Node.PROCESS_MODE_ALWAYS
	Me.finished.connect(OnMeFinished)
	add_child(Me)
	for i: int in range(SFX_POOL_SIZE):
		var Se: AudioStreamPlayer = AudioStreamPlayer.new()
		Se.name = "SFXPlayer_%d" % i
		Se.bus = ResolverBus(BUS_SFX)
		Se.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(Se)
		SfxPlayers.append(Se)

func Reproducir(Ruta: String) -> void:
	if Ruta.is_empty():
		Detener()
		return
	if  not ResourceLoader.exists(Ruta):
		push_warning("MusicManager: no existe: %s" % Ruta)
		return
	if Ruta == rutaActual and Bgm.playing:
		return
	var Nueva: AudioStream = load(Ruta) as AudioStream
	if Nueva == null:
		return
	BgmPausadaPorMe = false
	rutaActual = Ruta
	Bgm.stream = Nueva
	Bgm.volume_db = 0.0
	Bgm.play()

func Detener() -> void:
	Bgm.stop()
	Bgm.stream = null
	rutaActual = ""
	BgmPausadaPorMe = false

func ReproducirMapa(ID: MusicID.MapMusicID) -> void:
	if ID == MusicID.MapMusicID.BGM_NONE:
		Detener()
		return
	Reproducir(MusicID.MapMusicPath(ID))

func ReproducirBatalla(ID: MusicID.BattleMusicID) -> void:
	Reproducir(MusicID.BattleMusicPath(ID))

func ReproducirEfectoMusical(ID: MusicID.MusicEffectID) -> void:
	var Ruta: String = MusicID.MusicEffectPath(ID)
	if Ruta.is_empty() or not ResourceLoader.exists(Ruta):
		push_warning("MusicManager: ME inexistente")
		return
	var Stream: AudioStream = load(Ruta) as AudioStream
	if Stream == null:
		return
	if Bgm.playing:
		BgmPosicionGuardada = Bgm.get_playback_position()
		Bgm.stop()
		BgmPausadaPorMe = true
	Me.stream = Stream
	Me.volume_db = 0.0
	Me.play()
	
func OnMeFinished() -> void:
	if not BgmPausadaPorMe:
		return
	BgmPausadaPorMe = false
	if Bgm.stream == null or rutaActual.is_empty():
		return
	Bgm.play(BgmPosicionGuardada)

func ReproducirSe(ID: MusicID.SoundEffectID) -> void:
	var Ruta: String = MusicID.SoundEffectPath(ID)
	ReproducirSeRuta(Ruta)

func ReproducirSeRuta(Ruta: String) -> void:
	if Ruta.is_empty():
		return
	if not ResourceLoader.exists(Ruta):
		return
	var Stream: AudioStream = load(Ruta) as AudioStream
	if Stream == null:
		return
	var Players: AudioStreamPlayer = SfxLibre()
	Players.stream = Stream
	Players.play()

func SfxLibre() -> AudioStreamPlayer:
	for p: AudioStreamPlayer in SfxPlayers:
		if not p.playing:
			return p
	return SfxPlayers[0]

func EstaSonando() -> bool:
	return Bgm.playing

func RutaActual() -> String:
	return rutaActual

func  ResolverBus(Preferido: StringName) -> StringName:
	if AudioServer.get_bus_index(Preferido) >= 0:
		return Preferido
	push_warning("MusicManager: Falta bus '%s' -> Master. Crea buses Music y Sfx." % Preferido)
	return &"Master"
