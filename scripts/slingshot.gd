extends Node2D

var LINK: Sprite2D
var GRABBER: AnimatedSprite2D

func _ready():
	LINK = $SlingshotLink
	GRABBER = $SlingshotGrabber
	
	GRABBER.play("slingshot_grabber")
