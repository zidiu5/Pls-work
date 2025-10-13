local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Helper
local function tween(inst, props, time, style, dir)
	style = style or Enum.EasingStyle.Quint
	dir = dir or Enum.EasingDirection.Out
	return TweenService:Create(inst, TweenInfo.new(time or 0.35, style, dir), props)
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChatGPTStyleGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- Open Button
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0,40,0,40)
OpenButton.Position = UDim2.new(1,-70,1,-70)
OpenButton.BackgroundColor3 = Color3.fromRGB(40,0,0)
OpenButton.BorderSizePixel = 0
OpenButton.Text = "☰"
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 22
OpenButton.TextColor3 = Color3.new(1,1,1)
OpenButton.AutoButtonColor = false
local obCorner = Instance.new("UICorner", OpenButton)
obCorner.CornerRadius = UDim.new(1,0)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0,640,0,420)
MainFrame.Position = UDim2.new(0.5,-320,1,50)
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
local mainCorner = Instance.new("UICorner", MainFrame)
mainCorner.CornerRadius = UDim.new(0,12)

-- Sidebar + Content
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0,180,1,0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15,15,15)
Sidebar.BorderSizePixel = 0
local sbCorner = Instance.new("UICorner", Sidebar)
sbCorner.CornerRadius = UDim.new(0,10)

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1,-180,1,0)
Content.Position = UDim2.new(0,180,0,0)
Content.BackgroundColor3 = Color3.fromRGB(10,10,10)
local ctCorner = Instance.new("UICorner", Content)
ctCorner.CornerRadius = UDim.new(0,10)

-- Sidebar Scroll
local SidebarScroll = Instance.new("ScrollingFrame", Sidebar)
SidebarScroll.Size = UDim2.new(1,0,1,0)
SidebarScroll.BackgroundTransparency = 1
SidebarScroll.ScrollBarThickness = 8
SidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SidebarScroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
local SBList = Instance.new("UIListLayout", SidebarScroll)
SBList.SortOrder = Enum.SortOrder.LayoutOrder
SBList.Padding = UDim.new(0,8)
SBList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Content Holder
local ContentHolder = Instance.new("Frame", Content)
ContentHolder.Size = UDim2.new(1,0,1,0)
ContentHolder.BackgroundTransparency = 1
ContentHolder.ClipsDescendants = true

-- Tabs Setup
local Tabs = {}
local TabOrder = {"MAIN","TEST"}

