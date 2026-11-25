class_name Player
extends Node2D

@export var character: CharacterGame
@export_group("Controladores")
@export var movementController: MovementController
@export var animController: AnimController

@onready var AnimacionChar: AnimatedSprite2D = $Sprite
var EstaCorriendo: bool = false

func _physics_process(delta: float) -> void:
	if (character == null):
		printerr("character esta vacio, debes ingresar un tipo de recurso desde el inspector.")
		return
	
	var direccion: Vector2 = Vector2.ZERO
	if (Input.is_action_pressed("buttonDown")):
		direccion = Vector2.DOWN
	elif (Input.is_action_pressed("buttonLeft")):
		direccion = Vector2.LEFT
	elif (Input.is_action_pressed("buttonRight")):
		direccion = Vector2.RIGHT
	elif (Input.is_action_pressed("buttonUp")):
		direccion = Vector2.UP
	EstaCorriendo = ((direccion != Vector2.ZERO) && (Input.is_action_pressed("buttonB")))
	position = movementController.AplicarMovimiento(self, character, direccion, EstaCorriendo, delta)
	animController.AplicarAnimacion(AnimacionChar, movementController.DireccionActual, movementController.SeMueve, EstaCorriendo, movementController.EsPrimerPaso)
