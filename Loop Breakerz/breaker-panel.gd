extends Control

var commands = [
	["deploy", "amplify", "calibrate", "realign", "transfer", "activate", "trigger", "initiate", "unseal", "locate", "engage", "elevate", "decrypt", "access", "disrupt", "crack", "unlock", "trigger"],
	["hyper", "chrono", "sigma", "grid", "neon", "loopbound", "synthetic", "hyperion", "echo", "viral", "cascade", "parallel", "gridlock", "vortex", "quantum", "axis", "synaptic", "chrono"],
	["neon", "drive", "quantum", "flux", "vortex", "paradox", "circuit", "matrix", "frame", "axon", "subroutine", "node", "spectral", "synch", "fusion", "core", "feedback", "shard"],
	["core", "essence", "synth", "pulse", "shard", "cycle", "bind", "grid", "spectrum", "pathway", "axis", "stream", "cycle", "loop", "drive", "field", "shield", "link"]
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
var revealed = []
onready var lines = $"%Lines"
onready var command = $"%Command"
onready var response = $"%Response"

func _ready():
	randomize()
	generate()
	
func generate():
	revealed = []
	response.text = responses[stage]
	var coords_id = randi() % coords.size()
	for i in range(lines.get_child_count()):
		var line = commands[0][randi() % commands[0].size()] + " "
		line += commands[1][randi() % commands[1].size()] + " "
		line += commands[2][randi() % commands[2].size()] + " "
		if stage < 3:
			line += commands[3][randi() % commands[3].size()] + " "
		elif stage == 3:
			line += coords[coords_id][randi() % coords[coords_id].size()] + "-"
			line += str(randi() % 13 + 1) + " "
		elif stage == 4:
			line += coords[coords_id][randi() % coords[coords_id].size()] + "-"
			line += str(randi() % 13 + 1) + " "
		var params_id = randi() % params.size()
		line += params[params_id][randi() % params[params_id].size()] + "="
		if params_id:
			line += str(randi() % 99)
		else:
			line += "true" if randi() % 2 else "false"
		lines.get_child(i).text = line
		lines.get_child(i).modulate = Color(1, 1, 1, 1)
	expected_command = lines.get_child(randi() % lines.get_child_count()).text
	print(expected_command)

func _input(event):
	if event is InputEventKey and event.pressed:
		var c = event.as_text().to_lower()
		if c == "enter":
			if command.text == expected_command:
				if stage < 3:
					stage += 1
				generate()
			else:
				entered_line.modulate = Color(1, 0, 0, 1)
			command.text = ""
			return
		if c == "space":
			c = " "
		if c == "minus":
			c = "-"
		if c == "shift+7":
			c = "="
		if c.length() == 1:
			handle_input(c)

func handle_input(c):
	for line in lines.get_children():
		if line.text.begins_with(command.text + c):
			command.text += c
			break
	for line in lines.get_children():
		if line.text.begins_with(command.text):
			var text = line.text
			line.clear()
			line.append_bbcode("[color=yellow]" + text.substr(0, command.text.length()) + "[/color]" + text.substr(command.text.length()))
			entered_line = line
		else:
			line.text = line.text
	reveal()

func reveal():
	for line in lines.get_children():
		if line.text.begins_with(command.text):
			var text = line.text
			line.clear()
			line.append_bbcode("[color=yellow]" + text.substr(0, command.text.length()) + "[/color]")
			for i in range(command.text.length(), text.length()):
				if i != (text.length() - 1) and revealed.has(text[i] + text[i + 1]):
					line.append_bbcode("[color=green]" + text[i] + "[/color]")
				elif revealed.has(text[i - 1] + text[i]):
					line.append_bbcode("[color=green]" + text[i] + "[/color]")
				else:
					line.append_bbcode(text[i])
			
		else:
			var text = line.text
			line.clear()
			for i in range(text.length()):
				if i != (text.length() - 1) and revealed.has(text[i] + text[i + 1]):
					line.append_bbcode("[color=green]" + text[i] + "[/color]")
				elif revealed.has(text[i - 1] + text[i]):
					line.append_bbcode("[color=green]" + text[i] + "[/color]")
				else:
					line.append_bbcode(text[i])

func _on_Timer_timeout():
	var r = randi() % (expected_command.length() - 1)
	revealed.append(expected_command[r] + expected_command[r + 1])
	reveal()
