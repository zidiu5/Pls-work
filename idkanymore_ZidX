local Network = require(game:GetService("ReplicatedStorage").Library.Client.Network);
local function getUpvalueSafe(func, index)
	local success, value = pcall(debug.getupvalue, func, index);
	return (success and value) or nil;
end
local function renameRemotes()
	local fireFunc = Network.Fire;
	local u39 = getUpvalueSafe(fireFunc, 2);
	if u39 then
		local u35 = getUpvalueSafe(u39, 1);
		local u19 = getUpvalueSafe(u39, 2);
		if (u35 and u19) then
			local u20 = getUpvalueSafe(u35, 1);
			local u3 = getUpvalueSafe(u19, 1);
			if (u20 and u3) then
				for typ = 1, 2 do
					local nameToHash = u3[typ];
					local hashToRemote = u20[typ];
					if (nameToHash and hashToRemote) then
						for origName, hash in pairs(nameToHash) do
							local remote = hashToRemote[hash];
							if not remote then
								remote = game:GetService("ReplicatedStorage"):FindFirstChild(hash);
							end
							if (remote and (remote.Name ~= origName)) then
								remote.Name = origName;
							end
						end
					end
				end
			end
		end
	end
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/zidiu5/Pls-work/refs/heads/main/Rename.lua"))();
	end);
end
renameRemotes();
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/musicmaker-web/ZidX/refs/heads/main/ZidX.lua"))();
local Window = UILibrary.CreateWindow({Theme="Frost",Size=UDim2.new(0, 560, 0, 380)});
local MainTab = Window:CreateTab("Main", "⚡");
local MainSection = MainTab:CreateSection("Collectables");
local FarmTab = Window:CreateTab("Farm", "🌾");
local FarmSection = FarmTab:CreateSection("Autofarm Controls");
local EggsTab = Window:CreateTab("Eggs", "🥚");
local EggsSection = EggsTab:CreateSection("Egg Hatching");
local Services = {Players=game:GetService("Players"),ReplicatedStorage=game:GetService("ReplicatedStorage"),RunService=game:GetService("RunService")};
local LocalPlayer = Services.Players.LocalPlayer;
local Things = workspace:WaitForChild("__THINGS");
local PetsFolder = Things:WaitForChild("Pets");
local CoinsFolder = Things:WaitForChild("Coins");
local OrbsFolder = Things:WaitForChild("Orbs");
local LootbagsFolder = Things:WaitForChild("Lootbags");
local Directory = Services.ReplicatedStorage:WaitForChild("__DIRECTORY");
local EggDir = Directory:WaitForChild("Eggs");
local function getJoinRemote()
	return Services.ReplicatedStorage:FindFirstChild("Join Coin");
end
local function getFarmRemote()
	return Services.ReplicatedStorage:FindFirstChild("Farm Coin");
end
local function getClaimOrbsRemote()
	return Services.ReplicatedStorage:FindFirstChild("Claim Orbs") or Services.ReplicatedStorage:FindFirstChild("claim orbs");
end
local function getCollectLootbagRemote()
	return Services.ReplicatedStorage:FindFirstChild("Collect Lootbag") or Services.ReplicatedStorage:FindFirstChild("collect lootbag");
end
local function getBuyEggRemote()
	return Services.ReplicatedStorage:FindFirstChild("buy egg") or Services.ReplicatedStorage:FindFirstChild("Buy Egg") or Services.ReplicatedStorage:FindFirstChild("RemoteFunction");
end
local autoOrbsEnabled = false;
local autoLootbagsEnabled = false;
local autoFarmRunning = false;
local farmMode = "Closest Coin";
local multipleFarm = false;
local selectedArea = nil;
local selectedFolder = nil;
local selectedEgg = nil;
local autoHatch = false;
local hatchMode = "Single";
local orbCache = {};
local function getAttr(obj, name)
	local ok, v = pcall(function()
		return obj:GetAttribute(name);
	end);
	if (ok and (v ~= nil)) then
		return v;
	end
	local c = obj:FindFirstChild(name);
	if (c and (c.Value ~= nil)) then
		return c.Value;
	end
	return nil;
