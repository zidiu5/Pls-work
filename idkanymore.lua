-- ==================== REMOTE RENAMER (LOOP) ====================
-- Holy AI Comments
local Network = require(game:GetService("ReplicatedStorage").Library.Client.Network)

local function getUpvalueSafe(func, index)
    local success, value = pcall(debug.getupvalue, func, index)
    return success and value or nil
end

local function renameRemotes()
    local fireFunc = Network.Fire

    -- Upvalues extrahieren
    local u39 = getUpvalueSafe(fireFunc, 2)
    if not u39 then return end

    local u35 = getUpvalueSafe(u39, 1)
    local u19 = getUpvalueSafe(u39, 2)
    if not u35 or not u19 then return end

    local u20 = getUpvalueSafe(u35, 1)
    local u3 = getUpvalueSafe(u19, 1)
    if not u20 or not u3 then return end

    local renamedCount = 0

    for typ = 1, 2 do
        local nameToHash = u3[typ]
        local hashToRemote = u20[typ]

        if nameToHash and hashToRemote then
            for origName, hash in pairs(nameToHash) do
                local remote = hashToRemote[hash]
                if not remote then
                    remote = game:GetService("ReplicatedStorage"):FindFirstChild(hash)
                end

                if remote and remote.Name ~= origName then
                    remote.Name = origName
                    renamedCount = renamedCount + 1
                end
            end
        end
    end
end

-- Einmalig vor dem UI-Start ausführen
renameRemotes()

-- Alle 3 Sekunden im Hintergrund ausführen
task.spawn(function()
    while true do
        task.wait(3)
        pcall(renameRemotes)
    end
end)


-- ==================== RAYFIELD UI & MAIN SCRIPT ====================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Pet Simulator - Custom Autofarm",
   LoadingTitle = "Pet Simulator Script",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)
local FarmTab = Window:CreateTab("Farm", 4483362458)

-- Services
local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Things = workspace:WaitForChild("__THINGS")
local PetsFolder = Things:WaitForChild("Pets")
local CoinsFolder = Things:WaitForChild("Coins")
local OrbsFolder = Things:WaitForChild("Orbs")

-- Remotes werden dynamisch aus ReplicatedStorage geholt (Name wurde durch Renamer gefixt)
local function getJoinRemote()
    return Services.ReplicatedStorage:FindFirstChild("Join Coin")
end

local function getFarmRemote()
    return Services.ReplicatedStorage:FindFirstChild("Farm Coin")
end

-- Variables
local autoOrbsEnabled = false
local autoFarmRunning = false
local farmMode = "Closest Coin" 
local multipleFarm = false
local selectedArea = nil
local afterJoinDelay = 0.05

-- Helper: Attributes/Values auslesen
local function getAttr(obj, name)
    local ok, v = pcall(function() return obj:GetAttribute(name) end)
    if ok and v ~= nil then return v end
    local c = obj:FindFirstChild(name)
    if c and c.Value ~= nil then return c.Value end
    return nil
end

-- Helper: Hole das RootPart des Spielers
local function getRootPart()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    end
    return nil
end

-- Helper: Meine Pets abrufen
local function getMyPets()
    local myPets = {}
    for _, pet in ipairs(PetsFolder:GetChildren()) do
        local owner = getAttr(pet, "Owner")
        if owner and (tostring(owner) == LocalPlayer.Name or tostring(owner) == tostring(LocalPlayer.UserId)) then
            table.insert(myPets, pet.Name)
        end
    end
    return myPets
end

-- Helper: Alle Areas sammeln
local function collectAreas()
    local set = {}
    for _, c in pairs(CoinsFolder:GetChildren()) do
        local a = getAttr(c, "Area")
        if a then set[a] = true end
    end
    local t = {}
    for k in pairs(set) do table.insert(t, k) end
    table.sort(t)
    if #t == 0 then return {"None"} end
    return t
end

-- Helper: Coins in bestimmter Area holen
local function coinsInArea(area)
    local out = {}
    for _, c in pairs(CoinsFolder:GetChildren()) do
        if getAttr(c, "Area") == area then
            table.insert(out, c.Name)
        end
    end
    return out
end

