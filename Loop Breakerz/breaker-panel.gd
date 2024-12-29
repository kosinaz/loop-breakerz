extends CanvasLayer

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
onready var overlay = $Overlay

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

func _input(event):
	if event is InputEventKey and event.pressed:
		var c = event.as_text().to_lower()
		if c == "enter":
			if command.text == expected_command:
				if stage < 3:
					stage += 1
				generate()
			elif command.text.length() == entered_line.text.length():
				entered_line.modulate = Color(1, 0, 0, 1)
			command.text = ""
			return
		if c.length() == 1:
			handle_input(c)

func handle_input(c):
	for line in lines.get_children():
		if line.text.begins_with(command.text + c):
			command.text += c
			if line.text.begins_with(command.text + " "):
				command.text += " " 
			if line.text.begins_with(command.text + "-"):
				command.text += "-" 
			if line.text.begins_with(command.text + "="):
				command.text += "=" 
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
	# Cache the command text and its length
	var cmd_text = command.text
	var cmd_len = cmd_text.length()
	
	for line in lines.get_children():
		# Cache the line text and prepare a new BBCode string
		var text = line.text
		var bbcode_result = ""
		
		if text.begins_with(cmd_text):
			# Highlight matching prefix
			bbcode_result += "[color=yellow]" + text.substr(0, cmd_len) + "[/color]"
			
			# Process the remaining text
			for i in range(cmd_len, text.length()):
				var current_char = text[i]
				var next_char = text[i + 1] if i < text.length() - 1 else ""
				var prev_char = text[i - 1] if i > 0 else ""
				
				if revealed.has(current_char + next_char) or revealed.has(prev_char + current_char):
					bbcode_result += "[color=white]" + current_char + "[/color]"
				else:
					bbcode_result += current_char
		else:
			# Process the entire line if it doesn't match the command
			for i in range(text.length()):
				var current_char = text[i]
				var next_char = text[i + 1] if i < text.length() - 1 else ""
				var prev_char = text[i - 1] if i > 0 else ""
				
				if revealed.has(current_char + next_char) or revealed.has(prev_char + current_char):
					bbcode_result += "[color=white]" + current_char + "[/color]"
				else:
					bbcode_result += current_char
		
		# Apply the constructed BBCode to the line
		line.clear()
		line.append_bbcode(bbcode_result)

	
func reveal_next():
	var r = randi() % (expected_command.length() - 1)
	revealed.append(expected_command[r] + expected_command[r + 1])
	reveal()
