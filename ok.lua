local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TabbedGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

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
Title.Text = "The only working GUI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.SourceSansBold

local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Name = "TabFrame"
TabFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TabFrame.Size = UDim2.new(0, 140, 1, -38)
TabFrame.Position = UDim2.new(0, 0, 0, 38)

local UIListLayout = Instance.new("UIListLayout", TabFrame)
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Name = "ContentFrame"
ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ContentFrame.Size = UDim2.new(1, -140, 1, -38)
ContentFrame.Position = UDim2.new(0, 140, 0, 38)

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

local MainTabButton = createTabButton("Main")
local FarmTabButton = createTabButton("Farm")

local Tabs = {}
local function createTabContent(name)
    local tab = Instance.new("Frame", ContentFrame)
    tab.Name = name .. "Content"
    tab.BackgroundTransparency = 1
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.Visible = false
    Tabs[name] = tab
    return tab
end

local MainContent = createTabContent("Main")
local FarmContent = createTabContent("Farm")

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

local autoRank = false
local autoOrbs = false

local rankToggle = createToggle(TogglesList, "Auto Collect Rank Rewards", false)
rankToggle:SetCallback(function(state)
    autoRank = state
    if state then
        task.spawn(function()
            while autoRank do
                local success, err = pcall(function()
                    local args = {
                        {
                            { false },
                            { 2 }
                        }
                    }
                    if workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("__REMOTES") then
                        local remotes = workspace.__THINGS.__REMOTES
                        local remote = remotes:FindFirstChild("redeem rank rewards")
                        if remote and remote.InvokeServer then
                            remote:InvokeServer(unpack(args))
                        end
                    end
                end)
                if not success then

                end
                task.wait(10)
            end
        end)
    end
end)


