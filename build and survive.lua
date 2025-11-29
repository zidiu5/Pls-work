-- Lua (Fluent GUI) — Integrated Farm Script
-- Fügt dein bestehendes Farm-Script in Fluent Renewed ein (mobile-friendly, Resizeable, Settings-Tab, Save/Interface managers).
-- Keine zusätzlichen Fragen — alles was du geschickt hast wurde übernommen und in Fluent eingebaut.

--// LIBRARIES
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

--// SERVICES & BASIC
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local workspaceWait = workspace -- shorthand

--// REMOTES / PATHS (nutze exakt die Pfade die du gegeben hast)
local function GetRemotes()
    -- safe wait for the remotes/containers (blocking until available)
    local things = workspaceWait:WaitForChild("__THINGS")
    local remotes = things:WaitForChild("__REMOTES")
    local map = workspaceWait:WaitForChild("__MAP")
    local deb = workspaceWait:WaitForChild("__DEBRIS")
    return {
        MobRemote = remotes:WaitForChild("mobdodamage"),
        DropRemote = remotes:WaitForChild("redeemdrop"),
        PlaceBlockRemote = remotes:WaitForChild("placeblock"),
        Monsters = things:WaitForChild("Monsters"),
        MonsterDrops = deb:WaitForChild("MonsterDrops"),
        BuildArea = things:WaitForChild("BuildArea"),
        MapPart = map:WaitForChild("MAP"):WaitForChild("Part")
    }
end

local Remotes = GetRemotes()

--// CORE FUNCTIONS (deines Scripts, unverändert in Logik, nur etwas robuster gebettet)
local function DamageMobs(amount)
    -- iteriert alle Monster und feuert das Remote pro Mob (wrapped in pcall)
    for _, mob in pairs(Remotes.Monsters:GetChildren()) do
        local args = {
            {
                {
                    {
                        mob,
                        amount
                    }
                }
            }
        }
        pcall(function() Remotes.MobRemote:FireServer(unpack(args)) end)
    end
end

local function CollectDrops()
    for _, drop in pairs(Remotes.MonsterDrops:GetChildren()) do
        local uidObject = drop:FindFirstChild("UID")
        if uidObject then
            local args = {
                {
                    {
                        uidObject.Value,
                        "1b502290b3ca4943b055fb5f301d8a07"
                    }
                }
            }
            pcall(function() Remotes.DropRemote:FireServer(unpack(args)) end)
        end
    end
end

local function BuildCube()
    local corners = {
        {X=-252, Y=-8, Z=52,  target = Remotes.BuildArea},
        {X=112,  Y=-8, Z=52,  target = Remotes.BuildArea},
        {X=-252, Y=-8, Z=368, target = Remotes.BuildArea},
        {X=112,  Y=-8, Z=368, target = Remotes.MapPart},
        {X=-252, Y=72, Z=52,  target = Remotes.BuildArea},
        {X=112,  Y=72, Z=52,  target = Remotes.BuildArea},
        {X=-252, Y=72, Z=368, target = Remotes.BuildArea},
        {X=112,  Y=72, Z=368, target = Remotes.MapPart}
    }

    local step = 4 -- 1 Block = 4 studs

    local function buildLine3D(c1, c2)
        local steps = math.max(
            math.abs(c2.X - c1.X)/step,
            math.abs(c2.Y - c1.Y)/step,
            math.abs(c2.Z - c1.Z)/step
        )
        if steps < 1 then steps = 1 end
        for i = 0, steps do
            local x = c1.X + (c2.X - c1.X) * (i/steps)
            local y = c1.Y + (c2.Y - c1.Y) * (i/steps)
            local z = c1.Z + (c2.Z - c1.Z) * (i/steps)
            local args = {
                {
                    CFrame.new(x, y, z, 1,0,0,0,1,0,0,0,1),
                    "Metal",
                    c1.target
                }
            }
            pcall(function() Remotes.PlaceBlockRemote:FireServer(unpack(args)) end)
            task.wait(0.03) -- leichtes Throttling, damit Server nicht überfordert wird
        end
    end

    for i = 1, #corners do
        for j = i+1, #corners do
            buildLine3D(corners[i], corners[j])
        end
    end
end

--// STATE
local AutoCollect = false

--// FLUENT GUI SETUP
local Window = Library:CreateWindow{
    Title = `Fluent {Library.Version}`,
    SubTitle = "by Actual Master Oogway",
    TabWidth = 160,
    Size = UDim2.fromOffset(830, 525), -- mobile-friendly but resizable
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

-- Quick notification that script loaded
Library:Notify{
    Title = "Fluent",
    Content = "Farm GUI loaded into Fluent.",
    Duration = 6
}

--// MAIN TAB - Controls (entspricht deiner GUI)
Tabs.Main:CreateParagraph("Intro", {
    Title = "Farm GUI (Fluent)",
    Content = "Buttons mirror your original GUI: Instant Kill / Heal / Autocollect / Build Cube.\nMobile-friendly & resizable."
})

Tabs.Main:CreateButton{
    Title = "Instant Kill All Mobs (10000)",
    Description = "Sends damage remote for all monsters.",
    Callback = function()
        task.spawn(function() DamageMobs(10000) end)
        Library:Notify{ Title = "Action", Content = "Instant Kill triggered.", Duration = 3 }
    end
}

Tabs.Main:CreateButton{
    Title = "Instant Heal All Mobs (-1000)",
    Description = "Heals all monsters (negative damage).",
    Callback = function()
        task.spawn(function() DamageMobs(-1000) end)
        Library:Notify{ Title = "Action", Content = "Instant Heal triggered.", Duration = 3 }
    end
}

-- Autocollect toggle (Fluent Toggle element)
local AutoToggle = Tabs.Main:CreateToggle("AutoCollectToggle", {
    Title = "Autocollect",
    Default = false,
    Description = "Automatically redeems drops when ON"
})

AutoToggle:OnChanged(function()
    AutoCollect = AutoToggle.Value
    Library:Notify{ Title = "Autocollect", Content = AutoCollect and "ON" or "OFF", Duration = 2 }
end)

Tabs.Main:CreateButton{
    Title = "Build 8-Corner Cube",
    Description = "Places blocks to build cube edges.",
    Callback = function()
        task.spawn(function() BuildCube() end)
        Library:Notify{ Title = "Action", Content = "Building cube (may take a while).", Duration = 3 }
    end
}

-- optional: quick manual Collect button
Tabs.Main:CreateButton{
    Title = "Collect Drops Now",
    Description = "Redeem all current monster drops.",
    Callback = function()
        task.spawn(function() CollectDrops() end)
        Library:Notify{ Title = "Action", Content = "Collecting drops.", Duration = 2 }
    end
}

--// SETTINGS TAB: SaveManager + InterfaceManager integration (wie in deinem Snippet)
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes{}
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

-- Select first tab
Window:SelectTab(1)

--// AUTOCOLLECT LOOP (RunService.RenderStepped analog — nutze Heartbeat für stabilität auf mobile)
RunService.Heartbeat:Connect(function()
    if AutoCollect then
        -- safe spawn to avoid blocking
        task.spawn(CollectDrops)
    end
end)

--// CLEANUP (optional) - falls Library entladen wird
task.spawn(function()
    while true do
        task.wait(1)
        if Library.Unloaded then
            -- cleanup logic falls benötigt
            break
        end
    end
end)

-- End of integrated Fluent GUI script
