local CombatController = {}

local NPCManager = require(game.ServerScriptService.NPC.NPCManager)

local CombatSession = require(game.ServerScriptService.Combat.CombatSession)
local CombatStateMachine = require(game.ServerScriptService.Combat.CombatStateMachine)
local CombatMovement = require(game.ServerScriptService.Combat.CombatMovement)
local CombatArenaService = require(game.ServerScriptService.Combat.CombatArenaService)
local CombatThemeData = require(game.ReplicatedStorage.Modules.Combat.CombatThemeData)
local CombatStatsService = require(game.ServerScriptService.Combat.CombatStatsService)
local TurnManager = require(game.ServerScriptService.Combat.TurnManager)
local NPCSpawner = require (game.ServerScriptService.NPC.NPCSpawner)
local CombatClientEvent = game.ReplicatedStorage.RemoteEvents:WaitForChild("CombatClientEvent")
local DamageCalculator = require(game.ServerScriptService.DamageCalculator)
local TargetSelector = require(game.ServerScriptService.Combat.TargetSelector)
local CombatLog = require (game.ServerScriptService.Combat.CombatLog)
local ActionExecutor = require(game.ServerScriptService.Actions.ActionExecutor)
local CombatCamera = require(game.ServerScriptService.Combat.CombatCamera)
local EnumCombatCamera = require(game.ReplicatedStorage.Modules.Combat.EnumCombatCamera)


local DEFAULT_THEME_ID = "Default"
local DEFAULT_ARENA_ID = "DefaultArena"
local DEFAULT_ANIMATION_SET_ID = "Default"
--local TEMPORARY_ARENA_DURATION = 5

local sessionsByNPC = {}

function CombatController.EndCombat(npc, session, result, RecontactCooldown)
	if sessionsByNPC[npc] ~= session then
		return false
	end

	if session.State ~= "End" then
		CombatStateMachine.Transition(session, "End")
	end

	session.Result = result
	sessionsByNPC[npc] = nil
	NPCManager.MarkIdle(npc)
	CombatArenaService.Cleanup(session)
	local player = session.Participants[1]
	local playerInstance = player.Instance

	if playerInstance.Parent then
		CombatClientEvent:FireClient(playerInstance, "StopBattleIdle")
		CombatClientEvent:FireClient(playerInstance, "StopTheme")
	end

	--print("RecontactCooldown") 
	--print(RecontactCooldown)

	CombatMovement.UnlockPlayer(playerInstance)
	task.spawn(function()
		NPCManager.StartCooldown(npc, RecontactCooldown)
	end)

	if result == "Player wins" then
		npc:Destroy()
		CombatLog.Victory(player)
	elseif result == "Player defeated" then
			
		task.spawn(function()
			CombatMovement.UnlockNPC(npc,RecontactCooldown)
		end)
		
		CombatLog.Defeated(player)

	end 

	CombatCamera.Stop(session)

	return true
end

function CombatController.StartTurn(session, currentTurn)
	if not session then
		warn("No se encontró la sesión")
		return false
	end

	CombatLog.TurnStarted(session,currentTurn)

	local attacker = currentTurn
	local defender = TargetSelector.GetTarget(session, attacker)

	--if attacker.Type == "NPC" then
	--	defender = TargetSelector.GetNPCTarget(session,attacker)
	--elseif attacker.Type == "Player" then
	--	defender = TargetSelector.GetPlayerTarget(session)
	--else
	if not defender then
		warn("Tipo de participante inválido")
		return false
	end

	if not defender then
		warn("No se encontró el defensor")
		return false
	end

	local attackerInstance = attacker.Instance
	local defenderInstance = defender.Instance


	--local health = CombatStatsService.GetHealth(defender)

	--if type(health) ~= "number" then
	--	warn("Error al obtener la salud")
	--	return false
	--end

	ActionExecutor.Execute(attacker,defender,"BasicJump",session)

	--local damage, critical = DamageCalculator.Calculate(attacker, defender)

	--local vidaRestante = math.max(0, health - damage)

	--CombatStatsService.SetHP(defender, vidaRestante)
	
	--CombatLog.Damage(attacker,defender,damage,critical,vidaRestante)

	return true