local orbsToggle = createToggle(TogglesList, "Auto Collect Orbs", false)
orbsToggle:SetCallback(function(state)
    autoOrbs = state
    if state then
        task.spawn(function()
            while autoOrbs do
                local ok, _ = pcall(function()
                    local orbsFolder = workspace.__THINGS and workspace.__THINGS:FindFirstChild("Orbs")
                    if orbsFolder then
                        for _, orb in pairs(orbsFolder:GetChildren()) do
                            if orb and orb:IsA("Part") then
                                local args = {
                                    {
                                        { { orb.Name } },
                                        { false }
                                    }
                                }
                                if workspace.__THINGS and workspace.__THINGS.__REMOTES then
                                    local remotes = workspace.__THINGS.__REMOTES
                                    local remote = remotes:FindFirstChild("claim orbs")
                                    if remote and remote.FireServer then
                                        remote:FireServer(unpack(args))
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(2)
            end
        end)
    end
end)

local FarmLabel = Instance.new("TextLabel", FarmContent)
FarmLabel.Text = ""
FarmLabel.Size = UDim2.new(1, 0, 0, 30)
FarmLabel.Position = UDim2.new(0, 10, 0, 10)
FarmLabel.BackgroundTransparency = 1
FarmLabel.TextColor3 = Color3.fromRGB(255,255,255)
FarmLabel.TextSize = 16

local function showTab(name)
    for n, frame in pairs(Tabs) do
        frame.Visible = (n == name)
    end
end
showTab("Main")
MainTabButton.MouseButton1Click:Connect(function() showTab("Main") end)
FarmTabButton.MouseButton1Click:Connect(function() showTab("Farm") end)

local ButtonGui = Instance.new("Frame", ScreenGui)
ButtonGui.Name = "ButtonGui"
ButtonGui.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ButtonGui.Size = UDim2.new(0, 140, 0, 48)
ButtonGui.Position = UDim2.new(0.5, -70, 0.88, 0)
ButtonGui.ZIndex = 10

local ButtonLabel = Instance.new("TextButton", ButtonGui)
ButtonLabel.Name = "ButtonLabel"
ButtonLabel.Size = UDim2.new(1, 0, 1, 0)
ButtonLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ButtonLabel.Text = "Open GUI"
ButtonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ButtonLabel.TextSize = 18
ButtonLabel.Font = Enum.Font.SourceSansBold
ButtonLabel.AutoButtonColor = false

local function makeDraggable(frame, dragHandle, clickIndicator)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragInput, dragStart, startPos
    local moved = false

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        if not moved and (math.abs(delta.X) > 2 or math.abs(delta.Y) > 2) then
            moved = true
            pcall(function()
                dragHandle:SetAttribute("Moved", true)
                if clickIndicator then clickIndicator:SetAttribute("Moved", true) end
            end)
        end
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            moved = false
            pcall(function()
                dragHandle:SetAttribute("Moved", false)
                if clickIndicator then clickIndicator:SetAttribute("Moved", false) end
            end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
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

makeDraggable(MainFrame, MainFrame)

makeDraggable(ButtonGui, ButtonGui, ButtonLabel)

local isOpen = false
ButtonLabel.MouseButton1Click:Connect(function()
    local wasMoved = ButtonLabel:GetAttribute("Moved")
    if wasMoved then return end
    isOpen = not isOpen
    MainFrame.Visible = isOpen
    ButtonLabel.Text = isOpen and "Close GUI" or "Open GUI"
end)

-- ==== FARM TAB Inhalte ====
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

-- Überschrift
local FarmTitle = Instance.new("TextLabel", FarmScroll)
FarmTitle.Size = UDim2.new(1,0,0,30)
FarmTitle.BackgroundTransparency = 1
FarmTitle.Text = "Farm Controls"
FarmTitle.TextColor3 = Color3.fromRGB(255,255,255)
FarmTitle.TextSize = 18
FarmTitle.Font = Enum.Font.SourceSansBold

-- Toggle-Factory wie Main Tab
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

-- State-Variablen
local radiusFarmEnabled = false
local areaFarmEnabled = false
local autoCollectEnabled = false
local farmRadius = 50
local selectedArea = nil
local player = game.Players.LocalPlayer

-- ==== Toggles erstellen ====
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

-- ==== Farm Radius Input ====
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

-- ==== Area Dropdown ====
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

-- ==== AutoFarm Loops ====
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

-- Update ScrollFrame CanvasSize automatisch
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    FarmScroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
end)













-- ==== Slow Farm Tab erstellen ====
local SlowTabButton = createTabButton("Slow Farm")
local SlowContent = createTabContent("Slow Farm")
SlowTabButton.MouseButton1Click:Connect(function()
    showTab("Slow Farm")
end)


-- Überschrift
local SlowTitle = Instance.new("TextLabel", SlowContent)
SlowTitle.Size = UDim2.new(1, -20, 0, 30)
SlowTitle.Position = UDim2.new(0, 10, 0, 10)
SlowTitle.BackgroundTransparency = 1
SlowTitle.Text = "Slow Farm Controls"
SlowTitle.TextColor3 = Color3.fromRGB(255,255,255)
SlowTitle.TextSize = 18
SlowTitle.Font = Enum.Font.SourceSansBold
SlowTitle.TextXAlignment = Enum.TextXAlignment.Left

-- ScrollFrame
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

-- Toggle-Factory
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

-- Toggles
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

-- AutoFarm Loop (langsamer für weniger Lag)
task.spawn(function()
    while true do
        task.wait(0.1) -- langsamer als Standard
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

-- ScrollFrame CanvasSize automatisch anpassen
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SlowScroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
end)



-- ==== Eggs Tab ====
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EggsFolder = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Eggs")
local Remotes = workspace:WaitForChild("__THINGS"):WaitForChild("__REMOTES")

-- Tab-Button erstellen
local EggsTabButton = createTabButton("Eggs")
local EggsContent = createTabContent("Eggs")

-- Überschrift
local header = Instance.new("TextLabel", EggsContent)
header.Size = UDim2.new(1,0,0,30)
header.Position = UDim2.new(0,10,0,10)
header.BackgroundTransparency = 1
header.Text = "Egg Controls"
header.TextColor3 = Color3.fromRGB(255,255,255)
header.TextSize = 18
header.Font = Enum.Font.SourceSansBold
header.ZIndex = 1 -- Labels hinten

-- ScrollFrame für Toggles und Dropdowns
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

-- Toggle-Factory
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
    toggleBtn.ZIndex = 2 -- liegt vor Label

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

-- Dropdown-Factory
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
    button.ZIndex = 2 -- Button liegt VOR Label

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
        menuFrame.ZIndex = 3 -- Menü liegt über allem

        for i, opt in ipairs(options) do
            local btn = Instance.new("TextButton", menuFrame)
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.Position = UDim2.new(0, 0, 0, (i-1)*25)
            btn.Text = opt
            btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 16
            btn.ZIndex = 4 -- liegt ganz oben
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

-- ScrollFrame CanvasSize automatisch updaten
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    EggsScroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
end)

