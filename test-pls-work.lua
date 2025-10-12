--[[local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ===================== ScreenGui & Frame =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 250)
frame.Position = UDim2.new(0.5, -175, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.BorderSizePixel = 2
frame.Parent = screenGui

-- Frame draggable
local dragging = false
local dragInput, mousePos, framePos

local function update(input)
	local delta = input.Position - mousePos
	frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		mousePos = input.Position
		framePos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- UI ELEMENTS 
-- Label
local labelRadius = Instance.new("TextLabel")
labelRadius.Size = UDim2.new(1, -20, 0, 25)
labelRadius.Position = UDim2.new(0, 10, 0, 10)
labelRadius.BackgroundTransparency = 1
labelRadius.TextColor3 = Color3.fromRGB(255, 255, 255)
labelRadius.Text = "Farm Radius:"
labelRadius.TextScaled = true
labelRadius.Parent = frame

-- TextBox
local radiusBox = Instance.new("TextBox")
radiusBox.Size = UDim2.new(1, -20, 0, 25)
radiusBox.Position = UDim2.new(0, 10, 0, 40)
radiusBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
radiusBox.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusBox.Text = "50"
radiusBox.ClearTextOnFocus = false
radiusBox.Parent = frame

-- Toggle Button
local toggleRadiusBtn = Instance.new("TextButton")
toggleRadiusBtn.Size = UDim2.new(1, -20, 0, 35)
toggleRadiusBtn.Position = UDim2.new(0, 10, 0, 70)
toggleRadiusBtn.Text = "Radius Farm: OFF"
toggleRadiusBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
toggleRadiusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleRadiusBtn.Parent = frame

-- Label
local labelArea = Instance.new("TextLabel")
labelArea.Size = UDim2.new(1, -20, 0, 25)
labelArea.Position = UDim2.new(0, 10, 0, 110)
labelArea.BackgroundTransparency = 1
labelArea.TextColor3 = Color3.fromRGB(255, 255, 255)
labelArea.Text = "Select Area:"
labelArea.TextScaled = true
labelArea.Parent = frame

-- Dropdown
local areaDropdown = Instance.new("TextButton")
areaDropdown.Size = UDim2.new(1, -20, 0, 25)
areaDropdown.Position = UDim2.new(0, 10, 0, 140)
areaDropdown.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
areaDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
areaDropdown.Text = "None"
areaDropdown.Parent = frame

-- Toggle Button
local toggleAreaBtn = Instance.new("TextButton")
toggleAreaBtn.Size = UDim2.new(1, -20, 0, 35)
toggleAreaBtn.Position = UDim2.new(0, 10, 0, 170)
toggleAreaBtn.Text = "Area Farm: OFF"
toggleAreaBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
toggleAreaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleAreaBtn.Parent = frame

-- LOGIC 
local radiusFarmEnabled = false
local areaFarmEnabled = false
local farmRadius = 50
local selectedArea = nil

toggleRadiusBtn.MouseButton1Click:Connect(function()
	radiusFarmEnabled = not radiusFarmEnabled
	toggleRadiusBtn.Text = radiusFarmEnabled and "Radius Farm: ON" or "Radius Farm: OFF"
end)

toggleAreaBtn.MouseButton1Click:Connect(function()
	areaFarmEnabled = not areaFarmEnabled
	toggleAreaBtn.Text = areaFarmEnabled and "Area Farm: ON" or "Area Farm: OFF"
end)

-- Radius TextBox live
radiusBox:GetPropertyChangedSignal("Text"):Connect(function()
	local value = tonumber(radiusBox.Text)
	if value then
		farmRadius = value
	end
end)

-- Area Dropdown
local function updateAreas()
	local coinsFolder = workspace.__THINGS:FindFirstChild("Coins")
	if not coinsFolder then return end
	local areaSet = {}
	for _, coin in pairs(coinsFolder:GetChildren()) do
		local area = coin:GetAttribute("Area")
		if area and not areaSet[area] then
			areaSet[area] = true
		end
	end
	return areaSet
end

areaDropdown.MouseButton1Click:Connect(function()
	local areas = updateAreas()
	local list = {}
	for areaName in pairs(areas) do table.insert(list, areaName) end
	table.sort(list)

	local menu = Instance.new("Frame")
	menu.Size = UDim2.new(0, areaDropdown.AbsoluteSize.X, 0, #list*25)
	menu.Position = areaDropdown.Position + UDim2.new(0,0,0,areaDropdown.AbsoluteSize.Y)
	menu.BackgroundColor3 = Color3.fromRGB(60,60,60)
	menu.Parent = frame

	for i, areaName in pairs(list) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1,0,0,25)
		btn.Position = UDim2.new(0,0,0,(i-1)*25)
		btn.Text = areaName
		btn.BackgroundColor3 = Color3.fromRGB(100,100,100)
		btn.TextColor3 = Color3.fromRGB(255,255,255)
		btn.Parent = menu
		btn.MouseButton1Click:Connect(function()
			selectedArea = areaName
			areaDropdown.Text = areaName
			menu:Destroy()
		end)
	end
end)

-- Loop
task.spawn(function()
	while true do
		task.wait(0.05)
		local petsFolder = workspace.__THINGS:WaitForChild("Pets")
		local coinsFolder = workspace.__THINGS:FindFirstChild("Coins")
		if not coinsFolder then continue end

		local myPets = {}
		for _, pet in pairs(petsFolder:GetChildren()) do
			local owner = pet:GetAttribute("Owner")
			if owner == player or owner == player.Name or tostring(owner) == tostring(player.UserId) or tostring(owner):find(player.Name) then
				table.insert(myPets, pet.Name)
			end
		end

		-- -------- Radius Farm --------
		if radiusFarmEnabled then
			local availableCoins = {}
			for _, coin in pairs(coinsFolder:GetChildren()) do
				if coin:FindFirstChild("POS") then
					local distance = (player.Character.PrimaryPart.Position - coin.POS.Position).Magnitude
					if distance <= farmRadius then
						table.insert(availableCoins, coin)
					end
				end
			end
			for i, petId in pairs(myPets) do
				local coin = availableCoins[i]
				if coin then
					local coinId = coin.Name
					local joinArgs = {{{coinId,{petId}},{false,false}}}
					pcall(function() workspace.__THINGS.__REMOTES["join coin"]:InvokeServer(unpack(joinArgs)) end)
					local farmArgs = {{{coinId,petId},{false,false}}}
					pcall(function() workspace.__THINGS.__REMOTES["ur_lame_xd"]:FireServer(unpack(farmArgs)) end)
				end
			end
		end

		-- -------- Area Farm --------
		if areaFarmEnabled and selectedArea then
			local availableCoins = {}
			for _, coin in pairs(coinsFolder:GetChildren()) do
				if coin:GetAttribute("Area") == selectedArea then
					table.insert(availableCoins, coin)
				end
			end
			for i, petId in pairs(myPets) do
				local coin = availableCoins[i]
				if coin then
					local coinId = coin.Name
					local joinArgs = {{{coinId,{petId}},{false,false}}}
										pcall(function() workspace.__THINGS.__REMOTES["join coin"]:InvokeServer(unpack(joinArgs)) end)
					local farmArgs = {{{coinId, petId},{false,false}}}
					pcall(function() workspace.__THINGS.__REMOTES["ur_lame_xd"]:FireServer(unpack(farmArgs)) end)
				end
			end
		end
	end
end)
]]


























































