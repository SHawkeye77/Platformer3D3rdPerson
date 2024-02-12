"""
TODO
	- Fix/add the following known bugs/features
		- Sometimes during the dash the camera goes weird such that the camera seems to be inside the character for a split second. Happens especially when the player is moving away from the camera.
	- Upload to GitHub
	- Upload to itch.io
	- Update website with a link

Notes
	- Theme will be like a beach in the sky
	- At one point, I asked a forum question for this project. I'll link it below.
		- https://forum.godotengine.org/t/3d-dash-ghost-fading-effect-issue/46014
	- Things I'd like to add eventually
		- Make it so you can go around 90 degree turns while climbing 

Included Features
	- Jumping (including custom jump function, jump buffering, variable jump height, and coyote time)
	- Dashing (with ghost fade effect)
	- Wall jumping
	- Wall climb (changing such that direction is reltive to player when wall climbing)
	- Third person, turning direction-agnostic camera
	- Smooth player turning
	- Custom skybox

Resources Refrenced
	- Celeste 64 gameplay (inspiration)
		- https://youtu.be/GvVN7HaW_X8?si=EN3e6-TswbdEqDYL&t=1044
	- Character controller
		- https://www.youtube.com/watch?v=j_rf8zc5kTE
		- https://www.youtube.com/watch?v=A3HLeyaBCq4
		- https://www.youtube.com/watch?v=4NLrfxNt3ps
	- Skybox
		- https://www.youtube.com/watch?v=NtVABru6OXE
	- Dashing
		- https://www.youtube.com/watch?v=A-Y1zxJ6oH4
		- https://www.youtube.com/watch?v=Q2oRzUXB27w
	- Buffer jumping
		- https://www.youtube.com/watch?v=7XDMG3Xm5eg
	- Coyote time
		- https://www.youtube.com/watch?v=bJOpkFIEwCA
	- Custom jump
		- https://www.youtube.com/watch?v=IOe1aGY6hXA
	- Variable jump height
		- https://www.youtube.com/watch?v=eXmx3SQ_wBo
	- Wall climbing
		- https://www.youtube.com/watch?v=wRLmRedssvs
	- Wall jumping
		- https://www.youtube.com/watch?v=5K3rXNXUcbI

Assets Used
	- Palm Tree
		- https://poly.pizza/m/bjGeBbKhAVN
	- Spikes
		- https://poly.pizza/m/vBafePBZaf
	- Flag
		- https://poly.pizza/m/FuOkF3WBrx
	- Sand texture
		- https://ambientcg.com/view?id=Ground052
	- Sound effects
		- Jump
			- https://freesound.org/people/Raclure/sounds/483602/
		- Land
			- https://freesound.org/people/KieranKeegan/sounds/422753/
		- Dash
			- https://freesound.org/people/deleted_user_6479820/sounds/353046/
	- 
"""
