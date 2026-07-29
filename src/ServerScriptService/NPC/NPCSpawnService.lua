local NPCSpawnService = {}

local NPCSpawner = require(game.ServerScriptService.NPC.NPCSpawner)
local NPCManager = require(game.ServerScriptService.NPC.NPCManager)
local NPCAI = require(game.ServerScriptService.NPC.NPCAI)
local CombatInitiator = require(game.ServerScriptService.Combat.CombatInitiator)

local zoneStates = {}
local random = Random.new()

local function getZoneSettings(zone)
	local enemyID = zone:GetAttribute("EnemyID")
	local maxNPCs = zone:GetAttribute("MaxNPCs") or 1
	local respawnTime = zone:GetAttribute("RespawnTime") or 5

	if typeof(enemyID) ~= "number" then
		warn("La zona " .. zone.Name .. " no tiene un atributo numérico EnemyID")
		return nil
	end

	if typeof(maxNPCs) ~= "number" or maxNPCs < 1 or maxNPCs % 1 ~= 0 then
		warn("La zona " .. zone.Name .. " necesita un atributo entero MaxNPCs mayor que 0")
		return nil
	end

	if typeof(respawnTime) ~= "number" or respawnTime < 0 then
		warn("La zona " .. zone.Name .. " tiene un RespawnTime inválido")
		return nil
	end

	return enemyID, maxNPCs, respawnTime
end

local function getRandomSpawnCFrame(zone)
	local x = random:NextNumber(-zone.Size.X / 2, zone.Size.X / 2)
	local z = random:NextNumber(-zone.Size.Z / 2, zone.Size.Z / 2)

	return zone.CFrame * CFrame.new(x, zone.Size.Y / 2, z)
end

local function spawnNPCInZone(zone, state)
	if state.ActiveNPCs >= state.MaxNPCs then
		return
	end

	local spawnCFrame = getRandomSpawnCFrame(zone)
	local npc = NPCSpawner.Spawn(state.EnemyID, spawnCFrame)
	state.ActiveNPCs += 1
	NPCAI.Start(npc, spawnCFrame)
	CombatInitiator.StartEnemyContact(npc)

	npc.Destroying:Connect(function()
		NPCManager.Remove(npc)
		state.ActiveNPCs -= 1

		if zone.Parent and not state.Stopped then
			task.delay(state.RespawnTime, function()
				if zone.Parent and not state.Stopped then
					spawnNPCInZone(zone, state)
				end
			end)
		end
	end)
end

function NPCSpawnService.StartZone(zone)
	if not zone:IsA("BasePart") then
		warn("Una zona de aparición debe ser una BasePart")
		return false
	end

	if zoneStates[zone] then
		return false
	end

	local enemyID, maxNPCs, respawnTime = getZoneSettings(zone)

	if not enemyID then
		return false
	end

	local state = {
		EnemyID = enemyID,
		MaxNPCs = maxNPCs,
		RespawnTime = respawnTime,
		ActiveNPCs = 0,
		Stopped = false,
	}

	zoneStates[zone] = state

	for _ = 1, maxNPCs do
		spawnNPCInZone(zone, state)
	end

	return true
end

function NPCSpawnService.StopZone(zone)
	local state = zoneStates[zone]

	if not state then
		return false
	end

	state.Stopped = true
	zoneStates[zone] = nil

	return true
end

return NPCSpawnService
