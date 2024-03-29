Hay = {}

Hay.spawns = {{2485, -1670, 13}, {-2328, -1625, 484}, {358, 2537, 17}, {-2464, 2234, 5}, {210, 1904, 18}, {2015, 1252, 11}}
Hay.respawnTimer = {}

Hay.Skins= {0, 1, 2, 7, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 57, 58, 59, 60, 61, 62, 66, 67, 68, 70, 71, 72, 73, 78, 79, 80, 81, 82, 83, 84, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 120, 121, 122, 123, 124, 125, 126, 127, 128, 132, 133, 134, 135, 136, 137, 142, 143, 144, 146, 147, 153, 154, 155, 156, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 170, 171, 173, 174, 175, 176, 177, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 200, 202, 203, 204, 206, 209, 210, 212, 213, 217, 220, 221, 222, 223, 227, 228, 229, 230, 234, 235, 236, 239, 240, 241, 242, 247, 248, 249, 250, 252, 253, 254, 255, 258, 259, 260, 261, 262, 264, 265, 266, 267, 268, 269, 270, 271, 272, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 290, 291, 292, 293, 294, 295, 296, 297, 299, 300, 301, 302, 303, 305, 306, 307, 308, 309, 310, 311, 312, 9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 53, 54, 55, 56, 63, 64, 69, 75, 76, 77, 85, 87, 88, 89, 90, 91, 92, 93, 129, 130, 131, 138, 139, 140, 141, 145, 148, 150, 151, 152, 157, 169, 172, 178, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 201, 205, 207, 211, 214, 215, 216, 218, 219, 224, 225, 226, 231, 232, 233, 237, 238, 243, 244, 245, 246, 251, 256, 257, 263, 298, 304}

Hay.Options = {
	x = 4,
	y = 4,
	z = 40 - 1, -- Altura
	b = 40, -- Bloques
	r = 4
}

function Hay.load()

	outputServerLog(getElementID(source)..": Loading Hay Definitions")

	addEventHandler("onSetDownHayDefinitions", source, Hay.unload)
	addEventHandler("onPlayerWasted", source, Hay.playerWasted, true, "low")
	addEventHandler("onPlayerLeaveArena", source, Hay.quit)
	addEventHandler("onPlayerRequestSpawn", source, Hay.spawn)
	addEventHandler( "onPickupHit", root, Hay.pickupHit)
	
	triggerEvent("onStartNewMap", source, MapManager.getRandomArenaMap("Freeroam"), false)

	setElementData(source, "state", "In Progress")
	outputChatBox("[HAY] Iniciando...", root, 0, 255, 0)

	Hay.Iniciar(source)
end
addEvent("onSetUpHayDefinitions", true)
addEventHandler("onSetUpHayDefinitions", root, Hay.load)

function Hay.Iniciar(Arena)
	if not isElement(Arena) then return end
	
	Hay.Options.z = math.random(40, 60)
	Hay.Options.b = math.random(5, 7) * Hay.Options.z

	outputDebugString("[HAY] Creando "..Hay.Options.z.." niveles con "..Hay.Options.b.." bloques.")

	Hay.Matrix = {}
	Hay.Objects = {}
	Hay.Moving = {}

	--Clean matrix
	for x = 1, Hay.Options.x do
		Hay.Matrix[x] = {}
		for y = 1,Hay.Options.y do
			Hay.Matrix[x][y] = {}
			for z = 1,Hay.Options.z do
				Hay.Matrix[x][y][z] = 0
			end
		end
	end

    --Place number of haybails in matrix
	local x,y,z

	for count = 1, Hay.Options.b do
		repeat
			x = math.random ( 1, Hay.Options.x )
			y = math.random ( 1, Hay.Options.y )
			z = math.random ( 1, Hay.Options.z )
		until (Hay.Matrix[x][y][z] == 0)
		Hay.Matrix[x][y][z] = 1
		Hay.Objects[count] = createObject ( 3374, x * -4, y * -4, z * 3 )
		setElementDimension(Hay.Objects[count], getElementDimension(Arena))
	end

	--Calculate tower center and barrier radius
	barrier_x = (Hay.Options.x + 1) * -2
	barrier_y = (Hay.Options.y + 1) * -2	
	if (Hay.Options.x > Hay.Options.y) then 
		barrier_r = Hay.Options.x / 2 + 20 
	else
		barrier_r = Hay.Options.y / 2 + 20 
	end

	-- Bloque final y pickup
	Hay.Final = createObject ( 3374, barrier_x, barrier_y, Hay.Options.z * 3 + 3 )
	setElementDimension(Hay.Final, getElementDimension(Arena))

	Hay.Pickup = createPickup(barrier_x, barrier_y, Hay.Options.z * 3 + 6, 3, 2880, 1)
	setElementDimension(Hay.Pickup, getElementDimension(Arena))
	
	xy_speed = 2000 / (Hay.Options.z + 1)
	z_speed = 1500 / (Hay.Options.z + 1)

	Hay.Timer = setTimer(Hay.Move, 100, 0)
