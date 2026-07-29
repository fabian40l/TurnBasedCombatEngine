local CombatInitiator = {}

local CombatRequestHandler = require(game.ServerScriptService.Combat.CombatRequestHandler)
local NPCManager = require(game.ServerScriptService.NPC.NPCManager)
local NPCAI = require(game.ServerScriptService.NPC.NPCAI)

local UPDATE_INTERVAL = 0.1
local DEFAULT_CONTACT_RANGE = 4
local DEFAULT_RECONTACT_COOLDOWN = 3

local states = {}

local function getPlayerRootPart(player)
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

local function runContactCheck(npc, state)
	
	while state.Running and npc.Parent do
		if not NPCManager.IsInCombat(npc) and os.clock() >= state.NextContactTime then
			local targetPlayer = NPCAI.GetTargetPlayer(npc)
			local targetRootPart = targetPlayer and getPlayerRootPart(targetPlayer)

			if targetRootPart then
				local distance = (targetRootPart.Position - state.RootPart.Position).Magnitude

				if distance <= state.ContactRange then
					local started = CombatRequestHandler.Request(targetPlayer, npc, {
						Type = "EnemyContact",
						Initiator = npc,
					},states[npc].recontactCooldown)
					
				end
			end
		end

		task.wait(UPDATE_INTERVAL)
	end
end

function CombatInitiator.StartEnemyContact(npc)
	if states[npc] then
		return false
	end

	local rootPart = npc:FindFirstChild("HumanoidRootPart", true)

	if not rootPart or not rootPart:IsA("BasePart") then
		warn("No se pudo iniciar el contacto de combate: " .. npc.Name .. " no tiene HumanoidRootPart")
		return false
	end

	local contactRange = npc:GetAttribute("CombatContactRange") or DEFAULT_CONTACT_RANGE

	if typeof(contactRange) ~= "number" or contactRange <= 0 then
		warn("CombatContactRange inválido en " .. npc.Name .. "; se usará el valor por defecto")
		contactRange = DEFAULT_CONTACT_RANGE
	end

	local recontactCooldown = npc:GetAttribute("RecontactCooldown") or DEFAULT_RECONTACT_COOLDOWN

	if typeof(recontactCooldown) ~= "number" or recontactCooldown < 0 then
		warn("RecontactCooldown inválido en " .. npc.Name .. "; se usará el valor por defecto")
		recontactCooldown = DEFAULT_RECONTACT_COOLDOWN
	end

	local state = {
		Running = true,
		RootPart = rootPart,
		ContactRange = contactRange,
		RecontactCooldown = recontactCooldown,
		NextContactTime = 0,
	}

	states[npc] = state

	npc.Destroying:Connect(function()
		CombatInitiator.Stop(npc)
	end)

	task.spawn(runContactCheck, npc, state)

	return true
end

function CombatInitiator.Stop(npc)
	local state = states[npc]

	if not state then
		return false
	end

	state.Running = false
	states[npc] = nil

	return true
end

return CombatInitiator
