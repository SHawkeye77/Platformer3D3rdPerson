extends CharacterBody3D

@onready var meshes = get_node("%Meshes")
@onready var cameraGimbal = get_node("%CameraGimbal")
@onready var innerGimbal = get_node("%InnerGimbal")
@onready var camera = get_node("%Camera3D")
@onready var dashLengthTimer = get_node("%DashLengthTimer")
@onready var dashGhostTimer = get_node("%DashGhostTimer")
@onready var timeBetweenDashesTimer = get_node("%TimeBetweenDashesTimer")
@onready var coyoteTimer = get_node("%CoyoteTimer")
@onready var wallCheck = get_node("%WallCheck")
@onready var stillOnWallCheck = get_node("%StillOnWallCheck")
@onready var wallChecking = get_node("%WallChecking")
@onready var dashesLeft = Global.PLAYER_DASHES_ALLOWED
@onready var stickPointHolder = get_node("%StickPointHolder")
@onready var stickPoint = get_node("%StickPoint")
@onready var gameStartBufferTimer = get_node("%GameStartBufferTimer")
@onready var jumpAudio = get_node("%JumpAudio")
@onready var landAudio = get_node("%LandAudio")
@onready var dashAudio = get_node("%DashAudio")
const endScreen = "res://Scenes/end_screen.tscn"
var timeSinceHitJump = 0.0  # Used for jump buffering
var dashing = false
var canDash = true
var climbing = false
var gravityEnabled = true
var ghostsSpawnedThisDash = 0
# Custom jump variables
@onready var jumpVelocity = (2.0 * Global.PLAYER_JUMP_HEIGHT) / Global.PLAYER_JUMP_TIME_TO_PEAK
@onready var jumpGravity = (-2.0 * Global.PLAYER_JUMP_HEIGHT) / (Global.PLAYER_JUMP_TIME_TO_PEAK * Global.PLAYER_JUMP_TIME_TO_PEAK)
@onready var fallGravity = (-2.0 * Global.PLAYER_JUMP_HEIGHT) / (Global.PLAYER_JUMP_TIME_TO_DESCENT * Global.PLAYER_JUMP_TIME_TO_DESCENT)

func _ready():
	# Setting up dash variables
	dashLengthTimer.wait_time = Global.PLAYER_DASH_LENGTH
	dashGhostTimer.wait_time = Global.PLAYER_DASH_LENGTH / (Global.PLAYER_NUMBER_OF_DASH_GHOSTS - 1)
	timeBetweenDashesTimer.wait_time = Global.PLAYER_TIME_BETWEEN_DASHES_LENGTH
	# Setting up coyote timer
	coyoteTimer.wait_time = Global.PLAYER_JUMP_COYOTE_TIME

func _physics_process(delta):
	
	# Climbing
	checkClimbing()
	
	# Gravity
	if is_on_floor() or climbing:
		velocity.y = 0
	else:
		velocity.y += getGravity() * delta

	# Jumping (including jump buffering and coyote time)
	if Input.is_action_just_pressed("jump"):
		timeSinceHitJump = Global.PLAYER_JUMP_BUFFER_TIME
	if Input.is_action_just_released("jump") and velocity.y > 0:  # Variable height jump
		velocity.y = 0
	timeSinceHitJump -= delta
	if timeSinceHitJump < -999999:  # Just making sure it doesn't get too low and out of range
		timeSinceHitJump = 0.0
	if timeSinceHitJump > 0.0 and (is_on_floor() or !coyoteTimer.is_stopped() or climbing):
		timeSinceHitJump = 0.0
		jump()
	
	# Dashing
	if is_on_floor() and !dashing:
		dashesLeft = Global.PLAYER_DASHES_ALLOWED  # Resetting the dash
	if Input.is_action_just_pressed("dash") and canDash and dashesLeft > 0:
		playDashAudio()
		# If in the air, give a slight upwards boost
		if not is_on_floor():
			velocity.y = Global.PLAYER_DASH_UPWARDS_BOOST
		dashing = true
		canDash = false
		dashesLeft -= 1
		ghostsSpawnedThisDash = 0
		spawnGhost()
		dashGhostTimer.start()
		dashLengthTimer.start()

	# Exiting
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

	# Setting speed (dashing/climbing/walking)
	var speed = -1
	if dashing:
		speed = Global.PLAYER_DASH_SPEED
	elif climbing:
		speed = Global.PLAYER_CLIMBING_SPEED
	else:
		speed = Global.PLAYER_SPEED_WALK

	### Movement ###
	var inputDir = Input.get_vector("left", "right", "forward", "back")
	var direction = Vector3.ZERO
	if climbing:
		# Getting the direction relative to the player
		direction = Vector3(inputDir.x, inputDir.y, 0).rotated(Vector3.UP, meshes.rotation.y).normalized()
		if direction:
			velocity.x = direction.x * speed
			velocity.y = -direction.y * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0
			velocity.y = 0
			velocity.z = 0
		
		# Sticking the player to the wall
		stickPointHolder.global_transform.origin = wallCheck.get_collision_point()
		global_transform.origin.x = stickPoint.global_transform.origin.x
		global_transform.origin.z = stickPoint.global_transform.origin.z
	else:
		# Getting the direction relative to the camera
		direction = Vector3(inputDir.x, 0, inputDir.y).rotated(Vector3.UP, cameraGimbal.rotation.y).normalized()
		if is_on_floor():
			if direction:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = 0
				velocity.z = 0
		else:
			# Apply inertia while in the air
			velocity.x = lerp(velocity.x, direction.x * speed, delta * Global.ENVIRONMENT_AIR_INERTIA)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * Global.ENVIRONMENT_AIR_INERTIA)

	### Rotation ###
	if climbing:
		var lookAtDirection = Vector3(-wallCheck.get_collision_normal().x, -wallCheck.get_collision_normal().y, -wallCheck.get_collision_normal().z)
		meshes.look_at(meshes.global_position + lookAtDirection)
		wallChecking.look_at(wallChecking.global_position + lookAtDirection)
	elif direction:
		meshes.rotation.y = lerp_angle(meshes.rotation.y, atan2(-direction.x, -direction.z), delta * Global.PLAYER_ROTATION_SPEED)
		wallChecking.rotation.y = lerp_angle(wallChecking.rotation.y, atan2(-direction.x, -direction.z), delta * Global.PLAYER_ROTATION_SPEED)

	# FOV
	var velocityClamped = clamp(velocity.length(), 0.5, Global.PLAYER_SPEED_WALK * 2.0)
	var targetFov = Global.UI_BASE_FOV + Global.UI_FOV_CHANGE * velocityClamped
	camera.fov = lerp(camera.fov, targetFov, delta * 8.0)
	
	# Storing if we were on floor before move_and_slide (for coyote timer)
	var wasOnFloor = is_on_floor()

	move_and_slide()

	# If we just got off a platform, start our coyote timer
	if wasOnFloor and !is_on_floor():
		coyoteTimer.start()
	
	# If we just landed, play our landing audio
	if !wasOnFloor and is_on_floor() and gameStartBufferTimer.is_stopped():
		playLandAudio()

