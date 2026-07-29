local NPCData = {
	
	[1] = {
		
		Name = "Humanoid",
		
		MaxHealth = 30,
		
		CurrentHealth = 30,
		
		Attack = 6,
		
		Defense = 2,
		
		Speed = 8,
		
		Experience = 15,
		
		Luck = 1,
		
		Type = "Normal"
	},
	
	[2] = {
		Name = "Slime",

		MaxHealth = 10,

		Attack = 6,

		Defense = 1,

		Speed = 5,

		Experience = 5,
		
		Luck = 1,
		
		Type = "Normal"

	}
	
}

function buscarPorNombre(Name)
	if not Name then
		return nil
	end 
	
	for _, npc in pairs(NPCData) do
		if npc.Name == Name then
			return npc
		end
	end
	print("No existe un npc de nombre ".. Name)
	return nil
end


return NPCData
