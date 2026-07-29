local TurnManager = {}

local CombatStatsService = require(game.ServerScriptService.Combat.CombatStatsService)

local function 	ordernarPorVelocidad(queue)
	
	local priority = {}
	
	for _, participant in ipairs(queue) do
		priority[participant] = math.random()
	end
	
	table.sort(queue, function(a, b)
		local speedA = CombatStatsService.GetSpeed(a)
		local speedB = CombatStatsService.GetSpeed(b)

		if speedA ~= speedB then
			return speedA > speedB
		end

		return priority[a] > priority[b]
	end)		
end


function TurnManager.BuildQueue(session)
	local Participants = session.Participants
	if not Participants then
		print("Error en la session")
		return nil
	end
--	print("------------")
--	print(Participants)
--	print("------------")

	local player = Participants[1]
	if not player then
		print("Error al obtener el jugador de la session")
		return nil
	end
	
	local npcs = Participants.NPCs
	if not npcs then
		print("Error al obtener la lista de npcs de la session")
		return nil
	end
	
	local queue = {}
	
	for _, npc in ipairs(npcs) do
		table.insert(queue, npc)
	end
	
	table.insert(queue, player)
	
	--ordenar por velocidad
	
	ordernarPorVelocidad(queue)
	
	session.Turn.Queue = queue
	
	return queue
end


function TurnManager.StartCombat(session)
	local queue = session.Turn.Queue
	
	if not queue or #queue == 0 then
		warn("Error en la creacion de queue")
		return nil
	end
	
	local current = queue[1]
	
	session.Turn.Current = current
	
	session.Turn.CurrentIndex = 1
	
	session.Turn.Number = 1
	
	session.Turn.Round = 1
		
	return current
	
end

function TurnManager.GetNextTurn(session)
	local queue = session.Turn.Queue
	
	if not queue or #queue == 0 then
		warn("Error en la creacion de queue")
		return nil
	end

	local currentIndex = session.Turn.CurrentIndex
	local Current
	local startIndex  = currentIndex
	while(true)do
	
		if currentIndex == #queue then
			currentIndex = 1
			session.Turn.Round = session.Turn.Round + 1
		else
			currentIndex = currentIndex+1
		end
	
		Current = queue[currentIndex]
		
		if not Current then
			warn("Error al obtener el jugador actual")
			return nil
		end
		
		local instance = Current.Instance

		if not instance then
			warn("Error en obtener la instancia de la entidad del turno actual")
			return nil
		end
			
		if Current.Type == "Player" then 
--			print("Es el turno de ".. instance.Name)
			break 
		end
		
		if CombatStatsService.CanAct(Current) then
			break
		end 
		
		if(startIndex  == currentIndex) then
			warn("No hay npc restantes")
			return nil
		end
	end 
	
	
	session.Turn.CurrentIndex = currentIndex
	session.Turn.Current = Current
	
	session.Turn.Number = session.Turn.Number + 1
	
	return Current
	
end

return TurnManager


--local session = {

--	Participants = {

--		playerParticipant,

--		NPCs = npcsParticipant,  --La lista sabe cuantos elementos tiene

--	},

--	Turn = {

--		Queue = {},

--		Current = nil,

--		CurrentIndex = 1,

--		Number = 1,

--		Round = 1

--	},

--	State = "Created",

--	Result = nil,

--	Initiation = initiation or {

--		Type = "Unknown"

--	},

--	Presentation = {

--		ThemeID = themeID,

--		ArenaID = arenaID,

--		AnimationSetID = animationSetID

--	},

--	Arena = nil,

--	CombatData = {}

--}
--return session
