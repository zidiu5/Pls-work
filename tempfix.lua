-- PLS DONT EXPLODE

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

local function hatchEgg(eggName, mode)
    if not eggName then return end
    local single, triple = false, false
    if mode == "Single" then single, triple = false, false end
    if mode == "Triple" then single, triple = true, false end
    if mode == "Octuple" then single, triple = false, true end

    local args = { { eggName, single, triple } }
    pcall(function()
        buyEggRemote:InvokeServer(unpack(args))
    end)
end

-- === GUI ===
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

-- MAIN TAB
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

-- FARM TAB
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

-- EGGS TAB
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
                hatchEgg(selectedEgg, hatchMode)
            end
            task.wait(0.5)
        end
    end)
end)

-- SHOP TAB
local diamondPacks = {
    {id = 1, text = "Diamond Pack 1 - 5B Coins"},
    {id = 2, text = "Diamond Pack 2 - 17.5B Coins"},
    {id = 3, text = "Diamond Pack 3 - 40B Fantasy Coins"},
    {id = 4, text = "Diamond Pack 4 - 52.5M Tech Coins"}
}

for _, pack in ipairs(diamondPacks) do
    win:AddToggle(shopTab, pack.text, false, function(state)
        if not state then return end
        task.spawn(function()
            while state do
                local args = { { pack.id } }
                pcall(function()
                    workspace:WaitForChild("__THINGS"):WaitForChild("__REMOTES"):WaitForChild("buy diamondpack"):InvokeServer(unpack(args))
                end)
                task.wait(1)
            end
        end)
    end)
end
