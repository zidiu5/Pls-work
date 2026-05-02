local Network = require(game:GetService("ReplicatedStorage"):WaitForChild("Library"):WaitForChild("Client"):WaitForChild("Network"))
local shareddata = getupvalue(getupvalue(getrawmetatable(Network).__index, 1).Invoke, 2)

local function beautify()
    local hashstorage = getupvalue(getupvalue(shareddata, 2), 1)
    local remotestorage = getupvalue(getupvalue(shareddata, 1), 1)
    local nameLookup = {}
    for i = 1, #hashstorage do
        for name, id in next, hashstorage[i] do nameLookup[id] = name end
    end
    for i = 1, #remotestorage do
        for id, remoteObj in next, remotestorage[i] do
            if nameLookup[id] and remoteObj.Name ~= nameLookup[id] then
                remoteObj.Name = nameLookup[id]
            end
        end
    end
end

task.spawn(function()
    while true do
        pcall(beautify)
        task.wait(5)
    end
end)

local ZidiuUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/musicmaker-web/ZidiuUI/refs/heads/main/ZidiuUI.lua"))()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SaveModule = require(ReplicatedStorage.Library.Client.Save)


local Window = ZidiuUI:CreateWindow("PSX Ultimate AIO")
ZidiuUI:SetToastPosition("bottom-right")

local MainTab = Window:CreateTab("Main Stats", "📈")
local MainSection = MainTab:CreateSection("Precision Injector (1 Orb)")

local precisionAmount = 10
MainSection:CreateTextbox("Ammount", "10", function(text)
    precisionAmount = tonumber(text) or 0
end)

local selectedStat = "MaxEquipped"
local statOptions = {
    "MaxEquipped",
    "MaxSlots",
    "Quest Points",
    "RobuxSpent",
    "CollectionTier",
    "BoothDiamondsEarned",
    "MerchantLevel",
    "TitanicHatched",
    "FriendsBoost",
    "Age"
}

MainSection:CreateDropdown("Select Stat", statOptions, function(selected)
    selectedStat = selected
end)

local precisionActive = false
local PrecisionToggle = MainSection:CreateToggle("Wait for Orb & Inject", false, function(state)
    precisionActive = state
end)

local LiveLabel = MainSection:CreateLabel("Current Value: Loading...")

local CoinTab = Window:CreateTab("Currencies", "💰")
local CoinSection = CoinTab:CreateSection("Auto-Farm Settings")

local allCoinTypes = {
    "ALL COINS",
    "Coins", "Fantasy Coins", "Tech Coins", "Rainbow Coins", "Diamonds",
    "Popsicles", "Pog Coins", "Easter Coins", "Clover Coins", 
    "Lucky Coins", "Valentine Hearts", "Cartoon Coins", "Gingerbread", "Error Coins"
}

local selectedCoins = {}
CoinSection:CreateSearchDropdown("Select Currency", allCoinTypes, function(selectedList)
    local isAll = false
    for _, v in ipairs(selectedList) do if v == "ALL COINS" then isAll = true break end end
    
    if isAll then
        selectedCoins = {}
        for i = 2, #allCoinTypes do table.insert(selectedCoins, allCoinTypes[i]) end
        ZidiuUI:Notify("Currency!", "success", 2)
    else
        selectedCoins = selectedList
    end
end, true)

local cyclingActive = false
CoinSection:CreateToggle("Start Coin Cycler", false, function(state)
    cyclingActive = state
    if state and #selectedCoins == 0 then
        ZidiuUI:Notify("No Coin Selected!", "error", 3)
    end
end)


task.spawn(function()
    local coinIdx = 1
    
    while true do
        local things = workspace:FindFirstChild("__THINGS")
        local orbs = things and things:FindFirstChild("Orbs")
        local remote = ReplicatedStorage:FindFirstChild("Claim Orbs")
        
        if orbs and remote then
            local children = orbs:GetChildren()
            
            if #children > 0 then
                if precisionActive then
                    local orb = children[1]
                    remote:FireServer({{
                        type = selectedStat,
                        ids = {orb.Name},
                        amount = precisionAmount
                    }})
                    
                    ZidiuUI:Notify(selectedStat .. " increased by " .. precisionAmount, "success", 3)
                    orb:Destroy()
                    precisionActive = false
                    PrecisionToggle:SetState(false) 
                
                
                elseif cyclingActive and #selectedCoins > 0 then
                    local currentTarget = selectedCoins[coinIdx]
                    local batch = {}
                    
                    for _, o in ipairs(children) do
                        table.insert(batch, {
                            type = currentTarget,
                            ids = {o.Name},
                            amount = 10^15
                        })
                        o:Destroy()
                    end
                    
                    pcall(function() remote:FireServer(batch) end)
                    coinIdx = (coinIdx % #selectedCoins) + 1
                end
            end
        end
        
        local data = SaveModule.Get()
        if data and selectedStat then
            local val = data[selectedStat] or 0
            LiveLabel:SetText("Current " .. selectedStat .. ": " .. tostring(val))
        end
        
        task.wait(0.2)
    end
end)

ZidiuUI:Notify("Ultimate PSX Script Loaded!", "success", 4)
