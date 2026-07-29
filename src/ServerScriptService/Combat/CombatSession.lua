local CombatSession = {}

function CombatSession.Create(playerParticipant, npcsParticipant,initiation, themeID, arenaID, animationSetID)

	local session = {

		Participants = {

			playerParticipant,
			
			NPCs = npcsParticipant,  --La lista sabe cuantos elementos tiene

		},

		Turn = {

			Queue = {},

			Current = nil,

			CurrentIndex = 1,

			Number = 1,

			Round = 1

		},
		
		State = "Created",

		Result = nil,

		Initiation = initiation or {

			Type = "Unknown"

		},

		Presentation = {

			ThemeID = themeID,

			ArenaID = arenaID,

			AnimationSetID = animationSetID

		},

		Arena = nil,

		CombatData = {}

	}
	return session

end

return CombatSession