local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TabbedGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

--// Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Size = UDim2.new(0, 600, 0, 360)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -180)
MainFrame.Visible = false

local Title = Instance.new("TextLabel", MainFrame)
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 38)
Title.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
Title.Text = "NEVER STOP GAMBELING"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.SourceSansBold

local TabFrame = Instance.new("ScrollingFrame", MainFrame)
TabFrame.Name = "TabFrame"
TabFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TabFrame.Size = UDim2.new(0, 140, 1, -38)
TabFrame.Position = UDim2.new(0, 0, 0, 38)
TabFrame.ScrollBarThickness = 6
TabFrame.CanvasSize = UDim2.new(0,0,0,0)

local UIListLayout = Instance.new("UIListLayout", TabFrame)
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabFrame.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y + 8)
end)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Name = "ContentFrame"
ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ContentFrame.Size = UDim2.new(1, -140, 1, -38)
ContentFrame.Position = UDim2.new(0, 140, 0, 38)

--// Tabs & Content
local Tabs = {}
local function createTabButton(name)
    local btn = Instance.new("TextButton", TabFrame)
    btn.Name = name .. "Tab"
    btn.Text = name
    btn.Size = UDim2.new(1, -16, 0, 44)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    btn.Font = Enum.Font.SourceSans
    btn.AutoButtonColor = false
    btn.ZIndex = 2

    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(90,90,90) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(70,70,70) end)
    return btn
end

local function createTabContent(name)
    local tab = Instance.new("Frame", ContentFrame)
    tab.Name = name .. "Content"
    tab.BackgroundTransparency = 1
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.Visible = false
    Tabs[name] = tab
    return tab
end

local MainTabButton = createTabButton("Main")
local FarmTabButton = createTabButton("Farm")
local MainContent = createTabContent("Main")
local FarmContent = createTabContent("Farm")

local function showTab(name)
    for n, frame in pairs(Tabs) do
        frame.Visible = (n == name)
    end
end
showTab("Main")
MainTabButton.MouseButton1Click:Connect(function() showTab("Main") end)
FarmTabButton.MouseButton1Click:Connect(function() showTab("Farm") end)

--// Auto Collect Toggles
local AutoSection = Instance.new("Frame", MainContent)
AutoSection.Name = "AutoCollectsSection"
AutoSection.BackgroundTransparency = 1
AutoSection.Size = UDim2.new(1, -20, 0, 130)
AutoSection.Position = UDim2.new(0, 10, 0, 10)

