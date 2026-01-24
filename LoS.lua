--// 1. OPTIONAL SETTINGS TAB 
_G.showOptionalSettings = true

--// 2. FRAMEWORK 
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zidiu5/library-test/refs/heads/main/Framework.lua"))()

--// 3. SERVICES & REMOTES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local orbEvent = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("orbEvent")
local rebirthEvent = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("rebirthEvent")
local eggFunc = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("openCrystalRemote")
local giftFunc = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("freeGiftClaimRemote")

--// 4. TABS 
local OrbTab = Library:CreateTab("Orbs")
local EggTab = Library:CreateTab("Eggs & Gifts")
local MiscTab = Library:CreateTab("Rebirth & Race")

--// --- ORBS LOGIC ---
local orbList = {"Yellow Orb", "Blue Orb", "Red Orb", "Orange Orb", "Gem", "Ethereal Orb", "Infernal Gem"}
local locations = {"City", "Snow City", "Magma City", "Legends Highway", "Speed Jungle", "Desert"}
local selectedOrbLocation = locations[1]
local selectedOrbs = {}
local autoOrbs = false

OrbTab:Dropdown("Select Location", locations, function(val)
    selectedOrbLocation = val
end)

OrbTab:Dropdown("Select Orbs to Farm", orbList, function(option, state)
    selectedOrbs[option] = state
end, true)

OrbTab:Toggle("Ultra Fast Auto-Farm", false, function(state)
    autoOrbs = state
    if autoOrbs then
        task.spawn(function()
            while autoOrbs do
                for orbName, isSelected in pairs(selectedOrbs) do
                    if isSelected then
                        for i = 1, 15 do
                            orbEvent:FireServer("collectOrb", orbName, selectedOrbLocation)
                        end
                    end
                end
                task.wait() 
            end
        end)
    end
end, "Collects selected orb.")

OrbTab:Button("X10000 Instant Spawns", function()
    Library.Notify("Spawning", "Start massive-spawning...", "Success", 2)
    for orbName, isSelected in pairs(selectedOrbs) do
        if isSelected then
            for i = 1, 10000 do
                task.spawn(function()
                    orbEvent:FireServer("collectOrb", orbName, selectedOrbLocation)
                end)
            end
        end
    end
end, "Instantly collects 10,000 orbs.")

--// --- EGGS & GIFTS ---
local eggOptions = {"Jungle Crystal", "Electro Legends Crystal", "Inferno Crystal"}
local selectedEgg = eggOptions[1]
local eggAmount = 1

EggTab:Dropdown("Select Crystal", eggOptions, function(val)
    selectedEgg = val
end)

EggTab:TextBox("Amount to Open", function(val)
    eggAmount = tonumber(val) or 1
end)

EggTab:Button("Open Crystal(s)", function()
    for i = 1, eggAmount do
        task.spawn(function()
            pcall(function() eggFunc:InvokeServer("openCrystal", selectedEgg) end)
        end)
    end
end)

local autoGifts = false
EggTab:Toggle("Auto Claim Gifts (1-8)", false, function(state)
    autoGifts = state
    if autoGifts then
        task.spawn(function()
            while autoGifts do
                for i = 1, 8 do
                    pcall(function() giftFunc:InvokeServer("claimGift", i) end)
                end
                task.wait(10)
            end
        end)
    end
end)

--// --- REBIRTH & RACE ---
local autoRebirth = false
MiscTab:Toggle("Auto Rebirth", false, function(state)
    autoRebirth = state
    if autoRebirth then
        task.spawn(function()
            while autoRebirth do
                rebirthEvent:FireServer("rebirthRequest")
                task.wait(0.5)
            end
        end)
    end
end)

local function tp(x, y, z)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    end
end

MiscTab:Button("TP: Grasslands", function() tp(1646, 1, -5969) end)
MiscTab:Button("TP: Magma", function() tp(958, 1, -10979) end)
MiscTab:Button("TP: Desert", function() tp(6, 1, -8685) end)
MiscTab:Button("TP: Spawn", function() tp(-573, 4, 415) end)

--// FINALIZE
Library.Notify("LoS GUI Loaded", "Overdrive UI successfully initialized.", "Success", 5)
