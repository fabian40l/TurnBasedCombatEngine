local CombatStatsService = {}

local CombatLog = require(game.ServerScriptService.Combat.CombatLog)

local TempStats = {
	
	MaxHealth = 10,
	
	Health = 10,
	
	Attack = 4,

	Defense = 2,

	Speed = 8,

	Experience = 15,
	
	Luck = 2,
	
	

} --Dejará de usarse una vez implemente el manejo real de estadisticas de jugador

function CombatStatsService.IsAlive(participant)
	return CombatStatsService.GetHealth(participant) > 0
end

function CombatStatsService.CanAct(participant)
	return CombatStatsService.IsAlive(participant)  --Por ahora ase esto pero cuando agregue efectos de estado tendra mas sentido :)
end

function CombatStatsService.GetMaxHP(participant)
	if participant.Type == "Player" then
		return TempStats.MaxHealth
	elseif participant.Type == "NPC" then	
		local npc = participant.Instance
		if not npc then
			return nil
		end
		return npc:GetAttribute("MaxHealth")
	end
end

function CombatStatsService.GetHealth(participant)
	if participant.Type == "Player" then
		return TempStats.Health
	elseif participant.Type == "NPC" then	
		local npc = participant.Instance
		if not npc then
			return nil
		end

		return npc:GetAttribute("Health")
	end
end


function CombatStatsService.GetAttack(participant)
	if participant.Type == "Player" then
		return TempStats.Attack
	elseif participant.Type == "NPC" then	
		local npc = participant.Instance
		if not npc then
			return nil
		end

		return npc:GetAttribute("Attack")
	end

end

function CombatStatsService.GetDefense(participant)
	if participant.Type == "Player" then
		return TempStats.Defense
	elseif participant.Type == "NPC" then	
		local npc = participant.Instance
		if not npc then
			return nil
		end
		
		return npc:GetAttribute("Defense")
	end
end

function CombatStatsService.GetSpeed(participant)
	if participant.Type == "Player" then
		return TempStats.Speed
	elseif participant.Type == "NPC" then	
		local npc = participant.Instance
		if not npc then
			return nil
		end

		return npc:GetAttribute("Speed")
	end
end


function CombatStatsService.GetLuck(participant)
	if participant.Type == "Player" then
		return TempStats.Luck
	elseif participant.Type == "NPC" then	
		local npc = participant.Instance
		if not npc then
			return nil
		end
		
		return npc:GetAttribute("Luck")
	end	
end

function CombatStatsService.SetHP(participant,hp) --se supone que hp se envia como parametro ya calculado con el futuro "DamageCalculator"
	if participant.Type == "Player" then
		TempStats.Health=hp
	end
	if participant.Type == "NPC" then
		local npc = participant.Instance
		if not npc then
			return nil
		end

		npc:SetAttribute("Health",hp)
	end
end

function CombatStatsService.ApplyDamage(target,damage)
	local hp = CombatStatsService.GetHealth(target)

	local vidaRestante = math.max(0, hp - damage)

	CombatStatsService.SetHP(target,vidaRestante)
	
	return vidaRestante
end


return CombatStatsService
