local CombatStateMachine = {}

local validTransitions = {
	Created = {
		Intro = true,
		End = true,
	},
	Intro = {
		Deploying = true,
		End = true,
	},
	Deploying = {
		PlayerTurn = true,
		End = true,
	},
	PlayerTurn = {
		EnemyTurn = true,
		End = true,
	},
	EnemyTurn = {
		PlayerTurn = true,
		End = true,
	},
	End = {},
}

function CombatStateMachine.Transition(session, nextState)
	if type(session) ~= "table" then
		return false, "Sesión inválida"
	end

	local possibleTransitions = validTransitions[session.State]

	if not possibleTransitions or not possibleTransitions[nextState] then
		return false, "Transición inválida: " .. tostring(session.State) .. " -> " .. tostring(nextState)
	end

	session.State = nextState

	return true
end

function CombatStateMachine.IsState(session, state)
	return type(session) == "table" and session.State == state
end

return CombatStateMachine
