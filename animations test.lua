local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- helper: tween
local function tween(inst, props, time, style, dir)
	style = style or Enum.EasingStyle.Quint
	dir = dir or Enum.EasingDirection.Out
	return TweenService:Create(inst, TweenInfo.new(time or 0.35, style, dir), props)
end

-- create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChatGPTStyleGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- open/close button (separat, draggable)
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0,40,0,40)
OpenButton.Position = UDim2.new(1,-70,1,-70)
OpenButton.AnchorPoint = Vector2.new(0,0)
OpenButton.BackgroundColor3 = Color3.fromRGB(40,0,0)
OpenButton.BorderSizePixel = 0
OpenButton.Text = "☰"
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 22
OpenButton.TextColor3 = Color3.new(1,1,1)
OpenButton.AutoButtonColor = false
local obCorner = Instance.new("UICorner", OpenButton)
obCorner.CornerRadius = UDim.new(1,0)

-- main frame (initially offscreen)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0,640,0,420)
MainFrame.Position = UDim2.new(0.5,-320,1,50) -- start offscreen (below)
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
local mainCorner = Instance.new("UICorner", MainFrame)
mainCorner.CornerRadius = UDim.new(0,12)

-- main shadow (subtle)
local Shadow = Instance.new("ImageLabel")
Shadow.Parent = MainFrame
Shadow.AnchorPoint = Vector2.new(0.5,0.5)
Shadow.Position = UDim2.new(0.5,0.5,0,6)
Shadow.Size = UDim2.new(1,40,1,40)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageTransparency = 0.8
Shadow.ZIndex = 0

-- layout: sidebar + content with padding
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0,180,1,0)
Sidebar.Position = UDim2.new(0,0,0,0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15,15,15)
Sidebar.BorderSizePixel = 0
local sbCorner = Instance.new("UICorner", Sidebar)
sbCorner.CornerRadius = UDim.new(0,10)

local Content = Instance.new("Frame")
Content.Parent = MainFrame
Content.Name = "Content"
Content.Size = UDim2.new(1,-180,1,0)
Content.Position = UDim2.new(0,180,0,0)
Content.BackgroundColor3 = Color3.fromRGB(10,10,10)
Content.BorderSizePixel = 0
local ctCorner = Instance.new("UICorner", Content)
ctCorner.CornerRadius = UDim.new(0,10)

-- inner padding so things don't sit at the edges
local function addPadding(parent, left, top, right, bottom)
	local pad = Instance.new("UIPadding", parent)
	pad.PaddingLeft = UDim.new(0, left or 12)
	pad.PaddingTop = UDim.new(0, top or 12)
	pad.PaddingRight = UDim.new(0, right or 12)
	pad.PaddingBottom = UDim.new(0, bottom or 12)
	return pad
end
addPadding(Sidebar, 12, 12, 12, 12)
addPadding(Content, 14, 14, 14, 14)

-- title bar inside main (keeps draggable area visually)
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1,0,0,36)
TitleBar.Position = UDim2.new(0,0,0,0)
TitleBar.BackgroundTransparency = 1
local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -12, 1, 0)
Title.Position = UDim2.new(0,12,0,0)
Title.BackgroundTransparency = 1
Title.Text = "Animated Test GUI"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Scrolling Sidebar (tabs)
local SidebarScroll = Instance.new("ScrollingFrame")
SidebarScroll.Parent = Sidebar
SidebarScroll.Size = UDim2.new(1,0,1,0)
SidebarScroll.CanvasSize = UDim2.new(0,0,0,0)
SidebarScroll.ScrollBarThickness = 8
SidebarScroll.BackgroundTransparency = 1
SidebarScroll.BorderSizePixel = 0
SidebarScroll.AnchorPoint = Vector2.new(0,0)
SidebarScroll.Position = UDim2.new(0,0,0,36) -- leave the titlebar area
SidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SidebarScroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always

