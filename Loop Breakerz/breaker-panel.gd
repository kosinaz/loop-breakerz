extends Control

# Placeholder for command suggestions
var command_suggestions = [
	"RUN diagnostics Alpha-3 -analyze-account=true",
	"INITIATE protocol Bravo-7 -subroutine-priority=high",
	"EXECUTE script Charlie-5 -hash-speed=78",
	"ACCESS uplink Delta-9 -decrypt-code=34",
	"UPLOAD data Echo-2 -boost-level=99",
	"DOWNLOAD module Foxtrot-8 -analyze-account=false",
	"ACTIVATE sequence Golf-4 -hash-speed=474",
	"TERMINATE process Hotel-6 -subroutine-priority=medium",
	"LAUNCH operation India-1 -decrypt-code=56",
	"CONNECT network Juliet-3 -uplink-protocol-layer=50"
]

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


# Called when the user presses Enter in the input field
func _on_input_field_text_entered(new_text):
	if new_text in command_suggestions:
		print("Command executed:", new_text)
	else:
		print("Invalid command:", new_text)

func _ready():
	randomize()
	$"%LineEdit".grab_focus()
	# Populate the list of commands
	var lines = $"%Lines"
	var coords_id = randi() % coords.size()
	for i in range(lines.get_child_count()):
		var line = commands[0][randi() % commands[0].size()] + " "
		line += commands[1][randi() % commands[1].size()] + " "
		line += commands[2][randi() % commands[2].size()] + " "
#		line += commands[3][randi() % commands[3].size()] + " "
		line += coords[coords_id][randi() % coords[coords_id].size()] + "-"
		line += str(randi() % 13 + 1) + " "
		var params_id = randi() % params.size()
		line += params[params_id][randi() % params[params_id].size()] + "="
		if params_id:
			line += str(randi() % 99)
		else:
			line += "true" if randi() % 2 else "false"
		lines.get_child(i).text = line
