local AnimationDatabase = require(game.ReplicatedStorage.Modules.Animations.AnimationsDatabase)

local QTEDatabase = {

	JumpBasic = {

		Id = "JumpBasic",

		Name = "Salto Básico",

		Segments = {

			{
				Id = "FirstJump",

				Animation = AnimationDatabase.JumpBasic.FirstJump,

				FailAnimation = AnimationDatabase.JumpBasic.FailFirstJump,

				Input = {

					Key = Enum.KeyCode.Z,

					StartMarker = "QTE_Start",

					PerfectMarker = "QTE_Perfect",

					EndMarker = "QTE_End",

				},

				NextCombatPoint= "SecondJump",
				FailPoint= "FirstJump"
				
				

			},

			{
				Id = "SecondJump",

				Animation = AnimationDatabase.JumpBasic.SecondJump,

				FailAnimation = AnimationDatabase.JumpBasic.FailSecondJump,

				Input = {

					Key = Enum.KeyCode.Z,

					StartMarker = "QTE_Start",

					PerfectMarker = "QTE_Perfect",

					EndMarker = "QTE_End",

				},

				NextCombatPoint = "Finish",
				FailPoint= "FirstJump"

			},

			{
				Id = "Finish",

				Animation = AnimationDatabase.JumpBasic.Finish,

				FailAnimation = nil,

				Input = nil, -- Último segmento, no requiere otro QTE.
				
				NextCombatPoint= "FirstJump",
				FailPoint= nil


			}

		}

	}

}

function QTEDatabase.Get(id)
	return QTEDatabase[id]
end

return QTEDatabase