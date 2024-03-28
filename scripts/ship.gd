extends Area2D

const MOVE_SPEED = 600
const SLOW_LERP_CONSTANT = 1.5
const LERP_CONSTANT = 5
const FAST_LERP_CONSTANT = 10
const ENERGY_REGEN = 100
const MAX_ENERGY = 30
const MAX_ENERGY_COOLDOWN = 0.2
const HEALTH_REGEN = 10
const MAX_HEALTH = 1000
const ORBIT_SPEED = 3
const SLINGSHOT_LOCK_DISTANCE = 15
const INITIAL_CAMERA_ZOOM = Vector2(0.5, 0.5)
const BULLET_LOCATIONS = [Vector2(45, 0), Vector2(25, -45), Vector2(25, 45)]
const BULLET_DAMAGES = [30, 10, 10]
const BULLET_SPEEDS = [1000, 800, 800]
const BULLET_ROTATIONS = [0, 0, 0]
const MASS = 100
const SLINGSHOT_MULTIPLIER = 8

var SPRITE: AnimatedSprite2D
var CAMERA: Camera2D
var SHIELD_BAR_CONTAINER: AnimatedSprite2D
var SHIELD_BAR: AnimatedSprite2D
var SHIELD_ICON: AnimatedSprite2D
var COLLISION_SHAPE: CollisionShape2D
var THRUST_PARTICLE_EMITTER: GPUParticles2D
var EXPLOSION_PARTICLE_EMITTER: GPUParticles2D
var RENDER_AREA: Area2D
var SLINGSHOT

@export var bullet_scene: PackedScene
@export var slingshot_scene: PackedScene
@export var item_scene: PackedScene

var move_direction = Vector2.ZERO
var brake_mode = false
var speed = Vector2.ZERO
var health = MAX_HEALTH
var animation_time = 0.2
var particle_time = 2
var in_asteroid = false
var asteroid_in: Area2D
var asteroids = []
var energy = MAX_ENERGY
var energy_cooldown = MAX_ENERGY_COOLDOWN
var order_loc = 0
var closest_asteroid = null
var closest_distance = 10000
var asteroid_angle = 0
var orbit_speed = 0.0
var slingshot_attached = false
var releasing_asteroid = false

var areas_showing = []

var INVENTORY = []
var WEAPONS = []
var MAX_INVENTORY_SIZE = 10
var MAX_WEAPONS_SIZE = 10

func _ready():
	SPRITE = $AnimatedSprite2D
	CAMERA = $ShipCamera
	SHIELD_BAR_CONTAINER = $Shield/ShieldBarContainer
	SHIELD_BAR = $Shield/ShieldBar
	SHIELD_ICON = $Shield/ShieldIcon
	COLLISION_SHAPE = $CollisionShape2D
	THRUST_PARTICLE_EMITTER = $ThrustParticleEmitter
	EXPLOSION_PARTICLE_EMITTER = $ExplosionParticleEmitter
	RENDER_AREA = $RenderArea
	
	var r = RENDER_AREA.duplicate()
	RENDER_AREA.queue_free()
	get_parent().add_child(r)
	RENDER_AREA = r
	RENDER_AREA.scale = scale

