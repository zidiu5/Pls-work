local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DraggableToggleGUI"
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.5, -100, 0.5, -50)
Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Parent = ScreenGui
Frame.Active = true

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -20, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0, 25)
ToggleButton.Text = "Hatch Points"
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Parent = Frame

local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

Frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input == dragInput) then update(input) end
end)

local scriptEnabled = false

ToggleButton.MouseButton1Click:Connect(function()
	scriptEnabled = not scriptEnabled
	if scriptEnabled then
		ToggleButton.Text = "Hatching ON"
		task.spawn(function()
			while scriptEnabled do
				local args = {{{false},{2}}}
				workspace:WaitForChild("__THINGS"):WaitForChild("__REMOTES"):WaitForChild("halloweengiftbox3"):InvokeServer(unpack(args))
				task.wait(0.3)
			end
		end)
	else
		ToggleButton.Text = "Hatching OFF"
	end
end)

task.spawn(function()
	while true do
		task.wait(10)
		local randomAngle = math.random(-180, 180)
		TweenService:Create(Frame, TweenInfo.new(1, Enum.EasingStyle.Quad), {Rotation = randomAngle}):Play()
	end
end)

task.spawn(function()
	while true do
		task.wait(5)
		if math.random(1, 100) <= 10 then
			local ghostGui = Instance.new("Frame")
			ghostGui.Size = UDim2.new(0, 150, 0, 75)
			ghostGui.Position = UDim2.new(math.random(), -75, math.random(), -37)
			ghostGui.AnchorPoint = Vector2.new(0.5, 0.5)
			ghostGui.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			ghostGui.BackgroundTransparency = 0.3
			ghostGui.Parent = ScreenGui

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 25)
			corner.Parent = ghostGui

			task.spawn(function()
				local startTime = tick()
				while tick() - startTime < 5 do
					local t = tick()

					local r = math.sin(t * 2) * 0.5 + 0.5
					local g = math.sin(t * 2 + 2) * 0.5 + 0.5
					local b = math.sin(t * 2 + 4) * 0.5 + 0.5
					ghostGui.BackgroundColor3 = Color3.fromRGB(r * 255, g * 255, b * 255)

					ghostGui.Rotation = (tick() * 1080) % 360

					-- neues starkes „Pochen“: bis 4x größer
					local pulse = 1 + math.sin(t * 6) * 1.5  -- Wertebereich: 1 - 2.5
					local scale = math.clamp(pulse, 0.5, 4)
					ghostGui.Size = UDim2.new(0, 150 * scale, 0, 75 * scale)

					RunService.RenderStepped:Wait()
				end
				ghostGui:Destroy()
			end)
		end
	end
end)
