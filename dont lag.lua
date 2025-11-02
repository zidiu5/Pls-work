-- Update 1

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraDualHatchGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 260)
Frame.Position = UDim2.new(0.35, 0, 0.35, 0)
Frame.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Text = "🔥 Ultra Fast Hatch GUI"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true
Title.Parent = Frame

local Remotes = workspace:WaitForChild("__THINGS"):WaitForChild("__REMOTES")

local Label1 = Instance.new("TextLabel")
Label1.Text = "ExclusiveBeach8"
Label1.Size = UDim2.new(1, 0, 0, 25)
Label1.Position = UDim2.new(0, 0, 0, 40)
Label1.BackgroundTransparency = 1
Label1.TextColor3 = Color3.fromRGB(255, 120, 120)
Label1.Font = Enum.Font.SourceSansBold
Label1.TextScaled = true
Label1.Parent = Frame

local TextBox1 = Instance.new("TextBox")
TextBox1.Size = UDim2.new(0, 180, 0, 35)
TextBox1.Position = UDim2.new(0.5, -90, 0, 70)
TextBox1.PlaceholderText = "Enter amount (e.g. 1000)"
TextBox1.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
TextBox1.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox1.Font = Enum.Font.SourceSansBold
TextBox1.TextScaled = true
TextBox1.ClearTextOnFocus = false
TextBox1.Parent = Frame
Instance.new("UICorner", TextBox1).CornerRadius = UDim.new(0, 8)

local Button1 = Instance.new("TextButton")
Button1.Size = UDim2.new(0, 180, 0, 35)
Button1.Position = UDim2.new(0.5, -90, 0, 115)
Button1.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
Button1.TextColor3 = Color3.fromRGB(255, 255, 255)
Button1.Text = "Start"
Button1.Font = Enum.Font.SourceSansBold
Button1.TextScaled = true
Button1.Parent = Frame
Instance.new("UICorner", Button1).CornerRadius = UDim.new(0, 8)

local Label2 = Instance.new("TextLabel")
Label2.Text = "Buy Diamondpack"
Label2.Size = UDim2.new(1, 0, 0, 25)
Label2.Position = UDim2.new(0, 0, 0, 165)
Label2.BackgroundTransparency = 1
Label2.TextColor3 = Color3.fromRGB(255, 120, 120)
Label2.Font = Enum.Font.SourceSansBold
Label2.TextScaled = true
Label2.Parent = Frame

local TextBox2 = Instance.new("TextBox")
TextBox2.Size = UDim2.new(0, 180, 0, 35)
TextBox2.Position = UDim2.new(0.5, -90, 0, 195)
TextBox2.PlaceholderText = "Enter amount (e.g. 100)"
TextBox2.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
TextBox2.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox2.Font = Enum.Font.SourceSansBold
TextBox2.TextScaled = true
TextBox2.ClearTextOnFocus = false
TextBox2.Parent = Frame
Instance.new("UICorner", TextBox2).CornerRadius = UDim.new(0, 8)

local Button2 = Instance.new("TextButton")
Button2.Size = UDim2.new(0, 180, 0, 35)
Button2.Position = UDim2.new(0.5, -90, 0, 240)
Button2.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
Button2.TextColor3 = Color3.fromRGB(255, 255, 255)
Button2.Text = "Start"
Button2.Font = Enum.Font.SourceSansBold
Button2.TextScaled = true
Button2.Parent = Frame
Instance.new("UICorner", Button2).CornerRadius = UDim.new(0, 8)

Button1.MouseButton1Click:Connect(function()
	local amount = tonumber(TextBox1.Text)
	if not amount or amount <= 0 then
		Button1.Text = "❌ Invalid!"
		task.wait(1)
		Button1.Text = "Start"
		return
	end

	Button1.Text = "⏳ Running..."
	Button1.BackgroundColor3 = Color3.fromRGB(180, 80, 0)

	local remote = Remotes:WaitForChild("exclusivebeach8")
	local args = {
		{
			{false},
			{2}
		}
	}

	task.spawn(function()
		for i = 1, amount do
			task.spawn(function()
				pcall(function()
					remote:InvokeServer(unpack(args))
				end)
			end)
		end
		Button1.Text = "✅ Done!"
		Button1.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
		task.wait(1.5)
		Button1.Text = "Start"
		Button1.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	end)
end)

Button2.MouseButton1Click:Connect(function()
	local amount = tonumber(TextBox2.Text)
	if not amount or amount <= 0 then
		Button2.Text = "❌ Invalid!"
		task.wait(1)
		Button2.Text = "Start"
		return
	end

	Button2.Text = "⏳ Running..."
	Button2.BackgroundColor3 = Color3.fromRGB(180, 80, 0)

	local remote = Remotes:WaitForChild("buy diamondpack")
	local args = {
		{
			{8},
			{false}
		}
	}

	task.spawn(function()
		for i = 1, amount do
			task.spawn(function()
				pcall(function()
					remote:InvokeServer(unpack(args))
				end)
			end)
		end
		Button2.Text = "✅ Done!"
		Button2.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
		task.wait(1.5)
		Button2.Text = "Start"
		Button2.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	end)
end)