local SectionTitle = Instance.new("TextLabel", AutoSection)
SectionTitle.Size = UDim2.new(1, 0, 0, 24)
SectionTitle.BackgroundTransparency = 1
SectionTitle.Text = "Auto Collects"
SectionTitle.TextColor3 = Color3.fromRGB(255,255,255)
SectionTitle.TextSize = 18
SectionTitle.Font = Enum.Font.SourceSansBold

local TogglesList = Instance.new("Frame", AutoSection)
TogglesList.BackgroundTransparency = 1
TogglesList.Size = UDim2.new(1, 0, 1, -34)
TogglesList.Position = UDim2.new(0, 0, 0, 34)

local TogglesLayout = Instance.new("UIListLayout", TogglesList)
TogglesLayout.Padding = UDim.new(0, 8)
TogglesLayout.FillDirection = Enum.FillDirection.Vertical
TogglesLayout.SortOrder = Enum.SortOrder.LayoutOrder
TogglesLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local function createToggle(parent, text, initial)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 36)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.78, 0, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.TextSize = 16
    label.Font = Enum.Font.SourceSans

    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0.18, -6, 1, 0)
    toggleBtn.Position = UDim2.new(0.82, 0, 0, 0)
    toggleBtn.TextSize = 16
    toggleBtn.Font = Enum.Font.SourceSansBold
    toggleBtn.Text = initial and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = initial and Color3.fromRGB(60,140,60) or Color3.fromRGB(120,120,120)
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.AutoButtonColor = false

    local state = initial
    local onToggle = function(newState) end

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(60,140,60) or Color3.fromRGB(120,120,120)
        onToggle(state)
    end)

    local obj = {}
    function obj:SetCallback(fn) onToggle = fn end
    function obj:SetState(s)
        state = s
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(60,140,60) or Color3.fromRGB(120,120,120)
    end
    return obj
end

local rankToggle = createToggle(TogglesList, "Auto Collect Rank Rewards", false)
local orbsToggle = createToggle(TogglesList, "Auto Collect Orbs", false)

--// Open/Close Button with Animation
local OpenCloseBtn = Instance.new("TextButton", ScreenGui)
OpenCloseBtn.Name = "OpenClose"
OpenCloseBtn.Size = UDim2.new(0, 140, 0, 48)
OpenCloseBtn.Position = UDim2.new(0.5, -70, 0.88, 0)
OpenCloseBtn.Text = "Open GUI"
OpenCloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
OpenCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenCloseBtn.TextSize = 18
OpenCloseBtn.Font = Enum.Font.SourceSansBold
OpenCloseBtn.AutoButtonColor = false

--// Animated Border
local Border = Instance.new("Frame", OpenCloseBtn)
Border.Name = "AnimatedBorder"
Border.Size = UDim2.new(1, 6, 1, 6)
Border.Position = UDim2.new(0, -3, 0, -3)
Border.BackgroundTransparency = 1

local UIStroke = Instance.new("UIStroke", Border)
UIStroke.Thickness = 3
UIStroke.Color = Color3.fromRGB(255, 0, 0)

task.spawn(function()
    local hue = 0
    while task.wait(0.03) do
        hue = (hue + 2) % 360
        UIStroke.Color = Color3.fromHSV(hue / 360, 1, 1)
    end
end)



--// Funktion zum Draggen (Maus + Touch)
local function makeDraggable(frame)
    local dragging, dragInput, startPos, startInputPos

    local function update(input)
        local delta = input.Position - startInputPos
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInputPos = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

--// MainFrame und Open/Close Button draggable machen
makeDraggable(MainFrame)
makeDraggable(OpenCloseBtn)

--// Open/Close Button mit Animation
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local isOpen = false

OpenCloseBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    OpenCloseBtn.Text = isOpen and "Close GUI" or "Open GUI"

    if isOpen then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 600, 0, 360)}):Play()
    else
        local tween = TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)})
        tween:Play()
        tween.Completed:Connect(function()
            if not isOpen then MainFrame.Visible = false end
        end)
    end
end)




-- FARM TAB
local FarmScroll = Instance.new("ScrollingFrame", FarmContent)
FarmScroll.Size = UDim2.new(1,0,1,0)
FarmScroll.Position = UDim2.new(0,0,0,0)
FarmScroll.BackgroundTransparency = 1
FarmScroll.ScrollBarThickness = 6
FarmScroll.CanvasSize = UDim2.new(0,0,0,0)

local Layout = Instance.new("UIListLayout", FarmScroll)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0,10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local FarmTitle = Instance.new("TextLabel", FarmScroll)
FarmTitle.Size = UDim2.new(1,0,0,30)
FarmTitle.BackgroundTransparency = 1
FarmTitle.Text = "Farm Controls"
FarmTitle.TextColor3 = Color3.fromRGB(255,255,255)
FarmTitle.TextSize = 18
FarmTitle.Font = Enum.Font.SourceSansBold

