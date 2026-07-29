local NPCSpawnService = require(game.ServerScriptService.NPC.NPCSpawnService)

local NPCSpawns = workspace:WaitForChild("NPCSpawns")

local function startZone(zone)
	NPCSpawnService.StartZone(zone)
end

for _, zone in NPCSpawns:GetChildren() do
	startZone(zone)
end

NPCSpawns.ChildAdded:Connect(startZone)