end

function Hay.Destruir()
	if isTimer(Hay.Timer) then
		killTimer(Hay.Timer)
	end

	for _, Object in pairs(Hay.Objects) do
		if isElement(Object) then
			destroyElement(Object)
		end
	end

	if isElement(Hay.Pickup) then
		destroyElement(Hay.Pickup)
	end

	if isElement(Hay.Final) then
		destroyElement(Hay.Final)
	end
end

function Hay.Move()
	--outputDebugString("move entered")
	local rand
	repeat
		rand = math.random( 1, Hay.Options.b )
	until (Hay.Moving[rand] ~= 1)

	local object = Hay.Objects[ rand ]
	local move = math.random( 0, 5 )
	--outputDebugString("move: " .. move)
	local x,y,z
	local x2,y2,z2 = getElementPosition ( object )
	--Purge old player positions
	for x = 1,Hay.Options.x do
		for y = 1,Hay.Options.y do
			for z = 1,Hay.Options.z do
				if (Hay.Matrix[x][y][z] == 2) then
					Hay.Matrix[x][y][z] = 0
				end
			end
		end
	end
	--Fill in new player positions
	local players = getElementsByType( "player" )
	for k,v in ipairs(players) do
		x,y,z = getElementPosition( v )
		x = math.floor(x / -4 + 0.5)
		y = math.floor(y / -4 + 0.5)
		z = math.floor(z / 3 + 0.5)
		if (x >= 1) and (x <= Hay.Options.x) and (y >= 1) and (y <= Hay.Options.y) and (z >= 1) and (z <= Hay.Options.z) and (Hay.Matrix[x][y][z] == 0) then
			Hay.Matrix[x][y][z] = 2
		end
	end
	x = x2 / -4
	y = y2 / -4
	z = z2 / 3
	if (move == 0)  and (x ~= 1) and (Hay.Matrix[x-1][y][z] == 0) then
		Hay.Moving[rand] = 1
		local s = 4000 - xy_speed * z
		setTimer (Hay.Done, s, 1, rand, x, y, z)
		x = x - 1
		Hay.Matrix[x][y][z] = 1
		--outputDebugString("moving obj")
		moveObject ( object, s, x2 + 4, y2, z2, 0, 0, 0 )
	elseif (move == 1) and (x ~= Hay.Options.x) and (Hay.Matrix[x+1][y][z] == 0) then
		Hay.Moving[rand] = 1
		local s = 4000 - xy_speed * z
		setTimer (Hay.Done, s, 1, rand, x, y, z)
		x = x + 1
		Hay.Matrix[x][y][z] = 1
		--outputDebugString("moving obj")
		moveObject ( object, s, x2 - 4, y2, z2, 0, 0, 0 )
	elseif (move == 2) and (y ~= 1) and (Hay.Matrix[x][y-1][z] == 0) then
		Hay.Moving[rand] = 1
		local s = 4000 - xy_speed * z
		setTimer (Hay.Done, s, 1, rand, x, y, z)
		y = y - 1
		Hay.Matrix[x][y][z] = 1
		--outputDebugString("moving obj")
		moveObject ( object, s, x2, y2 + 4, z2, 0, 0, 0 )
	elseif (move == 3) and (y ~= Hay.Options.y) and (Hay.Matrix[x][y+1][z] == 0) then
		Hay.Moving[rand] = 1
		local s = 4000 - xy_speed * z
		setTimer (Hay.Done, s, 1, rand, x, y, z)
		y = y + 1
		Hay.Matrix[x][y][z] = 1
		--outputDebugString("moving obj")
		moveObject ( object, s, x2, y2 - 4, z2, 0, 0, 0 )
	elseif (move == 4) and (z ~= 1) and (Hay.Matrix[x][y][z-1] == 0) then
		Hay.Moving[rand] = 1
		local s = 3000 - z_speed * z
		setTimer (Hay.Done, s, 1, rand, x, y, z)
		z = z - 1
		Hay.Matrix[x][y][z] = 1
		--outputDebugString("moving obj")
		moveObject ( object, s, x2, y2, z2 - 3, 0, 0, 0 )
	elseif (move == 5) and (z ~= Hay.Options.z) and ((Hay.Matrix[x][y][z+1] == 0) or ((z ~= Hay.Options.z-1) and (Hay.Matrix[x][y][z+1] == 2) and (Hay.Matrix[x][y][z+2] ~= 1))) then
		Hay.Moving[rand] = 1
		local s = 3000 - z_speed * z
		setTimer (Hay.Done, s, 1, rand, x, y, z)
		z = z + 1
		Hay.Matrix[x][y][z] = 1
		--outputDebugString("moving obj")
		moveObject ( object, s, x2, y2, z2 + 3, 0, 0, 0 )
	end
	--	setTimer ("move", 100 )