local function createFarmToggle(parent, text, initial)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 36)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.TextSize = 16
    label.Font = Enum.Font.SourceSans

    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0.28, -6, 1, 0)
    toggleBtn.Position = UDim2.new(0.72, 0, 0, 0)
    toggleBtn.TextSize = 16
    toggleBtn.Font = Enum.Font.SourceSansBold
    toggleBtn.Text = initial and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = initial and Color3.fromRGB(60,140,60) or Color3.fromRGB(120,120,120)
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.AutoButtonColor = false

    local state = initial
    local onToggle = function(newState) end

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(60,140,60) or Color3.fromRGB(120,120,120)
        onToggle(state)
    end)

    local obj = {}
    function obj:SetCallback(fn) onToggle = fn end
    function obj:SetState(s)
        state = s
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(60,140,60) or Color3.fromRGB(120,120,120)
    end
    return obj
end

-- State-Variable
local radiusFarmEnabled = false
local areaFarmEnabled = false
local autoCollectEnabled = false
local farmRadius = 50
local selectedArea = nil
local player = game.Players.LocalPlayer

local radiusToggle = createFarmToggle(FarmScroll, "Radius Farm", false)
radiusToggle:SetCallback(function(state)
    radiusFarmEnabled = state
end)

local areaToggle = createFarmToggle(FarmScroll, "Area Farm", false)
areaToggle:SetCallback(function(state)
    areaFarmEnabled = state
end)

local autoCollectToggle = createFarmToggle(FarmScroll, "Auto Collect", false)
autoCollectToggle:SetCallback(function(state)
    autoCollectEnabled = state
end)

-- Farm Radius Input
local radiusFrame = Instance.new("Frame", FarmScroll)
radiusFrame.Size = UDim2.new(1, -20, 0, 30)
radiusFrame.BackgroundTransparency = 1

local radiusLabel = Instance.new("TextLabel", radiusFrame)
radiusLabel.Size = UDim2.new(0.5,0,1,0)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Text = "Farm Radius:"
radiusLabel.TextColor3 = Color3.fromRGB(255,255,255)
radiusLabel.TextSize = 16
radiusLabel.Font = Enum.Font.SourceSans

local radiusBox = Instance.new("TextBox", radiusFrame)
radiusBox.Size = UDim2.new(0.48,0,1,0)
radiusBox.Position = UDim2.new(0.52,0,0,0)
radiusBox.BackgroundColor3 = Color3.fromRGB(70,70,70)
radiusBox.TextColor3 = Color3.fromRGB(255,255,255)
radiusBox.Text = "50"
radiusBox.ClearTextOnFocus = false

radiusBox:GetPropertyChangedSignal("Text"):Connect(function()
    local value = tonumber(radiusBox.Text)
    if value then farmRadius = value end
end)

-- Area Dropdown
local areaDropdown = Instance.new("TextButton", FarmScroll)
areaDropdown.Size = UDim2.new(1, -20, 0, 30)
areaDropdown.BackgroundColor3 = Color3.fromRGB(70,70,70)
areaDropdown.TextColor3 = Color3.fromRGB(255,255,255)
areaDropdown.Text = "Select Area"

