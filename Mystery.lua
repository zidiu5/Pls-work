local Network = require(game:GetService("ReplicatedStorage"):WaitForChild("Library"):WaitForChild("Client"):WaitForChild("Network"))
local shareddata = getupvalue(getupvalue(getrawmetatable(Network).__index, 1).Invoke, 2)

-- Die Hauptfunktion zum Umbenennen
local function beautify()
    -- Diese Upvalues holen wir uns bei jedem Durchgang frisch, 
    -- falls das Spiel die Tabellen intern neu generiert.
    local hashstorage = getupvalue(getupvalue(shareddata, 2), 1)
    local remotestorage = getupvalue(getupvalue(shareddata, 1), 1)

    -- 1. Schritt: Namen-Index erstellen (ID zu Klartext)
    local nameLookup = {}
    for i = 1, #hashstorage do
        for name, id in next, hashstorage[i] do
            nameLookup[id] = name
        end
    end

    -- 2. Schritt: Remotes umbenennen
    for i = 1, #remotestorage do
        for id, remoteObj in next, remotestorage[i] do
            if nameLookup[id] then
                -- Nur umbenennen, wenn der Name noch nicht stimmt
                if remoteObj.Name ~= nameLookup[id] then
                    remoteObj.Name = nameLookup[id]
                end
            end
        end
    end
end

-- Der unendliche Loop
task.spawn(function()
    print("--- [Auto-Beautifier] Gestartet (Intervall: 5s) ---")
    
    while true do
        local success, err = pcall(beautify)
        
        if not success then
            warn("--- [Auto-Beautifier] Fehler beim Umbenennen: " .. tostring(err))
        end
        
        task.wait(5) -- Exakt 5 Sekunden Pause
    end
end)



-- Load ZidiuUI Library
local ZidiuUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/musicmaker-web/ZidiuUI/refs/heads/main/ZidiuUI.lua"))()

-- --- SERVICES & VARIABLES ---
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

-- Directories
local directory = ReplicatedStorage:FindFirstChild("__DIRECTORY")
local eggsRoot = directory and directory:FindFirstChild("Eggs")
local petsFolder = directory and directory:FindFirstChild("Pets")

local things = workspace:WaitForChild("__THINGS")
local orbsFolder = things:WaitForChild("Orbs")
local petsWorldFolder = things:WaitForChild("Pets")
local coinsFolder = things:WaitForChild("Coins")
local teleportsFolder = workspace:WaitForChild("__MAP"):WaitForChild("Teleports")

-- Remotes
local claimRemote = ReplicatedStorage:WaitForChild("Claim Orbs")
local joinRemote = ReplicatedStorage:WaitForChild("Join Coin")
local farmRemote = ReplicatedStorage:WaitForChild("Farm Coin")
local buyEggRemote = ReplicatedStorage:WaitForChild("Buy Egg")

-- State Variables
local autoCollectOrbs = false
local autoFarmActive = false
local autoHatchEnabled = false
local farmMode = "Nearest" 
local targetMode = "Multi-Target"
local selectedAreas = {}
local selectedEgg = ""
local hatchMode = "Single"
local eggList = {}

-- --- HELPER FUNCTIONS ---

local function formatNumber(n)
    n = tonumber(n) or 0
    if n < 1000 then return tostring(n) end
    local suffixes = {"k", "m", "b", "t", "qa", "qi"}
    local index = 0
    while n >= 1000 and index < #suffixes do
        n = n / 1000
        index = index + 1
    end
    return string.format("%.1f%s", n, suffixes[index]):gsub("%.0", "")
end

local function getDetailedPetStats(targetID)
    targetID = tonumber(targetID)
    if not targetID or not petsFolder then return nil end
    for _, petFolder in pairs(petsFolder:GetChildren()) do
        local dataScript = petFolder:FindFirstChildWhichIsA("ModuleScript")
        if dataScript then
            local s, pData = pcall(function() return require(dataScript) end)
            if s and (tonumber(pData._id) == targetID or tonumber(pData.id) == targetID) then
                return {
                    name = pData.name or petFolder.Name,
                    min = pData.strengthMin or 0,
                    max = pData.strengthMax or 0,
                    rarity = pData.rarity or "Unknown"
                }
            end
        end
    end
    return nil
end

local function getAllAreas()
    local areas = {}
    for _, part in pairs(teleportsFolder:GetChildren()) do
        if part:IsA("BasePart") then table.insert(areas, part.Name) end
    end
    table.sort(areas)
    return areas
