local NPCManager = {}

local NPCRegistry = {}

local npcData =require(game.ReplicatedStorage.Modules.NPC.NPCData)

function NPCManager.GetInfo(npc)

	return NPCRegistry[npc]

end

function NPCManager.Register(npc)
	
	NPCRegistry[npc] = {
		
		InCombat = false,

		InCooldown = false,

		Player = nil,

		SpawnPoint = nil,

		RespawnTime = nil,

		State = "Idle"

		
	}
	
end

function NPCManager.Remove(npc)

	NPCRegistry[npc] = nil

end

function NPCManager.Exists(npc)
	
	return NPCRegistry[npc]~=nil
	
end

function NPCManager.IsInCombat(npc)
	
	if not NPCRegistry[npc] then
		return false
	end

	return NPCRegistry[npc].InCombat

end

function NPCManager.GetAll()

	return NPCRegistry

end

function NPCManager.MarkInCombat(npc, player)

	local info = NPCRegistry[npc]

	if not info or info.InCombat then
		return false
	end

	info.InCombat = true
	info.Player = player
	info.State = "Combat"

	return true

end

function NPCManager.MarkIdle(npc)

	local info = NPCRegistry[npc]

	if not info then
		return false
	end

	info.InCombat = false
	info.Player = nil
	info.State = "Idle"

	return true

end

function NPCManager.StartCooldown(npc, seconds)
	
	local info = NPCRegistry[npc]
	
	if not info then
		return false
	end	
	
	info.State = "Cooldown"
	
	info.InCooldown = true
	
	task.wait(seconds)
	
	info.InCooldown = false
	
	info.State = "Idle"
	
	return true
end

function NPCManager.IsInCooldown(npc, seconds)
	
	local info = NPCRegistry[npc]
	
	if not info then
		return false
	end
	
	return info.InCooldown
	
end


return NPCManager