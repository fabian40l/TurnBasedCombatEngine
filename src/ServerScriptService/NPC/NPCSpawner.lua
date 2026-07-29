local NPCSpawner = {}

local NPCFactory = require(game.ReplicatedStorage.Modules.NPC.NPCFactory)

local NPCManager = require(game.ServerScriptService.NPC.NPCManager)

function NPCSpawner.Spawn(ID, spawnCFrame)

	if typeof(spawnCFrame) ~= "CFrame" then
		error("NPCSpawner.Spawn requiere un CFrame de aparición")
	end

	local npc = NPCFactory.Create(ID)

	npc:PivotTo(spawnCFrame)

	npc.Parent = workspace

	NPCManager.Register(npc)

	return npc

end

return NPCSpawner
