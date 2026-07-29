local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = game:GetService("Players").LocalPlayer
local combatClientEvent = ReplicatedStorage.RemoteEvents:WaitForChild("CombatClientEvent")
local CombatThemeData = require(ReplicatedStorage.Modules.Combat.CombatThemeData)
local CombatAnimationData = require(ReplicatedStorage.Modules.Combat.CombatAnimationData)

local combatMusic = nil
local battleIdleTrack = nil
local battleIdleAnimation = nil

local function stopAnimations(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return
	end

	for _, track in animator:GetPlayingAnimationTracks() do
		track:Stop(0)
	end
end

local function stopCombatAnimations()
	local character = player.Character

	if not character then
		return
	end

	stopAnimations(character)
	task.defer(stopAnimations, character)
end

local function stopTheme()
	if not combatMusic then
		return
	end

	combatMusic:Stop()
	combatMusic:Destroy()
	combatMusic = nil
end

local function playTheme(themeID)
	stopTheme()

	local theme = CombatThemeData[themeID]

	if not theme or theme.SoundId == "" then
		return
	end

	combatMusic = Instance.new("Sound")
	combatMusic.Name = "CombatMusic"
	combatMusic.SoundId = theme.SoundId
	combatMusic.Looped = true
	combatMusic.Parent = SoundService
	combatMusic:Play()
end

local function stopBattleIdle()
	if battleIdleTrack then
		battleIdleTrack:Stop(0)
		battleIdleTrack = nil
	end

	if battleIdleAnimation then
		battleIdleAnimation:Destroy()
		battleIdleAnimation = nil
	end
end

local function playBattleIdle(animationSetID)
	stopBattleIdle()

	local animationSet = CombatAnimationData[animationSetID]
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animationSet or animationSet.BattleIdle == "" or not animator then
		return
	end

	battleIdleAnimation = Instance.new("Animation")
	battleIdleAnimation.AnimationId = animationSet.BattleIdle
	battleIdleTrack = animator:LoadAnimation(battleIdleAnimation)
	battleIdleTrack.Looped = true
	battleIdleTrack.Priority = Enum.AnimationPriority.Idle
	battleIdleTrack:Play(0)
end

combatClientEvent.OnClientEvent:Connect(function(action)
	if action == "LockAnimations" then
		stopCombatAnimations()
	elseif action == "PlayTheme" then
		playTheme("Default")
	elseif action == "StopTheme" then
		stopTheme()
	elseif action == "PlayBattleIdle" then
		playBattleIdle("Default")
	elseif action == "StopBattleIdle" then
		stopBattleIdle()
	end
end)