end

function CombatController.IsCombatEnd(session)
	local player = session.Participants[1]
	
	if not CombatStatsService.IsAlive(player) then
		return true, "Player defeated"
	end
	
	for _, npc in pairs(session.Participants.NPCs) do
		if CombatStatsService.IsAlive(npc) then
			return false, nil
		end
	end
	
	return true, "Player wins"
end

function CombatController.StartCombat(player, npc, initiation)

	if not NPCManager.MarkInCombat(npc, player) then
		return nil
	end

	local theme = CombatThemeData[DEFAULT_THEME_ID]

	if not theme or typeof(theme.IntroDuration) ~= "number" or theme.IntroDuration < 0 then
		warn("El tema de combate por defecto no tiene un IntroDuration válido")
		NPCManager.MarkIdle(npc)
		return nil
	end

	local playerParticipant = {
		Type = "Player",
		Instance = player
		
	}

	local npcParticipants = {

		{
			Type = "NPC",
			Instance = npc
		}

	}	
	--El npc que toca la player siempre está
	--Logica para generar de forma pseudoAleatoria los enemigos rivales --POR ASIGNAR
	local session = CombatSession.Create(playerParticipant, npcParticipants, initiation, DEFAULT_THEME_ID, DEFAULT_ARENA_ID, DEFAULT_ANIMATION_SET_ID)
	sessionsByNPC[npc] = session

--	print(session)

	if not CombatMovement.LockPlayer(player) then
		CombatController.EndCombat(npc, session, "MovementLockFailed")
		return nil
	end

	if not CombatMovement.LockNPC(npc) then
		CombatController.EndCombat(npc, session, "MovementLockFailed")
		return nil
	end

	CombatClientEvent:FireClient(player, "LockAnimations")
	CombatClientEvent:FireClient(player, "PlayTheme", session.Presentation.ThemeID)

	local transitioned, reason = CombatStateMachine.Transition(session, "Intro")

	if not transitioned then
		CombatController.EndCombat(npc, session, "Error")
		warn(reason)
		return nil
	end


	CombatLog.CombatStarted(session)
	

	local result = nil

	task.delay(theme.IntroDuration, function()
		if sessionsByNPC[npc] ~= session then
			return
		end

		local deployed, reason = CombatStateMachine.Transition(session, "Deploying")

		if not deployed then
			warn(reason)
			CombatController.EndCombat(npc, session, "DeploymentFailed")
			return
		end

		local arenaDeployed, arenaReason = CombatArenaService.Deploy(session) --SE CREA UNA REFERENCIA A LA ARENA CREADA EN session.Arena DENTRO DE ESTA FUNCION 

		if not arenaDeployed then
			warn(arenaReason)
			CombatController.EndCombat(npc, session, "DeploymentFailed")
			return
		end
		
		CombatCamera.Start(session,EnumCombatCamera.Default)

		
		print("Estado: " .. session.State)
		CombatClientEvent:FireClient(player, "PlayBattleIdle", session.Presentation.AnimationSetID)

		--task.delay(TEMPORARY_ARENA_DURATION, function()
		--		CombatController.EndCombat(npc, session, "ArenaTestComplete",npc:GetAttribute("RecontactCooldown"))
		--end)
		
		TurnManager.BuildQueue(session)
		local currentTurn = TurnManager.StartCombat(session)
		
		while true do 
			if not currentTurn then
				warn("Error al obtener turno actual")
				return nil
			end
			
			if not CombatController.StartTurn(session,currentTurn) then
				result = "Error en el Turno de " .. currentTurn.Instance.Name
				break
			end

			local combatEnded
			combatEnded , result = CombatController.IsCombatEnd(session)

			if combatEnded then
				break
			end
			
			currentTurn = TurnManager.GetNextTurn(session)
		end
		
		CombatController.EndCombat(npc, session, result,npc:GetAttribute("RecontactCooldown"))
		
		CombatLog.CombatEnded(session)

	end)
	session.Result=result
	
	return session
end

return CombatController
