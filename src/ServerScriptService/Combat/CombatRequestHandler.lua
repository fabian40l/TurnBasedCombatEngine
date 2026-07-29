local CombatRequestHandler = {}

local NPCManager = require(game.ServerScriptService.NPC.NPCManager)
local CombatController = require(game.ServerScriptService.Combat.CombatController)

function CombatRequestHandler.Request(player, npc, initiation)

	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return false
	end

	if typeof(npc) ~= "Instance" or not npc:IsA("Model") then
		return false
	end

	if initiation and typeof(initiation.Type) ~= "string" then
		return false
	end

	if not NPCManager.Exists(npc) then
		return false
	end

	if NPCManager.IsInCombat(npc) then
		return false
	end

	if NPCManager.IsInCooldown(npc) then
		return false
	end

	return CombatController.StartCombat(player, npc,initiation, NPCManager) ~= nil

end

return CombatRequestHandler