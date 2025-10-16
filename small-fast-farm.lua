-- Draggable Tabbed GUI mit Main-Tab Toggles (Auto Collects)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TabbedGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- Haupt-Fenster
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
Title.Text = "My Custom GUI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.SourceSansBold

-- Tab-Leiste links als ScrollingFrame
local TabFrame = Instance.new("ScrollingFrame", MainFrame)
TabFrame.Name = "TabFrame"
TabFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TabFrame.Size = UDim2.new(0, 140, 1, -38)
TabFrame.Position = UDim2.new(0, 0, 0, 38)
TabFrame.ScrollBarThickness = 6
TabFrame.CanvasSize = UDim2.new(0,0,0,0) -- wird später angepasst

-- Layout für Tabs
local UIListLayout = Instance.new("UIListLayout", TabFrame)
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- CanvasSize automatisch anpassen
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabFrame.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y + 8)
end)

-- Inhaltsbereich
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Name = "ContentFrame"
ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ContentFrame.Size = UDim2.new(1, -140, 1, -38)
ContentFrame.Position = UDim2.new(0, 140, 0, 38)

-- Hilfsfunktion: Tab-Button
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

local spacer = Instance.new("Frame", TabFrame)
spacer.Size = UDim2.new(1,0,0,0) -- 10 Pixel hoch
spacer.BackgroundTransparency = 1


local MainTabButton = createTabButton("Main")
local FarmTabButton = createTabButton("Farm")

-- Tabs-Inhalte erstellen
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

-- Section: Auto Collects im MainTab
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

-- Toggle-Factory
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

    -- Rückgabe: set callback
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
local autoRank = false
local autoOrbs = false

-- Rank toggle
local rankToggle = createToggle(TogglesList, "Auto Collect Rank Rewards", false)
rankToggle:SetCallback(function(state)
    autoRank = state
    if state then
        -- spawn loop
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
                    -- safe fail: ignore or print(err)
                end
                task.wait(10)
            end
        end)
    end
end)

-- Orbs toggle
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

-- Platzhalter Farm-Tab Inhalt
local FarmLabel = Instance.new("TextLabel", FarmContent)
FarmLabel.Text = "Farm tab content here..."
FarmLabel.Size = UDim2.new(1, 0, 0, 30)
FarmLabel.Position = UDim2.new(0, 10, 0, 10)
FarmLabel.BackgroundTransparency = 1
FarmLabel.TextColor3 = Color3.fromRGB(255,255,255)
FarmLabel.TextSize = 16

-- Tab switching
local function showTab(name)
    for n, frame in pairs(Tabs) do
        frame.Visible = (n == name)
    end
end
showTab("Main")
MainTabButton.MouseButton1Click:Connect(function() showTab("Main") end)
FarmTabButton.MouseButton1Click:Connect(function() showTab("Farm") end)

-- Open/Close-Button GUI (kleine GUI)
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

-- makeDraggable: optional clickIndicator param (so clicks know if it was a drag)
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

-- MainFrame draggable (entire frame)
makeDraggable(MainFrame, MainFrame)

-- ButtonGui draggable: use ButtonGui as dragHandle, but set clickIndicator to ButtonLabel
-- so ButtonLabel.MouseButton1Click can detect whether a drag happened
makeDraggable(ButtonGui, ButtonGui, ButtonLabel)