-- Sidebar list layout
local SBList = Instance.new("UIListLayout", SidebarScroll)
SBList.SortOrder = Enum.SortOrder.LayoutOrder
SBList.Padding = UDim.new(0,8)
SBList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Content ScrollingFrame (holds tab frames stacked, we'll animate X)
local ContentHolder = Instance.new("Frame")
ContentHolder.Parent = Content
ContentHolder.Size = UDim2.new(1,0,1,0)
ContentHolder.BackgroundTransparency = 1
ContentHolder.ClipsDescendants = true

-- Each tab content will be a Frame inside ContentHolder and positioned side-by-side horizontally for slide animation
local Tabs = {}
local TabOrder = {"Test Buttons","Toggles","Inputs","Extras","More1","More2","More3","More4","More5","More6"} -- 10 tabs

-- create tab buttons and content frames
for index, name in ipairs(TabOrder) do
	-- tab button (in sidebar)
	local btnSizeY = 40
	local TabBtn = Instance.new("TextButton")
	TabBtn.Parent = SidebarScroll
	TabBtn.Name = "TabBtn_"..index
	TabBtn.Size = UDim2.new(1,-24,0,btnSizeY)
	TabBtn.BackgroundColor3 = Color3.fromRGB(25,25,25)
	TabBtn.BorderSizePixel = 0
	TabBtn.Text = name
	TabBtn.Font = Enum.Font.Gotham
	TabBtn.TextSize = 14
	TabBtn.TextColor3 = Color3.fromRGB(200,50,50)
	TabBtn.AutoButtonColor = false
	local tCorner = Instance.new("UICorner", TabBtn)
	tCorner.CornerRadius = UDim.new(0,8)
	
	TabBtn.MouseEnter:Connect(function()
		tween(TabBtn, {BackgroundColor3 = Color3.fromRGB(40,0,0)}, 0.18):Play()
	end)
	TabBtn.MouseLeave:Connect(function()
		tween(TabBtn, {BackgroundColor3 = Color3.fromRGB(25,25,25)}, 0.18):Play()
	end)
	
	-- content frame (positioned horizontally by index)
	local TabFrame = Instance.new("Frame")
	TabFrame.Parent = ContentHolder
	TabFrame.Name = "Content_"..index
	TabFrame.Size = UDim2.new(1,0,1,0)
	TabFrame.Position = UDim2.new((index-1),0,0,0) -- side-by-side
	TabFrame.BackgroundTransparency = 1
	TabFrame.ClipsDescendants = true

	-- inside content: use a ScrollingFrame so inner content scrolls vertically
	local InnerScroll = Instance.new("ScrollingFrame")
	InnerScroll.Parent = TabFrame
	InnerScroll.Size = UDim2.new(1,0,1,0)
	InnerScroll.Position = UDim2.new(0,0,0,0)
	InnerScroll.BackgroundTransparency = 1
	InnerScroll.BorderSizePixel = 0
	InnerScroll.ScrollBarThickness = 8
	InnerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	InnerScroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always

	local InnerList = Instance.new("UIListLayout", InnerScroll)
	InnerList.SortOrder = Enum.SortOrder.LayoutOrder
	InnerList.Padding = UDim.new(0,10)
	InnerList.HorizontalAlignment = Enum.HorizontalAlignment.Center

	-- add sample contents depending on tab
	if name == "Test Buttons" then
		for i=1,3 do
			local b = Instance.new("TextButton")
			b.Parent = InnerScroll
			b.Size = UDim2.new(0,360,0,40)
			b.BackgroundColor3 = Color3.fromRGB(60,0,0)
			b.Text = "Test Button "..i
			b.Font = Enum.Font.GothamBold
			b.TextSize = 16
			b.TextColor3 = Color3.new(1,1,1)
			local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0,8)

			b.MouseEnter:Connect(function() tween(b,{BackgroundColor3=Color3.fromRGB(110,0,0)},0.18):Play() end)
			b.MouseLeave:Connect(function() tween(b,{BackgroundColor3=Color3.fromRGB(60,0,0)},0.18):Play() end)
			b.MouseButton1Click:Connect(function()
				-- simple click feedback
				tween(b, {Size = UDim2.new(0,350,0,36)}, 0.06, Enum.EasingStyle.Sine, Enum.EasingDirection.In):Play()
				delay(0.06, function() tween(b, {Size = UDim2.new(0,360,0,40)}, 0.12):Play() end)
			end)
		end

		-- Dropdown (animated)
		local dropdown = Instance.new("Frame")
		dropdown.Parent = InnerScroll
		dropdown.Size = UDim2.new(0,360,0,40)
		dropdown.BackgroundColor3 = Color3.fromRGB(40,0,0)
		local dc = Instance.new("UICorner", dropdown); dc.CornerRadius = UDim.new(0,8)

		local label = Instance.new("TextLabel", dropdown)
		label.Size = UDim2.new(1,-10,1,0)
		label.Position = UDim2.new(0,8,0,0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.new(1,1,1)
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.Text = "Choose an option ▾"

		local arrow = Instance.new("TextLabel", dropdown)
		arrow.Size = UDim2.new(0,28,1,0)
		arrow.AnchorPoint = Vector2.new(1,0)
		arrow.Position = UDim2.new(1,-6,0,0)
		arrow.BackgroundTransparency = 1
		arrow.Text = ""
		
		local optionsFrame = Instance.new("Frame")
		optionsFrame.Parent = InnerScroll
		optionsFrame.Size = UDim2.new(0,360,0,0)
		optionsFrame.BackgroundTransparency = 1
		optionsFrame.ClipsDescendants = true

		-- option list (example)
		local options = {"Alpha","Bravo","Charlie","Delta"}
		local optButtons = {}
		for i,opt in ipairs(options) do
			local ob = Instance.new("TextButton")
			ob.Parent = optionsFrame
			ob.Size = UDim2.new(1,0,0,36)
			ob.Position = UDim2.new(0,0,0,(i-1)*40)
			ob.BackgroundColor3 = Color3.fromRGB(30,0,0)
			ob.Text = opt
			ob.Font = Enum.Font.Gotham
			ob.TextSize = 14
			ob.TextColor3 = Color3.new(1,1,1)
			ob.BorderSizePixel = 0
			local oc = Instance.new("UICorner", ob); oc.CornerRadius = UDim.new(0,6)
			table.insert(optButtons, ob)
		end

		local expanded = false
		local expandedSize = #options * 40
		local function toggleDropdown()
			expanded = not expanded
			if expanded then
				tween(optionsFrame, {Size = UDim2.new(0,360,0,expandedSize)}, 0.28):Play()
			else
				tween(optionsFrame, {Size = UDim2.new(0,360,0,0)}, 0.22):Play()
			end
		end

		dropdown.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				toggleDropdown()
			end
		end)

		for _, ob in ipairs(optButtons) do
			ob.MouseButton1Click:Connect(function()
				label.Text = ob.Text.." ▾"
				toggleDropdown()
			end)
		end
	elseif name == "Toggles" then
		for i=1,6 do
			local container = Instance.new("Frame")
			container.Parent = InnerScroll
			container.Size = UDim2.new(0,360,0,44)
			container.BackgroundTransparency = 1

			local lbl = Instance.new("TextLabel", container)
			lbl.Size = UDim2.new(0.7,0,1,0)
			lbl.Position = UDim2.new(0,8,0,0)
			lbl.BackgroundTransparency = 1
			lbl.Text = "Toggle Option "..i
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
			local tc = Instance.new("UICorner", tog); tc.CornerRadius = UDim.new(0,8)
			local state = false
			tog.MouseButton1Click:Connect(function()
				state = not state
				tween(tog, {BackgroundColor3 = state and Color3.fromRGB(120,0,0) or Color3.fromRGB(60,0,0)}, 0.25):Play()
				tog.Text = state and "ON" or "OFF"
			end)
		end
	elseif name == "Inputs" then
		for i=1,3 do
			local tb = Instance.new("TextBox")
			tb.Parent = InnerScroll
			tb.Size = UDim2.new(0,360,0,40)
			tb.PlaceholderText = "Enter text "..i
			tb.Font = Enum.Font.Gotham
			tb.TextSize = 14
			tb.TextColor3 = Color3.new(1,1,1)
			tb.BackgroundColor3 = Color3.fromRGB(40,0,0)
			local c = Instance.new("UICorner", tb); c.CornerRadius = UDim.new(0,8)
		end
		local submit = Instance.new("TextButton")
		submit.Parent = InnerScroll
		submit.Size = UDim2.new(0,360,0,40)
		submit.Text = "Submit"
		submit.Font = Enum.Font.GothamBold
		submit.TextSize = 16
		submit.TextColor3 = Color3.new(1,1,1)
		submit.BackgroundColor3 = Color3.fromRGB(60,0,0)
		local sC = Instance.new("UICorner", submit); sC.CornerRadius = UDim.new(0,8)
		submit.MouseButton1Click:Connect(function()
			tween(submit, {BackgroundColor3 = Color3.fromRGB(90,0,0)}, 0.08):Play()
			delay(0.08, function() tween(submit, {BackgroundColor3 = Color3.fromRGB(60,0,0)}, 0.12):Play() end)
		end)
	else
		-- other tabs: fill with some dummy controls so scroll is visible
		for i=1,8 do
			local lbl = Instance.new("TextLabel")
			lbl.Parent = InnerScroll
			lbl.Size = UDim2.new(0,360,0,34)
			lbl.BackgroundColor3 = Color3.fromRGB(20,20,20)
			lbl.Text = name.." Item "..i
			lbl.Font = Enum.Font.Gotham
			lbl.TextSize = 14
			lbl.TextColor3 = Color3.new(1,1,1)
			local lc = Instance.new("UICorner", lbl); lc.CornerRadius = UDim.new(0,6)
		end
	end

	Tabs[index] = {
		Name = name,
		Button = TabBtn,
		Frame = TabFrame,
		InnerScroll = InnerScroll
	}
