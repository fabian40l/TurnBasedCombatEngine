local CombatMovement = {}

local lockedCharacters = {}

local function stopAnimations(humanoid)
	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return
	end

	for _, track in animator:GetPlayingAnimationTracks() do
		track:Stop(0)
	end
end


local function lockCharacter(subject, character)

	if lockedCharacters[subject] then
		return false
	end

	if not character then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local animateScript = character:FindFirstChild("Animate")


	if animateScript 
		and not (animateScript:IsA("LocalScript") or animateScript:IsA("Script")) then

		animateScript = nil
	end


	if not humanoid or not rootPart then
		return false
	end


	local state = {

		Character = character,

		Humanoid = humanoid,

		RootPart = rootPart,

		OriginalPivot = character:GetPivot(),

		WalkSpeed = humanoid.WalkSpeed,

		UseJumpPower = humanoid.UseJumpPower,

		JumpPower = humanoid.JumpPower,

		JumpHeight = humanoid.JumpHeight,

		AutoRotate = humanoid.AutoRotate,

		RootAnchored = rootPart.Anchored,

		AnimateScript = animateScript,

		AnimateWasDisabled = animateScript and animateScript.Disabled,

		DestroyConnection = nil
	}


	lockedCharacters[subject] = state


	if animateScript then
		animateScript.Disabled = true
	end


	stopAnimations(humanoid)


	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	humanoid.AutoRotate = false


	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero
	rootPart.Anchored = true


	state.DestroyConnection = character.Destroying:Connect(function()

		local currentState = lockedCharacters[subject]

		if currentState then

			if currentState.DestroyConnection then
				currentState.DestroyConnection:Disconnect()
			end

			lockedCharacters[subject] = nil
		end

	end)


	return true
end



local function unlockCharacter(subject,RecontactCooldown)

	local state = lockedCharacters[subject]

	if not state then
		return false
	end


	local humanoid = state.Humanoid
	local rootPart = state.RootPart

	if state.Character.Parent then
		state.Character:PivotTo(state.OriginalPivot)
	end


	if RecontactCooldown then
		task.delay(RecontactCooldown,function()
			
			if humanoid and humanoid.Parent then

				humanoid.WalkSpeed = state.WalkSpeed

				humanoid.UseJumpPower = state.UseJumpPower

				humanoid.JumpPower = state.JumpPower

				humanoid.JumpHeight = state.JumpHeight

				humanoid.AutoRotate = state.AutoRotate
			end
			
		end)
	else

		if humanoid and humanoid.Parent then

			humanoid.WalkSpeed = state.WalkSpeed

			humanoid.UseJumpPower = state.UseJumpPower

			humanoid.JumpPower = state.JumpPower

			humanoid.JumpHeight = state.JumpHeight

			humanoid.AutoRotate = state.AutoRotate
		end

	end

		if rootPart and rootPart.Parent then
			rootPart.Anchored = state.RootAnchored
		end


		if state.AnimateScript and state.AnimateScript.Parent then

			state.AnimateScript.Disabled = state.AnimateWasDisabled
		end

	if state.DestroyConnection then
		state.DestroyConnection:Disconnect()
	end


	lockedCharacters[subject] = nil


	return true
end



function CombatMovement.LockPlayer(player)

	return lockCharacter(player, player.Character)

end



function CombatMovement.LockNPC(npc)

	return lockCharacter(npc, npc)

end



function CombatMovement.UnlockPlayer(player)

	return unlockCharacter(player)

end



function CombatMovement.UnlockNPC(npc,RecontactCooldown)

	return unlockCharacter(npc,RecontactCooldown)

end



return CombatMovement