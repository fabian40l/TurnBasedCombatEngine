local ActionExecutor = {}

local ActionDatabase = require(game.ReplicatedStorage.Modules.Actions.ActionDatabase)
local DamageCalculator = require(game.ServerScriptService.DamageCalculator)
local CombatLog = require(game.ServerScriptService.Combat.CombatLog)
local CombatStatsService = require(game.ServerScriptService.Combat.CombatStatsService)
local QTEController = require(game.ServerScriptService.QTE.QTEController)
local QTEResult = require(game.ReplicatedStorage.Modules.QTE.QTEResult)

function ActionExecutor.Execute(attacker,target,actionID, session)
	local action = ActionDatabase.Get(actionID)
	
	if not action then
		warn("Error al leer la accion a ejecutar")
		return nil
	end	
	

	local qteResult = QTEResult.Perfect --por agregar

	
	if attacker.Type=="Player" then
		local qteId = action.QTE

		qteResult = QTEController.Play(attacker, qteId, session, actionID)	--Solo esta implementado animaciones del player
	end

	local damage, isCritical, result = DamageCalculator.Calculate(attacker,target,action,qteResult)

	if not damage then
		warn("Error al calcular el daño")
		return nil
	end
	
	local hp
	
	if result == "Missed" then
		
		CombatLog.AttackMissed(attacker,target,action)
		
		return true
		
	elseif result == "NoDamage" then
		
		CombatLog.Damage(attacker,target,0)
		
		return true
		
	elseif result == "RecoilDamage" then
		
		CombatStatsService.ApplyDamage(attacker,1)
		
		CombatLog.RecoilDamage(attacker,target,action)
		
		return true
		
	end
	
	local vidaRestante = CombatStatsService.ApplyDamage(target,damage)
	
	CombatLog.Damage(attacker,target,damage,isCritical, vidaRestante)

	return QTEResult.Perfect
end

return ActionExecutor
