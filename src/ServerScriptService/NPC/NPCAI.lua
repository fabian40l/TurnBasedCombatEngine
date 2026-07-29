local NPCAI = {}

local Players = game:GetService("Players")
local NPCManager = require(game.ServerScriptService.NPC.NPCManager)

local UPDATE_INTERVAL = 0.25
local DEFAULT_AGGRO_RANGE = 10

local states = {}

local function getCharacterRootPart(player)
	local character = player.Character

	if not character then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or humanoid.Health <= 0 or not rootPart then
		return nil
	end

	return rootPart
end

local function getClosestPlayer(origin, maxDistance)
	local closestPlayer = nil
	local closestRootPart = nil
	local closestDistance = maxDistance

	for _, player in Players:GetPlayers() do
		local rootPart = getCharacterRootPart(player)

		if rootPart then
			local distance = (rootPart.Position - origin).Magnitude

			if distance <= closestDistance then
				closestPlayer = player
				closestRootPart = rootPart
				closestDistance = distance
			end
		end
	end

	return closestPlayer, closestRootPart
end

local function runAI(npc, state)
	while state.Running and npc.Parent do
		if NPCManager.IsInCombat(npc) then
			state.TargetPlayer = nil
			state.Humanoid:MoveTo(state.RootPart.Position)
		else
			local targetPlayer, targetRootPart = getClosestPlayer(state.RootPart.Position, state.AggroRange)

			if targetRootPart then
				state.TargetPlayer = targetPlayer
				state.Humanoid:MoveTo(targetRootPart.Position)
			else
				state.TargetPlayer = nil
				state.Humanoid:MoveTo(state.HomePosition)
			end
		end

		task.wait(UPDATE_INTERVAL)
	end
end

local function AfterBattleCooldown(npc,cooldown)
	if states[npc] then
		return false
	end
	
	states[npc].Humanoid:MoveTo(states[npc].RootPart.Position)
	
	task.wait(cooldown)
end

function NPCAI.Start(npc, homeCFrame)
	if states[npc] then
		return false
	end

	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	local rootPart = npc:FindFirstChild("HumanoidRootPart", true)

	if not humanoid or not rootPart or not rootPart:IsA("BasePart") then
		warn("No se pudo iniciar la IA: " .. npc.Name .. " necesita Humanoid y HumanoidRootPart")
		return false
	end

	local aggroRange = npc:GetAttribute("AggroRange") or DEFAULT_AGGRO_RANGE

	if typeof(aggroRange) ~= "number" or aggroRange <= 0 then
		warn("AggroRange inválido en " .. npc.Name .. "; se usará el valor por defecto")
		aggroRange = DEFAULT_AGGRO_RANGE
	end

	local state = {
		Running = true,
		Humanoid = humanoid,
		RootPart = rootPart,
		HomePosition = homeCFrame.Position,
		AggroRange = aggroRange,
		TargetPlayer = nil,
	}

	states[npc] = state

	npc.Destroying:Connect(function()
		NPCAI.Stop(npc)
	end)

	humanoid.Died:Connect(function()
		NPCAI.Stop(npc)
	end)

	task.spawn(runAI, npc, state)

	return true
end

function NPCAI.Stop(npc)
	local state = states[npc]

	if not state then
		return false
	end

	state.Running = false
	states[npc] = nil

	return true
end

function NPCAI.GetTargetPlayer(npc)
	local state = states[npc]

	if not state then
		return nil
	end

	return state.TargetPlayer
end

return NPCAI
