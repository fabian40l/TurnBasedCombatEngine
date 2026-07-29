local DamageCalculator = {}

local CombatStatsService = require(game.ServerScriptService.Combat.CombatStatsService)
local NPCData = require(game.ReplicatedStorage.Modules.NPC.NPCData)
local QTEResult = require(game.ReplicatedStorage.Modules.QTE.QTEResult)

local K = 40
local n = 2
local CRIT_ATTACK_MULTIPLIER = 1.30
local CRIT_DEFENSE_IGNORED = 0.20

local MIN_CRIT = 5
local MAX_CRIT = 75

local DMG_PERFECT_MULTIPLIER = 1.15

--Enemy type: Armored, Flying, Normal, Untouchable
--Attack type: Basic, Tool, Ranged, Ultimate
local function CalculateTypeEffectiveness(EnemyType,action)
	local AttackType=action.AttackType
	
	if not AttackType then
		warn("El ataque no tiene tipo")
		return nil
	end
	
	if AttackType=="Basic" then
		if EnemyType=="Armored" then
			return 0.4
			
		elseif EnemyType=="Flying" then
			
			local CanAttackFlying=action.CanAttackFlying
			if not CanAttackFlying then
				warn("Faltó agregar el atributo CanAttackFlying a esta accion Normal")
				return nil
			end
			
			if CanAttackFlying then
				return 1
			else
				return 0, "Missed"
			end
			
		elseif EnemyType=="Untouchable" then
			
			return 0, "RecoilDamage"
			
		elseif EnemyType== "Normal" then
			
			return 1
			
		else 
		
			return nil
			
		end
		
	elseif AttackType=="Tool" then
		if EnemyType=="Armored" then
			
			return 1
			
		elseif EnemyType=="Flying" then 
			
			return 0, "Missed"
			
		elseif EnemyType=="Untouchable" then	
			
			return 1.4
				
		elseif EnemyType == "Normal" then
			
			return 1		
			
		else 
			
			return nil
			
		end
			
	elseif AttackType=="Ranged" then
		if EnemyType=="Armored" then
		
			return 0, "NoDamage"

		elseif EnemyType=="Flying" then 
			
			return 1.4 

		elseif EnemyType=="Untouchable" then	
			
			return 1

		elseif EnemyType == "Normal" then
			
			return 1		
		else 
			
			return nil
			
		end

	else
		warn("El ataque no tiene tipo valido")
		return nil
	end
end

function DamageCalculator.GetCritChance(luck)
	return MIN_CRIT +
		(MAX_CRIT - MIN_CRIT) * math.pow(luck, n) /	(math.pow(luck, n) + math.pow(K, n))
end
function DamageCalculator.Calculate(attacker, defender, action, qteResult)

	local variacion = math.random(85,115) / 100

	local attack = CombatStatsService.GetAttack(attacker) or 0
 
	local defense = CombatStatsService.GetDefense(defender) or 0 

	local luck = CombatStatsService.GetLuck(attacker) or 0

	local effectiveAttack = attack
	
	local effectiveDefense = defense
	
	if attacker.Type == "Player"then
		local typeEnemyID = defender.Instance:GetAttribute("TypeEnemyID")
		
		if not typeEnemyID or typeEnemyID<0 then
			warn("El npc no tiene un tipo de enemigo valido")
			return nil
		end
				
		local EnemyType = defender.Instance:GetAttribute("Type")
		
		if not EnemyType then
			warn("Atributo Type no se cargo correctamente")
			return nil
		end
		
		if not EnemyType then
			warn("El npc presenta un valor inválido en el atributo Type")
		end
		
		local typeEffectiveness, typeAttackCondition = CalculateTypeEffectiveness(EnemyType,action)
		
		if not typeEffectiveness then
			return nil
		end
		
		if typeAttackCondition then
			if typeAttackCondition == "Missed" then
				
				return 0,0,typeAttackCondition
				
			elseif typeAttackCondition == "NoDamage" then
				
				return 0,0,typeAttackCondition
			
			elseif typeAttackCondition == "RecoilDamage" then
					
				return 0,0,typeAttackCondition	
			
			else
				
				warn("Condicion de ataque no definido")
				return nil
				
			end
		end
		
		effectiveAttack *= typeEffectiveness
	end
	
	local isCritical = math.random(1,100) <= DamageCalculator.GetCritChance(luck)
	if isCritical then
		effectiveAttack *= CRIT_ATTACK_MULTIPLIER
		effectiveDefense *= CRIT_DEFENSE_IGNORED
		--El critico solo multiplica su ataque en 1.30 pero hace que ignore la defensa en un 80%
	end
	
	local damage = math.max(1, effectiveAttack - effectiveDefense)
	damage = math.max(1,math.floor(damage * variacion))

	if qteResult == QTEResult.Perfect then 
		damage=math.floor(damage*DMG_PERFECT_MULTIPLIER)
	end

	return damage, isCritical, "Succeed"

end


return DamageCalculator