end
local function getRootPart()
	local char = LocalPlayer.Character;
	if char then
		return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso");
	end
	return nil;
end
local function getMyPets()
	local myPets = {};
	for _, pet in ipairs(PetsFolder:GetChildren()) do
		local owner = getAttr(pet, "Owner");
		if (owner and ((tostring(owner) == LocalPlayer.Name) or (tostring(owner) == tostring(LocalPlayer.UserId)))) then
			table.insert(myPets, pet.Name);
		end
	end
	return myPets;
end
local function collectAreas()
	local set = {};
	for _, c in pairs(CoinsFolder:GetChildren()) do
		local a = getAttr(c, "Area");
		if a then
			set[a] = true;
		end
	end
	local t = {};
	for k in pairs(set) do
		table.insert(t, k);
	end
	table.sort(t);
	if (#t == 0) then
		return {"None"};
	end
	return t;
end
local function coinsInArea(area)
	local out = {};
	for _, c in pairs(CoinsFolder:GetChildren()) do
		if (getAttr(c, "Area") == area) then
			table.insert(out, c.Name);
		end
	end
	return out;
end
local function getClosestCoin()
	local rootPart = getRootPart();
	if not rootPart then
		return nil;
	end
	local rootPos = rootPart.Position;
	local closestCoin = nil;
	local shortestDistance = math.huge;
	for _, coin in ipairs(CoinsFolder:GetChildren()) do
		local posPart = coin:FindFirstChild("POS") or coin:FindFirstChildWhichIsA("BasePart");
		if posPart then
			local distance = (rootPos - posPart.Position).Magnitude;
			if (distance < shortestDistance) then
				shortestDistance = distance;
				closestCoin = coin;
			end
		end
	end
	return closestCoin;
end
local function safeInvokeJoin(coinId, pets)
	local joinRemote = getJoinRemote();
	if joinRemote then
		pcall(function()
			joinRemote:InvokeServer(coinId, pets);
		end);
	end
end
local function safeFarm(coinId, petId)
	local farmRemote = getFarmRemote();
	if farmRemote then
		pcall(function()
			farmRemote:FireServer(coinId, petId);
		end);
	end
end
local function processOrbQueue()
	local claimOrbsRemote = getClaimOrbsRemote();
	if (not claimOrbsRemote or (#orbCache == 0)) then
		return;
	end
	local packSize = math.min(30, #orbCache);
	local orbPayload = {};
	for i = 1, packSize do
		local orbId = table.remove(orbCache, 1);
		table.insert(orbPayload, {ids={[1]=orbId}});
	end
	if (#orbPayload > 0) then
		pcall(function()
			claimOrbsRemote:FireServer(orbPayload);
		end);
	end
end
local function collectLootbags()
	local collectLootbagRemote = getCollectLootbagRemote();
	if not collectLootbagRemote then
		return;
	end
	for _, bag in ipairs(LootbagsFolder:GetChildren()) do
		local bagName = bag.Name;
		local pos = (bag:IsA("BasePart") and bag.Position) or Vector3.new(0, 0, 0);
		bag:Destroy();
		pcall(function()
			collectLootbagRemote:FireServer(bagName, pos);
		end);
	end
end
MainSection:CreateToggle({Text="Auto Claim Orbs (30 pro Remote)",Default=false,Flag="AutoOrbsToggle",Callback=function(Value)
	autoOrbsEnabled = Value;
	if autoOrbsEnabled then
		task.spawn(function()
			while autoOrbsEnabled do
				for _, orb in ipairs(OrbsFolder:GetChildren()) do
					local orbId = orb.Name;
					orb:Destroy();
					table.insert(orbCache, orbId);
				end
				if (#orbCache >= 30) then
					processOrbQueue();
				elseif (#orbCache > 0) then
					task.wait(0.2);
					processOrbQueue();
				end
				task.wait(0.05);
			end
		end);
	end
end});
MainSection:CreateToggle({Text="Auto Collect Lootbags (Einzeln)",Default=false,Flag="AutoLootbagsToggle",Callback=function(Value)
	autoLootbagsEnabled = Value;
	if autoLootbagsEnabled then
		task.spawn(function()
			while autoLootbagsEnabled do
				collectLootbags();
				task.wait(0.1);
			end
		end);
	end
end});
FarmSection:CreateDropdown({Text="Farm Target Mode",Options={"Closest Coin","Selected Area","Lowest Health","Highest Health"},Default="Closest Coin",Flag="TargetModeSelect",Callback=function(Option)
	farmMode = ((type(Option) == "table") and Option[1]) or Option;
end});
local initialAreas = collectAreas();
local areaDropdown = FarmSection:CreateSearchDropdown({Text="Select Area",Options=initialAreas,Default=initialAreas[1],Flag="AreaSelect",Callback=function(Option)
	selectedArea = ((type(Option) == "table") and Option[1]) or Option;
end});
FarmSection:CreateButton({Text="🔄 Refresh Areas",Callback=function()
	areaDropdown:SetOptions(collectAreas());
end});
FarmSection:CreateToggle({Text="Multiple Farm (Split Pets on Coins)",Default=false,Flag="MultipleFarmToggle",Callback=function(state)
	multipleFarm = state;
end});
FarmSection:CreateToggle({Text="Start Auto Farm",Default=false,Flag="AutoFarmToggle",Callback=function(state)
	autoFarmRunning = state;
	if not autoFarmRunning then
		return;
	end
	task.spawn(function()
		while autoFarmRunning do
			local pets = getMyPets();
			if (#pets == 0) then
				task.wait(0.2);
				continue;
			end
			if multipleFarm then
				for i, petId in ipairs(pets) do
					task.spawn(function()
						while autoFarmRunning and multipleFarm do
							local targetCoins = {};
							if (farmMode == "Closest Coin") then
								local closest = getClosestCoin();
								if closest then
									table.insert(targetCoins, closest.Name);
								end
							elseif ((farmMode == "Selected Area") and selectedArea and (selectedArea ~= "None")) then
								targetCoins = coinsInArea(selectedArea);
							elseif ((farmMode == "Lowest Health") or (farmMode == "Highest Health")) then
								local coins = {};
								for _, coin in ipairs(CoinsFolder:GetChildren()) do
									local area = getAttr(coin, "Area");
									if (not selectedArea or (selectedArea == "None") or (area == selectedArea)) then
										table.insert(coins, coin);
									end
								end
								if (farmMode == "Lowest Health") then
									table.sort(coins, function(a, b)
										local ha = getAttr(a, "Health") or 0;
										local hb = getAttr(b, "Health") or 0;
										return ha < hb;
									end);
								else
									table.sort(coins, function(a, b)
										local ha = getAttr(a, "Health") or 0;
										local hb = getAttr(b, "Health") or 0;
										return ha > hb;
									end);
								end
								for _, coin in ipairs(coins) do
									table.insert(targetCoins, coin.Name);
								end
							end
							if (#targetCoins == 0) then
								task.wait(0.1);
								continue;
							end
							local coinId = targetCoins[((i - 1) % #targetCoins) + 1];
							if coinId then
								safeInvokeJoin(coinId, {petId});
								while autoFarmRunning and multipleFarm and CoinsFolder:FindFirstChild(coinId) do
									safeFarm(coinId, petId);
									task.wait(0.15);
								end
							else
								task.wait(0.05);
							end
						end
					end);
				end
				repeat
					task.wait(0.1);
				until not autoFarmRunning or not multipleFarm 
			else
				local targetCoins = {};
				if (farmMode == "Closest Coin") then
					local closest = getClosestCoin();
					if closest then
						table.insert(targetCoins, closest.Name);
					end
				elseif ((farmMode == "Selected Area") and selectedArea and (selectedArea ~= "None")) then
					targetCoins = coinsInArea(selectedArea);
				elseif ((farmMode == "Lowest Health") or (farmMode == "Highest Health")) then
					local coins = {};
					for _, coin in ipairs(CoinsFolder:GetChildren()) do
						local area = getAttr(coin, "Area");
						if (not selectedArea or (selectedArea == "None") or (area == selectedArea)) then
							table.insert(coins, coin);
						end
					end
					if (farmMode == "Lowest Health") then
						table.sort(coins, function(a, b)
							local ha = getAttr(a, "Health") or 0;
							local hb = getAttr(b, "Health") or 0;
							return ha < hb;
						end);
					else
						table.sort(coins, function(a, b)
							local ha = getAttr(a, "Health") or 0;
							local hb = getAttr(b, "Health") or 0;
							return ha > hb;
						end);
					end
					for _, coin in ipairs(coins) do
						table.insert(targetCoins, coin.Name);
					end
				end
				if (#targetCoins == 0) then
					task.wait(0.1);
					continue;
				end
				local coinId = targetCoins[1];
				if coinId then
					safeInvokeJoin(coinId, pets);
					while autoFarmRunning and not multipleFarm and CoinsFolder:FindFirstChild(coinId) do
						for _, petId in ipairs(pets) do
							safeFarm(coinId, petId);
						end
						task.wait(0.15);
					end
				else
					task.wait(0.05);
				end
			end
		end
	end);
end});
local folderList = EggDir:GetChildren();
table.sort(folderList, function(a, b)
	return a.Name < b.Name;
end);
for _, folder in pairs(folderList) do
	local eggNames = {"None"};
	for _, egg in pairs(folder:GetChildren()) do
		table.insert(eggNames, egg.Name);
	end
	table.sort(eggNames);
	EggsSection:CreateSearchDropdown({Text=folder.Name,Options=eggNames,Default="None",Callback=function(Option)
		local val = ((type(Option) == "table") and Option[1]) or Option;
		if (val and (val ~= "None")) then
			selectedFolder = folder;
			selectedEgg = val;
		elseif (val == "None") then
			if (selectedFolder == folder) then
				selectedFolder = nil;
				selectedEgg = nil;
			end
		end
	end});
end
local eggInfoParagraph = EggsSection:CreateParagraph({Title="Egg Info",Text="Select an Egg to view info"});
EggsSection:CreateButton({Text="Egg Info",Callback=function()
	if (selectedFolder and selectedEgg) then
		local eggFolder = selectedFolder:FindFirstChild(selectedEgg);
		if eggFolder then
			local infoModule = eggFolder:FindFirstChild(selectedEgg);
			if (infoModule and infoModule:IsA("ModuleScript")) then
				local ok, data = pcall(require, infoModule);
				if (ok and (type(data) == "table")) then
					local text = string.format("Egg: %s\nHatchable: %s\nCost: %s\nCurrency: %s", selectedEgg, tostring(data.hatchable), tostring(data.cost), tostring(data.currency));
					eggInfoParagraph.Instance.Text = text;
				end
			end
		end
	else
		eggInfoParagraph.Instance.Text = "No Egg Selected";
	end
end});
EggsSection:CreateButton({Text="Unselect All",Callback=function()
	selectedFolder, selectedEgg = nil, nil;
	eggInfoParagraph.Instance.Text = "No Egg Selected";
end});
EggsSection:CreateDropdown({Text="Hatch Mode",Options={"Single","Triple","Octuple"},Default="Single",Callback=function(Option)
	hatchMode = ((type(Option) == "table") and Option[1]) or Option;
end});
EggsSection:CreateToggle({Text="Start Hatch",Default=false,Flag="AutoHatchToggle",Callback=function(state)
	autoHatch = state;
	if not autoHatch then
		return;
	end
	task.spawn(function()
		while autoHatch do
			if selectedEgg then
				local arg2, arg3, arg4 = false, false, false;
				if (hatchMode == "Single") then
					arg2, arg3, arg4 = false, false, false;
				elseif (hatchMode == "Triple") then
					arg2, arg3, arg4 = true, false, false;
				elseif (hatchMode == "Octuple") then
					arg2, arg3, arg4 = false, true, true;
				end
				local eggRemote = getBuyEggRemote();
				if eggRemote then
					pcall(function()
						eggRemote:InvokeServer(selectedEgg, arg2, arg3, arg4);
					end);
				end
			end
			task.wait(0.2);
		end
	end);
end});
