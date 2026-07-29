local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CameraEvent = ReplicatedStorage.RemoteEvents.CombatCameraEvent

local camera = workspace.CurrentCamera

CameraEvent.OnClientEvent:Connect(function(action, cameraID, ArenaID)

	if action == "Start" then
		print("[CameraClient] Iniciando Camara")
		print("ArenaID: "..ArenaID)
	
		local Arena = workspace.ActiveCombatArenas:WaitForChild(ArenaID)
	
		
		print("cameraID: ".. cameraID)
		local cameraPart = Arena.Camera:WaitForChild(cameraID)
		
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = cameraPart.CFrame

	elseif action == "Stop" then

		camera.CameraType = Enum.CameraType.Custom

	end

end)