end

-- update sidebar canvas size (ensure scroll works)
SidebarScroll.ChildAdded:Connect(function() end) -- placeholder
-- AUTOMATIC CANVAS SIZE already enabled for InnerScrolls; but ensure sidebar layout sets CanvasSize correctly
local function refreshSidebarCanvas()
	SidebarScroll.CanvasSize = UDim2.new(0,0,0,SBList.AbsoluteContentSize.Y + 12)
end
SBList.Changed:Connect(function(prop) if prop == "AbsoluteContentSize" then refreshSidebarCanvas() end end)
refreshSidebarCanvas()


-- manage current tab and sliding animation
local currentIndex = 1
local animating = false

local function switchToIndex(newIndex)
	if newIndex == currentIndex or animating then return end
	animating = true

	local oldTab = Tabs[currentIndex].Frame
	local newTab = Tabs[newIndex].Frame

	-- Beide Tabs sichtbar machen, für Animation
	oldTab.Visible = true
	newTab.Visible = true

	-- Startposition: neuer Tab rechts außerhalb, alter Tab an 0
	oldTab.Position = UDim2.new(0, 0, 0, 0)
	newTab.Position = UDim2.new(1, 0, 0, 0)

	-- Tween: alter Tab raus nach links, neuer rein von rechts
	local tweenOut = TweenService:Create(oldTab, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(-1, 0, 0, 0)})
	local tweenIn = TweenService:Create(newTab, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})

	tweenOut:Play()
	tweenIn:Play()

	tweenIn.Completed:Connect(function()
		-- Nach der Animation: alten Tab verstecken und zurücksetzen
		oldTab.Visible = false
		oldTab.Position = UDim2.new(0, 0, 0, 0)
		animating = false
	end)

	-- Sidebar-Button-Highlight anpassen
	tween(Tabs[currentIndex].Button, {BackgroundColor3 = Color3.fromRGB(25,25,25)}, 0.18):Play()
	tween(Tabs[newIndex].Button, {BackgroundColor3 = Color3.fromRGB(40,0,0)}, 0.18):Play()

	currentIndex = newIndex