local areaMenu
areaDropdown.MouseButton1Click:Connect(function()
    if areaMenu then
        areaMenu:Destroy()
        areaMenu = nil
        return
    end
    local coinsFolder = workspace.__THINGS:FindFirstChild("Coins")
    if not coinsFolder then return end
    local areaSet = {}
    for _, coin in pairs(coinsFolder:GetChildren()) do
        local area = coin:GetAttribute("Area")
        if area then areaSet[area] = true end
    end
    local list = {}
    for areaName in pairs(areaSet) do table.insert(list, areaName) end
    table.sort(list)

    areaMenu = Instance.new("ScrollingFrame", FarmScroll)
    areaMenu.Size = UDim2.new(1, -40, 0, math.min(#list*25,200))
    areaMenu.Position = areaDropdown.Position + UDim2.new(0,0,0,areaDropdown.AbsoluteSize.Y)
    areaMenu.BackgroundColor3 = Color3.fromRGB(60,60,60)
    areaMenu.CanvasSize = UDim2.new(0,0,0,#list*25)
    areaMenu.ScrollBarThickness = 6

    for i, areaName in pairs(list) do
        local btn = Instance.new("TextButton", areaMenu)
        btn.Size = UDim2.new(1,0,0,25)
        btn.Position = UDim2.new(0,0,0,(i-1)*25)
        btn.Text = areaName
        btn.BackgroundColor3 = Color3.fromRGB(100,100,100)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.MouseButton1Click:Connect(function()
            selectedArea = areaName
            areaDropdown.Text = areaName
            areaMenu:Destroy()
            areaMenu = nil
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        local petsFolder = workspace.__THINGS:WaitForChild("Pets")
        local coinsFolder = workspace.__THINGS:FindFirstChild("Coins")
        if not coinsFolder then continue end

        local myPets = {}
        for _, pet in pairs(petsFolder:GetChildren()) do
            local owner = pet:GetAttribute("Owner")
            if owner == player or owner == player.Name or tostring(owner) == tostring(player.UserId) or tostring(owner):find(player.Name) then
                table.insert(myPets, pet.Name)
            end
        end

        -- Radius Farm
        if radiusFarmEnabled then
            local availableCoins = {}
            for _, coin in pairs(coinsFolder:GetChildren()) do
                if coin:FindFirstChild("POS") then
                    local distance = (player.Character.PrimaryPart.Position - coin.POS.Position).Magnitude
                    if distance <= farmRadius then
                        table.insert(availableCoins, coin)
                    end
                end
            end
            for i, petId in pairs(myPets) do
                local coin = availableCoins[i]
                if coin then
                    local coinId = coin.Name
                    local joinArgs = {{{coinId,{petId}},{false,false}}}
                    pcall(function() workspace.__THINGS.__REMOTES["join coin"]:InvokeServer(unpack(joinArgs)) end)
                    local farmArgs = {{{coinId,petId},{false,false}}}
                    pcall(function() workspace.__THINGS.__REMOTES["ur_lame_xd"]:FireServer(unpack(farmArgs)) end)
                end
            end
        end

        -- Area Farm
        if areaFarmEnabled and selectedArea then
            local availableCoins = {}
            for _, coin in pairs(coinsFolder:GetChildren()) do
                if coin:GetAttribute("Area") == selectedArea then
                    table.insert(availableCoins, coin)
                end
            end
            for i, petId in pairs(myPets) do
                local coin = availableCoins[i]
                if coin then
                    local coinId = coin.Name
                    local joinArgs = {{{coinId,{petId}},{false,false}}}
                    pcall(function() workspace.__THINGS.__REMOTES["join coin"]:InvokeServer(unpack(joinArgs)) end)
                    local farmArgs = {{{coinId, petId},{false,false}}}
                    pcall(function() workspace.__THINGS.__REMOTES["ur_lame_xd"]:FireServer(unpack(farmArgs)) end)
                end
            end
        end

        -- Auto Collect
        if autoCollectEnabled then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local orbs = workspace.__THINGS:FindFirstChild("Orbs")
                if orbs then
                    for _, orb in pairs(orbs:GetChildren()) do
                        if orb:IsA("BasePart") then
                            orb.CFrame = hrp.CFrame
                        elseif orb:IsA("Model") and orb.PrimaryPart then
                            orb:SetPrimaryPartCFrame(hrp.CFrame)
                        end
                    end
                end
                local lootbags = workspace.__THINGS:FindFirstChild("Lootbags")
                if lootbags then
                    for _, bag in pairs(lootbags:GetChildren()) do
                        if bag:IsA("BasePart") then
                            bag.CFrame = hrp.CFrame
                        elseif bag:IsA("Model") and bag.PrimaryPart then
                            bag:SetPrimaryPartCFrame(hrp.CFrame)
                        end
                    end
                end
            end
        end
    end
end)

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    FarmScroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
end)



-- Slow Farm Tab
local SlowTabButton = createTabButton("Slow Farm")
local SlowContent = createTabContent("Slow Farm")
SlowTabButton.MouseButton1Click:Connect(function()
    showTab("Slow Farm")
end)

local SlowTitle = Instance.new("TextLabel", SlowContent)
SlowTitle.Size = UDim2.new(1, -20, 0, 30)
SlowTitle.Position = UDim2.new(0, 10, 0, 10)
SlowTitle.BackgroundTransparency = 1
SlowTitle.Text = "Slow Farm Controls"
SlowTitle.TextColor3 = Color3.fromRGB(255,255,255)
SlowTitle.TextSize = 18
SlowTitle.Font = Enum.Font.SourceSansBold
SlowTitle.TextXAlignment = Enum.TextXAlignment.Left

local SlowScroll = Instance.new("ScrollingFrame", SlowContent)
SlowScroll.Size = UDim2.new(1, 0, 1, -40)
SlowScroll.Position = UDim2.new(0, 0, 0, 40)
SlowScroll.BackgroundTransparency = 1
SlowScroll.ScrollBarThickness = 6
SlowScroll.CanvasSize = UDim2.new(0,0,0,0)

local Layout = Instance.new("UIListLayout", SlowScroll)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0,10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createSlowToggle(parent, text, initial)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 36)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.TextSize = 16
    label.Font = Enum.Font.SourceSans

    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0.28, -6, 1, 0)
    toggleBtn.Position = UDim2.new(0.72, 0, 0, 0)
    toggleBtn.TextSize = 16
    toggleBtn.Font = Enum.Font.SourceSansBold
    toggleBtn.Text = initial and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = initial and Color3.fromRGB(60,140,60) or Color3.fromRGB(120,120,120)
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.AutoButtonColor = false

    local state = initial
    local onToggle = function(newState) end

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(60,140,60) or Color3.fromRGB(120,120,120)
        onToggle(state)
    end)

    local obj = {}
    function obj:SetCallback(fn) onToggle = fn end
    function obj:SetState(s)
        state = s
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(60,140,60) or Color3.fromRGB(120,120,120)
    end
    return obj
end

