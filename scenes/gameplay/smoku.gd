extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$CPUParticles2D.set_emitting(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !$CPUParticles2D.is_emitting():
		queue_free()
	pass