end

-- connect sidebar buttons
for i, t in ipairs(Tabs) do
	local idx = i
	t.Button.MouseButton1Click:Connect(function()
		switchToIndex(idx)
	end)
end




--// OPEN/CLOSE LOGIC + POSITIONSMERKUNG + DRAGGING

local guiVisible = false
local lastPosition = UDim2.new(0.5, -320, 0.5, -210) -- Startposition

-- Öffnen / Schließen mit gespeicherter Position
local function openGUI()
	if guiVisible then return end
	guiVisible = true
	MainFrame.Visible = true
	MainFrame.Position = lastPosition
	MainFrame.BackgroundTransparency = 1
	MainFrame.Size = UDim2.new(0, 0, 0, 0)
	tween(MainFrame, {Size = UDim2.new(0, 640, 0, 420), BackgroundTransparency = 0}, 0.4):Play()
end

local function closeGUI()
	if not guiVisible then return end
	guiVisible = false
	lastPosition = MainFrame.Position -- Position merken!
	local tw = tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.35)
	tw:Play()
	tw.Completed:Wait()
	MainFrame.Visible = false
end

OpenButton.MouseButton1Click:Connect(function()
	if guiVisible then
		closeGUI()
	else
		openGUI()
	end
end)

--// DRAGGABLE MAINFRAME (volle Fläche)
local dragging = false
local dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		local screenW = workspace.CurrentCamera.ViewportSize.X
		local screenH = workspace.CurrentCamera.ViewportSize.Y
		local newX = startPos.X.Scale + (delta.X / screenW)
		local newY = startPos.Y.Scale + (delta.Y / screenH)
		MainFrame.Position = UDim2.new(newX, startPos.X.Offset + delta.X, newY, startPos.Y.Offset + delta.Y)
	end
end)

--// DRAGGABLE OPENBUTTON (separat)
local obDragging = false
local obStartPos, obDragStart

OpenButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		obDragging = true
		obDragStart = input.Position
		obStartPos = OpenButton.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				obDragging = false
			end
		end)
	end
end)

OpenButton.InputChanged:Connect(function(input)
	if obDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - obDragStart
		local screenW = workspace.CurrentCamera.ViewportSize.X
		local screenH = workspace.CurrentCamera.ViewportSize.Y
		local newX = obStartPos.X.Scale + (delta.X / screenW)
		local newY = obStartPos.Y.Scale + (delta.Y / screenH)
		OpenButton.Position = UDim2.new(newX, obStartPos.X.Offset + delta.X, newY, obStartPos.Y.Offset + delta.Y)
	end
end)




-- ensure ContentHolder starts at correct position
ContentHolder.Position = UDim2.new(0,0,0,0)
-- highlight initial tab button
tween(Tabs[1].Button, {BackgroundColor3 = Color3.fromRGB(40,0,0)}, 0.18):Play()

-- Make sure GUI adjusts on screen size changes
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() end)
UserInputService.WindowSizeChanged:Connect(function()
	-- nothing heavy, just keep MainFrame visible within screen bounds if needed (optional)
end)

-- initial ready
print("ChatGPT-style GUI loaded.")
