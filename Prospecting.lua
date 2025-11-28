--==============================================================
-- FLUENT GUI LADEN
--==============================================================

local Library = loadstring(game:HttpGetAsync(
    "https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"
))()

local Window = Library:CreateWindow{
    Title = "Prospecting GUI",
    SubTitle = "by Zidiu1",
    Size = UDim2.fromOffset(500, 500),
    Resize = true,
    Theme = "Dark"
}

local Tabs = {
    Main = Window:CreateTab{Title = "Pans", Icon = "phosphor-users-bold"},
    Teleports = Window:CreateTab{Title = "Teleports", Icon = "phosphor-rocket-bold"},
    ESP = Window:CreateTab{Title = "ESP", Icon = "phosphor-eye-bold"},
    Shop = Window:CreateTab{Title = "Shop", Icon = "phosphor-shopping-cart-bold"}
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--==============================================================
-- ALLE PAN NAMEN AUTOMATISCH LADEN
--==============================================================

local PanFolder = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Pans")
local PanNames = {}

for _, pan in ipairs(PanFolder:GetChildren()) do
    table.insert(PanNames, pan.Name)
end

--==============================================================
-- AKTIVE PAN FINDEN
--==============================================================

local function GetEquippedPan()
    local char = LocalPlayer.Character
    if not char then return nil end

    for _, panName in ipairs(PanNames) do
        if char:FindFirstChild(panName) then
            return char[panName]
        end
    end

    return nil
end

--==============================================================
-- COLLECT / PAN / SHAKE – GLOBAL TOGGLES
--==============================================================

-- ========== COLLECT ==========

local CollectToggle = Tabs.Main:CreateToggle("CollectAll", {
    Title = "Collect dirt🤮",
    Default = false
})

CollectToggle:OnChanged(function(state)
    spawn(function()
        while state and not Library.Unloaded do
            local pan = GetEquippedPan()
            if pan then
                local collect = pan:WaitForChild("Scripts"):WaitForChild("Collect")
                local args = {1}
                collect:InvokeServer(unpack(args))
            end
            task.wait(0.01)
        end
    end)
end)

-- ========== PAN ==========

local PanToggle = Tabs.Main:CreateToggle("PanAll", {
    Title = "Pan",
    Default = false
})

PanToggle:OnChanged(function(state)
    spawn(function()
        while state and not Library.Unloaded do
            local pan = GetEquippedPan()
            if pan then
                local panCall = pan:WaitForChild("Scripts"):WaitForChild("Pan")
                panCall:InvokeServer()
            end
            task.wait(0.01)
        end
    end)
end)

-- ========== SHAKE ==========

local ShakeToggle = Tabs.Main:CreateToggle("ShakeAll", {
    Title = "Shake",
    Default = false
})

ShakeToggle:OnChanged(function(state)
    spawn(function()
        while state and not Library.Unloaded do
            local pan = GetEquippedPan()
            if pan then
                local shake = pan:WaitForChild("Scripts"):WaitForChild("Shake")
                shake:FireServer()
            end
            task.wait(0.05)
        end
    end)
end)

--==============================================================
-- SELL ALL BUTTON
--==============================================================

Tabs.Main:CreateButton{
    Title = "Sell All",
    Description = "Sells all items",
    Callback = function()
        ReplicatedStorage.Remotes.Shop.SellAll:InvokeServer()
    end
}

--==============================================================
-- ESP TAB – ACTIVE TOTEMS
--==============================================================

local ESPToggle = Tabs.ESP:CreateToggle("TotemESP", {
    Title = "Totem ESP",
    Default = false
})

local ESPEnabled = false
local ESPConnections = {}

local function createESP(model)
    if not ESPEnabled then return end
    if model:FindFirstChild("ESP") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Adornee = model.PrimaryPart
    billboard.Size = UDim2.new(0,100,0,50)
    billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1,0,0)
    text.TextScaled = true
    text.Font = Enum.Font.SourceSansBold
    text.Text = model.Name
    text.Parent = billboard
end

ESPToggle:OnChanged(function(state)
    ESPEnabled = state

    if state then
        for _, m in ipairs(workspace.ActiveTotems:GetChildren()) do
            if m:IsA("Model") then createESP(m) end
        end
        ESPConnections.ChildAdded =
            workspace.ActiveTotems.ChildAdded:Connect(function(m)
                if m:IsA("Model") then createESP(m) end
            end)
    else
        if ESPConnections.ChildAdded then ESPConnections.ChildAdded:Disconnect() end
        for _, m in ipairs(workspace.ActiveTotems:GetChildren()) do
            if m:FindFirstChild("ESP") then m.ESP:Destroy() end
        end
    end
end)

--==============================================================
-- TELEPORT TAB
--==============================================================

local Waypoints = workspace.Map.Waypoints
local waypointNames = {}

for _, m in ipairs(Waypoints:GetChildren()) do
    if m:IsA("Model") and m.Name ~= "Rubble Creek" then
        table.insert(waypointNames, m.Name)
    end
end

local selectedTarget = waypointNames[1]

Tabs.Teleports:CreateDropdown("FastTravelDrop", {
    Title = "Choose Area",
    Values = waypointNames,
    Multi = false,
    Default = selectedTarget
}):OnChanged(function(v)
    selectedTarget = v
end)

Tabs.Teleports:CreateButton{
    Title = "Teleport to area",
    Callback = function()
        local args = {
            Waypoints["Rubble Creek"],
            Waypoints[selectedTarget]
        }
        ReplicatedStorage.Remotes.Misc.FastTravel:FireServer(unpack(args))
    end
}

Tabs.Teleports:CreateButton{
    Title = "TP to all Geodes",
    Callback = function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        for _, model in ipairs(workspace.Geode:GetChildren()) do
            if model:IsA("Model") then
                local cf = model.PrimaryPart and model.PrimaryPart.CFrame or model:GetModelCFrame()
                hrp.CFrame = cf + Vector3.new(0,3,0)
                task.wait(0.3)
            end
        end
    end
}

--==============================================================
-- SHOP TAB
--==============================================================

local amountInput = Tabs.Shop:CreateInput("ShopAmount", {
    Title = "Amount",
    Default = "1",
    Numeric = true
})

local function buyItem(town, item)
    local amount = tonumber(amountInput.Value) or 1
    local shopItem = workspace.Purchasable[town][item].ShopItem
    local args = {shopItem, amount}
    ReplicatedStorage.Remotes.Shop.BuyItem:InvokeServer(unpack(args))
end

Tabs.Shop:CreateButton{
    Title = "Buy Basic Capacity Potion",
    Callback = function() buyItem("RiverTown", "Basic Capacity Potion") end
}

Tabs.Shop:CreateButton{
    Title = "Buy Basic Luck Potion",
    Callback = function() buyItem("RiverTown", "Basic Luck Potion") end
}

Tabs.Shop:CreateButton{
    Title = "Buy Greater Luck Potion",
    Callback = function() buyItem("RiverTown", "Greater Luck Potion") end
}

--==============================================================
-- NOTIFY
--==============================================================

Library:Notify{
    Title = "GAY GUI",
    Content = "GUI LOADED!",
    Duration = 5
}
