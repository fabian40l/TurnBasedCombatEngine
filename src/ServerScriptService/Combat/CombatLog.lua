local CombatLog = {}

local function GetName(participant)
	return participant.Instance.Name
end





function CombatLog.CombatStarted(session)
	
	
	print("[COMBAT START] Combate iniciado")
	
	print("[COMBAT START] Jugador: " .. GetName(session.Participants[1]))
	
	print("[COMBAT START] Enemigos{")
	for _, npc in pairs(session.Participants.NPCs) do
		print("NPC: " .. GetName(npc))
	end
	print("}")
	print("[COMBAT START] Inicio: " .. session.Initiation.Type)
	print("[COMBAT START] Estado: " .. session.State)
end

function CombatLog.TurnStarted(session, currentTurn)
	print("[TURN] Ronda: " .. session.Turn.Round .. " | Turno: " .. session.Turn.Number .. " | Turno iniciado para "..GetName(currentTurn))
end

function CombatLog.Damage(attacker, defender, damage, critical, vidaRestante)
	local attackerInstance = attacker.Instance
	local defenderInstance = defender.Instance
	
	print("[ATTACK] " .. attackerInstance.Name .. " atacó a " .. defenderInstance.Name)
	if critical then
		print("[ATTACK] ¡CRÍTICO!")
	end

	print("[ATTACK] Daño: " .. damage )
	print("[ATTACK] Vida Restante: ".. vidaRestante)

end

function CombatLog.AttackMissed(attacker,target, action)
	print("[ATTACK MISSED] El ataque ".. action.Name .. " de tipo ".. action.Type .. " falló")
	
	if target.Type=="NPC" then
		local targetEnemyType = target.Instance:GetAttribute("Type")
		print("[ATTACK MISSED] " .. GetName(attacker).. " falló el ataque a " .. GetName(target) .. " de tipo " .. targetEnemyType)
	end
end

function CombatLog.RecoilDamage(attacker, target, action)
	CombatLog.AttackMissed(attacker,target,action)
	print("[RECOIL DAMAGE] El jugador recibió daño de regreso")
end

function CombatLog.Defeated(participant)
	print("[COMBAT LOST] Resultado del combate: ".. GetName(participant) .. " fue derrotado" )

end

function CombatLog.Victory(participant)
	print("[COMBAT WON] Resultado del combate: ".. GetName(participant) .. " ganó la batalla" )
	
end

function CombatLog.CombatEnded(session)
	print("[COMBAT END] Combate terminado")
	print("[COMBAT END] Numero de Rondas: " .. session.Turn.Round)
end

return CombatLog