class_name MumbleVoice
extends Node

@export var dialogue_label: DialogueLabel
@export var bus: StringName = &"Master"
@export_range(60.0, 300.0) var base_f0: float = 120.0    # lower = deeper voice
@export_range(0.5, 2.0) var formant_shift: float = 1.0   # <1 bigger throat, >1 smaller
@export var base_pitch: float = 1.0
@export var pitch_spread: float = 0.05                   # per-letter pitch step
@export var jitter: float = 0.03
@export var min_interval_ms: int = 70                    # thins out blips at fast text speeds
@export var volume_db: float = -8.0
@export var pool_size: int = 4

const SR := 22050
const VOWELS := {            # [F1, F2] in Hz
	"a": [800.0, 1200.0],
	"e": [530.0, 1840.0],
	"i": [300.0, 2300.0],
	"o": [500.0, 900.0],
	"u": [325.0, 700.0],
}

var _bank := {}
var _pool: Array[AudioStreamPlayer] = []
var _next := 0
var _last_play_ms := 0


func _ready() -> void:
	for i in pool_size:
		var p := AudioStreamPlayer.new()
		p.bus = bus
		p.volume_db = volume_db
		add_child(p)
		_pool.append(p)
	rebuild()
	if dialogue_label:
		dialogue_label.spoke.connect(_on_spoke)


## Call again after changing base_f0 or formant_shift (e.g. when the speaker changes).
func rebuild() -> void:
	_bank.clear()
	for v in VOWELS:
		_bank[v] = _synth(VOWELS[v][0], VOWELS[v][1], 0.09)


func _on_spoke(letter: String, _letter_index: int, _speed: float) -> void:
	var c := letter.to_lower()
	if not _bank.has(c):
		return   # consonants, spaces, punctuation: silent

	var now := Time.get_ticks_msec()
	if now - _last_play_ms < min_interval_ms:
		return
	_last_play_ms = now

	var p := _pool[_next]
	_next = (_next + 1) % _pool.size()
	p.stream = _bank[c]
	# Same vowel in the same word position-ish -> consistent pitch; jitter keeps it organic
	var offset := float(_letter_index % 7 - 3) * pitch_spread
	p.pitch_scale = maxf(0.1, base_pitch * (1.0 + offset) + randf_range(-jitter, jitter))
	p.play()


# --- Synthesis: glottal saw -> two resonators (formants) -> envelope ---

func _res(freq: float, bw: float) -> Vector3:
	var r := exp(-PI * bw / SR)
	var theta := TAU * clampf(freq, 50.0, SR * 0.45) / SR
	return Vector3(1.0 - r, 2.0 * r * cos(theta), -r * r)  # gain, b1, b2


func _synth(f1: float, f2: float, dur: float) -> AudioStreamWAV:
	var n := int(SR * dur)
	var c1 := _res(f1 * formant_shift, 90.0)
	var c2 := _res(f2 * formant_shift, 130.0)
	var y1a := 0.0
	var y1b := 0.0
	var y2a := 0.0
	var y2b := 0.0
	var phase := 0.0
	var buf := PackedFloat32Array()
	buf.resize(n)
	var peak := 0.0001

	for i in n:
		var t := float(i) / SR
		var f0 := base_f0 * (1.0 + 0.02 * sin(TAU * 5.0 * t))   # slight vibrato
		phase = fposmod(phase + f0 / SR, 1.0)
		var src := (1.0 - phase) * 2.0 - 1.0                      # saw

		var o1 := c1.x * src + c1.y * y1a + c1.z * y1b
		y1b = y1a
		y1a = o1
		var o2 := c2.x * src + c2.y * y2a + c2.z * y2b
		y2b = y2a
		y2a = o2

		var env := sin(PI * float(i) / float(n))
		var s := (o1 + 0.6 * o2) * env
		buf[i] = s
		peak = maxf(peak, absf(s))

	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in n:
		bytes.encode_s16(i * 2, int(clampf(buf[i] / peak, -1.0, 1.0) * 32767.0))

	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = SR
	w.stereo = false
	w.data = bytes
	return w
