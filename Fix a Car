local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local backpack = localPlayer:WaitForChild("Backpack")
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local workspacePlots = workspace:WaitForChild("Plots")

-- === GUI Setup ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoToolsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 350)
Frame.Position = UDim2.new(0.5, -150, 0.5, -175)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Frame.Visible = false
Frame.Active = true
Frame.Draggable = true

-- Open/Close Button separat
local OpenCloseGui = Instance.new("ScreenGui")
OpenCloseGui.Name = "OpenCloseButtonGUI"
OpenCloseGui.ResetOnSpawn = false
OpenCloseGui.Parent = localPlayer:WaitForChild("PlayerGui")

local OpenCloseBtn = Instance.new("TextButton")
OpenCloseBtn.Size = UDim2.new(0, 100, 0, 40)
OpenCloseBtn.Position = UDim2.new(0, 20, 0, 20)
OpenCloseBtn.Text = "Open GUI"
OpenCloseBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
OpenCloseBtn.BorderSizePixel = 0
OpenCloseBtn.Parent = OpenCloseGui

OpenCloseBtn.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
    OpenCloseBtn.Text = Frame.Visible and "Close GUI" or "Open GUI"
end)

-- === Helper: Toggle Buttons ===
local function createToggle(name, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 40)
    btn.Position = pos
    btn.Text = name .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.BorderSizePixel = 0
    btn.Parent = Frame

    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = name .. (enabled and ": ON" or ": OFF")
        callback(enabled)
    end)
end

-- === Toggle Status ===
local autoCleanEnabled = false
local autoFixBuyEnabled = false
local autoReplaceEnabled = false
local autoFixAllEnabled = false
local autoSandEnabled = false

-- === Part Mapping ===
local partMap = {Wheel="Wheel", Door="Door", Window="Windshield", Windshield="Windshield", Spoiler="Spoiler", FuelCap="Spoiler", Engine="Engine"}
local BuyRemote = ReplicatedStorage.Shared.RBXUtil.Net["RE/BuyItem"]
local FixRustRemote = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RBXUtil"):WaitForChild("Net"):WaitForChild("URE/Fix Rust")
local CleanRemote = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RBXUtil"):WaitForChild("Net"):WaitForChild("URE/Wash Dirt")

-- === Helper: Find all plots of player ===
local function getMyPlots()
    local plots = {}
    for _, plot in ipairs(workspacePlots:GetChildren()) do
        local config = plot:FindFirstChild("PlotConfig")
        if config and config:FindFirstChild("Owner") and config.Owner.Value == localPlayer then
            table.insert(plots, plot)
        end
    end
    return plots
end

