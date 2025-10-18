-- AutoDelete Pets (Polling Save) - Mit Keep Gold & Rainbow pro Rarity

-- == Services ==
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace_ = workspace
local LocalPlayer = Players.LocalPlayer
local Remotes = workspace_:WaitForChild("__THINGS"):WaitForChild("__REMOTES")
local PetsFolder = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Pets")

print("✅ [Init] AutoDelete (Polling) geladen")

-- == Save Module ==
local SaveModule
local ok,res = pcall(function()
    return require(ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Modules"):WaitForChild("Client"):WaitForChild("4 | Save"))
end)
if ok and res then
    SaveModule = res
    print("🔁 [Save] SaveModule geladen")
else
    warn("❌ [Save] Konnte SaveModule nicht require() - Polling versucht trotzdem")
end

-- == Settings ==
local rarities = {"Basic","Rare","Epic","Legendary","Mythical","Exclusive"}
local DeleteSettings = {}
local KeepSettings = {}
for _,r in ipairs(rarities) do
    DeleteSettings[r] = false
    KeepSettings[r] = { Gold=false, Rainbow=false }
end

-- == GUI ==
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoDeleteGUI_Poll"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 500, 0, 300)
Frame.Position = UDim2.new(0.3,0,0.3,0)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,8)

local Title = Instance.new("TextLabel")
Title.Text = "AutoDelete Pets"
Title.Size = UDim2.new(1,0,0,32)
Title.Position = UDim2.new(0,0,0,0)
Title.BackgroundColor3 = Color3.fromRGB(40,40,40)
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.Parent = Frame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0,8)

-- Helper: Button erstellen
local function createButton(parent, text, posX, toggleTable, key1, key2)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 80, 0, 24)
    btn.Position = UDim2.new(0, posX, 0, 0)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)

    btn.MouseButton1Click:Connect(function()
        if key2 then
            toggleTable[key1][key2] = not toggleTable[key1][key2]
            btn.BackgroundColor3 = toggleTable[key1][key2] and Color3.fromRGB(0,200,100) or Color3.fromRGB(80,80,80)
            print("🔘 [Toggle] "..key1.." Keep "..key2.." = "..tostring(toggleTable[key1][key2]))
        else
            toggleTable[key1] = not toggleTable[key1]
            btn.BackgroundColor3 = toggleTable[key1] and Color3.fromRGB(200,0,0) or Color3.fromRGB(80,80,80)
            print("🔘 [Toggle] Delete "..key1.." = "..tostring(toggleTable[key1]))
        end
    end)
    return btn
end

-- GUI erstellen
for i, rarity in ipairs(rarities) do
    local y = 36 + (i-1)*34
    local rowFrame = Instance.new("Frame", Frame)
    rowFrame.Size = UDim2.new(1,-20,0,28)
    rowFrame.Position = UDim2.new(0,10,0,y)
    rowFrame.BackgroundTransparency = 1

    -- Delete Toggle
    createButton(rowFrame, rarity, 0, DeleteSettings, rarity, nil)
    -- Keep Gold
    createButton(rowFrame, "Gold", 120, KeepSettings, rarity, "Gold")
    -- Keep Rainbow
    createButton(rowFrame, "Rainbow", 220, KeepSettings, rarity, "Rainbow")
end

print("✅ [GUI] Buttons erstellt")

-- == Helper: Pet Rarity ==
local function getPetRarity(petId)
    if not petId then return nil end
    for _,pf in ipairs(PetsFolder:GetChildren()) do
        local num = pf.Name:match("^(%d+)")
        if num and tostring(num)==tostring(petId) then
            for _,child in ipairs(pf:GetChildren()) do
                if child:IsA("ModuleScript") then
                    local ok,res = pcall(require,child)
                    if ok and res and res.rarity then return res.rarity end
                end
            end
        end
    end
    return nil
end

-- == Delete Function ==
local function deletePets(uids)
    if not uids or #uids==0 then return end
    print("🗑️ [Delete] Versuch, "..#uids.." Pets: "..table.concat(uids,", "))
    local args = { { {uids}, {false} } }
    local ok,res = pcall(function() return Remotes:WaitForChild("delete several pets"):InvokeServer(unpack(args)) end)
    if ok then print("✅ [Delete] InvokeServer erfolgreich") else warn("❌ [Delete] Fehlgeschlagen: "..tostring(res)) end
end

-- == Save Extraction ==
local function extractPetsFromSave(save)
    if not save then return {} end
    if save.Inventory and save.Inventory.Pets then return save.Inventory.Pets end
    if save.Pets then return save.Pets end
    for k,v in pairs(save) do
        if type(v)=="table" then
            for _,entry in pairs(v) do
                if type(entry)=="table" and (entry.uid or entry.id) then return v end
            end
        end
    end
    return {}
end

-- == Polling ==
local prevUIDs = {}
local pollingInterval = 0.6

spawn(function()
    while true do
        local success, save = pcall(function() if SaveModule and SaveModule.Get then return SaveModule.Get(LocalPlayer) else return nil end end)
        if not success then save=nil end

        local petsTable = extractPetsFromSave(save)
        local currentUIDs={}
        local petEntries={}
        if petsTable then
            for k,entry in pairs(petsTable) do
                if type(entry)=="table" then
                    if entry.uid then currentUIDs[entry.uid]=true; petEntries[entry.uid]=entry
                    elseif tostring(k):sub(1,2)=="id" then currentUIDs[tostring(k)]=true; petEntries[tostring(k)]=entry end
                end
            end
        end

        local newUIDs = {}
        for uid,_ in pairs(currentUIDs) do if not prevUIDs[uid] then table.insert(newUIDs,uid) end end

        if #newUIDs>0 then
            print("🥚 Neue Pets entdeckt: "..table.concat(newUIDs,", "))
            local toDelete={}
            for _,uid in ipairs(newUIDs) do
                local entry=petEntries[uid]
                local petId=entry and (entry.id or entry.idt)
                if not petId then
                    for k,v in pairs(petsTable) do
                        if type(v)=="table" then
                            for _,sub in pairs(v) do
                                if type(sub)=="table" and sub.uid==uid then petId=sub.id; break end
                            end
                        end
                        if petId then break end
                    end
                end

                local rarity = getPetRarity(petId)
                local keep = false
                if entry and rarity then
                    if entry.g and KeepSettings[rarity].Gold then keep=true end
                    if entry.r and KeepSettings[rarity].Rainbow then keep=true end
                end

                if petId then
                    if not keep and rarity and DeleteSettings[rarity] then
                        table.insert(toDelete,uid)
                        print("🗑️ [Markiert] UID "..uid.." (ID "..petId..", "..rarity..")")
                    else
                        print("✅ [Behalte] UID "..uid.." (ID "..tostring(petId)..", "..tostring(rarity)..")")
                    end
                else
                    warn("⚠️ Konnte petId für UID "..tostring(uid).." nicht ermitteln")
                end
            end

            if #toDelete>0 then
                local batchSize=10
                for i=1,#toDelete,batchSize do
                    local batch={}
                    for j=i,math.min(i+batchSize-1,#toDelete) do table.insert(batch,toDelete[j]) end
                    task.wait(0.25)
                    deletePets(batch)
                end
            else
                print("ℹ️ Keine Pets markiert")
            end
        end

        prevUIDs={}
        for uid,_ in pairs(currentUIDs) do prevUIDs[uid]=true end
        task.wait(pollingInterval)
    end
end)

print("🚀 AutoDelete Polling läuft. Toggles: Delete + Keep Gold/Rainbow pro Rarity.")
