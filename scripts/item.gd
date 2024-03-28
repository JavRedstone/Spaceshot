extends Node2D

const LERP_CONSTANT = 0.05
const JUNK_HEALTH_BOOST = 30
const SUCKING_SPEED = 10
const SUCK_DISTANCE = 25
const DEG_WIGGLE = 20
const WIGGLE_LERP = 0.5
const SPEED = 25

var COUNT = 1

var SPRITE: AnimatedSprite2D
var TYPE = "junk"
var AREA: Area2D = null
var SUCKED = false

var speed = Vector2.ZERO
var animation_time = 0.1

var INVENTORY_TYPES = [
	"junk",
	"aluminum",
	"iron",
	"lead",
	"plutonium",
	"quartz",
	"silicon",
	"titanium",
	"methane",
	"nitrogen"
]

var WEAPON_TYPES = [
	"attack_module", #s
	"defence_module", #s
	"generator_module", #s
	"healing_module", #s
	"emp", #l
	"small_bomb", #n
	"large_bomb", #m
	"plasma_bomb", #l
	"small_mine", #n
	"large_mine", #m
	"rocket", #m
	"missile", #m
	"torpedo" #l
]

var IS_WEAPON = false
var lerp_left = false # item wiggle
var despawn_time = 120
var r = false

func _ready():
	SPRITE = $AnimatedSprite2D
	hide() # similar to bullet we dont set the physics process off
	r = true
	
func _physics_process(delta):
	speed = lerp(speed, Vector2.ZERO, LERP_CONSTANT)
	var clamped_pos = Vector2(clamp(position.x, -get_parent().GAME_SIZE, get_parent().GAME_SIZE), clamp(position.y, -get_parent().GAME_SIZE, get_parent().GAME_SIZE))
	if clamped_pos != position:
		queue_free()
	SPRITE.play(TYPE)
	if rotation <= deg_to_rad(-DEG_WIGGLE + 1): #buffer
		lerp_left = false
	elif rotation >= deg_to_rad(DEG_WIGGLE - 1):
		lerp_left = true
		
	if lerp_left:
		rotation = lerp_angle(rotation, -deg_to_rad(DEG_WIGGLE), WIGGLE_LERP)
	else:
		rotation = lerp_angle(rotation, deg_to_rad(DEG_WIGGLE), WIGGLE_LERP)
	if is_instance_valid(AREA) and AREA.get_parent().health > 0:
		if (!IS_WEAPON and AREA.get_parent().INVENTORY.size() < AREA.get_parent().MAX_INVENTORY_SIZE) or (IS_WEAPON and AREA.get_parent().WEAPONS.size() < AREA.get_parent().MAX_WEAPONS_SIZE):
			var pointingVector = AREA.global_position - position
			# Item perks
			if pointingVector.length() < SUCK_DISTANCE:
				if !SUCKED:
					SUCKED = true
					queue_free()
					if !IS_WEAPON:
						AREA.get_parent().INVENTORY.append(TYPE)
					else:
						AREA.get_parent().WEAPONS.append(TYPE)
	#				if TYPE == "junk":				
	#					var healthBoost = JUNK_HEALTH_BOOST
	#					if AREA.get_parent().health + healthBoost > AREA.get_parent().MAX_HEALTH:
	#						healthBoost = AREA.get_parent().MAX_HEALTH - AREA.get_parent().health
	#					AREA.get_parent().health += healthBoost
	#				if get_parent().PARTICLES:
	#					AREA.get_parent().BOOSTED_PARTICLE_EMITTER.emitting = true
	#				else:
	#					AREA.get_parent().BOOSTED_PARTICLE_EMITTER.emitting = false
	#				hide()
	#			animation_time -= delta
	#			if animation_time <= 0:
	#				if get_parent().PARTICLES:
	#					AREA.get_parent().BOOSTED_PARTICLE_EMITTER.emitting = false
	#				queue_free()
				
			speed = pointingVector.normalized() * SUCKING_SPEED
	position += speed
	despawn_time -= delta
	if despawn_time <= 0:
		queue_free()
		
func _on_area_entered(area: Area2D):
	# Keep pulling on the object once entered, only one area also to prevent stealing unless the user stands far enough
	if area.is_in_group("item_pickups") and (AREA == null or !is_instance_valid(AREA)):
		AREA = area
