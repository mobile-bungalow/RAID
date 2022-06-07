extends KinematicBody2D

export var direction: Vector2; # shot angle
var speed: float = 750.0;
var lifespan = 5.0;

func strike():
	$CPUParticles2D.emitting = true;
	speed = 0;
	$Line2D.hide()

func is_lethal():
	return true;

# Called when the node enters the scene tree for the first time.
func _ready():
	direction = direction.normalized();
	self.rotate(atan(direction.y / direction.x))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_and_slide(direction * speed)
	lifespan -= delta;
	if lifespan <= 0:
		queue_free()