-- Open / Close (only when it wasn't a drag)
local isOpen = false
ButtonLabel.MouseButton1Click:Connect(function()
    local wasMoved = ButtonLabel:GetAttribute("Moved")
    if wasMoved then return end
    isOpen = not isOpen
    MainFrame.Visible = isOpen
    ButtonLabel.Text = isOpen and "Close GUI" or "Open GUI"
end)

-- AUTO INDEX FARM TAB (Normal + Gold)

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = workspace:WaitForChild("__THINGS"):WaitForChild("__REMOTES")

local SaveModule = require(ReplicatedStorage.Framework.Modules.Client:WaitForChild("4 | Save"))

local SaveData = SaveModule.Get(LocalPlayer)

-- == Tab Setup ==

local AutoIndexTabButton = createTabButton("Auto Index Farm")

local AutoIndexTabContent = createTabContent("Auto Index Farm")

-- Inner Tabs: Normal / Gold

local innerTabs = {"Normal","Gold"}

local innerTabFrames = {}

local innerSelected = "Normal"

local innerButtonHolder = Instance.new("Frame", AutoIndexTabContent)

innerButtonHolder.Size = UDim2.new(1,0,0,40)

innerButtonHolder.Position = UDim2.new(0,0,0,10)

innerButtonHolder.BackgroundTransparency = 1

local innerLayout = Instance.new("UIListLayout", innerButtonHolder)

innerLayout.FillDirection = Enum.FillDirection.Horizontal

innerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

innerLayout.VerticalAlignment = Enum.VerticalAlignment.Center

innerLayout.Padding = UDim.new(0,8)

for _, tabName in ipairs(innerTabs) do

local btn = Instance.new("TextButton", innerButtonHolder)

btn.Text = tabName

btn.Size = UDim2.new(0,120,1,0)

btn.BackgroundColor3 = Color3.fromRGB(70,70,70)

btn.TextColor3 = Color3.fromRGB(255,255,255)

btn.Font = Enum.Font.SourceSans

btn.TextSize = 15

btn.AutoButtonColor = false



local frame = Instance.new("Frame", AutoIndexTabContent)

frame.Size = UDim2.new(1,0,1,-60)

frame.Position = UDim2.new(0,0,0,55)

frame.BackgroundTransparency = 1

frame.Visible = (tabName == innerSelected)

innerTabFrames[tabName] = frame



btn.MouseButton1Click:Connect(function()

	for n,f in pairs(innerTabFrames) do f.Visible = (n == tabName) end

	innerSelected = tabName

end)

end

-- === Gemeinsame Funktionen ===

local rarityMap = { ["1"]="Normal", ["2"]="Gold", ["3"]="Rainbow", ["4"]="DarkMatter", ["5"]="Exclusive" }

local function loadFoundPets()

local foundPets = {}

local PetIndex = SaveData.Collection or {}

for petID, val in pairs(PetIndex) do

	local artID, rarityNum = tostring(val):match("^(%d+)%-(%d+)$")

	if artID and rarityNum then

		foundPets[tonumber(artID)] = foundPets[tonumber(artID)] or {Normal=false, Gold=false, Rainbow=false, DarkMatter=false}

		local rarityName = rarityMap[rarityNum]

		if rarityName and foundPets[tonumber(artID)][rarityName] ~= nil then

			foundPets[tonumber(artID)][rarityName] = true

		end

	end

end

return foundPets

end

local allPets, petRarity = {}, {}

local allPetsFolder = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Pets")

for _, petFolder in ipairs(allPetsFolder:GetChildren()) do

local petModule = petFolder:FindFirstChildOfClass("ModuleScript")

if petModule then

	local success, petData = pcall(require, petModule)

	if success and petData then

		local petID = tonumber(petFolder.Name:match("^(%d+)")) or 0

		allPets[petID] = petData.name or "?"

		petRarity[petID] = petData.rarity or "Normal"

	end

end

end

local function findEggForPet(petID, isGold)

local EggsFolder = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Eggs")

for _, category in ipairs(EggsFolder:GetChildren()) do

    for _, eggFolder in ipairs(category:GetChildren()) do

        local eggModule = eggFolder:FindFirstChildOfClass("ModuleScript")

        if eggModule then

            local success, eggData = pcall(require, eggModule)

            if success and eggData and type(eggData.drops) == "table" then

                for _, drop in ipairs(eggData.drops) do

                    if tonumber(drop[1]) == petID then

                        local name = eggData.displayName or eggFolder.Name

                        if isGold then

                            name = name:find("Golden") and name or "Golden " .. name

                        end



                        local cost = eggData.cost or 0

                        local currency = eggData.currency or "Coins"

                        local chance = drop[2] or 0



                        return name, cost, currency, chance

                    end

                end

            end

        end

    end

end

return nil, nil, nil, nil

end

local function hatchEgg(eggName)

local args = {{

	{

		eggName,

		false,

		true

	},

	{false,false,false}

}}

Remotes["buy egg"]:InvokeServer(unpack(args))

end

-- === Funktion für UI pro Untertab ===

local function createFarmUI(parent, isGold)

local Frame = Instance.new("Frame", parent)

Frame.Size = UDim2.new(0, 350, 0, 220)

Frame.Position = UDim2.new(0.5, -175, 0.1, 0)

Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

Frame.BorderSizePixel = 0

Frame.Active = true

Frame.Draggable = true



local Title = Instance.new("TextLabel", Frame)

Title.Size = UDim2.new(1, 0, 0, 30)

Title.BackgroundColor3 = Color3.fromRGB(50,50,50)

Title.Text = isGold and "🐾 Auto Index Farm (Gold)" or "🐾 Auto Index Farm (Normal)"

Title.TextColor3 = Color3.fromRGB(255,255,255)

Title.Font = Enum.Font.SourceSansBold

Title.TextSize = 20



local StartBtn = Instance.new("TextButton", Frame)

StartBtn.Size = UDim2.new(0.3, 0, 0, 35)

StartBtn.Position = UDim2.new(0.05, 0, 0.2, 0)

StartBtn.BackgroundColor3 = Color3.fromRGB(60,180,75)

StartBtn.Text = "▶ Start"

StartBtn.TextColor3 = Color3.new(1,1,1)

StartBtn.Font = Enum.Font.SourceSansBold

StartBtn.TextSize = 18



local StopBtn = Instance.new("TextButton", Frame)

StopBtn.Size = UDim2.new(0.3, 0, 0, 35)

StopBtn.Position = UDim2.new(0.35, 0, 0.2, 0)

StopBtn.BackgroundColor3 = Color3.fromRGB(220,60,60)

StopBtn.Text = "⏹ Stop"

StopBtn.TextColor3 = Color3.new(1,1,1)

StopBtn.Font = Enum.Font.SourceSansBold

StopBtn.TextSize = 18



local SkipBtn = Instance.new("TextButton", Frame)

SkipBtn.Size = UDim2.new(0.3, 0, 0, 35)

SkipBtn.Position = UDim2.new(0.65, 0, 0.2, 0)

SkipBtn.BackgroundColor3 = Color3.fromRGB(255,180,0)

SkipBtn.Text = "⏭ Skip Pet"

SkipBtn.TextColor3 = Color3.new(1,1,1)

SkipBtn.Font = Enum.Font.SourceSansBold

SkipBtn.TextSize = 18



local StatusLabel = Instance.new("TextLabel", Frame)

StatusLabel.Size = UDim2.new(1, -10, 0, 25)

StatusLabel.Position = UDim2.new(0, 5, 0.45, 0)

StatusLabel.BackgroundTransparency = 1

StatusLabel.Text = "Status: ⏸ Idle"

StatusLabel.TextColor3 = Color3.fromRGB(255,255,255)

StatusLabel.Font = Enum.Font.SourceSans

StatusLabel.TextSize = 16

StatusLabel.TextXAlignment = Enum.TextXAlignment.Left



local CurrentPetLabel = Instance.new("TextLabel", Frame)

CurrentPetLabel.Size = UDim2.new(1, -10, 0, 25)

CurrentPetLabel.Position = UDim2.new(0, 5, 0.55, 0)

CurrentPetLabel.BackgroundTransparency = 1

CurrentPetLabel.Text = "Aktuelles Pet: -"

CurrentPetLabel.TextColor3 = Color3.fromRGB(255,255,255)

CurrentPetLabel.Font = Enum.Font.SourceSans

CurrentPetLabel.TextSize = 16

CurrentPetLabel.TextXAlignment = Enum.TextXAlignment.Left



local ChanceLabel = Instance.new("TextLabel", Frame)

ChanceLabel.Size = UDim2.new(1, -10, 0, 25)

ChanceLabel.Position = UDim2.new(0, 5, 0.65, 0)

ChanceLabel.BackgroundTransparency = 1

ChanceLabel.Text = "Chance: 0%"

ChanceLabel.TextColor3 = Color3.fromRGB(180,255,180)

ChanceLabel.Font = Enum.Font.SourceSans

ChanceLabel.TextSize = 16

ChanceLabel.TextXAlignment = Enum.TextXAlignment.Left



local ProgressLabel = Instance.new("TextLabel", Frame)

ProgressLabel.Size = UDim2.new(1, -10, 0, 25)

ProgressLabel.Position = UDim2.new(0, 5, 0.75, 0)

ProgressLabel.BackgroundTransparency = 1

ProgressLabel.Text = "Fortschritt: 0/0"

ProgressLabel.TextColor3 = Color3.fromRGB(180,180,255)

ProgressLabel.Font = Enum.Font.SourceSans

ProgressLabel.TextSize = 16

ProgressLabel.TextXAlignment = Enum.TextXAlignment.Left



local running = false

local skipCurrent = false



local function getMissingPets()

	local foundPets = loadFoundPets()

	local missingList = {}

	for id,_ in pairs(allPets) do

		local owned = foundPets[id]

		local rarity = petRarity[id] or "Normal"

		if rarity ~= "Exclusive" then

			if not owned or not owned[isGold and "Gold" or "Normal"] then

				table.insert(missingList, id)

			end

		end

	end

	return missingList

end



local function getCurrencyAmount(currencyName)

local SaveData = SaveModule.Get(LocalPlayer)

if not SaveData then return 0 end



-- Alle bekannten Währungen prüfen

local amounts = {

	Coins = SaveData.Coins or 0,

	["Tech Coins"] = SaveData["Tech Coins"] or 0,

	["Rainbow Coins"] = SaveData["Rainbow Coins"] or 0,

	["Halloween Candy"] = SaveData["Halloween Candy"] or 0,

	["Rng Coins"] = SaveData["Rng Coins"] or 0,

	["Fantasy Coins"] = SaveData["Fantasy Coins"] or 0,

	Gingerbread = SaveData.Gingerbread or 0,

	Diamonds = SaveData.Diamonds or 0

}

    return amounts[currencyName] or 0

end



local function autoFarm()

    running = true

    local foundPets = loadFoundPets()

    local missing = getMissingPets()

    local total = #missing

    local currentIndex = 1



    while running and currentIndex <= total do

        local petID = missing[currentIndex]

        local petName = allPets[petID] or tostring(petID)

        local rarity = petRarity[petID] or "Normal"

        local eggName, cost, currency, chance = findEggForPet(petID, isGold)



        if not eggName then

            print("⚠️ Kein Egg gefunden für", petName)

            currentIndex += 1

            continue

        end



        -- Prüfen ob genug Währung vorhanden

        local currentAmount = getCurrencyAmount(currency)

        print("💰 "..eggName.." kostet "..cost.." "..currency.." | Du hast: "..currentAmount)

        if cost > currentAmount then

            print("⚠️ Nicht genug " .. currency .. " für " .. petName .. " | Überspringe...")

            currentIndex += 1

            continue

        end





        CurrentPetLabel.Text = "Aktuelles Pet: "..petName.." | Rarity: "..rarity

        ChanceLabel.Text = "Chance: "..chance.."%"

        ProgressLabel.Text = "Fortschritt: "..currentIndex.."/"..total

        StatusLabel.Text = "Status: 🥚 Hatching "..eggName



        skipCurrent = false

        while running and not skipCurrent do

            foundPets = loadFoundPets()

            if foundPets[petID] and foundPets[petID][isGold and "Gold" or "Normal"] then

                break

            end

            hatchEgg(eggName)

            task.wait(0.3)

        end



        currentIndex += 1

    end



    StatusLabel.Text = "Status: ✅ Fertig"

    CurrentPetLabel.Text = "Aktuelles Pet: -"

    ChanceLabel.Text = "Chance: 0%"

    ProgressLabel.Text = "Fortschritt: 0/0"

    running = false

end





StartBtn.MouseButton1Click:Connect(function()

	if running then return end

	task.spawn(autoFarm)

end)



StopBtn.MouseButton1Click:Connect(function()

	running = false

	StatusLabel.Text = "Status: ⏸ Gestoppt"

end)



SkipBtn.MouseButton1Click:Connect(function()

	skipCurrent = true

end)

end

createFarmUI(innerTabFrames["Normal"], false)

createFarmUI(innerTabFrames["Gold"], true)

AutoIndexTabButton.MouseButton1Click:Connect(function()

showTab("Auto Index Farm")

end)

