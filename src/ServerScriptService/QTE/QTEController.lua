local QTEController = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StartQTE = ReplicatedStorage.RemoteEvents.StartQTE
local SubmitQTE = ReplicatedStorage.RemoteEvents.SubmitQTE

local QTEDatabase = require(game.ReplicatedStorage.Modules.QTE.QTEDatabase)
local QTEResult = require(game.ReplicatedStorage.Modules.QTE.QTEResult)
local CombatArenaService = require(game.ServerScriptService.Combat.CombatArenaService)

local waitingInputs = {}

SubmitQTE.OnServerEvent:Connect(function(player, segmentId)

	local waiting = waitingInputs[player]

	if not waiting then
		return
	end

	if waiting.SegmentId ~= segmentId then
		return
	end

	waiting.Result = true
	waiting.Event:Fire()

end)

local function WaitForInput(player, segment, timeout)

	local bindable = Instance.new("BindableEvent")

	waitingInputs[player] = {

		SegmentId = segment.Id,
		Event = bindable,
		Result = false

	}

	local finished = false

	task.delay(timeout, function()

		if finished then
			return
		end

		finished = true
		bindable:Fire()

	end)

	bindable.Event:Wait()

	local result = waitingInputs[player]

	waitingInputs[player] = nil
	bindable:Destroy()

	if not result then
		return false
	end

	return result.Result

end

local function LoadAnimation(humanoid, animationId)

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId

	return humanoid.Animator:LoadAnimation(animation)

end

function QTEController.Play(actor, qteId, session, actionId)

	local qte = QTEDatabase.Get(qteId)

	if not qte then
		warn("No se encontró el QTE " .. qteId)
		return QTEResult.Miss
	end

	local player=nil

	if actor.Type == "Player" then
		player = actor.Instance
	end
	
	local character
	
	if player then 
		character = player.Character 
	elseif actor.Type == "NPC" then
		character = actor.Instance	
	else 
		warn("El actor no tiene un tipo valido")
		return nil
	end
	
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		warn("No se encontró el Humanoid")
		return QTEResult.Miss
	end


	local success
	local failedPointID = qte.Segments[#qte.Segments].NextCombatPoint
	local failTrack=nil

	for _, segment in ipairs(qte.Segments) do

		local track = LoadAnimation(humanoid, segment.Animation)

		track:Play()


		track.Stopped:Connect(function()
			CombatArenaService.MoveParticipantToActionPoint(
				session,
				actor,
				actionId,
				segment.NextCombatPoint)
		end)


		if segment.Input then

			track:GetMarkerReachedSignal(segment.Input.StartMarker):Wait()

			StartQTE:FireClient(player, segment)

			success = WaitForInput(player, segment,0.35)


			if not success then


				if segment.FailAnimation then

					local failTrack = LoadAnimation(
						humanoid,
						segment.FailAnimation
					)

					failTrack:Play()

					failTrack.Stopped:Connect(function()
						CombatArenaService.MoveParticipantToActionPoint(
							session,
							actor,
							actionId,
							segment.FailPoint
						)
					end)

					failTrack.Stopped:Wait()


					return QTEResult.Miss


				end


				return QTEResult.Miss

			end

		end



		track.Stopped:Wait()



	end
	return QTEResult.Perfect

end

return QTEController