end

local function refreshEggList()
    eggList = {}
    if eggsRoot then
        for _, area in pairs(eggsRoot:GetChildren()) do
            for _, egg in pairs(area:GetChildren()) do
                table.insert(eggList, egg.Name)
            end
        end
    end
    table.sort(eggList)
    return eggList
end

local function getMyPetIds()
    local myPetIds = {}
    for _, pet in pairs(petsWorldFolder:GetChildren()) do
        if tostring(pet:GetAttribute("Owner")) == tostring(localPlayer.UserId) or pet:GetAttribute("Owner") == localPlayer.Name then
            table.insert(myPetIds, pet:GetAttribute("ID") or pet.Name)
        end
    end
    return myPetIds
end

local function getSortedCoins()
    local coins = {}
    local char = localPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return {} end
    local myPos = char.HumanoidRootPart.Position

    for _, coin in pairs(coinsFolder:GetChildren()) do
        local area = coin:GetAttribute("Area") or ""
        local hp = coin:GetAttribute("Health") or 0
        local posPart = coin:FindFirstChild("POS")
        local areaAllowed = #selectedAreas == 0 or table.find(selectedAreas, area)

        if areaAllowed and hp > 0 and posPart then
            table.insert(coins, {
                id = coin:GetAttribute("ID") or coin.Name,
                hp = hp,
                dist = (myPos - posPart.Position).Magnitude
            })
        end
    end

    if farmMode == "Nearest" then
        table.sort(coins, function(a, b) return a.dist < b.dist end)
    elseif farmMode == "Lowest Health" then
        table.sort(coins, function(a, b) return a.hp < b.hp end)
    elseif farmMode == "Highest Health" then
        table.sort(coins, function(a, b) return a.hp > b.hp end)
    end
    return coins
end

-- Initialize Data
refreshEggList()

-- --- MAIN WINDOW SETUP ---
local Window = ZidiuUI:CreateWindow("Sometimes those scripts pmo")

-- --- TAB 1: FARMING ---
local FarmTab = Window:CreateTab("Farming", "🚜")
local ConfigSec = FarmTab:CreateSection("Auto Farm Engine")

ConfigSec:CreateToggle("Master Switch (Auto Farm)", false, function(state)
    autoFarmActive = state
end)

ConfigSec:CreateMultiDropdown("Select Farm Areas", getAllAreas(), function(selectedTable)
    selectedAreas = selectedTable
    ZidiuUI:Notify("Areas updated!", "info", 2)
end)

ConfigSec:CreateDropdown("Farm Priority", {"Nearest", "Lowest Health", "Highest Health"}, function(val)
    farmMode = val
end)

ConfigSec:CreateDropdown("Targeting Mode", {"Multi-Target", "Single-Target"}, function(val)
    targetMode = val
end)

local MiscSec = FarmTab:CreateSection("Automation")
MiscSec:CreateToggle("Auto Collect Orbs", false, function(state)
    autoCollectOrbs = state
end)

-- --- TAB 2: AUTO-HATCH ---
local HatchTab = Window:CreateTab("Auto-Hatch", "🥚")
local HatchSec = HatchTab:CreateSection("Egg Settings")

HatchSec:CreateLabel("1. Select an Egg:")
local EggDropdown = HatchSec:CreateSearchDropdown("Search Egg...", eggList, function(selected)
    selectedEgg = selected
end)

HatchSec:CreateLabel("2. Select Hatch Mode:")
HatchSec:CreateDropdown("Hatch Mode", {"Single", "Triple", "Octuple"}, function(selected)
    hatchMode = selected
    ZidiuUI:Notify("Mode changed to: " .. selected, "info", 2)
end)

HatchSec:CreateToggle("Start Auto Hatch", false, function(state)
    if selectedEgg == "" and state then
        ZidiuUI:Notify("Error: No egg selected!", "error", 3)
        return
    end
    autoHatchEnabled = state
end)

HatchSec:CreateButton("Reload Egg List", function()
    local newList = refreshEggList()
    EggDropdown:SetOptions(newList)
    ZidiuUI:Notify("List updated!", "success", 2)
end)

-- --- TAB 3: SCANNER ---
local ScanTab = Window:CreateTab("Scanner", "🔍")
local SearchSection = ScanTab:CreateSection("Egg & Pet Database")

