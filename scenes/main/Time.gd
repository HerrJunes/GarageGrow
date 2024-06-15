extends Node

var HOLD = false
var timeMultiplier = 10

var day = 1
var timestamp = 180

### 180 = 12:00 ### 0 = 00:00

@export_node_path var SUN
@export_node_path var GUI

# Called when the node enters the scene tree for the first time.
func _ready():
	if not SUN:
		HOLD = true
		return

func showTime():
	get_node(GUI).get_node("RichTextLabel").clear()
	get_node(GUI).get_node("RichTextLabel").add_text(str("Timestamp (seconds): ", timestamp))
	get_node(GUI).get_node("RichTextLabel").add_text("\n")
	get_node(GUI).get_node("RichTextLabel").add_text(str("Day: ", day))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if HOLD:
		return
	
	timestamp += (1*delta) * timeMultiplier
	get_node(SUN).rotation.z = timestamp*delta
	#get_node(SUN).rotate_z(0.1)
	
	if timestamp >= 360:
		timestamp = 0
		day += 1
	
	showTime()
