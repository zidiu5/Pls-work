-- PLS DONT EXPLODE v2.1

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zidiu5/library-test/refs/heads/main/library.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local THINGS = workspace:WaitForChild("__THINGS")
local REMOTES = THINGS:WaitForChild("__REMOTES")
local COINS = THINGS:WaitForChild("Coins")
local PETS = THINGS:WaitForChild("Pets")
local ORBS = THINGS:WaitForChild("Orbs")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EGG_DIR = ReplicatedStorage:WaitForChild("__DIRECTORY"):WaitForChild("Eggs")

local joinRemote = REMOTES:WaitForChild("join coin")
local farmRemote = REMOTES:WaitForChild("farm coin")
local claimOrbsRemote = REMOTES:WaitForChild("claim orbs")
local buyEggRemote = REMOTES:WaitForChild("buy egg")

local afterJoinDelay = 0.05

-- Hash Funktion
local function hash(str)
    local hashed = 0
    for i = 1, #str do
        hashed = (hashed * 31 + str:byte(i)) % 2^32
    end
    return hashed
end

local correctHash = 3816376214

local PasswordScreen = Instance.new("ScreenGui")
PasswordScreen.Parent = LocalPlayer:WaitForChild("PlayerGui")
PasswordScreen.ResetOnSpawn = false

local PasswordFrame = Instance.new("Frame")
PasswordFrame.Size = UDim2.new(0, 360, 0, 130)
PasswordFrame.Position = UDim2.new(0.5, -180, 0.5, -65)
PasswordFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
PasswordFrame.BorderSizePixel = 0
PasswordFrame.Parent = PasswordScreen
PasswordFrame.Active = true
PasswordFrame.Draggable = true

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Position = UDim2.new(0, 0, 0, 5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Enter Password"
TitleLabel.TextScaled = true
TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = PasswordFrame

local PasswordBox = Instance.new("TextBox")
PasswordBox.Size = UDim2.new(0, 260, 0, 34)
PasswordBox.Position = UDim2.new(0.5, -130, 0.5, -8)
PasswordBox.PlaceholderText = "Password"
PasswordBox.Text = ""
PasswordBox.TextScaled = true
PasswordBox.BackgroundColor3 = Color3.fromRGB(200,200,200)
PasswordBox.TextColor3 = Color3.fromRGB(0,0,0)
PasswordBox.ClearTextOnFocus = true
PasswordBox.Parent = PasswordFrame

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0, 80, 0, 34)
SubmitBtn.Position = UDim2.new(0.5, 90, 0.5, -8)
SubmitBtn.Text = "OK"
SubmitBtn.TextScaled = true
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.Parent = PasswordFrame
SubmitBtn.BackgroundColor3 = Color3.fromRGB(100,200,100)
SubmitBtn.TextColor3 = Color3.fromRGB(0,0,0)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 1, -22)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
StatusLabel.TextScaled = true
StatusLabel.Text = ""
StatusLabel.Parent = PasswordFrame

local function tryPassword(input)
    if hash(input) == correctHash then
        PasswordScreen:Destroy()
        createAutofarmGUI()
    else
        StatusLabel.Text = "Wrong password!"
        PasswordBox.Text = ""
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(200,100,100)
        task.delay(0.25, function() SubmitBtn.BackgroundColor3 = Color3.fromRGB(100,200,100) end)
    end
end

SubmitBtn.MouseButton1Click:Connect(function()
    tryPassword(PasswordBox.Text)
end)

PasswordBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        tryPassword(PasswordBox.Text)
    end
end)