local InfoWindow = SearchSection:CreateExLabel("Scan Results", "Search for an egg first...")

SearchSection:CreateButton("Open Detailed Results", function()
    InfoWindow:Open()
    InfoWindow:Focus()
end)

SearchSection:CreateTextbox("Egg Name (e.g. Pixel Egg)", "Enter name...", function(input)
    if input == "" or not eggsRoot then return end
    local search = input:lower()
    local found = false

    for _, area in pairs(eggsRoot:GetChildren()) do
        for _, eggFolder in pairs(area:GetChildren()) do
            local mod = eggFolder:FindFirstChildWhichIsA("ModuleScript")
            if mod then
                local s, data = pcall(function() return require(mod) end)
                if s and data.displayName and data.displayName:lower() == search then
                    found = true
                    local totalWeight = 0
                    if data.drops then
                        for _, d in ipairs(data.drops) do totalWeight = totalWeight + (tonumber(d[2]) or 0) end
                    end

                    local infoText = "🥚 EGG: " .. data.displayName:upper() .. "\n"
                    infoText = infoText .. "📍 AREA: " .. area.Name .. "\n"
                    infoText = infoText .. "💰 PRICE: " .. formatNumber(data.cost) .. " " .. tostring(data.currency) .. "\n"
                    infoText = infoText .. string.rep("═", 35) .. "\n\n"
                    
                    if data.drops and totalWeight > 0 then
                        table.sort(data.drops, function(a, b) return a[2] < b[2] end)
                        for _, d in ipairs(data.drops) do
                            local stats = getDetailedPetStats(d[1])
                            local realPercent = (tonumber(d[2]) / totalWeight) * 100
                            local pStr = realPercent < 1 and string.format("%.4f%%", realPercent) or string.format("%.2f%%", realPercent)
                            if stats then
                                infoText = infoText .. string.format("[%s] %s (%s)\n   └ Str: %s - %s\n\n", 
                                    pStr, stats.name, stats.rarity, formatNumber(stats.min), formatNumber(stats.max))
                            else
                                infoText = infoText .. string.format("[%s] ID: %s (N/A)\n\n", pStr, tostring(d[1]))
                            end
                        end
                    end
                    InfoWindow:SetTitle("Stats: " .. data.displayName)
                    InfoWindow:SetText(infoText)
                    ZidiuUI:Notify("Data ready!", "success", 3)
                    return
                end
            end
        end
    end
    if not found then ZidiuUI:Notify("Egg not found!", "error", 3) end
end)

-- --- BACKGROUND LOOPS ---

-- Orb Collector Loop
task.spawn(function()
    while true do
        if autoCollectOrbs then
            local children = orbsFolder:GetChildren()
            if #children > 0 then
                local ids = {}
                for i = 1, #children do ids[i] = children[i].Name end
                claimRemote:FireServer(ids)
            end
        end
        task.wait(0.1)
    end
end)

-- Auto Farm Loop
task.spawn(function()
    while true do
        if autoFarmActive then
            local myPets = getMyPetIds()
            local sortedCoins = getSortedCoins()

            if #myPets > 0 and #sortedCoins > 0 then
                if targetMode == "Single-Target" then
                    local targetId = sortedCoins[1].id
                    for _, petId in ipairs(myPets) do
                        task.spawn(function()
                            joinRemote:InvokeServer(targetId, {petId})
                            farmRemote:FireServer(targetId, petId)
                        end)
                    end
                else
                    for i, petId in ipairs(myPets) do
                        local targetId = sortedCoins[((i - 1) % #sortedCoins) + 1].id
                        task.spawn(function()
                            joinRemote:InvokeServer(targetId, {petId})
                            farmRemote:FireServer(targetId, petId)
                        end)
                    end
                end
            end
        end
        task.wait(1)
    end
end)

-- Auto Hatch Loop
task.spawn(function()
    while true do
        if autoHatchEnabled and selectedEgg ~= "" then
            local args = {}
            if hatchMode == "Single" then
                args = {selectedEgg, false, false, false}
            elseif hatchMode == "Triple" then
                args = {selectedEgg, true, false, false}
            elseif hatchMode == "Octuple" then
                args = {selectedEgg, false, true, true}
            end
            
            pcall(function()
                buyEggRemote:InvokeServer(unpack(args))
            end)
        end
        task.wait(0.1)
    end
end)

ZidiuUI:Notify("Gemini Hub Loaded Successfully!", "success", 5)

