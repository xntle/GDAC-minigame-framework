extends Minigame

# Pattern variables
var current_pattern: String = ""
var input_progress: String = ""
var base_pattern_length: int = 4
var pattern_length: int = base_pattern_length

# UI references
@onready var key_container: HBoxContainer = $KeyContainer
@onready var feedback_label: Label = $FeedbackLabel

# Valid keys for pattern generation
const VALID_KEYS = ["W", "A", "S", "D"]

# Key textures (1.png=W, 2.png=A, 3.png=S, 4.png=D)
var key_textures = {}


func _ready():
	# Load the key images BEFORE calling super() (which calls start())
	key_textures["W"] = load("res://minigames/react_wasd/1.png")
	key_textures["A"] = load("res://minigames/react_wasd/2.png")
	key_textures["S"] = load("res://minigames/react_wasd/3.png")
	key_textures["D"] = load("res://minigames/react_wasd/4.png")
	super()


func start():
	# Reset variables
	current_pattern = ""
	input_progress = ""
	pattern_length = base_pattern_length

	# Adjust for difficulty
	# Increase pattern length and reduce time as difficulty increases
	pattern_length = base_pattern_length + roundi(difficulty * 1.5)
	countdown_time = max(3.0, 7.0 / difficulty)

	# Generate random pattern
	generate_pattern()

	# Update UI
	update_display()
	feedback_label.text = ""


func generate_pattern():
	current_pattern = ""
	for i in range(pattern_length):
		current_pattern += VALID_KEYS[randi() % VALID_KEYS.size()]


func run():
	# Check for WASD input
	if Input.is_action_just_pressed("up"):
		process_input("W")
	elif Input.is_action_just_pressed("left"):
		process_input("A")
	elif Input.is_action_just_pressed("down"):
		process_input("S")
	elif Input.is_action_just_pressed("right"):
		process_input("D")


func process_input(key: String):
	if has_ended:
		return

	# Check if input matches the current position in pattern
	if key == current_pattern[input_progress.length()]:
		# Correct input
		input_progress += key
		update_display()

		# Check if pattern is complete
		if input_progress.length() == current_pattern.length():
			feedback_label.text = "Perfect!"
			feedback_label.modulate = Color(0.3, 1, 0.3)
			win()
	else:
		# Wrong input
		feedback_label.text = "Wrong! Try again!"
		feedback_label.modulate = Color(1, 0.3, 0.3)
		input_progress = ""
		update_display()

		# Flash the wrong input briefly
		await get_tree().create_timer(0.5).timeout
		if not has_ended:
			feedback_label.text = ""


func update_display():
	# Clear existing display
	for child in key_container.get_children():
		child.queue_free()

	# Display one row with typed keys bright and untyped keys dark
	for i in range(current_pattern.length()):
		var key = current_pattern[i]
		var texture_rect = TextureRect.new()
		texture_rect.texture = key_textures[key]
		texture_rect.custom_minimum_size = Vector2(100, 100)
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		if i < input_progress.length():
			# Typed - bright/colored
			texture_rect.modulate = Color(0.5, 1, 0.5)  # Bright green for typed
		else:
			# Untyped - very dark/black
			texture_rect.modulate = Color(0.15, 0.15, 0.15)  # Very dark for untyped

		key_container.add_child(texture_rect)


func win():
	super()


func lose():
	super()
	feedback_label.text = "Time's up!"
	feedback_label.modulate = Color(1, 0.5, 0.3)
