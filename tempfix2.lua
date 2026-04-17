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

-- Password Logic
local function hash(str)
    local hashed = 0
    for i = 1, #str do hashed = (hashed * 31 + str:byte(i)) % 2^32 end
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
PasswordFrame.Parent = PasswordScreen
PasswordFrame.Active = true
PasswordFrame.Draggable = true

local PasswordBox = Instance.new("TextBox")
PasswordBox.Size = UDim2.new(0, 260, 0, 34)
PasswordBox.Position = UDim2.new(0.5, -130, 0.5, -8)
PasswordBox.PlaceholderText = "Password"
PasswordBox.Parent = PasswordFrame

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0, 80, 0, 34)
SubmitBtn.Position = UDim2.new(0.5, 90, 0.5, -8)
SubmitBtn.Text = "OK"
SubmitBtn.Parent = PasswordFrame

local function tryPassword(input)
    if hash(input) == correctHash then
        PasswordScreen:Destroy()
        createAutofarmGUI()
    end
end

SubmitBtn.MouseButton1Click:Connect(function() tryPassword(PasswordBox.Text) end)

function createAutofarmGUI()
    local win = Library.new({title = "Autofarm GUI - Fixed Hatch"})
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

    -- === HELPER ===
    local function getAttr(obj, name)
        local ok, v = pcall(function() return obj:GetAttribute(name) end)
        return (ok and v) or (obj:FindFirstChild(name) and obj:FindFirstChild(name).Value)
    end

    -- === MAIN & FARM (Unverändert) ===
    win:AddToggle(mainTab, "Auto Collect", false, function(state)
        autoCollect = state
        task.spawn(function()
            while autoCollect do pcall(function() claimOrbsRemote:FireServer({{"all"}}) end) task.wait(0.5) end
        end)
    end)

    -- === EGGS TAB (KORRIGIERT) ===
    local folderList = EGG_DIR:GetChildren()
    table.sort(folderList, function(a,b) return a.Name < b.Name end)

    for _, folder in pairs(folderList) do
        local eggNames = {"None"}
        for _, egg in pairs(folder:GetChildren()) do table.insert(eggNames, egg.Name) end
        win:AddDropdown(eggsTab, folder.Name, eggNames, function(selected)
            for k, v in pairs(selected) do
                if v and k ~= "None" then
                    selectedFolder = folder
                    selectedEgg = k
                end
            end
        end)
    end

    -- Korrigierte Hatch-Modus Auswahl
    win:AddDropdown(eggsTab, "Hatch Mode", {"Single", "Triple", "Octuple"}, function(selected)
        for k,v in pairs(selected) do
            if v then hatchMode = k end
        end
    end)

    -- Der verbesserte Hatch-Loop
    win:AddToggle(eggsTab, "Start Hatch", false, function(state)
        autoHatch = state
        if not autoHatch then return end
        
        task.spawn(function()
            while autoHatch do
                if selectedEgg then
                    local arg2, arg3, arg4 = false, false, false
                    
                    -- Deine neuen Argument-Logiken:
                    if hatchMode == "Single" then
                        arg2, arg3, arg4 = false, false, false
                    elseif hatchMode == "Triple" then
                        arg2, arg3, arg4 = true, false, false
                    elseif hatchMode == "Octuple" then
                        arg2, arg3, arg4 = false, true, true
                    end
                    
                    -- Sende alle 4 Argumente an den Server
                    local args = { { selectedEgg, arg2, arg3, arg4 } }
                    pcall(function() 
                        buyEggRemote:InvokeServer(unpack(args)) 
                    end)
                end
                task.wait(0.6) -- Kleiner Delay gegen Lags
            end
        end)
    end)

    -- SHOP TAB (Unverändert)
    local diamondPacks = {
        {id = 1, text = "Diamond Pack 1"},
        {id = 2, text = "Diamond Pack 2"},
        {id = 3, text = "Diamond Pack 3"},
        {id = 4, text = "Diamond Pack 4"}
    }

    for _, pack in ipairs(diamondPacks) do
        win:AddToggle(shopTab, pack.text, false, function(state)
            task.spawn(function()
                while state do
                    pcall(function() REMOTES:WaitForChild("buy diamondpack"):InvokeServer({pack.id}) end)
                    task.wait(1)
                end
            end)
        end)
    end
end
