local CombatArenaService = {}

local ServerStorage = game:GetService("ServerStorage")

local arenaTemplates = ServerStorage:WaitForChild("CombatArenas")

local activeArenas = workspace:FindFirstChild("ActiveCombatArenas")

if not activeArenas then
	activeArenas = Instance.new("Folder")
	activeArenas.Name = "ActiveCombatArenas"
	activeArenas.Parent = workspace
end

local function getPositionPart(arena, folderName, positionIndex)
	local positionsFolder = arena:FindFirstChild(folderName)

	if not positionsFolder then
		return nil
	end

	local positionPart = positionsFolder:FindFirstChild(tostring(positionIndex))

	if not positionPart or not positionPart:IsA("BasePart") then
		return nil
	end

	return positionPart
end

local function getPlacementCFrame(model, positionPart)
	local currentPivot = model:GetPivot()
	local boundingBoxCFrame, boundingBoxSize = model:GetBoundingBox()
	local bottomOffset = boundingBoxCFrame.Position.Y - currentPivot.Position.Y - boundingBoxSize.Y / 2
	local heightOffset = positionPart.Size.Y / 2 - bottomOffset

	return positionPart.CFrame * CFrame.new(0, heightOffset, 0)
end

local function facePosition(placementCFrame, targetPosition)
	local position = placementCFrame.Position
	local flatTarget = Vector3.new(targetPosition.X, position.Y, targetPosition.Z)

	return CFrame.lookAt(position, flatTarget)
end

function CombatArenaService.Deploy(session)
	local template = arenaTemplates:FindFirstChild(session.Presentation.ArenaID)

	if not template or not template:IsA("Model") then
		return false, "No existe la arena " .. tostring(session.PresentationArenaID)
	end

	local playerPosition = getPositionPart(template, "PlayerPositions", 1)
	local enemyPosition = getPositionPart(template, "EnemyPositions", 1)

	if not playerPosition or not enemyPosition then
		return false, "La arena necesita PlayerPositions/1 y EnemyPositions/1"
	end

	local player = session.Participants[1].Instance
	local npc = session.Participants.NPCs[1].Instance --A CAMBIARLO CUANDO IMPLEMETE MULTIPLES NPCS
	local character = player.Character

	if not character or not npc.Parent then
		return false, "Un participante ya no existe"
	end

	local arena = template:Clone()
	arena.Parent = activeArenas

	local playerPlacement = getPlacementCFrame(character, playerPosition)
	local enemyPlacement = getPlacementCFrame(npc, enemyPosition)

	character:PivotTo(facePosition(playerPlacement, enemyPlacement.Position))
	npc:PivotTo(facePosition(enemyPlacement, playerPlacement.Position))

	session.Arena = arena

	return true
end

function CombatArenaService.Cleanup(session)
	if not session.Arena then
		return
	end

	session.Arena:Destroy()
	session.Arena = nil
end

function CombatArenaService.GetActionPoint(session, actionId, pointId)


	--print (actionId .. " " .. pointId)
	if not session.Arena then
		return nil
	end

	local actionPoints = session.Arena:FindFirstChild("ActionPoints")

	if not actionPoints then
		return nil
	end

	local actionFolder = actionPoints:FindFirstChild(actionId)

	if not actionFolder then
		return nil
	end

	return actionFolder:FindFirstChild(pointId)

end

function CombatArenaService.MoveParticipantToActionPoint(session, participant, actionId, pointId)

	local point = CombatArenaService.GetActionPoint(session, actionId, pointId)

	if not point then
		return false
	end

	local role = participant.Type
	
	if not role then
		warn("Error al leer el tipo del participante")
		return nil
	end
	
	local position = point:FindFirstChild(role)

	if not position then
		return false
	end

	local model = participant.Instance

	if participant.Type == "Player" then
		model = participant.Instance.Character
	end

	local placement = getPlacementCFrame(model, position)

	--	print("ANTES", model:GetPivot().Position)
	--	print("DESTINO", point.Player.CFrame)
	model:PivotTo(point.Player.CFrame)

	--  print("DESPUES", model:GetPivot().Position)

	return true

end

function CombatArenaService.MoveParticipantsToActionPoint(session, attacker, defender, actionId, pointId)

	CombatArenaService.MoveParticipantToActionPoint(
		session,
		attacker,
		actionId,
		pointId
	)

	CombatArenaService.MoveParticipantToActionPoint(
		session,
		defender,
		actionId,
		pointId
	)

end


return CombatArenaService
