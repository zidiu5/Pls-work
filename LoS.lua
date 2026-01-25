--// 1. ENABLE OPTIONAL SETTINGS TAB
_G.showOptionalSettings = true

--// 2. LOAD FRAMEWORK
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zidiu5/library-test/refs/heads/main/Framework.lua"))()

--// 3. SERVICES & REMOTES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local orbEvent = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("orbEvent")
local rebirthEvent = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("rebirthEvent")
local eggFunc = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("openCrystalRemote")
local giftFunc = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("freeGiftClaimRemote")
local travelRemote = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("areaTravelRemote")
local raceEvent = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("raceEvent")

--// 4. CREATE TABS
local FarmTab = Library:CreateTab("Autofarm")
local CrystalTab = Library:CreateTab("Crystals")
local WorldMiscTab = Library:CreateTab("World & Misc")

--================================================================
-- [AUTOFARM TAB]
--================================================================
local OrbSection = FarmTab:Section("Orb Farming", true)
local selectedOrbs = {}
local orbList = {"Yellow Orb", "Blue Orb", "Red Orb", "Orange Orb", "Gem", "Ethereal Orb", "Infernal Gem"}
local orbLocations = {"City", "Snow City", "Magma City", "Legends Highway", "Speed Jungle", "Desert"}
local selectedOrbLoc = orbLocations[1]

OrbSection:Dropdown("Select Location", orbLocations, function(val) selectedOrbLoc = val end)
OrbSection:Dropdown("Select Orbs", orbList, function(opt, state) selectedOrbs[opt] = state end, true)

OrbSection:Toggle("Ultra Fast Collect", false, function(state)
    _G.autoOrbs = state
    task.spawn(function()
        while _G.autoOrbs do
            for name, active in pairs(selectedOrbs) do
                if active then
                    for i = 1, 10 do orbEvent:FireServer("collectOrb", name, selectedOrbLoc) end
                end
            end
            task.wait()
        end
    end)
end)

-- The x10,000 Button
OrbSection:Button("x10,000 Instant Collect", function()
    Library.Notify("Orb Farm", "Starting Mass Collect (10k)...", "Success", 3)
    for name, active in pairs(selectedOrbs) do
        if active then
            for i = 1, 10000 do
                task.spawn(function()
                    orbEvent:FireServer("collectOrb", name, selectedOrbLoc)
                end)
            end
        end
    end
end)

local MiscFarmSection = FarmTab:Section("Misc Farming", true)

local HoopsFolder = workspace:WaitForChild("Hoops")
local OriginalHoopPositions = {}
local hoopConn = nil

MiscFarmSection:Toggle("Hoop Magnet", false, function(state)
    if state then
        for _, hoop in ipairs(HoopsFolder:GetChildren()) do
            if hoop:IsA("BasePart") and not OriginalHoopPositions[hoop] then
                OriginalHoopPositions[hoop] = hoop.CFrame
            end
        end
        hoopConn = RunService.Heartbeat:Connect(function()
            local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, hoop in ipairs(HoopsFolder:GetChildren()) do
                    if hoop:IsA("BasePart") then
                        hoop.CFrame = hrp.CFrame * CFrame.new(0, 2, 0)
                    end
                end
            end
        end)
    else
        if hoopConn then hoopConn:Disconnect() hoopConn = nil end
        for hoop, cf in pairs(OriginalHoopPositions) do
            if hoop and hoop.Parent then hoop.CFrame = cf end
        end
    end
end)

MiscFarmSection:Toggle("Auto Rebirth", false, function(state)
    _G.autoRebirth = state
    task.spawn(function()
        while _G.autoRebirth do
            rebirthEvent:FireServer("rebirthRequest")
            task.wait(0.5)
        end
    end)
end)

--================================================================
-- [CRYSTALS TAB]
--================================================================
local EggSection = CrystalTab:Section("Crystal Opener", true)
local CrystalFolder = workspace:WaitForChild("mapCrystalsFolder")
local CrystalNames = {}
for _, c in ipairs(CrystalFolder:GetChildren()) do table.insert(CrystalNames, c.Name) end
table.sort(CrystalNames)

local selectedCrystal = CrystalNames[1]
local openAmount = 1

EggSection:Dropdown("Select Crystal", CrystalNames, function(val) selectedCrystal = val end)
EggSection:TextBox("Amount to Open", function(val) openAmount = tonumber(val) or 1 end)
EggSection:Button("Open Crystal", function()
    for i = 1, openAmount do
        task.spawn(function() pcall(function() eggFunc:InvokeServer("openCrystal", selectedCrystal) end) end)
    end
end)

--================================================================
-- [WORLD & MISC TAB]
--================================================================
local TPSection = WorldMiscTab:Section("TP To Area", true)
local AreaCircles = workspace:WaitForChild("areaCircles")
local Areas = {}
local AreaNames = {}

for _, portal in ipairs(AreaCircles:GetChildren()) do
    local nv = portal:FindFirstChild("areaName")
    if nv and not Areas[nv.Value] then
        Areas[nv.Value] = portal
        table.insert(AreaNames, nv.Value)
    end
end
table.sort(AreaNames)

local selectedAreaName = nil
TPSection:Dropdown("Select Portal", AreaNames, function(val) selectedAreaName = val end)
TPSection:Button("Teleport to Area", function()
    if selectedAreaName and Areas[selectedAreaName] then
        travelRemote:InvokeServer("travelToArea", Areas[selectedAreaName])
    end
end)

local RaceSection = WorldMiscTab:Section("Race", true)

-- Auto Join Race Toggle
RaceSection:Toggle("Auto Join Race", false, function(state)
    _G.autoJoinRace = state
    task.spawn(function()
        while _G.autoJoinRace do
            raceEvent:FireServer("joinRace")
            task.wait(1)
        end
    end)
end)

local function tp(x,y,z) 
    local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(x,y,z) end
end
RaceSection:Button("Teleport to Spawn", function() tp(-573, 4, 415) end)
RaceSection:Button("Teleport to Magma", function() tp(958, 1, -10979) end)
RaceSection:Button("Teleport to Grassland", function() tp(1646, 1, -5969) end)
RaceSection:Button("Teleport to Desert", function() tp(6, 1, -8685) end)

local MiscSection = WorldMiscTab:Section("Misc", true)

MiscSection:Toggle("Auto Claim Gifts (1-8)", false, function(state)
    _G.autoGifts = state
    task.spawn(function()
        while _G.autoGifts do
            for i = 1, 8 do pcall(function() giftFunc:InvokeServer("claimGift", i) end) end
            task.wait(10)
        end
    end)
end)

MiscSection:Button("Enable Walk on Parkour Floor", function()
    local TouchFolder = workspace:WaitForChild("touchTeleportParts")
    for _, part in ipairs(TouchFolder:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
            local t = part:FindFirstChildOfClass("TouchTransmitter") or part:FindFirstChild("TouchInterest")
            if t then t:Destroy() end
        end
    end
    Library.Notify("Parkour", "Parkour Floor enabled!", "Success", 3)
end)

MiscSection:Button("Disable Lava Damage", function()
    local LavaFolder = workspace:WaitForChild("lavaTouchParts")
    for _, part in ipairs(LavaFolder:GetChildren()) do
        local t = part:FindFirstChildOfClass("TouchTransmitter") or part:FindFirstChild("TouchInterest")
        if t then t:Destroy() end
    end
    Library.Notify("Lava", "Lava damage disabled!", "Success", 3)
end)

-- FINISH
Library.Notify("LoS Ultimate", "Update: Race & x10k added!", "Success", 5)
