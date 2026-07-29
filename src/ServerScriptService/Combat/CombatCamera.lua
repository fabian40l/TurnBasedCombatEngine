local CombatCamera = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CameraEvent = ReplicatedStorage.RemoteEvents.CombatCameraEvent
local EnumCombatCamera = require(ReplicatedStorage.Modules.Combat.EnumCombatCamera)
function CombatCamera.Start(session,cameraID)

	local player = session.Participants[1].Instance

	if not session.Arena then
		warn("No hay Arena")
		return
	end
		
	local cameraPart = session.Arena.Camera:WaitForChild(cameraID)

	if not cameraPart then
		warn("La arena no tiene una parte llamada Camera")
		return
	end
	
	if not cameraPart then
		warn("No se encontró la cámara con el ID: " .. cameraID)
		return
	end
	
	print(cameraPart.CFrame)
	CameraEvent:FireClient(player, "Start", cameraID,session.Arena.Name)

end

function CombatCamera.Stop(session)

	local player = session.Participants[1].Instance

	CameraEvent:FireClient(player, "Stop")

end

return CombatCamera