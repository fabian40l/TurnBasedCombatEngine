local TargetSelector = {}

local CombatStatsService = require(game.ServerScriptService.Combat.CombatStatsService)

function TargetSelector.GetPlayerTarget(session)
	for _, npc in ipairs(session.Participants.NPCs) do
		if npc and npc.Instance and CombatStatsService.IsAlive(npc) then
			return npc
		end
	end

	return nil
end

function TargetSelector.GetNPCTarget(session, npc)
	local player = session.Participants[1]

	if player and CombatStatsService.IsAlive(player) then
		return player
	end

	return nil
end

function TargetSelector.GetTarget(session, participant)
	if participant.Type == "Player" then
		return TargetSelector.GetPlayerTarget(session)
	elseif participant.Type == "NPC" then
		return TargetSelector.GetNPCTarget(session, participant)
	end
end

return TargetSelector