-- State-Variablen
local slowRadiusEnabled = false
local slowAreaEnabled = false
local slowChestEnabled = false
local slowAutoCollectEnabled = false
local slowFarmRadius = 50
local selectedSlowArea = nil
local selectedSlowChest = nil
local player = game.Players.LocalPlayer

local radiusToggle = createSlowToggle(SlowScroll, "Radius Farm", false)
radiusToggle:SetCallback(function(state) slowRadiusEnabled = state end)

local areaToggle = createSlowToggle(SlowScroll, "Area Farm", false)
areaToggle:SetCallback(function(state) slowAreaEnabled = state end)

local chestToggle = createSlowToggle(SlowScroll, "Chest Farm", false)
chestToggle:SetCallback(function(state) slowChestEnabled = state end)

local autoCollectToggle = createSlowToggle(SlowScroll, "Auto Collect", false)
autoCollectToggle:SetCallback(function(state) slowAutoCollectEnabled = state end)

-- Radius Box
local radiusFrame = Instance.new("Frame", SlowScroll)
radiusFrame.Size = UDim2.new(1, -20, 0, 30)
radiusFrame.BackgroundTransparency = 1

local radiusLabel = Instance.new("TextLabel", radiusFrame)
radiusLabel.Size = UDim2.new(0.5,0,1,0)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Text = "Farm Radius:"
radiusLabel.TextColor3 = Color3.fromRGB(255,255,255)
radiusLabel.TextSize = 16
radiusLabel.Font = Enum.Font.SourceSans

local radiusBox = Instance.new("TextBox", radiusFrame)
radiusBox.Size = UDim2.new(0.48,0,1,0)
radiusBox.Position = UDim2.new(0.52,0,0,0)
radiusBox.BackgroundColor3 = Color3.fromRGB(70,70,70)
radiusBox.TextColor3 = Color3.fromRGB(255,255,255)
radiusBox.Text = "50"
radiusBox.ClearTextOnFocus = false

radiusBox:GetPropertyChangedSignal("Text"):Connect(function()
    local value = tonumber(radiusBox.Text)
    if value then slowFarmRadius = value end
end)

-- Area Dropdown
local areaDropdown = Instance.new("TextButton", SlowScroll)
areaDropdown.Size = UDim2.new(1, -20, 0, 30)
areaDropdown.BackgroundColor3 = Color3.fromRGB(70,70,70)
areaDropdown.TextColor3 = Color3.fromRGB(255,255,255)
areaDropdown.Text = "Select Area"