-- Tab aktivieren beim Klick
EggsTabButton.MouseButton1Click:Connect(function()
    showTab("Eggs")
end)







-- MACHINES TAB
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetsFolder = workspace:WaitForChild("__THINGS"):WaitForChild("Pets")
local SaveModule = require(ReplicatedStorage.Framework.Modules.Client:WaitForChild("4 | Save"))
local Remotes = workspace:WaitForChild("__THINGS"):WaitForChild("__REMOTES")

-- CONFIG
local EnchantsList = {"Coins", "Fantasy Coins", "Tech Coins", "Royalty", "Diamonds", "Rng Coins", "Agility", "Charm", "Chests", "Glittering", "Magnet", "Present", "Strength", "Teamwork"}
local AutoEnchantRunning = false

-- Tab Setup
local MachinesTabButton = createTabButton("Machines")
local MachinesContent = createTabContent("Machines")

-- Header
local header = Instance.new("TextLabel", MachinesContent)
header.Size = UDim2.new(1,0,0,30)
header.Position = UDim2.new(0,10,0,10)
header.BackgroundTransparency = 1
header.Text = "Machine Controls"
header.TextColor3 = Color3.fromRGB(255,255,255)
header.TextSize = 18
header.Font = Enum.Font.SourceSansBold

-- ScrollFrame
local MachinesScroll = Instance.new("ScrollingFrame", MachinesContent)
MachinesScroll.Size = UDim2.new(1,0,1,-40)
MachinesScroll.Position = UDim2.new(0,0,0,40)
MachinesScroll.BackgroundTransparency = 1
MachinesScroll.ScrollBarThickness = 6
MachinesScroll.CanvasSize = UDim2.new(0,0,0,0)

local Layout = Instance.new("UIListLayout", MachinesScroll)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0,10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- AUTO ENCHANT SECTION 
local EnchantToggles = {}
local EnchantLevels = {}

local EnchantHeader = Instance.new("TextLabel", MachinesScroll)
EnchantHeader.Size = UDim2.new(1, -20, 0, 30)
EnchantHeader.BackgroundTransparency = 1
EnchantHeader.Text = "Auto Enchant"
EnchantHeader.TextColor3 = Color3.fromRGB(255,255,0)
EnchantHeader.TextSize = 18
EnchantHeader.Font = Enum.Font.SourceSansBold

for _, enchant in ipairs(EnchantsList) do
    local frame = Instance.new("Frame", MachinesScroll)
    frame.Size = UDim2.new(1, -20, 0, 36)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6,0,1,0)
    label.Position = UDim2.new(0,0,0,0)
    label.BackgroundTransparency = 1
    label.Text = enchant
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.TextSize = 16
    label.Font = Enum.Font.SourceSans

    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0.2,0,1,0)
    toggleBtn.Position = UDim2.new(0.6,5,0,0)
    toggleBtn.Text = "OFF"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(120,120,120)
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.TextSize = 16
    toggleBtn.Font = Enum.Font.SourceSansBold
    toggleBtn.AutoButtonColor = false

    local state = false
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(60,140,60) or Color3.fromRGB(120,120,120)
        EnchantToggles[enchant] = state
    end)
    EnchantToggles[enchant] = false

    local levelBox = Instance.new("TextBox", frame)
    levelBox.Text = ""
    levelBox.Size = UDim2.new(0.18,0,1,0)
    levelBox.Position = UDim2.new(0.81,0,0,0)
    levelBox.BackgroundColor3 = Color3.fromRGB(70,70,70)
    levelBox.TextColor3 = Color3.fromRGB(255,255,255)
    levelBox.PlaceholderText = "Lvl"
    levelBox.ClearTextOnFocus = false
    levelBox.TextScaled = true
    levelBox.FocusLost:Connect(function()
        local num = tonumber(levelBox.Text)
        if num then
            EnchantLevels[enchant] = num
        else
            levelBox.Text = ""
            EnchantLevels[enchant] = nil
        end
    end)
end

-- Start/Stop Button für AutoEnchant
local startBtn = Instance.new("TextButton", MachinesScroll)
startBtn.Size = UDim2.new(1, -20, 0, 40)
startBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
startBtn.Text = "Start AutoEnchant"
startBtn.TextSize = 16
startBtn.Font = Enum.Font.SourceSansBold
startBtn.TextColor3 = Color3.fromRGB(255,255,255)
startBtn.Parent = MachinesScroll

