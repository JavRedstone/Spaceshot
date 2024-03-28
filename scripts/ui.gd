extends Control

var HOME_PAGE: CanvasLayer
var DEATH_SCREEN: CanvasLayer
var LOADING: CanvasLayer
var QUITTING: CanvasLayer
var SHIP_HUD: CanvasLayer
var SHIP_UPGRADES: CanvasLayer
var SHIP_INVENTORY_WEAPONS: CanvasLayer
var SHIELD_BAR: TextureProgressBar
var ENERGY_BAR: TextureProgressBar

var upgrades_hidden = true
var inventory_weapons_hidden = true

func _ready():
	HOME_PAGE = $HomePage
	DEATH_SCREEN = $DeathScreen
	LOADING = $Loading
	QUITTING = $Quitting
	SHIP_HUD = $ShipHUD
	SHIP_UPGRADES = $ShipUpgrades
	SHIP_INVENTORY_WEAPONS = $ShipInventoryWeapons
	SHIELD_BAR = $ShipHUD/Shield/ShieldBar
	ENERGY_BAR = $ShipHUD/Energy/EnergyBar
	
	HOME_PAGE.show()
	DEATH_SCREEN.hide()
	LOADING.hide()
	QUITTING.hide()
	SHIP_HUD.hide()
	SHIP_UPGRADES.hide()
	SHIP_INVENTORY_WEAPONS.hide()

func _physics_process(_delta):
	if get_parent().WORLD_INSTANTIATED:
		HOME_PAGE.hide()
		LOADING.hide()
		SHIP_HUD.show()
		if get_parent().SHIP_DIED:
			DEATH_SCREEN.show()
			SHIP_HUD.hide()
			SHIP_UPGRADES.hide()
			upgrades_hidden = true
		else:
			DEATH_SCREEN.hide()
			SHIP_HUD.show()
			
			SHIELD_BAR.value = 100 * get_parent().ship.health / get_parent().ship.MAX_HEALTH
			ENERGY_BAR.value = 100 * get_parent().ship.energy / get_parent().ship.MAX_ENERGY
	elif get_parent().LOADING_WORLD:
		HOME_PAGE.hide()
		LOADING.show()
		SHIP_UPGRADES.hide()
		upgrades_hidden = true

func _on_singleplayer_button_button_down():
	get_parent().create_new_world()

func _on_respawn_button_button_down():
	get_parent().respawn_ship()

func _on_quit_button_button_down():
	DEATH_SCREEN.hide()
	QUITTING.show()
	get_parent().quit = true

func _on_upgrades_pressed():
	if upgrades_hidden:
		SHIP_UPGRADES.show()
	else:
		SHIP_UPGRADES.hide()
	upgrades_hidden = !upgrades_hidden
	
func _on_inventory_weapons_pressed():
	if inventory_weapons_hidden:
		SHIP_INVENTORY_WEAPONS.show()
	else:
		SHIP_INVENTORY_WEAPONS.hide()
	inventory_weapons_hidden = !inventory_weapons_hidden

func _on_upgrade_shield_cap_pressed():
	pass # Replace with function body.

func _on_upgrade_shield_reg_pressed():
	pass # Replace with function body.

func _on_upgrade_bullet_cap_pressed():
	pass # Replace with function body.

func _on_upgrade_bullet_reg_pressed():
	pass # Replace with function body.

func _on_upgrade_bullet_dmg_pressed():
	pass # Replace with function body.

func _on_upgrade_bullet_speed_pressed():
	pass # Replace with function body.

func _on_upgrade_ship_speed_pressed():
	pass # Replace with function body.

func _on_upgrade_ship_agility_pressed():
	pass # Replace with function body.

func _on_upgrade_ship_fov_pressed():
	pass # Replace with function body.

func _on_upgrade_weapon_slots_pressed():
	pass # Replace with function body.
