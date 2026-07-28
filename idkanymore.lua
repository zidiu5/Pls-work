local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local existingGui = playerGui:FindFirstChild("ModernMenuGui")
if existingGui then
	existingGui:Destroy()
end

local existingBlur = Lighting:FindFirstChild("UIBlur")
if existingBlur then
	existingBlur:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local blur = Instance.new("BlurEffect")
blur.Name = "UIBlur"
blur.Size = 0
blur.Parent = Lighting

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)

local targetPosition = UDim2.new(0.5, 0, 0.5, -40)
local startPosition = UDim2.new(0.5, 0, 1.5, 0)

mainFrame.Position = startPosition
mainFrame.Size = UDim2.new(0, 360, 0, 240)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 255, 255)
mainStroke.Transparency = 1
mainStroke.Thickness = 1.5
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "SELECT AN OPTION"
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
titleLabel.TextSize = 18
titleLabel.Parent = mainFrame

local function createButton(btnText, position, gradientColors)
	local button = Instance.new("TextButton")
	button.Name = btnText
	button.AnchorPoint = Vector2.new(0.5, 0)
	button.Position = position
	button.Size = UDim2.new(0.85, 0, 0, 50)
	button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	button.AutoButtonColor = false
	button.Text = ""
	button.ClipsDescendants = true
	button.Parent = mainFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 12)
	btnCorner.Parent = button

	local btnGradient = Instance.new("UIGradient")
	btnGradient.Color = gradientColors
	btnGradient.Rotation = 45
	btnGradient.Parent = button

	local btnStroke = Instance.new("UIStroke")
	btnStroke.Color = Color3.fromRGB(255, 255, 255)
	btnStroke.Transparency = 0.8
	btnStroke.Thickness = 1
	btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	btnStroke.Parent = button

	local label = Instance.new("TextLabel")
	label.Name = "ButtonLabel"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = btnText
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 16
	label.ZIndex = 2
	label.Parent = button

	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	button.MouseEnter:Connect(function()
		TweenService:Create(button, tweenInfo, {
			Size = UDim2.new(0.88, 0, 0, 52),
			Position = position + UDim2.new(0, 0, 0, -1)
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, tweenInfo, {
			Size = UDim2.new(0.85, 0, 0, 50),
			Position = position
		}):Play()
	end)

	return button
end

local blueGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 130, 246)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 51, 234))
})

local purpleGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(236, 72, 153)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 92, 246))
})

local button1 = createButton("Rayfield", UDim2.new(0.5, 0, 0, 70), blueGradient)
local button2 = createButton("ZidX", UDim2.new(0.5, 0, 0, 135), purpleGradient)

task.delay(1, function()
	local introInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	
	TweenService:Create(blur, introInfo, {Size = 16}):Play()
	TweenService:Create(mainFrame, introInfo, {
		Position = targetPosition,
		BackgroundTransparency = 0.1
	}):Play()
	TweenService:Create(mainStroke, introInfo, {
		Transparency = 0.88
	}):Play()
end)

local function destroyUI()
	local fadeInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	
	TweenService:Create(blur, fadeInfo, {Size = 0}):Play()
	
	local tween = TweenService:Create(mainFrame, fadeInfo, {
		Position = startPosition,
		BackgroundTransparency = 1
	})
	
	tween:Play()
	tween.Completed:Connect(function()
		blur:Destroy()
		screenGui:Destroy()
	end)
end

button1.MouseButton1Click:Connect(function()
	destroyUI()
	task.spawn(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/zidiu5/Pls-work/refs/heads/main/idkanymore_Ray.lua"))()
	end)
end)

button2.MouseButton1Click:Connect(function()
	destroyUI()
	task.spawn(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/zidiu5/Pls-work/refs/heads/main/idkanymore_ZidX.lua"))()
	end)
end)
