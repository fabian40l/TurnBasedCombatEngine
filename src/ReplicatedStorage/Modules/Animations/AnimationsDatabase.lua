local AnimationDatabase = {

	JumpBasic = {

		FirstJump = "rbxassetid://100513683890320",

		SecondJump = "rbxassetid://74643254996446",

		Finish = "rbxassetid://124973322553939",

		FailFirstJump = "rbxassetid://77157703470985",

		FailSecondJump = "rbxassetid://107027802765373",

	}

}

function AnimationDatabase.get(id)
	return AnimationDatabase[id]
end

return AnimationDatabase