local areaMenu = nil
areaDropdown.MouseButton1Click:Connect(function()
    if areaMenu then
        areaMenu:Destroy()
        areaMenu = nil
        return
    end
    local coinsFolder = workspace.__THINGS:FindFirstChild("Coins")
    if not coinsFolder then return end
    local areaSet = {}
    for _, coin in pairs(coinsFolder:GetChildren()) do
        local area = coin:GetAttribute("Area")
        if area then areaSet[area] = true end
    end
    local list = {}
    for name in pairs(areaSet) do table.insert(list, name) end
    table.sort(list)

    areaMenu = Instance.new("ScrollingFrame", SlowScroll)
    areaMenu.Size = UDim2.new(1, -40, 0, math.min(#list*25,200))
    areaMenu.Position = areaDropdown.Position + UDim2.new(0,0,0,areaDropdown.AbsoluteSize.Y)
    areaMenu.BackgroundColor3 = Color3.fromRGB(60,60,60)
    areaMenu.CanvasSize = UDim2.new(0,0,0,#list*25)
    areaMenu.ScrollBarThickness = 6

    for i, name in pairs(list) do
        local btn = Instance.new("TextButton", areaMenu)
        btn.Size = UDim2.new(1,0,0,25)
        btn.Position = UDim2.new(0,0,0,(i-1)*25)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(100,100,100)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.MouseButton1Click:Connect(function()
            selectedSlowArea = name
            areaDropdown.Text = name
            areaMenu:Destroy()
            areaMenu = nil
        end)
    end
end)

-- Chest Dropdown
local chestDropdown = Instance.new("TextButton", SlowScroll)
chestDropdown.Size = UDim2.new(1, -20, 0, 30)
chestDropdown.BackgroundColor3 = Color3.fromRGB(70,70,70)
chestDropdown.TextColor3 = Color3.fromRGB(255,255,255)
chestDropdown.Text = "Select Chest"

local chestMenu = nil
chestDropdown.MouseButton1Click:Connect(function()
    if chestMenu then
        chestMenu:Destroy()
        chestMenu = nil
        return
    end
    local coinsFolder = workspace.__THINGS:FindFirstChild("Coins")
    if not coinsFolder then return end
    local chestSet = {}
    for _, coin in pairs(coinsFolder:GetChildren()) do
        local name = coin:GetAttribute("Name")
        if name and name:find("Chest") then chestSet[name] = true end
    end
    local list = {}
    for name in pairs(chestSet) do table.insert(list, name) end
    table.sort(list)

    chestMenu = Instance.new("ScrollingFrame", SlowScroll)
    chestMenu.Size = UDim2.new(1, -40, 0, math.min(#list*25,200))
    chestMenu.Position = chestDropdown.Position + UDim2.new(0,0,0,chestDropdown.AbsoluteSize.Y)
    chestMenu.BackgroundColor3 = Color3.fromRGB(60,60,60)
    chestMenu.CanvasSize = UDim2.new(0,0,0,#list*25)
    chestMenu.ScrollBarThickness = 6

    for i, name in pairs(list) do
        local btn = Instance.new("TextButton", chestMenu)
        btn.Size = UDim2.new(1,0,0,25)
        btn.Position = UDim2.new(0,0,0,(i-1)*25)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(100,100,100)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.MouseButton1Click:Connect(function()
            selectedSlowChest = name
            chestDropdown.Text = name
            chestMenu:Destroy()
            chestMenu = nil
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5) 
        local petsFolder = workspace.__THINGS:WaitForChild("Pets")
        local coinsFolder = workspace.__THINGS:FindFirstChild("Coins")
        if not coinsFolder then continue end

        local myPets = {}
        for _, pet in pairs(petsFolder:GetChildren()) do
            local owner = pet:GetAttribute("Owner")
            if owner == player or owner == player.Name or tostring(owner) == tostring(player.UserId) or tostring(owner):find(player.Name) then
                table.insert(myPets, pet.Name)
            end
        end

        -- Radius Farm
        if slowRadiusEnabled then
            local availableCoins = {}
            for _, coin in pairs(coinsFolder:GetChildren()) do
                if coin:FindFirstChild("POS") then
                    local distance = (player.Character.PrimaryPart.Position - coin.POS.Position).Magnitude
                    if distance <= slowFarmRadius then
                        table.insert(availableCoins, coin)
                    end
                end
            end
            for _, coin in pairs(availableCoins) do
                local joinArgs = {{{coin.Name, myPets},{false,false}}}
                pcall(function() workspace.__THINGS.__REMOTES["join coin"]:InvokeServer(unpack(joinArgs)) end)
                for _, petId in pairs(myPets) do
                    local farmArgs = {{{coin.Name, petId},{false,false}}}
                    pcall(function() workspace.__THINGS.__REMOTES["ur_lame_xd"]:FireServer(unpack(farmArgs)) end)
                end
            end
        end

        -- Area Farm
        if slowAreaEnabled and selectedSlowArea then
            local availableCoins = {}
            for _, coin in pairs(coinsFolder:GetChildren()) do
                if coin:GetAttribute("Area") == selectedSlowArea then
                    table.insert(availableCoins, coin)
                end
            end
            for _, coin in pairs(availableCoins) do
                local joinArgs = {{{coin.Name, myPets},{false,false}}}
                pcall(function() workspace.__THINGS.__REMOTES["join coin"]:InvokeServer(unpack(joinArgs)) end)
                for _, petId in pairs(myPets) do
                    local farmArgs = {{{coin.Name, petId},{false,false}}}
                    pcall(function() workspace.__THINGS.__REMOTES["ur_lame_xd"]:FireServer(unpack(farmArgs)) end)
                end
            end
        end

        -- Chest Farm
        if slowChestEnabled and selectedSlowChest then
            local availableCoins = {}
            for _, coin in pairs(coinsFolder:GetChildren()) do
                if coin:GetAttribute("Name") == selectedSlowChest then
                    table.insert(availableCoins, coin)
                end
            end
            for _, coin in pairs(availableCoins) do
                local joinArgs = {{{coin.Name, myPets},{false,false}}}
                pcall(function() workspace.__THINGS.__REMOTES["join coin"]:InvokeServer(unpack(joinArgs)) end)
                for _, petId in pairs(myPets) do
                    local farmArgs = {{{coin.Name, petId},{false,false}}}
                    pcall(function() workspace.__THINGS.__REMOTES["ur_lame_xd"]:FireServer(unpack(farmArgs)) end)
                end
            end
        end

        -- Auto Collect
        if slowAutoCollectEnabled then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local orbs = workspace.__THINGS:FindFirstChild("Orbs")
                if orbs then
                    for _, orb in pairs(orbs:GetChildren()) do
                        if orb:IsA("BasePart") then
                            orb.CFrame = hrp.CFrame
                        elseif orb:IsA("Model") and orb.PrimaryPart then
                            orb:SetPrimaryPartCFrame(hrp.CFrame)
                        end
                    end
                end
                local lootbags = workspace.__THINGS:FindFirstChild("Lootbags")
                if lootbags then
                    for _, bag in pairs(lootbags:GetChildren()) do
                        if bag:IsA("BasePart") then
                            bag.CFrame = hrp.CFrame
                        elseif bag:IsA("Model") and bag.PrimaryPart then
                            bag:SetPrimaryPartCFrame(hrp.CFrame)
                        end
                    end
                end
            end
        end
    end
end)

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SlowScroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
end)



-- ==== Eggs Tab ====
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EggsFolder = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Eggs")
local Remotes = workspace:WaitForChild("__THINGS"):WaitForChild("__REMOTES")

local EggsTabButton = createTabButton("Eggs")
local EggsContent = createTabContent("Eggs")

local header = Instance.new("TextLabel", EggsContent)
header.Size = UDim2.new(1,0,0,30)
header.Position = UDim2.new(0,10,0,10)
header.BackgroundTransparency = 1
header.Text = "Egg Controls"
header.TextColor3 = Color3.fromRGB(255,255,255)
header.TextSize = 18
header.Font = Enum.Font.SourceSansBold
header.ZIndex = 1

local EggsScroll = Instance.new("ScrollingFrame", EggsContent)
EggsScroll.Size = UDim2.new(1,0,1,-40)
EggsScroll.Position = UDim2.new(0,0,0,40)
EggsScroll.BackgroundTransparency = 1
EggsScroll.ScrollBarThickness = 6
EggsScroll.CanvasSize = UDim2.new(0,0,0,0)

local Layout = Instance.new("UIListLayout", EggsScroll)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0,10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createEggToggle(parent, text, initial)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 36)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.TextSize = 16
    label.Font = Enum.Font.SourceSans
    label.ZIndex = 1

    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0.28, -6, 1, 0)
    toggleBtn.Position = UDim2.new(0.72, 0, 0, 0)
    toggleBtn.TextSize = 16
    toggleBtn.Font = Enum.Font.SourceSansBold
    toggleBtn.Text = initial and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = initial and Color3.fromRGB(60,140,60) or Color3.fromRGB(120,120,120)
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.AutoButtonColor = false
    toggleBtn.ZIndex = 2 

    local state = initial
    local onToggle = function(newState) end

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(60,140,60) or Color3.fromRGB(120,120,120)
        onToggle(state)
    end)

    local obj = {}
    function obj:SetCallback(fn) onToggle = fn end
    function obj:SetState(s)
        state = s
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(60,140,60) or Color3.fromRGB(120,120,120)
    end
    return obj
end

local function createDropdown(parent, title, options, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 36)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7,0,1,0)
    label.Position = UDim2.new(0,6,0,0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.TextSize = 16
    label.Font = Enum.Font.SourceSans
    label.ZIndex = 1

    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(0.28, -6, 1, 0)
    button.Position = UDim2.new(0.72,0,0,0)
    button.Text = "Select"
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.BackgroundColor3 = Color3.fromRGB(70,70,70)
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.AutoButtonColor = false
    button.ZIndex = 2 

    local menuOpen = false
    local menuFrame

    button.MouseButton1Click:Connect(function()
        if menuOpen then
            if menuFrame then menuFrame:Destroy() end
            menuOpen = false
            return
        end

        menuFrame = Instance.new("ScrollingFrame", frame)
        menuFrame.Size = UDim2.new(1, 0, 0, math.min(#options*25, 200))
        menuFrame.Position = UDim2.new(0, 0, 1, 0)
        menuFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        menuFrame.CanvasSize = UDim2.new(0, 0, 0, #options*25)
        menuFrame.ScrollBarThickness = 6
        menuFrame.BorderSizePixel = 0
        menuFrame.ClipsDescendants = true
        menuFrame.ZIndex = 3 

        for i, opt in ipairs(options) do
            local btn = Instance.new("TextButton", menuFrame)
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.Position = UDim2.new(0, 0, 0, (i-1)*25)
            btn.Text = opt
            btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 16
            btn.ZIndex = 4 
            btn.MouseButton1Click:Connect(function()
                button.Text = opt
                callback(opt)
                menuFrame:Destroy()
                menuOpen = false
            end)
        end

        menuOpen = true
    end)
end

-- Spawn Eggs
for _, category in pairs(EggsFolder:GetChildren()) do
    if category:IsA("Folder") then
        local eggList = { "None" }
        for _, egg in pairs(category:GetChildren()) do
            if egg:IsA("Folder") then
                table.insert(eggList, egg.Name)
            end
        end

        local selectedEgg = "None"
        local autoHatch = false

        createDropdown(EggsScroll, category.Name, eggList, function(opt)
            selectedEgg = opt
        end)

        local toggle = createEggToggle(EggsScroll, "Auto Hatch " .. category.Name, false)
        toggle:SetCallback(function(state)
            autoHatch = state
            if state then
                task.spawn(function()
                    while autoHatch do
                        if selectedEgg ~= "None" then
                            local args = {
                                {
                                    {selectedEgg,true,false},
                                    {false,false,false}
                                }
                            }
                            pcall(function()
                                if Remotes:FindFirstChild("buy egg") and Remotes["buy egg"].InvokeServer then
                                    Remotes["buy egg"]:InvokeServer(unpack(args))
                                end
                            end)
                        end
                        task.wait()
                    end
                end)
            end
        end)
    end
end

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    EggsScroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
end)

EggsTabButton.MouseButton1Click:Connect(function()
    showTab("Eggs")
end)