for index, name in ipairs(TabOrder) do
	local TabBtn = Instance.new("TextButton")
	TabBtn.Parent = SidebarScroll
	TabBtn.Name = "TabBtn_"..index
	TabBtn.Size = UDim2.new(1,-24,0,40)
	TabBtn.BackgroundColor3 = Color3.fromRGB(25,25,25)
	TabBtn.Text = name
	TabBtn.Font = Enum.Font.Gotham
	TabBtn.TextSize = 14
	TabBtn.TextColor3 = Color3.fromRGB(200,50,50)
	TabBtn.AutoButtonColor = false
	local tCorner = Instance.new("UICorner", TabBtn)
	tCorner.CornerRadius = UDim.new(0,8)
	TabBtn.MouseEnter:Connect(function() tween(TabBtn,{BackgroundColor3=Color3.fromRGB(40,0,0)},0.18):Play() end)
	TabBtn.MouseLeave:Connect(function()
		if Tabs[index] and index ~= Tabs.currentIndex then
			tween(TabBtn,{BackgroundColor3=Color3.fromRGB(25,25,25)},0.18):Play()
		end
	end)

	local TabFrame = Instance.new("Frame")
	TabFrame.Parent = ContentHolder
	TabFrame.Name = "Content_"..index
	TabFrame.Size = UDim2.new(1,0,1,0)
	TabFrame.Position = UDim2.new((index-1),0,0,0)
	TabFrame.BackgroundTransparency = 1
	TabFrame.ClipsDescendants = true

	local InnerScroll = Instance.new("ScrollingFrame", TabFrame)
	InnerScroll.Size = UDim2.new(1,0,1,0)
	InnerScroll.BackgroundTransparency = 1
	InnerScroll.ScrollBarThickness = 8
	InnerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	InnerScroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	local InnerList = Instance.new("UIListLayout", InnerScroll)
	InnerList.SortOrder = Enum.SortOrder.LayoutOrder
	InnerList.Padding = UDim.new(0,10)
	InnerList.HorizontalAlignment = Enum.HorizontalAlignment.Center

	-- MAIN Tab Inhalt
	if name == "MAIN" then
		local container = Instance.new("Frame", InnerScroll)
		container.Size = UDim2.new(0,360,0,44)
		container.BackgroundTransparency = 1

		local lbl = Instance.new("TextLabel", container)
		lbl.Size = UDim2.new(0.7,0,1,0)
		lbl.Position = UDim2.new(0,8,0,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = "GiftBox Toggle"
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 14
		lbl.TextColor3 = Color3.new(1,1,1)

		local tog = Instance.new("TextButton", container)
		tog.Size = UDim2.new(0,100,0,32)
		tog.Position = UDim2.new(1,-110,0.5,-16)
		tog.BackgroundColor3 = Color3.fromRGB(60,0,0)
		tog.Text = "OFF"
		tog.Font = Enum.Font.GothamBold
		tog.TextSize = 14
		tog.TextColor3 = Color3.new(1,1,1)
		tog.AutoButtonColor = false
		local tc = Instance.new("UICorner", tog)
		tc.CornerRadius = UDim.new(0,8)
		local state = false

		tog.MouseButton1Click:Connect(function()
			state = not state
			tween(tog, {BackgroundColor3 = state and Color3.fromRGB(120,0,0) or Color3.fromRGB(60,0,0)}, 0.25):Play()
			tog.Text = state and "ON" or "OFF"
			if state then
				local args = {
					{
						{ false },
						{ 2 }
					}
				}
				workspace:WaitForChild("__THINGS"):WaitForChild("__REMOTES"):WaitForChild("halloweengiftbox3"):InvokeServer(unpack(args))
			end
		end)
	else
		-- TEST Tab Dummy Content
		for i=1,4 do
			local lbl = Instance.new("TextLabel", InnerScroll)
			lbl.Size = UDim2.new(0,360,0,34)
			lbl.BackgroundColor3 = Color3.fromRGB(20,20,20)
			lbl.Text = "TEST Item "..i
			lbl.Font = Enum.Font.Gotham
			lbl.TextSize = 14
			lbl.TextColor3 = Color3.new(1,1,1)
			local lc = Instance.new("UICorner", lbl)
			lc.CornerRadius = UDim.new(0,6)
		end
	end

	Tabs[index] = {Name=name,Button=TabBtn,Frame=TabFrame,InnerScroll=InnerScroll}
end

-- Tab switch logic
local currentIndex = 1
local animating = false
local function switchToIndex(newIndex)
	if newIndex == currentIndex or animating then return end
	animating = true
	local oldTab = Tabs[currentIndex].Frame
	local newTab = Tabs[newIndex].Frame
	oldTab.Visible = true
	newTab.Visible = true
	oldTab.Position = UDim2.new(0,0,0,0)
	newTab.Position = UDim2.new(1,0,0,0)
	local tweenOut = TweenService:Create(oldTab, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {Position = UDim2.new(-1,0,0,0)})
	local tweenIn = TweenService:Create(newTab, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {Position = UDim2.new(0,0,0,0)})
	tweenOut:Play()
	tweenIn:Play()
	tweenIn.Completed:Connect(function()
		oldTab.Visible = false
		animating = false
	end)
	tween(Tabs[currentIndex].Button, {BackgroundColor3=Color3.fromRGB(25,25,25)}, 0.18):Play()
	tween(Tabs[newIndex].Button, {BackgroundColor3=Color3.fromRGB(40,0,0)}, 0.18):Play()
	currentIndex = newIndex
end

for i,t in ipairs(Tabs) do
	t.Button.MouseButton1Click:Connect(function() switchToIndex(i) end)
end

-- Open/Close logic
local guiVisible = false
local lastPosition = UDim2.new(0.5,-320,0.5,-210)
local function openGUI()
	if guiVisible then return end
	guiVisible = true
	MainFrame.Visible = true
	MainFrame.Position = lastPosition
	MainFrame.BackgroundTransparency = 1
	MainFrame.Size = UDim2.new(0,0,0,0)
	tween(MainFrame,{Size=UDim2.new(0,640,0,420),BackgroundTransparency=0},0.4):Play()
end
local function closeGUI()
	if not guiVisible then return end
	guiVisible = false
	lastPosition = MainFrame.Position
	local tw = tween(MainFrame,{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1},0.35)
	tw:Play()
	tw.Completed:Wait()
	MainFrame.Visible = false
end
OpenButton.MouseButton1Click:Connect(function()
	if guiVisible then closeGUI() else openGUI() end
end)

-- Draggable Frames
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
MainFrame.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		local screenW = workspace.CurrentCamera.ViewportSize.X
		local screenH = workspace.CurrentCamera.ViewportSize.Y
		MainFrame.Position = UDim2.new(startPos.X.Scale + delta.X/screenW, startPos.X.Offset + delta.X, startPos.Y.Scale + delta.Y/screenH, startPos.Y.Offset + delta.Y)
	end
end)

local obDragging, obDragStart, obStartPos
OpenButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		obDragging = true
		obDragStart = input.Position
		obStartPos = OpenButton.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then obDragging = false end
		end)
	end
end)
OpenButton.InputChanged:Connect(function(input)
	if obDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - obDragStart
		local screenW = workspace.CurrentCamera.ViewportSize.X
		local screenH = workspace.CurrentCamera.ViewportSize.Y
		OpenButton.Position = UDim2.new(obStartPos.X.Scale + delta.X/screenW, obStartPos.X.Offset + delta.X, obStartPos.Y.Scale + delta.Y/screenH, obStartPos.Y.Offset + delta.Y)
	end
end)

-- Highlight default tab
tween(Tabs[1].Button,{BackgroundColor3=Color3.fromRGB(40,0,0)},0.18):Play()

print("Simplified GUI (MAIN + TEST) loaded.")