startBtn.MouseButton1Click:Connect(function()
    AutoEnchantRunning = not AutoEnchantRunning
    startBtn.Text = AutoEnchantRunning and "Stop AutoEnchant" or "Start AutoEnchant"

    if AutoEnchantRunning then
        for _, pet in ipairs(PetsFolder:GetChildren()) do
            if pet:GetAttribute("Owner") == LocalPlayer.Name then
                task.spawn(function()
                    local petFinished = false
                    while AutoEnchantRunning and not petFinished do
                        local SaveData = SaveModule.Get(LocalPlayer)
                        if not SaveData or not SaveData.Pets then break end
                        local petSave
                        for _, p in ipairs(SaveData.Pets) do
                            if p.uid == (pet:GetAttribute("ID") or pet.Name) then petSave = p break end
                        end
                        if petSave then
                            local done = false
                            for enchant, lvl in pairs(EnchantLevels) do
                                if EnchantToggles[enchant] then
                                    for _, power in ipairs(petSave.powers) do
                                        if power[1] == enchant and power[2] == lvl then
                                            done = true
                                        end
                                    end
                                end
                            end
                            if done then
                                petFinished = true
                            else
                                local args = {{{petSave.uid},{false}}}
                                pcall(function()
                                    if Remotes:FindFirstChild("enchant pet") then
                                        local r = Remotes["enchant pet"]
                                        if r.ClassName == "RemoteFunction" then
                                            r:InvokeServer(unpack(args))
                                        else
                                            r:FireServer(unpack(args))
                                        end
                                    end
                                end)
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end
    end
end)

-- AUTO CRAFT SECTION 
local CraftHeader = Instance.new("TextLabel", MachinesScroll)
CraftHeader.Size = UDim2.new(1, -20, 0, 30)
CraftHeader.BackgroundTransparency = 1
CraftHeader.Text = "AutoCraft"
CraftHeader.TextColor3 = Color3.fromRGB(255,200,50)
CraftHeader.TextSize = 18
CraftHeader.Font = Enum.Font.SourceSansBold

local PetCountLabel = Instance.new("TextLabel", MachinesScroll)
PetCountLabel.Size = UDim2.new(1, -20, 0, 25)
PetCountLabel.BackgroundTransparency = 1
PetCountLabel.Text = "Pets per Craft (1–6):"
PetCountLabel.TextColor3 = Color3.fromRGB(255,255,255)
PetCountLabel.TextSize = 16
PetCountLabel.Font = Enum.Font.SourceSans

local PetCountBox = Instance.new("TextBox", MachinesScroll)
PetCountBox.Size = UDim2.new(1, -20, 0, 30)
PetCountBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
PetCountBox.TextColor3 = Color3.fromRGB(255,255,255)
PetCountBox.Font = Enum.Font.SourceSans
PetCountBox.TextSize = 16
PetCountBox.ClearTextOnFocus = false
PetCountBox.Text = "6"

local GoldToggle = Instance.new("TextButton", MachinesScroll)
GoldToggle.Size = UDim2.new(1, -20, 0, 40)
GoldToggle.BackgroundColor3 = Color3.fromRGB(120, 0, 250)
GoldToggle.TextColor3 = Color3.fromRGB(255,255,255)
GoldToggle.Font = Enum.Font.SourceSansBold
GoldToggle.TextSize = 18
GoldToggle.Text = "Gold: OFF"

local RainbowToggle = Instance.new("TextButton", MachinesScroll)
RainbowToggle.Size = UDim2.new(1, -20, 0, 40)
RainbowToggle.BackgroundColor3 = Color3.fromRGB(250,140,0)
RainbowToggle.TextColor3 = Color3.fromRGB(255,255,255)
RainbowToggle.Font = Enum.Font.SourceSansBold
RainbowToggle.TextSize = 18
RainbowToggle.Text = "Rainbow: OFF"

local GoldActive, RainbowActive = false, false

GoldToggle.MouseButton1Click:Connect(function()
    GoldActive = not GoldActive
    GoldToggle.Text = "Gold: "..(GoldActive and "ON" or "OFF")
    GoldToggle.BackgroundColor3 = GoldActive and Color3.fromRGB(80,200,80) or Color3.fromRGB(120,0,250)
end)

RainbowToggle.MouseButton1Click:Connect(function()
    RainbowActive = not RainbowActive
    RainbowToggle.Text = "Rainbow: "..(RainbowActive and "ON" or "OFF")
    RainbowToggle.BackgroundColor3 = RainbowActive and Color3.fromRGB(80,200,80) or Color3.fromRGB(250,140,0)
end)

-- Helper: send payload robust (FireServer if RemoteEvent, otherwise InvokeServer batched)
local function sendPayloadsBatched(machineRemote, payloads)
    if not machineRemote then return end

    if machineRemote.ClassName == "RemoteEvent" then
        -- RemoteEvent: safe to fire all quickly (async)
        for _, payload in ipairs(payloads) do
            task.spawn(function()
                pcall(function() machineRemote:FireServer(payload) end)
            end)
        end
    elseif machineRemote.ClassName == "RemoteFunction" then
        -- RemoteFunction: batch to avoid freezing
        local maxParallel = 10
        for i = 1, #payloads, maxParallel do
            for j = i, math.min(i + maxParallel - 1, #payloads) do
                task.spawn(function()
                    pcall(function() machineRemote:InvokeServer(payloads[j]) end)
                end)
            end
            task.wait(0.06) -- tiny pause between waves
        end
    else
        -- fallback: try InvokeServer for each
        for _, payload in ipairs(payloads) do
            task.spawn(function()
                pcall(function() 
                    if machineRemote.InvokeServer then
                        machineRemote:InvokeServer(payload)
                    elseif machineRemote.FireServer then
                        machineRemote:FireServer(payload)
                    end
                end)
            end)
        end
    end
end

-- craftAll: gruppiert Save.Pets nach pet.id, macht Packs der gewählten Größe und sendet sie
local function craftAll(isGold)
    local SaveData = SaveModule.Get(LocalPlayer)
    if not SaveData or not SaveData.Pets then return end

    local count = tonumber(PetCountBox.Text) or 6
    if count < 1 or count > 6 then count = 6 end

    local machineRemote = isGold and Remotes:FindFirstChild("use golden machine") or Remotes:FindFirstChild("use rainbow machine")
    if not machineRemote then return end

    local petsByID = {}
    for _, pet in ipairs(SaveData.Pets) do
        if pet.id then
            if isGold then
                if not pet.g and not pet.r and not pet.dm then
                    petsByID[pet.id] = petsByID[pet.id] or {}
                    table.insert(petsByID[pet.id], pet)
                end
            else
                if pet.g then
                    petsByID[pet.id] = petsByID[pet.id] or {}
                    table.insert(petsByID[pet.id], pet)
                end
            end
        end
    end

    local allPayloads = {}
    for petID, pets in pairs(petsByID) do
        local totalPacks = math.floor(#pets / count)
        for i = 0, totalPacks - 1 do
            local pack = {}
            for j = 1, count do
                table.insert(pack, pets[i * count + j].uid)
            end
            local payload = {{pack}, {false}} -- korrekte Struktur
            table.insert(allPayloads, payload)
        end
    end

    -- send payloads (batched or instant, je nach Remotetype)
    if #allPayloads > 0 then
        sendPayloadsBatched(machineRemote, allPayloads)
    end
end

-- Loop für aktive Toggles (wenn ON -> craftAll)
task.spawn(function()
    while true do
        if GoldActive then craftAll(true) end
        if RainbowActive then craftAll(false) end
        task.wait(0.6)
    end
end)

-- Dynamische ScrollSize
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    MachinesScroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
end)

MachinesTabButton.MouseButton1Click:Connect(function()
    showTab("Machines")
end)




-- ==== Misc Tab ====
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SaveModule = require(ReplicatedStorage.Framework.Modules.Client:WaitForChild("4 | Save"))
local Remotes = Workspace:WaitForChild("__THINGS"):WaitForChild("__REMOTES")
local BuyEggRemote = Remotes:WaitForChild("buy egg")
local DeletePetsRemote = Remotes:WaitForChild("delete several pets")

-- === Tab-Erstellung ===
local MiscTabButton = createTabButton("Misc")
local MiscContent = createTabContent("Misc")

-- === Überschrift ===
local header = Instance.new("TextLabel", MiscContent)
header.Size = UDim2.new(1,0,0,30)
header.Position = UDim2.new(0,10,0,10)
header.BackgroundTransparency = 1
header.Text = "Misc Features"
header.TextColor3 = Color3.fromRGB(255,255,255)
header.TextSize = 18
header.Font = Enum.Font.SourceSansBold

-- === ScrollFrame ===
local MiscScroll = Instance.new("ScrollingFrame", MiscContent)
MiscScroll.Size = UDim2.new(1,0,1,-40)
MiscScroll.Position = UDim2.new(0,0,0,40)
MiscScroll.BackgroundTransparency = 1
MiscScroll.ScrollBarThickness = 6
MiscScroll.CanvasSize = UDim2.new(0,0,0,0)

local Layout = Instance.new("UIListLayout", MiscScroll)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0,10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- === Auto-Hatch Steuerung ===
local EggName = "Grim Eggz"
local TargetPetID = "1215"
local HatchDelay = 0.3
local Running = false
local EggsHatched = 0

local hatchLabel = Instance.new("TextLabel", MiscScroll)
hatchLabel.Size = UDim2.new(1, -20, 0, 30)
hatchLabel.BackgroundTransparency = 1
hatchLabel.TextColor3 = Color3.fromRGB(255,255,255)
hatchLabel.Text = "Eggs gehatcht: 0"
hatchLabel.Font = Enum.Font.SourceSans
hatchLabel.TextSize = 16

local startBtn = Instance.new("TextButton", MiscScroll)
startBtn.Size = UDim2.new(1, -20, 0, 36)
startBtn.BackgroundColor3 = Color3.fromRGB(50,200,50)
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Text = "Start Auto Hatch"
startBtn.Font = Enum.Font.SourceSansBold
startBtn.TextSize = 18

local stopBtn = Instance.new("TextButton", MiscScroll)
stopBtn.Size = UDim2.new(1, -20, 0, 36)
stopBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.Text = "Stop Auto Hatch"
stopBtn.Font = Enum.Font.SourceSansBold
stopBtn.TextSize = 18

-- === Funktionen ===
local function DeletePet(petUID)
    local args = {
        { { {petUID} }, {false} }
    }
    DeletePetsRemote:InvokeServer(unpack(args))
end

local function CheckNewPets()
    local SaveData = SaveModule.Get(LocalPlayer)
    if not SaveData or not SaveData.Pets then return end
    for _, pet in ipairs(SaveData.Pets) do
        if pet.id == TargetPetID then
            if not pet.r and not pet.dm then
                DeletePet(pet.uid)
            end
        end
    end
end

local function AutoHatchLoop()
    while Running do
        local args = {
            { { EggName, true, false }, { false, false, false } }
        }
        BuyEggRemote:InvokeServer(unpack(args))
        task.wait(0.5)
        CheckNewPets()
        EggsHatched += 3
        hatchLabel.Text = "Eggs hatched: " .. EggsHatched
        task.wait(HatchDelay)
    end
end

-- === Button-Events ===
startBtn.MouseButton1Click:Connect(function()
    if not Running then
        Running = true
        spawn(AutoHatchLoop)
    end
end)

stopBtn.MouseButton1Click:Connect(function()
    Running = false
end)

-- === Animation Toggle ===
local disableAnim = false
local animToggle = Instance.new("TextButton", MiscScroll)
animToggle.Size = UDim2.new(1, -20, 0, 36)
animToggle.BackgroundColor3 = Color3.fromRGB(100,100,100)
animToggle.TextColor3 = Color3.new(1,1,1)
animToggle.Text = "Disable Egg Animation: OFF"
animToggle.Font = Enum.Font.SourceSansBold
animToggle.TextSize = 16

animToggle.MouseButton1Click:Connect(function()
    disableAnim = not disableAnim
    animToggle.Text = "Disable Egg Animation: " .. (disableAnim and "ON" or "OFF")
    animToggle.BackgroundColor3 = disableAnim and Color3.fromRGB(60,140,60) or Color3.fromRGB(100,100,100)

    for _,v in pairs(getgc(true)) do
        if typeof(v) == "table" and rawget(v, "OpenEgg") then
            if disableAnim then
                v.OpenEgg = function() return end
                else
                loadstring("game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId)")()
            end
        end
    end
end)

-- === ScrollFrame automatisch updaten ===
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    MiscScroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
end)

-- === Tab aktivieren ===
MiscTabButton.MouseButton1Click:Connect(function()
    showTab("Misc")
end)