-- === 1️⃣ AutoClean ===
local function autoClean(enabled)
    autoCleanEnabled = enabled
    if enabled then
        task.spawn(function()
            while autoCleanEnabled do
                for _, plot in ipairs(getMyPlots()) do
                    local car = plot:FindFirstChild("ActiveCar")
                    if car then
                        task.spawn(function()
                            for _, obj in ipairs(car:GetDescendants()) do
                                if obj.Name == "Dirt" then
                                    local target = obj:IsA("BasePart") and obj or obj:FindFirstChild("Dirt") or obj
                                    if target then
                                        CleanRemote:FireServer(target)
                                        task.wait(0.05)
                                    end
                                end
                            end
                        end)
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end

-- === 2️⃣ AutoFix+Buy ===
local function autoFixBuy(enabled)
    autoFixBuyEnabled = enabled
    if enabled then
        task.spawn(function()
            while autoFixBuyEnabled do
                for _, plot in ipairs(getMyPlots()) do
                    local car = plot:FindFirstChild("ActiveCar")
                    if car then
                        task.spawn(function()
                            local function getOwned(itemName)
                                local backpackItem = backpack:FindFirstChild(itemName)
                                return backpackItem and backpackItem:GetAttribute("Amount") or 0
                            end

                            local neededParts = {}
                            for _, fixRemote in ipairs(car:GetDescendants()) do
                                if fixRemote:IsA("RemoteEvent") and fixRemote.Name == "Fix" then
                                    local parent = fixRemote.Parent
                                    if parent then
                                        local partType
                                        if parent.Name == "FrontWindow" then partType="Windshield"
                                        elseif parent.Name == "EngineBlock" then partType="Engine"
                                        elseif parent.Name:match("^Wheel") then partType="Wheel"
                                        elseif parent.Name:match("^Door") then partType="Door"
                                        elseif parent.Name:match("^Window") then partType="Window"
                                        elseif partMap[parent.Name] then partType = parent.Name
                                        else partType = nil
                                        end

                                        if partType then
                                            neededParts[partType] = (neededParts[partType] or 0) + 1
                                        end
                                    end
                                    fixRemote:FireServer()
                                    task.wait(0.05)
                                end
                            end

                            for partType, count in pairs(neededParts) do
                                local itemName = partMap[partType]
                                if itemName then
                                    local owned = getOwned(itemName)
                                    local toBuy = math.max(0, count - owned)
                                    for i=1, toBuy do
                                        BuyRemote:FireServer("CarParts", itemName)
                                        task.wait(0.6)
                                    end
                                end
                            end
                        end)
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end

-- === 3️⃣ AutoReplace ===
local function autoReplace(enabled)
    autoReplaceEnabled = enabled
    if enabled then
        task.spawn(function()
            while autoReplaceEnabled do
                for _, plot in ipairs(getMyPlots()) do
                    local car = plot:FindFirstChild("ActiveCar")
                    if car then
                        task.spawn(function()
                            local function detectPartType(name)
                                if name == "FrontWindow" then return "Windshield"
                                elseif name == "EngineBlock" then return "Engine"
                                elseif name:match("^Wheel") then return "Wheel"
                                elseif name:match("^Door") then return "Door"
                                elseif name:match("^Window") then return "Window"
                                elseif partMap[name] then return name
                                else return nil end
                            end

                            for _, fixRemote in ipairs(car:GetDescendants()) do
                                if fixRemote:IsA("RemoteEvent") and fixRemote.Name == "Fix" then
                                    local parent = fixRemote.Parent
                                    if parent then
                                        local partType = detectPartType(parent.Name)
                                        local itemName = partMap[partType]
                                        if itemName then
                                            for _, item in ipairs(character:GetChildren()) do
                                                if item:IsA("Tool") then item.Parent = backpack end
                                            end
                                            local item = backpack:FindFirstChild(itemName)
                                            if item then item.Parent = character end
                                            fixRemote:FireServer()
                                            task.wait(0.6)
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end

-- === 4️⃣ Autofix All Parallel ===
local function autoFixAll(enabled)
    autoFixAllEnabled = enabled
    if enabled then
        task.spawn(function()
            while autoFixAllEnabled do
                for _, plot in ipairs(getMyPlots()) do
                    local car = plot:FindFirstChild("ActiveCar")
                    if car then
                        task.spawn(function()
                            -- 1️⃣ Clean
                            for _, obj in ipairs(car:GetDescendants()) do
                                if obj.Name == "Dirt" then
                                    local target = obj:IsA("BasePart") and obj or obj:FindFirstChild("Dirt") or obj
                                    if target then CleanRemote:FireServer(target) task.wait(0.05) end
                                end
                            end
                            task.wait(0.2)

                            -- 2️⃣ Repair & Buy
                            local fixRemotes = {}
                            local neededParts = {}
                            for _, fixRemote in ipairs(car:GetDescendants()) do
                                if fixRemote:IsA("RemoteEvent") and fixRemote.Name == "Fix" then
                                    table.insert(fixRemotes, fixRemote)
                                    fixRemote:FireServer()
                                    task.wait(0.05)
                                    local parent = fixRemote.Parent
                                    if parent then
                                        local partType
                                        if parent.Name == "FrontWindow" then partType="Windshield"
                                        elseif parent.Name == "EngineBlock" then partType="Engine"
                                        elseif parent.Name:match("^Wheel") then partType="Wheel"
                                        elseif parent.Name:match("^Door") then partType="Door"
                                        elseif parent.Name:match("^Window") then partType="Window"
                                        elseif partMap[parent.Name] then partType = parent.Name
                                        else partType = nil
                                        end
                                        if partType then
                                            neededParts[partType] = (neededParts[partType] or 0) + 1
                                        end
                                    end
                                end
                            end

                            local function getOwned(itemName)
                                local backpackItem = backpack:FindFirstChild(itemName)
                                return backpackItem and backpackItem:GetAttribute("Amount") or 0
                            end
                            for partType, count in pairs(neededParts) do
                                local itemName = partMap[partType]
                                if itemName then
                                    local owned = getOwned(itemName)
                                    local toBuy = math.max(0, count - owned)
                                    for i=1, toBuy do BuyRemote:FireServer("CarParts", itemName) task.wait(0.6) end
                                end
                            end

                            -- 3️⃣ Replace
                            for _, fixRemote in ipairs(fixRemotes) do
                                local parent = fixRemote.Parent
                                if parent then
                                    local partType
                                    if parent.Name == "FrontWindow" then partType="Windshield"
                                    elseif parent.Name == "EngineBlock" then partType="Engine"
                                    elseif parent.Name:match("^Wheel") then partType="Wheel"
                                    elseif parent.Name:match("^Door") then partType="Door"
                                    elseif parent.Name:match("^Window") then partType="Window"
                                    elseif partMap[parent.Name] then partType = parent.Name
                                    else partType = nil
                                    end
                                    local itemName = partMap[partType]
                                    if itemName then
                                        for _, item in ipairs(character:GetChildren()) do
                                            if item:IsA("Tool") then item.Parent = backpack end
                                        end
                                        local item = backpack:FindFirstChild(itemName)
                                        if item then item.Parent = character end
                                        fixRemote:FireServer()
                                        task.wait(0.6)
                                    end
                                end
                            end

                            -- 4️⃣ Finish Order
                            local mainCar = car:GetChildren()[1]
                            if mainCar and mainCar:GetAttribute("OrderIndex") then
                                local args = {tostring(mainCar:GetAttribute("OrderIndex"))}
                                ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RBXUtil"):WaitForChild("Net"):WaitForChild("RE/Finish Order"):FireServer(unpack(args))
                            end
                        end)
                    end
                end
                task.wait(1)
            end
        end)
    end
end

-- === 5️⃣ AutoSand Parallel ===
local function autoSand(enabled)
    autoSandEnabled = enabled
    if enabled then
        task.spawn(function()
            while autoSandEnabled do
                for _, plot in ipairs(getMyPlots()) do
                    local activeCar = plot:FindFirstChild("ActiveCar")
                    if activeCar then
                        task.spawn(function()
                            local function fixAllParts(parent)
                                for _, part in ipairs(parent:GetChildren()) do
                                    FixRustRemote:FireServer(part)
                                    if #part:GetChildren() > 0 then fixAllParts(part) end
                                end
                            end
                            for _, car in ipairs(activeCar:GetChildren()) do
                                fixAllParts(car)
                            end
                        end)
                    end
                end
                task.wait(1)
            end
        end)
    end
end

-- === Erstelle GUI Toggles ===
createToggle("AutoClean", UDim2.new(0,10,0,60), autoClean)
createToggle("AutoFix+Buy", UDim2.new(0,150,0,60), autoFixBuy)
createToggle("AutoReplace", UDim2.new(0,10,0,120), autoReplace)
createToggle("Autofix All", UDim2.new(0,150,0,120), autoFixAll)
createToggle("AutoSand", UDim2.new(0,10,0,180), autoSand)
