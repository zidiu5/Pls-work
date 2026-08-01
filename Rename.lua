
local replicatedStorage = game:GetService("ReplicatedStorage")

-- ===================== SHA256 (reines Lua) =====================
local function sha256(msg)
    local K = {
        0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
        0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
        0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
        0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
        0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
        0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
        0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
        0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
    }

    local function rrot(x, n)
        return bit32.bor(bit32.rshift(x, n), bit32.lshift(x, 32 - n))
    end

    local function ch(x, y, z)
        return bit32.bxor(bit32.band(x, y), bit32.band(bit32.bnot(x), z))
    end

    local function maj(x, y, z)
        return bit32.bxor(bit32.bxor(bit32.band(x, y), bit32.band(x, z)), bit32.band(y, z))
    end

    local function sigma0(x)
        return bit32.bxor(rrot(x, 2), rrot(x, 13), rrot(x, 22))
    end

    local function sigma1(x)
        return bit32.bxor(rrot(x, 6), rrot(x, 11), rrot(x, 25))
    end

    local function gamma0(x)
        return bit32.bxor(rrot(x, 7), rrot(x, 18), bit32.rshift(x, 3))
    end

    local function gamma1(x)
        return bit32.bxor(rrot(x, 17), rrot(x, 19), bit32.rshift(x, 10))
    end

    local msg_len = #msg * 8
    msg = msg .. "\128"
    while (#msg * 8) % 512 ~= 448 do
        msg = msg .. "\0"
    end

    local len_bytes = string.char(
        bit32.band(bit32.rshift(msg_len, 56), 0xff),
        bit32.band(bit32.rshift(msg_len, 48), 0xff),
        bit32.band(bit32.rshift(msg_len, 40), 0xff),
        bit32.band(bit32.rshift(msg_len, 32), 0xff),
        bit32.band(bit32.rshift(msg_len, 24), 0xff),
        bit32.band(bit32.rshift(msg_len, 16), 0xff),
        bit32.band(bit32.rshift(msg_len, 8),  0xff),
        bit32.band(msg_len, 0xff)
    )
    msg = msg .. len_bytes

    local H0, H1, H2, H3, H4, H5, H6, H7 =
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
        0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19

    for i = 1, #msg, 64 do
        local chunk = msg:sub(i, i + 63)
        local W = {}
        for j = 1, 16 do
            local b = chunk:sub(j*4 - 3, j*4)
            W[j] = bit32.bor(
                bit32.lshift(b:byte(1), 24),
                bit32.lshift(b:byte(2), 16),
                bit32.lshift(b:byte(3), 8),
                b:byte(4)
            )
        end
        for j = 17, 64 do
            W[j] = bit32.band(
                gamma1(W[j-2]) + W[j-7] + gamma0(W[j-15]) + W[j-16],
                0xffffffff
            )
        end

        local a, b, c, d, e, f, g, h = H0, H1, H2, H3, H4, H5, H6, H7

        for j = 1, 64 do
            local T1 = bit32.band(h + sigma1(e) + ch(e,f,g) + K[j] + W[j], 0xffffffff)
            local T2 = bit32.band(sigma0(a) + maj(a,b,c), 0xffffffff)
            h = g
            g = f
            f = e
            e = bit32.band(d + T1, 0xffffffff)
            d = c
            c = b
            b = a
            a = bit32.band(T1 + T2, 0xffffffff)
        end

        H0 = bit32.band(H0 + a, 0xffffffff)
        H1 = bit32.band(H1 + b, 0xffffffff)
        H2 = bit32.band(H2 + c, 0xffffffff)
        H3 = bit32.band(H3 + d, 0xffffffff)
        H4 = bit32.band(H4 + e, 0xffffffff)
        H5 = bit32.band(H5 + f, 0xffffffff)
        H6 = bit32.band(H6 + g, 0xffffffff)
        H7 = bit32.band(H7 + h, 0xffffffff)
    end

    return string.format("%08x%08x%08x%08x%08x%08x%08x%08x", H0, H1, H2, H3, H4, H5, H6, H7)
end

-- ==================== Hash-Berechnung ====================
local function getRemoteName(realName, typ)
    local jobId = game.JobId
    if jobId == "" then jobId = "00000000-0000-0000-0000-000000000000" end
    local salt = "LORUSSYIFYOUSEETHISYOUAREAFUCKINGPUSSYOFANEXPLOITERLMAO/Network4/"
    local input = salt .. game.GameId .. "/" .. game.PlaceId .. "/" .. game.PlaceVersion .. "/"
                .. jobId .. "/" .. tostring(typ) .. "/" .. realName
    local hash = sha256(input)
    return hash:sub(5, 36)  -- 32 Zeichen (Position 5 bis 36)
end

-- ==================== Sichere Upvalue-Suche ====================
local function getUpvalueSafe(func, index)
    local success, value = pcall(debug.getupvalue, func, index)
    if success then
        return value
    end
    return nil
end

local function findInternalTable()
    local network = require(replicatedStorage:WaitForChild("Library"):WaitForChild("Client"):WaitForChild("Network"))
    local fireFunc = network.Fire

    local function search(func, depth)
        if depth > 20 then return nil end
        local i = 1
        while true do
            local value = getUpvalueSafe(func, i)
            if value == nil then break end
            if type(value) == "table" then
                -- Prüfen, ob es die gesuchte Tabelle ist
                if value[1] and type(value[1]) == "table" and value[2] and type(value[2]) == "table" then
                    local hasRemote = false
                    for _, v in pairs(value[1]) do
                        if typeof(v) == "Instance" and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
                            hasRemote = true
                            break
                        end
                    end
                    if hasRemote then return value end
                end
                -- Rekursion in der Tabelle
                for _, v in pairs(value) do
                    if type(v) == "function" then
                        local res = search(v, depth + 1)
                        if res then return res end
                    end
                end
            elseif type(value) == "function" then
                local res = search(value, depth + 1)
                if res then return res end
            end
            i = i + 1
        end
        return nil
    end

    return search(fireFunc, 0)
end

-- ==================== Namenslisten (aus internenamen.txt) ====================
-- RemoteEvents
local eventNames = {
    "Using Fuse Pets Machine", "Diamond Party: Buy", "Upgrade Bought", "New Stats",
    "Get Pet Positions", "Update Trade Invites Open", "Enchant Pets", "Use Rainbow Machine",
    "Spinny Wheel: Update", "Orb Removed", "ExclusiveShopOpened", "Equip Hoverboard",
    "Update Event Countdown", "Get Item Rarity DB", "Merchant Departed", "Chat Msg",
    "Buy Admin Merchant Item", "Kawaii Alley: Enabled", "Toggle Auto Hatch Setting",
    "FastHatchBoost", "Buy Trading Plaza", "Redeem VIP Rewards", "RobuxHugeUpdated",
    "FireDragonDropGet", "Verify Group", "Use Golden Machine", "Remove Coin",
    "Process Pending Start", "Dark Matter Machine Redeemed", "Attempt Buy Octuple Eggs",
    "Use Flag", "Upgrade Potion Machine", "Update Hoverboard State", "Orb Added",
    "Claim Orbs", "Pet Update", "Reset Auto Settings", "Attempt Buy 15 Pets Equipped",
    "Unequip All Pets", "Try Sign Pet", "Update Item Gui", "Dark Matter Timer Skipped",
    "Auto Delete Enabled", "Upgrade Station Animation", "Entity Updates", "Stop Event Countdown",
    "Redeem Rank Rewards", "PS99: Communicate Offset", "Toggle Setting", "Notification",
    "Toggle Hardcore Mode", "Get Global Eggs Leaderboard", "Leave Coin", "Select Coin",
    "Update Trade", "Toggle Auto Delete", "New Item", "Toggle Always Keep Setting",
    "Is Admin Merchant Here", "TitanicDropPurchase", "Huge Pegasus Notification",
    "Teleport To Player", "Submit Vote", "Clear Inventory Notifications", "Redeem Merch Code",
    "Cannon Fired", "RobuxHugeGet", "Unequip Pet", "Request Cannon Launch",
    "Hoverboard_Unequipped", "Lootbox Pet Reward", "Send Position", "Travel to Main Place",
    "Pet Added", "Redeem Pet Collection", "Merchant Arrival", "Sent Progress Notification",
    "Redeem Dark Matter Pet", "Admin Merchant Arrival", "Get Local Power Leaderboard",
    "Add Coin", "Mastery Leveled Up", "Redeem Corrupted Pet", "Send Message",
    "Is Merchant Here", "Pet Positions", "Player Statues: Get Statue Data",
    "Redeem All Corrupted Pets", "Rebirth 2", "Gamepass Bought", "Consume Potion",
    "OneHitBreakable", "Coin Bonus", "Read Changelog", "Get Diamonds Pack Prices",
    "Lootbox Animation", "Entity Clear Updates", "Pet Equip Changed", "Prompt Dark Matter Skip",
    "Start Shutdown", "Raffle Updated", "Buy Upgrade", "Performed Teleport",
    "Notification Opt In State", "Pick Starter", "Raffle Global Winner", "Get Local Leaderboard",
    "Join Coin", "Redeem All Dark Matter Pets", "Crafting: Pending Updated",
    "Trade Processing Resolved", "Admin Merchant Departed", "Hoverboard_Equipped",
    "Damage Coin", "Start Event Countdown", "TitanicDropGet", "Buy Egg",
    "Get Update Countdown Details", "Update Coin Special Bonus", "FireDragonDropUpdated",
    "Using Rainbow Machine", "Buy Dominus Gate", "Get Robux Spent Leaderboard",
    "Events: Reset", "Fireworks Animation", "Get Rebirth 2 State", "Equip Pet",
    "Fuse Pets", "Get Diamond Supply", "Get Rebirth 1 State", "Exclusive Eggs: Compute Positions",
    "Exclusive Eggs: Open", "Get OSTime", "Hoverboard State Changed", "Get Merchant Timer",
    "Product Failed", "Get Merchant Items", "Lock Pet", "Get Like Goal", "Trade Cancelled",
    "F2pTitanicDeal1", "Get Global Power Leaderboard", "Consume Item", "Events: Update",
    "Achievement Completed", "Get Coins", "Get Coin Targets", "Raffle Local Winner",
    "Update Coin Pets", "Capybara Apple Fix", "Delete Several Pets", "Product Bought",
    "Set Riding Pet", "Verify Twitter", "Spinny Wheel: Animate", "Farm Coin",
    "Update Vote Signs", "Claim Login Streak", "Exclusive Eggs: Lucky", "Init Trade",
    "Equip Best Pets", "Boost Activated", "Diamonds Packs", "Update Coin Health",
    "Force Teleport", "Merchant Updated", "Inventory Slots Given", "Convert To Corrupted",
    "Rewards Redeemed", "Exclusive Shop: Exclusive Egg", "Explode Pet", "Check Opening Status",
    "Cannon Fire", "Notification Opt In Mark Prompted", "Rank Goal Progress",
    "Hoverboard Unlocked", "Buy Merchant Item", "Buy Hacker Gate", "FireDragonDropPurchaseDiamonds",
    "AdminAbuse:GlobalMessage", "Trade Errored", "Dark Matter Machine Used",
    "Process Pending Stop", "Buy Gamepass With Diamonds", "Hoverboard Shop: Buy",
    "Trade Processing Pending", "Rank Changed", "Start Dance Party Fireworks",
    "Remove Lootbag", "Fishing: Other", "Buy Area", "Pet Target Coin", "PS99: Countdown Debug",
    "MilestoneCelebrationBoost", "Reset Player", "Convert To Dark Matter", "Pet Target Player",
    "Get Admin Merchant Timer", "Trade Sent Chat Result", "Change Pet Target",
    "Grab All Entities", "Player Teleported", "Open Egg", "Admin Merchant Updated",
    "Redeem Twitter Code", "Lootbox Currency Reward", "Rename Pet", "Trade Processed",
    "Travel to Trading Plaza", "Spawn Lootbag", "Rebirth 1", "Events: Complete",
    "Trade Recieved", "Exclusive Eggs: Animation", "TitanicDropUpdated", "Boost Ended",
    "Trade Ignored", "Using Golden Machine", "Buy Teleport Area", "Blunder Report",
    "Get Admin Merchant Items", "Play Fireworks", "Enchanted Pets", "PlaySound",
    "Message", "Spooky Upgrade Animation", "Player Statues: Pool loaded", "Collect Lootbag",
    "Finished Tutorial", "Pet Removed", "BreathOfFireBreakable", "Force Load World"
}

-- RemoteFunctions
local functionNames = {
    "Set Riding Pet", "Diamond Party: Buy", "Upgrade Bought", "Get Pet Positions",
    "Enchant Pets", "Use Rainbow Machine", "Convert To Corrupted", "Orb Removed",
    "ExclusiveShopOpened", "Is Merchant Here", "Update Coin Pets", "Get Item Rarity DB",
    "Merchant Departed", "Get Coins", "Buy Admin Merchant Item", "Kawaii Alley: Enabled",
    "Toggle Auto Hatch Setting", "FastHatchBoost", "Buy Trading Plaza", "Redeem VIP Rewards",
    "Teleport To Player", "Enchanted Pets", "Process Pending Start", "Dark Matter Machine Redeemed",
    "Attempt Buy Octuple Eggs", "Orb Added", "Get Robux Spent Leaderboard",
    "Attempt Buy 15 Pets Equipped", "Update Item Gui", "Dark Matter Timer Skipped",
    "Auto Delete Enabled", "Upgrade Station Animation", "Stop Event Countdown", "Coin Bonus",
    "Notification", "Get Global Eggs Leaderboard", "Leave Coin", "Select Coin",
    "Get OSTime", "Is Admin Merchant Here", "TitanicDropPurchase", "Get Stats",
    "Clear Inventory Notifications", "Equip Best Pets", "Unequip Pet", "Read Changelog",
    "Travel to Main Place", "Get Rebirth 2 State", "Sent Progress Notification",
    "Admin Merchant Arrival", "Get Local Power Leaderboard", "Add Coin", "Mastery Leveled Up",
    "Get Invites Open", "Send Message", "Buy Area", "Player Statues: Get Statue Data",
    "Admin Merchant Departed", "Exclusive Eggs: Lucky", "Consume Potion", "OneHitBreakable",
    "Verify Group", "Trade Processing Resolved", "Get Diamonds Pack Prices", "Using Golden Machine",
    "Rebirth 2", "Using Fuse Pets Machine", "Use Golden Machine", "Start Shutdown",
    "Farm Coin", "Use Flag", "Upgrade Potion Machine", "Redeem Rank Rewards", "Pick Starter",
    "Update Hoverboard State", "Update Event Countdown", "Check Opening Status", "Request World",
    "Update Coin Health", "Buy Upgrade", "Claim Login Streak", "Submit Vote", "Damage Coin",
    "Hoverboard_GetState", "TitanicDropGet", "Unequip All Pets", "Try Sign Pet",
    "Update Coin Special Bonus", "FireDragonDropUpdated", "Using Rainbow Machine",
    "Get Rebirth 1 State", "Trade Processing Pending", "Get Merchant Timer", "Fireworks Animation",
    "Toggle Setting", "Equip Pet", "Fuse Pets", "Get Local Leaderboard", "Toggle Hardcore Mode",
    "Exclusive Eggs: Compute Positions", "Exclusive Eggs: Open", "Toggle Auto Delete",
    "Hoverboard State Changed", "Toggle Always Keep Setting", "Cannon Fire", "TitanicDropUpdated",
    "Lock Pet", "Start Event Countdown", "Start Dance Party Fireworks", "F2pTitanicDeal1",
    "Get Global Power Leaderboard", "Consume Item", "Gamepass Bought", "Achievement Completed",
    "Send Position", "RobuxHugeUpdated", "Rewards Redeemed", "Reset Player", "Reset Auto Settings",
    "Request Cannon Launch", "Performed Teleport", "Get Pet Rarity DB", "Verify Twitter",
    "Remove Coin", "Get Diamond Supply", "Update Vote Signs", "Redeem All Corrupted Pets",
    "Redeem Merch Code", "Redeem Dark Matter Pet", "Redeem Corrupted Pet", "Boost Activated",
    "Redeem All Dark Matter Pets", "Redeem Pet Collection", "Force Teleport", "Merchant Updated",
    "New Item", "Spinny Wheel: Request Wheels", "Rank Goal Progress", "Exclusive Shop: Exclusive Egg",
    "Explode Pet", "Equip Hoverboard", "PS99: Countdown Debug", "Notification Opt In Mark Prompted",
    "PS99: Communicate Offset", "Hoverboard Unlocked", "Prompt Dark Matter Skip", "Product Failed",
    "FireDragonDropPurchaseDiamonds", "Buy Gamepass With Diamonds", "Finished Tutorial",
    "Dark Matter Machine Used", "Process Pending Stop", "Product Bought", "Hoverboard Shop: Buy",
    "Buy Egg", "Rank Changed", "Player Statues: Pool loaded", "Remove Lootbag",
    "Huge Pegasus Notification", "Notification Opt In State", "Inventory Slots Given",
    "Get Merchant Items", "MilestoneCelebrationBoost", "Pet Target Player", "Convert To Dark Matter",
    "Get Like Goal", "Get Admin Merchant Timer", "Pet Target Coin", "Change Pet Target",
    "Pet Positions", "Player Teleported", "Buy Dominus Gate", "Admin Merchant Updated",
    "Redeem Twitter Code", "Diamonds Packs", "Rename Pet", "Open Egg", "Travel to Trading Plaza",
    "Spawn Lootbag", "Rebirth 1", "Merchant Arrival", "Buy Hacker Gate", "Exclusive Eggs: Animation",
    "Join Coin", "Get Update Countdown Details", "Boost Ended", "Buy Merchant Item",
    "Buy Teleport Area", "Delete Several Pets", "Get Admin Merchant Items", "Play Fireworks",
    "Has Loaded", "Claim Orbs", "Get Coin Targets", "Spooky Upgrade Animation",
    "BreathOfFireBreakable", "Collect Lootbag", "Cannon Fired", "RobuxHugeGet",
    "FireDragonDropGet", "Force Load World", "Crafting: Start", "Crafting: Claim", "Convert To Dark Matter"
}

-- ==================== Hauptlogik ====================
print("=== Starte Remote-Entschleierung ===")

-- 1. Interne Tabelle finden
local internal = findInternalTable()
if not internal then
    warn("Konnte interne Tabelle (v_u_20) nicht finden – Abbruch.")
    return
end
print("Interne Tabelle erfolgreich gefunden.")


local function renameFromList(nameList, typ)
    local count = 0
    local map = internal[typ]  -- typ 1 = Events, 2 = Functions
    if not map then
        warn("Keine Einträge für Typ " .. tostring(typ) .. " in der internen Tabelle.")
        return 0
    end
    for _, realName in ipairs(nameList) do
        local hash = getRemoteName(realName, typ)
        local remoteObj = map[hash]
        if remoteObj then
            remoteObj.Name = realName
            count = count + 1
            print("[RENAMED] " .. hash .. " -> " .. realName .. " (Typ " .. typ .. ")")
        end
    end
    return count
end


local eCount = renameFromList(eventNames, 1)
local fCount = renameFromList(functionNames, 2)

print(string.format("Finished: %d RemoteEvents and %d RemoteFunctions renamed. Insgesamt: %d",
    eCount, fCount, eCount + fCount))
