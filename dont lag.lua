
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExclusiveBeach8Ultra"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 130)
Frame.Position = UDim2.new(0.35, 0, 0.35, 0)
Frame.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Text = "ExclusiveBeach8 Ultra Hatch"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true
Title.Parent = Frame

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0, 180, 0, 35)
TextBox.Position = UDim2.new(0.5, -90, 0.5, -15)
TextBox.PlaceholderText = "Specify quantity (f.ex: 10)"
TextBox.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.Font = Enum.Font.SourceSansBold
TextBox.TextScaled = true
TextBox.ClearTextOnFocus = false
TextBox.Parent = Frame

local UICorner2 = Instance.new("UICorner", TextBox)
UICorner2.CornerRadius = UDim.new(0, 8)

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 180, 0, 35)
Button.Position = UDim2.new(0.5, -90, 0.5, 30)
Button.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Text = "Start"
Button.Font = Enum.Font.SourceSansBold
Button.TextScaled = true
Button.Parent = Frame

local UICorner3 = Instance.new("UICorner", Button)
UICorner3.CornerRadius = UDim.new(0, 8)

local Remotes = workspace:WaitForChild("__THINGS"):WaitForChild("__REMOTES")
local remote = Remotes:WaitForChild("exclusivebeach8")

local args = {
	{
		{false},
		{2}
	}
}

Button.MouseButton1Click:Connect(function()
	local amount = tonumber(TextBox.Text)
	if not amount or amount <= 0 then
		Button.Text = "❌ Invalid!"
		task.wait(1)
		Button.Text = "Start"
		return
	end

	Button.Text = "⏳ Running..."
	Button.BackgroundColor3 = Color3.fromRGB(180, 80, 0)

	task.spawn(function()
		for i = 1, amount do
			task.spawn(function()
				pcall(function()
					remote:InvokeServer(unpack(args))
				end)
			end)
		end
		Button.Text = "✅ Complete!"
		Button.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
		task.wait(1.5)
		Button.Text = "Start"
		Button.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	end)
end)
