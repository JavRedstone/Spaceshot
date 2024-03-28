extends Area2D

const MAX_HEALTH = 600
const DAMAGE = 200
const HIGH_DAMAGE = 1000
const SLOWNESS = 0.2
const LERP_CONSTANT = 5
const MASS = 10000
const DAMAGE_DIVIDER = 5
var DEAD = false

@export var item_scene: PackedScene

var SPRITE: AnimatedSprite2D
var COLLISION_SHAPE: CollisionShape2D
var EXPLOSION_PARTICLE_EMITTER: GPUParticles2D

var areas_accepted = []

var speed = Vector2.ZERO
var health = MAX_HEALTH
var animation_time = 0.2
var particle_time = 1
var spawned_item = false

var moved = false
var spinning = false
var spinner: Area2D = null

func _ready():
	SPRITE = $AnimatedSprite2D
	COLLISION_SHAPE = $CollisionShape2D
	EXPLOSION_PARTICLE_EMITTER = $ExplosionParticleEmitter
	hide()
	set_physics_process(false)
	
func _physics_process(delta):
	if speed.length() != 0 and !moved:
		moved = true
		get_parent().MOVED_OBJECTS.append(position)
		get_parent().MOVED_TIMINGS.append(get_parent().MOVED_TIMING)
		get_parent().MOVED_TYPES.append("asteroid")

	position += speed
	
	if health <= 0:
		speed = Vector2.ZERO
		if !spawned_item:
			spawned_item = true
			var item = item_scene.instantiate()
			get_parent().add_child(item)
			item.global_position = position
			item.TYPE = item.INVENTORY_TYPES[randi() % item.INVENTORY_TYPES.size()] # modulus gives us the number between 0 and the length - 1
			item.IS_WEAPON = false
			item.speed = Vector2(randf_range(-item.SPEED, item.SPEED), randf_range(-item.SPEED, item.SPEED))
		SPRITE.play("explode")
		if get_parent().PARTICLES:
			EXPLOSION_PARTICLE_EMITTER.emitting = true
		animation_time -= delta
		if animation_time <= 0:
			particle_time -= delta
			EXPLOSION_PARTICLE_EMITTER.emitting = false
			if !moved:
				get_parent().MOVED_OBJECTS.append(position)
				get_parent().MOVED_TIMINGS.append(get_parent().MOVED_TIMING)
				moved = true
			SPRITE.hide()
			DEAD = true
			if particle_time <= 0:
				queue_free()
	else:
		if health > 0.75 * MAX_HEALTH:
			SPRITE.play("75")
		elif health > 0.50 * MAX_HEALTH:
			SPRITE.play("50")
		elif health > 0.25 * MAX_HEALTH:
			SPRITE.play("25")
		elif health > 0:
			SPRITE.play("0")
		
	for i in range(0, areas_accepted.size()):
		if health > 0:
			if !(spinning and spinner == areas_accepted[i][0]):
				var damage = DAMAGE
				if spinning and areas_accepted[i][0].is_in_group("aliens"):
					damage = HIGH_DAMAGE
				areas_accepted[i][0].health -= damage * delta
				health -= damage / DAMAGE_DIVIDER * delta
				if areas_accepted[i][0].is_in_group("ships") and !areas_accepted[i][0].brake_mode:
					areas_accepted[i][0].speed = areas_accepted[i][0].speed.lerp(areas_accepted[i][0].speed.normalized() * areas_accepted[i][1] * SLOWNESS, delta * LERP_CONSTANT)
				else:
					areas_accepted[i][0].speed = areas_accepted[i][0].speed.lerp(Vector2.ZERO, delta * LERP_CONSTANT)

func _on_area_entered(area: Area2D):
	if area.is_in_group("asteroids") or area.is_in_group("ships") or area.is_in_group("aliens"):
		if !area.is_in_group("ships") && area.DEAD:
			return
		areas_accepted.append([area, area.speed.length()])

func _on_area_exited(area: Area2D):
	if area.is_in_group("asteroids") or area.is_in_group("ships") or area.is_in_group("aliens"):
		for pair in areas_accepted:
			if pair[0] == area:
				areas_accepted.erase(pair)
				break
