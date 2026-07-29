local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local StartQTE = ReplicatedStorage.RemoteEvents.StartQTE
local SubmitQTE = ReplicatedStorage.RemoteEvents.SubmitQTE

local listening = false
local expectedKey
local currentSegment

StartQTE.OnClientEvent:Connect(function(segment)
	listening = true
	currentSegment=segment
	
	expectedKey = segment.Input.Key
	
	print("QTE iniciado")
	
end)



UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if not listening then
		return
	end

	if not currentSegment then
		return
	end
	
	if not currentSegment.Input then
		return
	end


	if input.KeyCode == expectedKey then
		listening = false

		print("CLIENTE -> Enviando", currentSegment.Id)

		SubmitQTE:FireServer(currentSegment.Id)
		
		currentSegment = nil
		expectedKey = nil
	end	
	
end)
