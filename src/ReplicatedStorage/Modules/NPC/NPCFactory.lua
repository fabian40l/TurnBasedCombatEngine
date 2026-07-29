local NPCFactory = {}

local NPCData = require(script.Parent.NPCData)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Models = ReplicatedStorage.NPCModels

function NPCFactory.Create(ID) 
	
	local data = NPCData[ID]
	
	if not data then 
		error("NPC no existe") 
	end
	
	local model = Models:FindFirstChild(data.Name)
	
	if not model then
		error("Modelo inexistente")
	end
	
	local npc = model:Clone()
	
	npc:SetAttribute("TypeEnemyID",ID)

	npc:SetAttribute("MaxHealth",data.MaxHealth)

	npc:SetAttribute("Health",data.MaxHealth)

	npc:SetAttribute("Attack",data.Attack)

	npc:SetAttribute("Defense",data.Defense)

	npc:SetAttribute("Speed",data.Speed)

	npc:SetAttribute("Experience",data.Experience)
	
	npc:SetAttribute("Luck",data.Luck)

	npc:SetAttribute("Type",data.Type)

	return npc
	
end

return NPCFactory
