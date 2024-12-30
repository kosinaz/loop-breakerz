extends CanvasLayer

var commands = [
	["deploy", "amplify", "calibrate", "realign", "transfer", "activate", "trigger", "initiate", "unseal", "locate", "engage", "elevate", "decrypt", "access", "disrupt", "crack", "unlock"],
	["sigma", "synthetic", "hyperion", "echo", "viral", "cascade", "parallel", "grid", "vortex", "quantum", "axis", "synaptic"],
	["drive", "flux", "paradox", "circuit", "matrix", "frame", "axon", "subroutine", "node", "spectral", "synch", "fusion", "feedback"],
	["essence", "synth", "pulse", "bind", "spectrum", "pathway", "stream", "loop", "field", "shield", "link"]
]
var coords = [
	["alpha", "bravo", "charlie", "delta", "echo", "foxtrot", "golf", "hotel", "india", "juliet", "kilo", "lima", "mike", "november", "oscar", "papa", "quebec", "romeo", "sierra", "tango", "uniform", "victor", "whiskey", "x-ray", "yankee", "zulu"],
	["alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta", "iota", "kappa", "lambda", "mu", "nu", "xi", "omicron", "pi", "rho", "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega"],
	["aether", "beacon", "circuit", "drift", "element", "forge", "glyph", "haven", "impulse", "junction", "keystone", "lattice", "monolith", "nexus", "obsidian", "phantom", "quasar", "relic", "sphere", "tether", "umbra", "vector", "wavelength", "xylon", "yield", "zephyr"]
]
var params = [
	["-analyze-account", "-auto-reroute", "-system-backup", "-override-gate", "-close-loop", "-cache-lock", "-fail-safe", "-integrity-check", "-initialize-key", "-protocol-delay", "-optimize-thread", "-network-scan", "-runtime-lock"],
	["-hash-speed", "-subroutine-priority", "-boost-level", "-uplink-protocol-layer", "-vector-sync", "-lock-security", "-flux-capacity", "-trace-pathway", "-core-hash", "-link-strength", "-redirect-flow", "-amplify-rate", "-scan-frequency", "-bypass-rate", "-process-stack"],
]
var responses = [
	"Stage 1 access denied!\nEnter a valid command to continue!",
	"Stage 1 access granted!\nStage 2 access denied!\nEnter a valid command to continue!",
	"Stage 1 access granted!\nStage 2 access granted!\nStage 3 access denied!\nEnter a valid command to continue!",
	"All access granted!\nEnter a valid zone maintenance command!",
]
var stage = 0
var expected_command = ""
var entered_line = null
var keywords = []
var revealed = -1
var guesses = []
onready var response_label = $"%Response"
onready var keywords_label = $"%Keywords"
onready var guesses_container = $"%Guesses"
onready var command_label = $"%Command"
onready var overlay = $Overlay

func _ready():
	randomize()
	generate()
	
func generate():
	keywords = []
	revealed = -1
	expected_command = ""
	for guess in guesses_container.get_children():
		guess.queue_free()
	response_label.text = responses[stage]
	for i in commands.size():
		commands[i].shuffle()
		keywords += commands[i].slice(0, 5)
		expected_command += commands[i][0] + " "
	expected_command = expected_command.rstrip(" ")
	print(expected_command)
	keywords.sort()
	keywords_label.text = "Traced keywords:\n"
	for keyword in keywords:
		keywords_label.text += keyword + " "

func _input(event):
	if not (event is InputEventKey and event.pressed):
		return
	var c = event.as_text().to_lower()
	if c == "enter":
		if command_label.text.rstrip(" ") == expected_command:
			if stage < 3:
				stage += 1
			generate()
		elif command_label.text.rstrip(" ").split(" ").size() == 4:
			var guess = command_label.duplicate()
			guess.text = guess.text.rstrip(" ")
			guesses_container.add_child(guess)
		command_label.text = ""
		return
	if c.length() == 1:
		handle_input(c)

func handle_input(c):
	var current_word = Array(command_label.text.split(" ")).back()
	for keyword in keywords:
		if keyword.begins_with(current_word + c):
			command_label.text += c
			if keyword == current_word + c:
				command_label.text += " " 
			break


func reveal_next():
	if guesses_container.get_child_count() <= revealed + 1:
		return
	revealed += 1
	var guess = guesses_container.get_child(revealed)
	var words = guess.text.split(" ")
	var expected_words = expected_command.split(" ")
	var revealed_text = ""
	for i in range(words.size()):
		if expected_words[i] == words[i]:
			revealed_text += "[color=#00ff00]" + words[i] + "[/color] "
			continue
		if expected_words.has(words[i]):
			revealed_text += "[color=yellow][u]" + words[i] + "[/u][/color] "
			continue
		revealed_text += "[color=red][s]" + words[i] + "[/s][/color] "
	guess.bbcode_text = revealed_text