-- Helper: Nächstgelegene Coin finden
local function getClosestCoin()
    local rootPart = getRootPart()
    if not rootPart then return nil end
    
    local rootPos = rootPart.Position
    local closestCoin = nil
    local shortestDistance = math.huge

    for _, coin in ipairs(CoinsFolder:GetChildren()) do
        local posPart = coin:FindFirstChild("POS") or coin:FindFirstChildWhichIsA("BasePart")
        if posPart then
            local distance = (rootPos - posPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestCoin = coin
            end
        end
    end

    return closestCoin
end

-- Safely Executing Remotes
local function safeInvokeJoin(coinId, pets)
    local joinRemote = getJoinRemote()
    if joinRemote then
        pcall(function() joinRemote:InvokeServer(coinId, pets) end)
    end
end

local function safeFarm(coinId, petId)
    local farmRemote = getFarmRemote()
    if farmRemote then
        pcall(function() farmRemote:FireServer(coinId, petId) end)
    end
end


-- ==================== MAIN TAB (ORBS TP) ====================

local function tpOrb(orb)
    local rootPart = getRootPart()
    if not rootPart then return end

    local basePos = rootPart.Position + Vector3.new(0, 3, 0)
    local offset = Vector3.new(
        math.random(-3, 3),
        math.random(-1, 2),
        math.random(-3, 3)
    )

    if orb:IsA("BasePart") then
        orb.CFrame = CFrame.new(basePos + offset)
    elseif orb:IsA("Model") then
        local primary = orb.PrimaryPart or orb:FindFirstChildWhichIsA("BasePart")
        if primary then
            orb:SetPrimaryPartCFrame(CFrame.new(basePos + offset))
        end
    end
end

OrbsFolder.ChildAdded:Connect(function(child)
    if autoOrbsEnabled then
        tpOrb(child)
    end
end)

MainTab:CreateToggle({
   Name = "Auto TP Orbs",
   CurrentValue = false,
   Flag = "AutoOrbsToggle",
   Callback = function(Value)
       autoOrbsEnabled = Value
       if autoOrbsEnabled then
           task.spawn(function()
               while autoOrbsEnabled do
                   for _, orb in pairs(OrbsFolder:GetChildren()) do
                       tpOrb(orb)
                   end
                   task.wait(0.3)
               end
           end)
       end
   end,
})


-- ==================== FARM TAB ====================

FarmTab:CreateDropdown({
    Name = "Farm Target Mode",
    Options = {"Closest Coin", "Selected Area"},
    CurrentOption = {"Closest Coin"},
    Flag = "TargetModeSelect",
    Callback = function(Option)
        farmMode = type(Option) == "table" and Option[1] or Option
    end
})

local initialAreas = collectAreas()
local areaDropdown = FarmTab:CreateDropdown({
    Name = "Select Area",
    Options = initialAreas,
    CurrentOption = {initialAreas[1]},
    Flag = "AreaSelect",
    Callback = function(Option)
        selectedArea = type(Option) == "table" and Option[1] or Option
    end
})

FarmTab:CreateButton({
    Name = "🔄 Refresh Areas",
    Callback = function()
        areaDropdown:Refresh(collectAreas())
    end
})

FarmTab:CreateToggle({
    Name = "Multiple Farm (Split Pets on Coins)",
    CurrentValue = false,
    Flag = "MultipleFarmToggle",
    Callback = function(state)
        multipleFarm = state
    end
})

FarmTab:CreateToggle({
    Name = "Start Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(state)
        autoFarmRunning = state
        if not autoFarmRunning then return end

        task.spawn(function()
            while autoFarmRunning do
                local pets = getMyPets()
                if #pets == 0 then 
                    task.wait(0.5)
                    continue 
                end

                local targetCoins = {}

                if farmMode == "Closest Coin" then
                    local closest = getClosestCoin()
                    if closest then
                        table.insert(targetCoins, closest.Name)
                    end
                elseif farmMode == "Selected Area" and selectedArea and selectedArea ~= "None" then
                    targetCoins = coinsInArea(selectedArea)
                end

                if #targetCoins == 0 then
                    task.wait(0.3)
                    continue
                end

                if multipleFarm then
                    for i, petId in ipairs(pets) do
                        if not autoFarmRunning then break end
                        local coinId = targetCoins[(i - 1) % #targetCoins + 1]
                        task.spawn(function()
                            safeInvokeJoin(coinId, { petId })
                            task.wait(afterJoinDelay)
                            safeFarm(coinId, petId)
                        end)
                    end
                    task.wait(0.05)
                else
                    local coinId = targetCoins[1]
                    if coinId then
                        safeInvokeJoin(coinId, pets)
                        task.wait(afterJoinDelay)
                        for _, petId in ipairs(pets) do
                            safeFarm(coinId, petId)
                        end
                        
                        repeat task.wait(0.1)
                        until not CoinsFolder:FindFirstChild(coinId) or not autoFarmRunning
                    else
                        task.wait(0.1)
                    end
                end
            end
        end)
    end
})
