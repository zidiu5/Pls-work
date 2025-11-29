
--// LIBRARIES
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

--// VARIABLES
local teleporting = false
local invisible = false
local noclipConn, antiFallBV
local positions = {
    Vector3.new(-40, 35, 1371),
    Vector3.new(-61, 33, 2140),
    Vector3.new(-76, 41, 2909),
    Vector3.new(-87, 42, 3678),
    Vector3.new(-41, 48, 4450),
    Vector3.new(-88, 54, 5220),
    Vector3.new(-63, 49, 5990),
    Vector3.new(-83, 63, 6759),
    Vector3.new(-64, 51, 7530),
    Vector3.new(-99, 49, 8298),
    Vector3.new(-120, 179, 9132),
    Vector3.new(-56, -359, 9496)
}

--// HELPER FUNCTIONS
local function waitForCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")
    return char, hrp, humanoid
end

local function enableNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

local function disableNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
end

local function preventFalling(hrp)
    if not antiFallBV then
        antiFallBV = Instance.new("BodyVelocity")
        antiFallBV.Velocity = Vector3.new(0,0,0)
        antiFallBV.MaxForce = Vector3.new(0,math.huge,0)
        antiFallBV.Parent = hrp
    end
end

local function allowFalling()
    if antiFallBV then
        antiFallBV:Destroy()
        antiFallBV = nil
    end
end

local function tweenTo(hrp, pos)
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

local function restartAfterRespawn()
    local _, _, humanoid = waitForCharacter()
    repeat task.wait(0.2) until humanoid.Health >= humanoid.MaxHealth
    task.wait(2)
end

local function doFarm()
    task.spawn(function()
        while teleporting do
            local char, hrp, humanoid = waitForCharacter()
            enableNoclip()
            preventFalling(hrp)

            local died = false
            local diedConn = humanoid.Died:Connect(function() died = true end)

            for i, pos in ipairs(positions) do
                if not teleporting or died then break end
                tweenTo(hrp, pos)
                if i < #positions then
                    task.wait(0.1)
                else
                    allowFalling()
                    disableNoclip()
                    local waited = 0
                    while waited < 15 and humanoid.Health > 0 and teleporting do
                        task.wait(1)
                        waited += 1
                    end
                end
            end

            diedConn:Disconnect()
            if died then restartAfterRespawn() end
        end
    end)
end

local function setInvisible(state)
    local char = player.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if part.Name ~= "HumanoidRootPart" then part.Transparency = state and 1 or 0 end
        elseif part:IsA("Decal") then
            part.Transparency = state and 1 or 0
        elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
            part.Handle.Transparency = state and 1 or 0
        end
    end
end

player.CharacterAdded:Connect(function(char)
    if invisible then
        task.wait(1)
        setInvisible(true)
    end
end)

--// FLUENT GUI SETUP
local Window = Library:CreateWindow{
    Title = `Simple Hub {Library.Version}`,
    SubTitle = "by Zidiu1",
    TabWidth = 160,
    Size = UDim2.fromOffset(700, 450),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
}

local Tabs = {
    Main = Window:CreateTab{ Title = "Main", Icon = "phosphor-users-bold" },
    Settings = Window:CreateTab{ Title = "Settings", Icon = "settings" }
}

-- MAIN TAB
Tabs.Main:CreateParagraph("Intro", {
    Title = "Simple Hub",
    Content = "Farm & Invisible features, fully Fluent GUI integrated."
})

-- Buttons
local FarmButton = Tabs.Main:CreateToggle("FarmToggle", {
    Title = "Farm",
    Default = false
})

FarmButton:OnChanged(function()
    teleporting = FarmButton.Value
    if teleporting then
        StarterGui:SetCore("SendNotification", {Title="Farm", Text="Farm started!", Duration=3})
        doFarm()
    else
        allowFalling()
        disableNoclip()
        StarterGui:SetCore("SendNotification", {Title="Farm", Text="Farm stopped!", Duration=3})
    end
end)

local InvisButton = Tabs.Main:CreateToggle("InvisibleToggle", {
    Title = "Invisible",
    Default = false
})

InvisButton:OnChanged(function()
    invisible = InvisButton.Value
    setInvisible(invisible)
    StarterGui:SetCore("SendNotification", {
        Title="Invisible",
        Text=invisible and "You are now invisible!" or "You are now visible!",
        Duration=3
    })
end)

-- SETTINGS TAB
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)
