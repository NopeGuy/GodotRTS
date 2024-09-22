extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar

var health = 0 : set = _set_health
var damage_speed = 35  # Speed at which the damage bar catches up to the health
var wait_time = 0.5  # Delay before starting to deplete the damage bar
var is_depleting = false  # Flag to control the depletion process

func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health  # Update the current health bar instantly

	# Start the timer with a delay if the health has changed
	if health != prev_health:
		if !timer.is_stopped():
			timer.stop()  # Reset the timer to avoid multiple starts
		timer.wait_time = wait_time  # Set the timer delay to 0.5 seconds
		timer.start()  # Start the timer
		is_depleting = false  # Stop depleting until the timer triggers

func init_health(_health, pos):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health  # Set the damage bar to full health initially
	self.top_level = true
	self.position = pos

# Timer timeout function to start depletion after the delay
func _on_timer_timeout() -> void:
	is_depleting = true  # Set the flag to start depletion
	timer.stop()  # No longer need the timer

# Deplete the damage bar over time
func _process(delta):
	if is_depleting:
		if damage_bar.value > health:
			damage_bar.value -= damage_speed * delta  # Smoothly decrease the damage bar
			if damage_bar.value < health:
				damage_bar.value = health  # Ensure no overshoot

		elif damage_bar.value < health:
			damage_bar.value += damage_speed * delta  # Smoothly increase the damage bar for healing
			if damage_bar.value > health:
				damage_bar.value = health  # Ensure no overshoot

		# If health reaches zero and the damage bar has caught up, queue free the node
		if health <= 0 and damage_bar.value <= 0:
			queue_free()  # Remove the health bar after depletion

func update_pos(pos):
	self.position = pos