-- GUI Funktion
function createAutofarmGUI()
    local win = Library.new({title = "Autofarm GUI"})
    local mainTab = win:AddTab("Main")
    local farmTab = win:AddTab("Farm")
    local eggsTab = win:AddTab("Eggs")
    local shopTab = win:AddTab("Shop")

    local selectedArea = nil
    local running = false
    local multiple = false
    local autoCollect = false
    local selectedFolder = nil
    local selectedEgg = nil
    local autoHatch = false
    local hatchMode = "Single"

    -- Helper functions
    local function getAttr(obj, name)
        local ok, v = pcall(function() return obj:GetAttribute(name) end)
        if ok and v ~= nil then return v end
        local c = obj:FindFirstChild(name)
        if c and c.Value ~= nil then return c.Value end
        return nil
    end

    local function collectAreas()
        local set = {}
        for _, c in pairs(COINS:GetChildren()) do
            local a = getAttr(c, "Area")
            if a then set[a] = true end
        end
        local t = {}
        for k in pairs(set) do table.insert(t, k) end
        table.sort(t)
        return t
    end

    local function coinsInArea(area)
        local out = {}
        for _, c in pairs(COINS:GetChildren()) do
            if getAttr(c, "Area") == area then
                table.insert(out, c.Name)
            end
        end
        return out
    end

    local function myPets()
        local out = {}
        for _, p in pairs(PETS:GetChildren()) do
            local o = getAttr(p, "Owner")
            if tostring(o) == tostring(LocalPlayer.Name) or tostring(o) == tostring(LocalPlayer.UserId) then
                table.insert(out, p.Name)
            end
        end
        return out
    end

    local function safeInvokeJoin(coinId, pets)
        local args = { { coinId, pets } }
        pcall(function() joinRemote:InvokeServer(unpack(args)) end)
    end

    local function safeFarm(coinId, petId)
        local args = { { coinId, petId } }
        pcall(function() farmRemote:FireServer(unpack(args)) end)
    end

    local function collectOrbs()
        local ids = {}
        for _, orb in pairs(ORBS:GetChildren()) do
            table.insert(ids, orb.Name)
        end
        if #ids > 0 then
            local args = { { ids } }
            pcall(function() claimOrbsRemote:FireServer(unpack(args)) end)
        end
    end

    -- === MAIN TAB ===
    win:AddToggle(mainTab, "Auto Collect", false, function(state)
        autoCollect = state
        if not autoCollect then return end
        task.spawn(function()
            while autoCollect do
                collectOrbs()
                task.wait(0.2)
            end
        end)
    end)

    -- === FARM TAB ===
    local areaDropdown = select(1, win:AddDropdown(farmTab, "Select Area", collectAreas(), function(selected)
        for k, v in pairs(selected) do
            if v then selectedArea = k end
        end
    end))

    win:AddButton(farmTab, "🔄 Refresh Areas", function()
        win:UpdateDropdown(areaDropdown, collectAreas())
    end)

    win:AddToggle(farmTab, "Multiple Farm", false, function(state)
        multiple = state
    end)

    win:AddToggle(farmTab, "Auto Farm", false, function(state)
        running = state
        if not running then return end
        if not selectedArea then return end
        local pets = myPets()
        if #pets == 0 then return end
        task.spawn(function()
            while running do
                local coins = coinsInArea(selectedArea)
                if #coins == 0 then
                    task.wait(0.3)
                    continue
                end
                if multiple then
                    for i, petId in ipairs(pets) do
                        if not running then break end
                        local coinId = coins[(i - 1) % #coins + 1]
                        task.spawn(function()
                            safeInvokeJoin(coinId, { petId })
                            task.wait(afterJoinDelay)
                            safeFarm(coinId, petId)
                        end)
                    end
                    task.wait(0.05)
                else
                    local coinId = coins[1]
                    if coinId then
                        safeInvokeJoin(coinId, pets)
                        task.wait(afterJoinDelay)
                        for _, petId in ipairs(pets) do
                            safeFarm(coinId, petId)
                        end
                        repeat task.wait(0.1)
                        until not COINS:FindFirstChild(coinId) or not running
                    else
                        task.wait(0.1)
                    end
                end
            end
        end)
    end)

    -- === EGGS TAB ===
    local eggDropdowns = {}
    local folderList = EGG_DIR:GetChildren()
    table.sort(folderList, function(a,b) return a.Name < b.Name end)

    for _, folder in pairs(folderList) do
        local eggNames = {"None"}
        for _, egg in pairs(folder:GetChildren()) do
            table.insert(eggNames, egg.Name)
        end
        table.sort(eggNames)
        local dropdownId = select(1, win:AddDropdown(eggsTab, folder.Name, eggNames, function(selected)
            for k, v in pairs(selected) do
                if v and k ~= "None" then
                    selectedFolder = folder
                    selectedEgg = k
                elseif k == "None" then
                    if selectedFolder == folder then
                        selectedFolder = nil
                        selectedEgg = nil
                    end
                end
            end
        end))
        eggDropdowns[folder.Name] = dropdownId
    end

    local eggInfoId = select(1, win:AddLabel(eggsTab, "Select an Egg to view info"))
    win:AddButton(eggsTab, "Egg Info", function()
        if selectedFolder and selectedEgg then
            local eggFolder = selectedFolder:FindFirstChild(selectedEgg)
            if eggFolder then
                local infoModule = eggFolder:FindFirstChild(selectedEgg)
                if infoModule and infoModule:IsA("ModuleScript") then
                    local ok, data = pcall(require, infoModule)
                    if ok and type(data) == "table" then
                        local text = string.format("Egg: %s\nHatchable: %s\nCost: %s\nCurrency: %s",
                            selectedEgg, tostring(data.hatchable), tostring(data.cost), tostring(data.currency))
                        win:UpdateLabel(eggInfoId, text)
                    end
                end
            end
        else
            win:UpdateLabel(eggInfoId, "No Egg Selected")
        end
    end)

    win:AddButton(eggsTab, "Unselect All", function()
        selectedFolder, selectedEgg = nil, nil
        win:UpdateLabel(eggInfoId, "No Egg Selected")
    end)

    -- Hatch mode dropdown
    win:AddDropdown(eggsTab, "Hatch Mode", {"Single", "Triple", "Octuple"}, function(selected)
        for k,v in pairs(selected) do
            if v then hatchMode = k end
        end
    end)

    -- Start hatch toggle
    win:AddToggle(eggsTab, "Start Hatch", false, function(state)
        autoHatch = state
        if not autoHatch then return end
        task.spawn(function()
            while autoHatch do
                if selectedEgg then
                    local single, triple = false, false
                    if hatchMode == "Single" then single, triple = false, false end
                    if hatchMode == "Triple" then single, triple = true, false end
                    if hatchMode == "Octuple" then single, triple = false, true end
                    local args = { { selectedEgg, single, triple } }
                    pcall(function() buyEggRemote:InvokeServer(unpack(args)) end)
                end
                task.wait(0.5)
            end
        end)
    end)

    -- SHOP TAB
    local diamondPacks = {
        {id = 1, text = "Diamond Pack 1 - 3B Coins"},
        {id = 2, text = "Diamond Pack 2 - 15B Fantasy Coins"},
        {id = 3, text = "Diamond Pack 3 - 45M Tech Coins"},
        {id = 4, text = "Diamond Pack 4 - 150M Tech Coins"}
    }

    for _, pack in ipairs(diamondPacks) do
        win:AddToggle(shopTab, pack.text, false, function(state)
            if not state then return end
            task.spawn(function()
                while state do
                    local args = { { pack.id } }
                    pcall(function()
                        REMOTES:WaitForChild("buy diamondpack"):InvokeServer(unpack(args))
                    end)
                    task.wait(1)
                end
            end)
        end)
    end
end
