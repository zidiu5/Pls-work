local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zidiu5/library-test/refs/heads/main/library.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local THINGS = workspace:WaitForChild("__THINGS")
local REMOTES = THINGS:WaitForChild("__REMOTES")
local COINS = THINGS:WaitForChild("Coins")
local PETS = THINGS:WaitForChild("Pets")
local ORBS = THINGS:WaitForChild("Orbs")

local joinRemote = REMOTES:WaitForChild("join coin")
local farmRemote = REMOTES:WaitForChild("farm coin")
local claimOrbsRemote = REMOTES:WaitForChild("claim orbs")

local afterJoinDelay = 0.05

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

-- === GUI ===
local win = Library.new({title = "Autofarm GUI"})
local mainTab = win:AddTab("Main")
local farmTab = win:AddTab("Farm")

local selectedArea = nil
local running = false
local multiple = false
local autoCollect = false

-- MAIN TAB
local collectToggleId = select(1, win:AddToggle(mainTab, "Autocollect", false, function(state)
    autoCollect = state
    if not autoCollect then return end

    task.spawn(function()
        while autoCollect do
            collectOrbs()
            task.wait(0.2)
        end
    end)
end))

-- FARM TAB
local dropdownId = select(1, win:AddDropdown(farmTab, "Area wählen", collectAreas(), function(selected)
    for k,v in pairs(selected) do
        if v then selectedArea = k end
    end
end))

local refreshBtnId = select(1, win:AddButton(farmTab, "🔄 Refresh Areas", function()
    win:UpdateDropdown(dropdownId, collectAreas())
end))

local multipleToggleId = select(1, win:AddToggle(farmTab, "Multiple Farm", false, function(state)
    multiple = state
end))

local farmToggleId = select(1, win:AddToggle(farmTab, "Autofarm", false, function(state)
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
                    repeat
                        task.wait(0.1)
                    until not COINS:FindFirstChild(coinId) or not running
                else
                    task.wait(0.1)
                end
            end
        end
    end)
end))