end

function Hay.Done ( id, x, y, z )
	Hay.Moving[id] = 0
	Hay.Matrix[x][y][z] = 0
end

function Hay.unload()
	outputServerLog(getElementID(source)..": Unloading Hay Definitions")

	removeEventHandler("onSetDownHayDefinitions", source, Hay.unload)
	removeEventHandler("onPlayerWasted", source, Hay.playerWasted)
	removeEventHandler("onPlayerLeaveArena", source, Hay.quit)
	removeEventHandler("onPlayerRequestSpawn", source, Hay.spawn)
	removeEventHandler( "onPickupHit", root, Hay.pickupHit)
	
	setElementData(source, "state", "End")

	outputDebugString("[HAY] Destruyendo objetos...")

	Hay.Destruir()
end
addEvent("onSetDownHayDefinitions", true)

function Hay.SpawnPlayer(Player)
	
	local arenaElement = getElementParent(Player)

	r = 20
	angle = math.random(133, 308) --random angle between 0 and 359.99
	centerX = -12
	centerY = -10
	spawnX = r*math.cos(angle) + centerX --circle trig math
	spawnY = r*math.sin(angle) + centerY --circle trig math
	spawnAngle = 360 - math.deg( math.atan2 ( (centerX - spawnX), (centerY - spawnY) ) )
	skinrandom = Hay.Skins[math.random(1, #Hay.Skins)]

	spawnPlayer(Player, spawnX, spawnY, 3.3, spawnAngle, skinrandom, 0, getElementDimension(arenaElement))
	setElementFrozen(Player, false)
	setElementRotation(Player, 0, 0, 0)
	setElementData(Player, "state", "Alive")
	setCameraTarget(Player, Player)
	toggleAllControls(Player, true, true, true)
	toggleControl(Player, "fire", false)
	toggleControl(Player, "action", false)
	toggleControl(Player, "aim_weapon", false)
	setPedStat(Player, 160, 1000)
	setPedStat(Player, 229, 1000)
	setPedStat(Player, 230, 1000)
end

function Hay.spawn()
	local arenaElement = getElementParent(source)

	triggerClientEvent(source, "onClientPlayerReady", arenaElement, false, false)	

	if getElementData(source, "Spectator") then
		triggerClientEvent(source, "onClientRequestSpectatorMode", source, true)
		return
	end

	Hay.SpawnPlayer(source)
	
end

function Hay.quit()
	if isTimer(Hay.respawnTimer[source]) then killTimer(Hay.respawnTimer[source]) end
	Hay.respawnTimer[source] = nil
end
addEvent("onPlayerLeaveArena", true)


function Hay.playerWasted(totalAmmo, killer)

	local arenaElement = getElementParent(source)

	setElementData(source, "state", "Dead")

	if killer then
	
		local myPlayerName = getPlayerName(source)

		local hisPlayername = getPlayerName(killer)

		triggerClientEvent(arenaElement, "onClientCreateMessage", source, "#ffffff"..myPlayerName.." #00ffffwas killed by #ffffff"..hisPlayername)

	else
	
		triggerClientEvent(arenaElement, "onClientCreateMessage", arenaElement, getPlayerName(source).."#ff0000 died!", "right")	
		
	end
	
	Hay.respawnTimer[source] = setTimer(Hay.respawn, 3000, 1, source)
	
end


function Hay.respawn(player)

	if not isElement(player) then return end

	if getElementData(player, "state") ~= "Dead" then return end
	
	Hay.SpawnPlayer(player)
end

function Hay.pickupHit(Player)
	if not isElement(Player) or source ~= Hay.Pickup then return end
	
	local Arena = getElementParent(Player)

	if getElementData(Arena, "name") == "Hay" then
		outputChatBox( "* " .. getPlayerName ( Player ) .. " made it to the top!", root, 255, 100, 100, false )
		outputChatBox( "Restarting arena in 10 seconds!", root, 255, 100, 100, false )
		toggleControl ( Player, "fire", true )
		destroyElement( source )
		
		setTimer(Hay.Reiniciar, 10000, 1, Arena)
	end
end

function Hay.Reiniciar(Arena)
	Hay.Destruir()

	for _, Player in pairs(getAlivePlayersInArena(Arena)) do
		Hay.SpawnPlayer(Player)
		triggerClientEvent(Player, "onClientResetHay", Arena, false, false)
	end
	
	Hay.Iniciar(Arena)
end