func _physics_process(delta):
	RENDER_AREA.position = position
	if energy < MAX_ENERGY:
		energy += ENERGY_REGEN * delta
	else:
		energy = MAX_ENERGY
		
	energy_cooldown += delta
	
	# Change zoom / fov based on window size
	var viewport = get_viewport_rect().size
	CAMERA.zoom = INITIAL_CAMERA_ZOOM * viewport.length() / get_parent().INITIAL_VIEWPORT_SIZE.length()

	# Determine the direction the player should face based on the mouse position
	var mouse_position = get_global_mouse_position()
	var aim_direction = (mouse_position - position).normalized()
	var target_rotation = aim_direction.angle()

	# Rotate the player towards the target rotation with a maximum speed limit
	var current_rotation = rotation
	rotation = lerp_angle(current_rotation, target_rotation, delta * LERP_CONSTANT)
	
	var current_direction = Vector2.RIGHT.rotated(rotation)
	aim_direction = lerp(current_direction, aim_direction, delta * LERP_CONSTANT)

	# Move the player in the desired direction when the move button is pressed
	move_direction = Vector2.ZERO
	if health > 0:
		if Input.is_action_pressed("move"):
			move_direction = aim_direction
			speed = speed.lerp(move_direction * MOVE_SPEED, delta * SLOW_LERP_CONSTANT)
			SPRITE.play("on")
			if get_parent().PARTICLES:
				THRUST_PARTICLE_EMITTER.emitting = true
			else:
				THRUST_PARTICLE_EMITTER.emitting = false
		else:
			# Apply a lerp to the player's speed to simulate friction in brake mode
			if brake_mode:
				speed = speed.lerp(Vector2.ZERO, delta * SLOW_LERP_CONSTANT)
			SPRITE.play("off")
			THRUST_PARTICLE_EMITTER.emitting = false
	else:
		THRUST_PARTICLE_EMITTER.emitting = false
		speed = Vector2.ZERO
		
	if speed.length() > MOVE_SPEED:
		speed = speed.normalized() * MOVE_SPEED

	# Toggle the brake mode when the brake button is pressed
	if Input.is_action_just_pressed("brake"):
		brake_mode = !brake_mode

	# Fire a bullet when the shoot button is pressed
	if Input.is_action_pressed("shoot"):
		var max_energy = 0
		var sorted_energies = BULLET_DAMAGES.duplicate()
		sorted_energies.sort()
		sorted_energies.reverse()
		for e in sorted_energies:
			if energy >= e:
				max_energy = e
				break
		var available_energies = []
		for i in range(0, BULLET_DAMAGES.size()):
			if max_energy == BULLET_DAMAGES[i]:
				available_energies.append(i)
		if available_energies == []:
			order_loc = null
		else:	
			order_loc = available_energies.pick_random()
		if order_loc != null and energy_cooldown >= MAX_ENERGY_COOLDOWN and energy >= BULLET_DAMAGES[order_loc] and health > 0:
			var bullet = bullet_scene.instantiate()
			bullet.SHOOTER = self
			bullet.TEAMS.append(self)
			bullet.DAMAGE = BULLET_DAMAGES[order_loc]
			bullet.rotation = rotation + BULLET_ROTATIONS[order_loc]
			bullet.position = position + BULLET_LOCATIONS[order_loc].rotated(rotation)
			bullet.speed = aim_direction.rotated(BULLET_ROTATIONS[order_loc]) * BULLET_SPEEDS[order_loc] + speed
			get_parent().add_child(bullet)
			
			var residual = energy - BULLET_DAMAGES[order_loc]
			if residual < 0:
				energy = 0
			else:
				energy = residual
			
			energy_cooldown = 0
	
	if Input.is_action_just_pressed("slingshot"):
		if !releasing_asteroid and (SLINGSHOT == null or !is_instance_valid(SLINGSHOT)):
			closest_asteroid = null
			closest_distance = 10000
			for asteroid in asteroids:
				if position.distance_to(asteroid.position) < closest_distance:
					closest_distance = position.distance_to(asteroid.position)
					closest_asteroid = asteroid
					closest_asteroid.spinning = true
					closest_asteroid.spinner = self
			if closest_asteroid != null:
				SLINGSHOT = slingshot_scene.instantiate()
				add_child(SLINGSHOT)
		else:
			release_asteroid()
			
	if SLINGSHOT != null and is_instance_valid(SLINGSHOT) and is_instance_valid(closest_asteroid) and !closest_asteroid.DEAD:
		if slingshot_attached:
			SLINGSHOT.GRABBER.play("attached")
			closest_asteroid.speed.x = closest_distance * cos(asteroid_angle) + position.x - closest_asteroid.position.x
			closest_asteroid.speed.y = closest_distance * sin(asteroid_angle) + position.y - closest_asteroid.position.y
			SLINGSHOT.GRABBER.global_position = closest_asteroid.position
			SLINGSHOT.GRABBER.global_rotation = position.angle_to_point(SLINGSHOT.GRABBER.global_position)
			SLINGSHOT.LINK.region_rect.size.x = position.distance_to(SLINGSHOT.GRABBER.global_position) * SLINGSHOT_MULTIPLIER
			SLINGSHOT.LINK.global_rotation = position.angle_to_point(SLINGSHOT.GRABBER.global_position)
			orbit_speed = lerp(orbit_speed, ORBIT_SPEED * delta, delta * SLOW_LERP_CONSTANT)
			asteroid_angle += orbit_speed
		elif !releasing_asteroid:
			SLINGSHOT.GRABBER.global_position = lerp(SLINGSHOT.GRABBER.global_position, closest_asteroid.position, delta * FAST_LERP_CONSTANT)
			SLINGSHOT.GRABBER.global_rotation = position.angle_to_point(SLINGSHOT.GRABBER.global_position)
			SLINGSHOT.LINK.region_rect.size.x = position.distance_to(SLINGSHOT.GRABBER.global_position) * SLINGSHOT_MULTIPLIER
			SLINGSHOT.LINK.global_rotation = position.angle_to_point(SLINGSHOT.GRABBER.global_position)
			if (SLINGSHOT.GRABBER.global_position - closest_asteroid.position).length() <= SLINGSHOT_LOCK_DISTANCE:
				slingshot_attached = true
				closest_distance = position.distance_to(closest_asteroid.position)
				asteroid_angle = position.angle_to_point(closest_asteroid.position)
	
	if releasing_asteroid:
		if is_instance_valid(SLINGSHOT):
			SLINGSHOT.GRABBER.play("slingshot_grabber")
			SLINGSHOT.GRABBER.global_position = lerp(SLINGSHOT.GRABBER.global_position, position, delta * FAST_LERP_CONSTANT)
			SLINGSHOT.GRABBER.global_rotation = position.angle_to_point(SLINGSHOT.GRABBER.global_position)
			SLINGSHOT.LINK.region_rect.size.x = position.distance_to(SLINGSHOT.GRABBER.global_position) * SLINGSHOT_MULTIPLIER
			SLINGSHOT.LINK.global_rotation = position.angle_to_point(SLINGSHOT.GRABBER.global_position)
			if (SLINGSHOT.GRABBER.global_position - position).length() <= SLINGSHOT_LOCK_DISTANCE:
				SLINGSHOT.queue_free()
				releasing_asteroid = false
		else:
			releasing_asteroid = false
	
	if is_instance_valid(SLINGSHOT) and !is_instance_valid(closest_asteroid.COLLISION_SHAPE):
		release_asteroid()

	if health <= 0:
		speed = Vector2.ZERO
		for i in INVENTORY:
			var item = item_scene.instantiate()
			get_parent().add_child(item)
			item.global_position = position
			item.TYPE = i
			item.IS_WEAPON = false
			item.speed = Vector2(randf_range(-item.SPEED, item.SPEED), randf_range(-item.SPEED, item.SPEED))
		INVENTORY.clear()
		
		for i in WEAPONS:
			var item = item_scene.instantiate()
			get_parent().add_child(item)
			item.global_position = position
			item.TYPE = i
			item.IS_WEAPON = true
			item.speed = Vector2(randf_range(-item.SPEED, item.SPEED), randf_range(-item.SPEED, item.SPEED))
		WEAPONS.clear()
		
		if is_instance_valid(SLINGSHOT):
			release_asteroid()
		SPRITE.play("explode")
		if get_parent().PARTICLES:
			EXPLOSION_PARTICLE_EMITTER.emitting = true
		animation_time -= delta
		if animation_time <= 0:
			particle_time -= delta
			EXPLOSION_PARTICLE_EMITTER.emitting = false
			SPRITE.hide()
			SHIELD_BAR.hide()
			SHIELD_BAR_CONTAINER.hide()
			SHIELD_ICON.hide()
			
			if is_instance_valid(COLLISION_SHAPE):
				COLLISION_SHAPE.queue_free() # somehow works idk why
			if particle_time <= 0:
				get_parent().SHIP_DIED = true
				for area in areas_showing:
					if is_instance_valid(area):
						area.hide()
				queue_free()
	else:
		SHIELD_BAR.scale.x = 0.1 * health / MAX_HEALTH
	
	SHIELD_BAR.global_rotation = 0
	SHIELD_BAR_CONTAINER.global_rotation = 0
	SHIELD_ICON.global_rotation = 0
	
	# Move the player based on the speed and delta time
	position += speed * delta
	
	# Update regeneration
	if health < MAX_HEALTH:
		if health > 0:
			health += HEALTH_REGEN * delta
	else:
		health = MAX_HEALTH

func release_asteroid():
	if is_instance_valid(SLINGSHOT):
		releasing_asteroid = true
		slingshot_attached = false
		# needs to be double
		orbit_speed = 0.0

func _on_slingshot_area_area_entered(area: Area2D):
	if area.is_in_group("asteroids"):
		asteroids.append(area)


func _on_slingshot_area_area_exited(area: Area2D):
	if area.is_in_group("asteroids"):
		asteroids.erase(area)
		if area == closest_asteroid:
			release_asteroid()

func _on_render_area_area_entered(area: Area2D):
	if area != self:
		areas_showing.append(area)
		area.show()
		area.set_physics_process(true)

func _on_render_area_area_exited(area: Area2D):
	if area != self:
		areas_showing.erase(area)
		area.hide()
		if !area.is_in_group("bullets") and !area.is_in_group("items"):
			area.set_physics_process(false)