func _input(event):
	# Camera rotation
	if event is InputEventMouseMotion:
		# Rotating left and right
		cameraGimbal.rotate_object_local(Vector3(0, 1, 0), deg_to_rad(-event.relative.x * Global.UI_SENSITIVITY))
		# Rotating up and down
		innerGimbal.rotate_object_local(Vector3(1, 0, 0), deg_to_rad(-event.relative.y * Global.UI_SENSITIVITY))
		innerGimbal.rotation.x = clamp(innerGimbal.rotation.x, deg_to_rad(-90), deg_to_rad(45))

func checkClimbing():
	# Checking if the player is currently climbing
	if wallCheck.is_colliding():
		if stillOnWallCheck.is_colliding():
			if Input.is_action_pressed("climb"):
				if is_on_floor():
					climbing = false
				else:
					climbing = true
			else:
				climbing = false
		# Player is at the top of a climb, so boost them over the top
		else:
			velocity.y = Global.PLAYER_JUMP_OVER_LEDGE_VELOCITY
			await get_tree().create_timer(0.3).timeout
			climbing = false
	else:
		climbing = false

func getGravity():
	if velocity.y > 0.0:
		return jumpGravity
	else:
		return fallGravity

func jump():
	playJumpAudio()
	# Normal jump
	if !climbing:
		velocity.y = jumpVelocity
	# Wall jump
	else:
		# Flip the player direction
		var lookAtDirection = wallCheck.get_collision_normal()
		meshes.look_at(meshes.global_position + lookAtDirection)
		wallChecking.look_at(wallChecking.global_position + lookAtDirection)
		# Add the wall jump velocity
		velocity = wallCheck.get_collision_normal() * jumpVelocity * Global.PLAYER_WALL_JUMP_X_MULTIPLIER
		velocity.y += jumpVelocity * Global.PLAYER_WALL_JUMP_Y_MULTIPLIER
		climbing = false

func spawnGhost():
	# Marking that we have spawned a ghost
	ghostsSpawnedThisDash += 1
	# Making a ghost of each mesh
	for mesh in meshes.get_children():
		# Copying the mesh to create the ghost from
		var ghostMesh = mesh.duplicate()
		ghostMesh.position = mesh.global_position
		ghostMesh.rotation = mesh.rotation
		# Creating a new material to fade out and copying its attributes over
		var ghostMaterial = StandardMaterial3D.new()
		ghostMaterial.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
		ghostMaterial.albedo_color = mesh.mesh.material.albedo_color  # Copy the color
		ghostMaterial.albedo_color.a = Global.PLAYER_GHOST_STARTING_ALPHA  # Set a new alpha
		ghostMesh.material_override = ghostMaterial
		# Setting a tween to gradually fade out the mesh
		var tweenFadeBody = create_tween()
		tweenFadeBody.tween_property(ghostMesh.material_override, "albedo_color:a", 0, Global.PLAYER_GHOST_FADE_LENGTH)
		get_tree().root.add_child(ghostMesh)
		# Deleting the mesh after the tween ends
		get_tree().create_timer(Global.PLAYER_GHOST_FADE_LENGTH).timeout.connect(ghostMesh.queue_free)

func _on_dash_length_timer_timeout():
	dashing = false
	timeBetweenDashesTimer.start()

func _on_time_between_dashes_timer_timeout():
	canDash = true

func _on_dash_ghost_timer_timeout():
	# Still have more ghosts to spawn
	if ghostsSpawnedThisDash < Global.PLAYER_NUMBER_OF_DASH_GHOSTS:
		spawnGhost()
		dashGhostTimer.start()

func playJumpAudio():
	jumpAudio.play()

func playLandAudio():
	landAudio.play()

func playDashAudio():
	dashAudio.play()

func death():
	Global.wonGame = false
	var _level = get_tree().change_scene_to_file(endScreen)

func victory():
	Global.wonGame = true
	var _level = get_tree().change_scene_to_file(endScreen)
