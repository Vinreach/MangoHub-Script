-- =================================
-- 🟣 MangoHub Full Auto Mobile Final (GAG Edition) + EVENT TAB
-- Fixed version: safer, pcall-wrapped, dynamic seed dropdown, throttles
-- =================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
if not player then
    Players.PlayerAdded:Wait()
    player = Players.LocalPlayer
end

-- Character / HRP safe updater
local character = player.Character or player.CharacterAdded:Wait()
local hrp = nil
local function updateCharacter(c)
    character = c or player.Character
    if character then
        hrp = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
    else
        hrp = nil
    end
end
updateCharacter(character)
player.CharacterAdded:Connect(function(char) task.wait(0.05); updateCharacter(char) end)

-- Safe WindUI load (not fatal)
local WindUI
local ok, ui = pcall(function()
    local src = game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua")
    local fn = loadstring(src)
    return fn()
end)
if ok and ui then
    WindUI = ui
else
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title="MangoHub", Text="Không tải được WindUI — UI tắt", Duration=4})
    end)
    -- fallback minimal dummy object to avoid nil errors
    WindUI = {
        CreateWindow = function() return {
            Section = function() return { Tab = function() return {
                Paragraph=function() end, Button=function() end, Toggle=function() end, Dropdown=function() return { SetValues=function() end } end
            } end } end
        } end,
        Notify = function(...) print(...) end,
        SetTheme = function(...) end
    }
end

-- Globals
getgenv().AutoClickSeedPack = false
getgenv().AutoOpenMode = "None"
getgenv().AutoPlant = false
getgenv().PlantMode = "Player Positions"

getgenv().AutoSellMode = "None" -- None / Always / InventoryFull
getgenv().InventoryLimit = 200

getgenv().AutoBuySeed = false
getgenv().SeedTier = "Tier 1"
getgenv().SelectedSeed = nil
getgenv().AutoBuyPetEgg = false
getgenv().SelectedEgg = nil
getgenv().AutoBuyGear = false
getgenv().SelectedGear = nil

local DarkMode = true
local CurrentLanguage = "Vietnamese"

-- throttles
local lastSell = 0
local SELL_COOLDOWN = 1.25
local lastBuy = 0
local BUY_COOLDOWN = 0.6
local lastClick = 0
local CLICK_COOLDOWN = 0.35
local lastPlant = 0
local PLANT_COOLDOWN = 0.12

-- utility: safe find nested children
local function safeFind(obj, ...)
    for i = 1, select("#", ...) do
        if not obj then return nil end
        local name = select(i, ...)
        obj = obj:FindFirstChild(name)
    end
    return obj
end

-- Helper: safe FireServer wrapper
local function safeFire(remote, ...)
    if not remote then return false, "remote nil" end
    local ok, err = pcall(function() remote:FireServer(...) end)
    if not ok then warn("[MangoHub] FireServer failed:", err) end
    return ok, err
end

-- Helper: get inventory count safely
local function getInventoryCount()
    local inv = player:FindFirstChild("FruitInventory") or player:FindFirstChild("Inventory")
    if inv and type(inv.GetChildren) == "function" then
        return #inv:GetChildren()
    end
    return 0
end

-- Helper: activate tool safely (handles Activate Remote or method)
local function safeActivateTool(tool)
    if not tool then return end
    pcall(function()
        local activateChild = tool:FindFirstChild("Activate")
        if activateChild and activateChild.ClassName == "RemoteEvent" then
            pcall(function() activateChild:FireServer() end)
            return
        end
        -- If tool has Activate method
        if typeof(tool.Activate) == "function" then
            pcall(function() tool:Activate() end)
            return
        end
        -- fallback: call .Activate property if it's a function-like value
        local act = tool:FindFirstChildWhichIsA("RemoteEvent") or tool:FindFirstChildWhichIsA("RemoteFunction")
        if act and act.Fire then pcall(function() act:FireServer() end) end
    end)
end

-- =========================
-- Auto-fetch Seed / Gear / Egg from workspace shops (one-time at load)
-- =========================
local Tier1Seeds, Tier2Seeds, GearList, PetEggs = {}, {}, {}, {}

local seedShop = safeFind(Workspace, "Farm", "Farm", "Important", "SeedShop")
if seedShop then
    for _, child in ipairs(seedShop:GetChildren()) do
        if child.Name == "Tier 1" then
            for _, s in ipairs(child:GetChildren()) do table.insert(Tier1Seeds, s.Name) end
        elseif child.Name == "Tier 2" then
            for _, s in ipairs(child:GetChildren()) do table.insert(Tier2Seeds, s.Name) end
        else
            -- some games put seeds flat — try to include
            if child:IsA("BasePart") or child:IsA("Model") or child:IsA("Folder") then
                table.insert(Tier1Seeds, child.Name)
            end
        end
    end
end

local gearShop = safeFind(Workspace, "Farm", "Farm", "Important", "GearShop")
if gearShop then
    for _, g in ipairs(gearShop:GetChildren()) do table.insert(GearList, g.Name) end
end

local eggShop = safeFind(Workspace, "Farm", "Farm", "Important", "EggShop")
if eggShop then
    for _, e in ipairs(eggShop:GetChildren()) do table.insert(PetEggs, e.Name) end
end

-- fallbacks to avoid empty dropdowns
if #Tier1Seeds == 0 then Tier1Seeds = {"Carrot","Tomato"} end
if #Tier2Seeds == 0 then Tier2Seeds = {"Strawberry","Corn"} end
if #GearList == 0 then GearList = {"Watering Can","Sprinkler"} end
if #PetEggs == 0 then PetEggs = {"Common Egg","Rare Egg"} end

-- Sell CFrame (kept)
local SellCFrame = CFrame.new(86.174316, 4.266193, 0.386498, 0, 0.990634, -0.136543, -0.000332, 0.136543, 0.990634, 1, 0, 0)

-- =========================
-- Build UI
-- =========================
local Window = WindUI:CreateWindow({Title="MangoHub Full Auto",Icon="zap",Author="Vinreach",Folder="Mango",Size=UDim2.fromOffset(350,420),Theme=(DarkMode and "Dark" or "Light")})
local MainSection = Window:Section({Title="Main Features",Opened=true})
local AutoSection = Window:Section({Title="Automatic Features",Opened=true})
local SettingsSection = Window:Section({Title="Settings",Opened=true})

local MainTab = MainSection:Tab({Title="Main",Icon="house"})
MainTab:Paragraph({Title="MangoHub",Desc="Full Auto Script ✅\nFarm - Sell - Buy - Plant",Image="zap",Color=Color3.fromRGB(0,200,255)})

-- Event
local EventTab = MainSection:Tab({Title="Event",Icon="gift"})
EventTab:Button({
    Title = "Auto Submit All Plants (Fairy Fountain)",
    Description = "Nộp tất cả cây vào Fairy Fountain (sự kiện)",
    Callback = function()
        local fairyRemote = safeFind(ReplicatedStorage, "GameEvents", "FairyService", "SubmitFairyFountainAllPlants")
        if fairyRemote then
            pcall(function() fairyRemote:FireServer() end)
        else
            WindUI:Notify({Title="Lỗi",Content="Không tìm thấy RemoteEvent!",Icon="x",Duration=2})
        end
    end
})

-- Auto Tab
local AutoTab = AutoSection:Tab({Title="Automatic",Icon="mouse-pointer-click"})

-- AUTO CLICK
AutoTab:Paragraph({Title="[AUTO CLICK]",Desc="Tự động click Seed Pack / Chest",Image="mouse-pointer-click",Color=Color3.fromRGB(255,170,0)})
AutoTab:Toggle({Title="Enable Auto Click",Value=false,Callback=function(s)getgenv().AutoClickSeedPack=s end})
AutoTab:Dropdown({Title="Mode Open",Values={"None","Seed Pack","Chest"},Callback=function(v)getgenv().AutoOpenMode=v end})

-- AUTO SELL
AutoTab:Paragraph({Title="[AUTO SELL]",Desc="3 chế độ bán fruit",Image="credit-card",Color=Color3.fromRGB(255,80,80)})
local fruitStatus = AutoTab:Paragraph({Title="Fruit Status",Desc="Đang load...",Color=Color3.fromRGB(80,200,255)})

task.spawn(function()
    while task.wait(1) do
        local count = getInventoryCount()
        local cap = (player:FindFirstChild("MaxFruit") and player.MaxFruit.Value) or getgenv().InventoryLimit
        pcall(function() fruitStatus:SetDesc("Fruits: "..tostring(count).."/"..tostring(cap)) end)
    end
end)

AutoTab:Dropdown({
    Title="Auto Sell Mode",
    Values={"None","Always","InventoryFull"},
    Callback=function(v)getgenv().AutoSellMode=v end
})

AutoTab:Button({
    Title="Sell Once",
    Description="Bấm để bán fruit 1 lần",
    Callback=function()
        local SellRemote = safeFind(ReplicatedStorage, "GameEvents", "Sell_Inventory")
        if SellRemote and hrp then
            spawn(function()
                local ok, err = pcall(function()
                    local old = hrp.CFrame
                    hrp.CFrame = SellCFrame
                    task.wait(1.2)
                    SellRemote:FireServer()
                    WindUI:Notify({Title="Sell",Content="Đã bán inventory (1 lần)",Icon="credit-card",Duration=2})
                    task.wait(0.6)
                    if old and hrp then hrp.CFrame = old end
                end)
                if not ok then WindUI:Notify({Title="Lỗi",Content="Sell failed: "..tostring(err),Duration=3}) end
            end)
        else
            WindUI:Notify({Title="Lỗi",Content="Không tìm thấy Sell_Inventory hoặc HRP!",Icon="x",Duration=2})
        end
    end
})

-- AUTO PLANT
AutoTab:Paragraph({Title="[AUTO PLANT]",Desc="Chỉ trồng trong farm của bạn",Image="seedling",Color=Color3.fromRGB(0,220,100)})
AutoTab:Toggle({Title="Enable Auto Plant",Value=false,Callback=function(s)getgenv().AutoPlant=s end})
AutoTab:Dropdown({Title="Plant Mode",Values={"Player Positions","Random Can Plant"},Callback=function(v)getgenv().PlantMode=v end})

-- AUTO BUY
AutoTab:Paragraph({Title="[AUTO BUY]",Desc="Tự động mua Seed / Pet / Gear",Image="shopping-cart",Color=Color3.fromRGB(255,200,0)})
AutoTab:Toggle({Title="Auto Buy Seed",Value=false,Callback=function(s)getgenv().AutoBuySeed=s end})

-- Seed Tier dropdown + dynamic seed list dropdown
local seedTierDropdown = AutoTab:Dropdown({
    Title="Seed Tier",
    Values={"Tier 1","Tier 2"},
    Callback=function(v)
        getgenv().SeedTier = v
        -- update seed list values
        local list = (v == "Tier 1") and Tier1Seeds or Tier2Seeds
        if seedListDropdown and type(seedListDropdown.SetValues) == "function" then
            pcall(function() seedListDropdown:SetValues(list) end)
        end
    end
})

-- store reference to seedList dropdown for dynamic updates
local seedListDropdown
seedListDropdown = AutoTab:Dropdown({
    Title="Select Seed",
    Values=Tier1Seeds,
    Callback=function(v) getgenv().SelectedSeed = v end
})

AutoTab:Toggle({Title="Auto Buy Pet Egg",Value=false,Callback=function(s)getgenv().AutoBuyPetEgg=s end})
local eggDropdown = AutoTab:Dropdown({Title="Select Pet Egg",Values=PetEggs,Callback=function(v)getgenv().SelectedEgg=v end})
AutoTab:Toggle({Title="Auto Buy Gear",Value=false,Callback=function(s)getgenv().AutoBuyGear=s end})
local gearDropdown = AutoTab:Dropdown({Title="Select Gear",Values=GearList,Callback=function(v)getgenv().SelectedGear=v end})

-- SETTINGS
local SettingsTab = SettingsSection:Tab({Title="Settings",Icon="cog"})
SettingsTab:Toggle({
    Title="Dark / Light Mode",
    Value=DarkMode,
    Callback=function(state)
        DarkMode = state
        pcall(function() WindUI:SetTheme(DarkMode and "Dark" or "Light") end)
    end
})
SettingsTab:Dropdown({
    Title="Language",
    Values={"Vietnamese","English"},
    Callback=function(v) CurrentLanguage=v end
})

-- Plant locations finder
local function getPlantLocations()
    local plantFolder = safeFind(Workspace, "Farm", "Farm", "Important", "Plant_Locations")
    local canPlantParts = {}
    if plantFolder then
        for _, model in pairs(plantFolder:GetChildren()) do
            local canPart = model:FindFirstChild("Can_Plant")
            if canPart and canPart:IsA("BasePart") then table.insert(canPlantParts, canPart.Position) end
        end
    end
    return canPlantParts
end

-- Main auto loop (throttled, safe)
task.spawn(function()
    while task.wait(0.45) do
        -- Auto Click
        if getgenv().AutoClickSeedPack and getgenv().AutoOpenMode ~= "None" and (tick() - lastClick >= CLICK_COOLDOWN) then
            lastClick = tick()
            local mode = getgenv().AutoOpenMode
            -- try backpack then character
            local containers = {}
            if player:FindFirstChild("Backpack") then table.insert(containers, player.Backpack) end
            if character then table.insert(containers, character) end
            for _, cont in ipairs(containers) do
                for _, item in ipairs(cont:GetChildren()) do
                    if item and item:IsA("Tool") and (item.Name:match(mode) or item.Name == mode) then
                        pcall(function() safeActivateTool(item) end)
                    end
                end
            end
        end

        -- Auto Sell
        local count = getInventoryCount()
        local cap = (player:FindFirstChild("MaxFruit") and player.MaxFruit.Value) or getgenv().InventoryLimit
        local shouldSell = (getgenv().AutoSellMode == "Always") or (getgenv().AutoSellMode == "InventoryFull" and count >= cap)
        if shouldSell and (tick() - lastSell >= SELL_COOLDOWN) then
            lastSell = tick()
            local SellRemote = safeFind(ReplicatedStorage, "GameEvents", "Sell_Inventory")
            if SellRemote and hrp then
                pcall(function()
                    local old = hrp.CFrame
                    hrp.CFrame = SellCFrame
                    task.wait(1.0)
                    SellRemote:FireServer()
                    task.wait(0.9)
                    if old and hrp then hrp.CFrame = old end
                end)
            end
        end

        -- Auto Plant
        local farmData = safeFind(Workspace, "Farm", "Farm", "Important", "Data")
        local isOwner = farmData and farmData:FindFirstChild("Owner") and farmData.Owner.Value == player.Name
        if getgenv().AutoPlant and isOwner and hrp and (tick() - lastPlant >= PLANT_COOLDOWN) then
            lastPlant = tick()
            local PlantEvent = safeFind(ReplicatedStorage, "GameEvents", "Plant_RE")
            local seeds = (getgenv().SeedTier == "Tier 1") and Tier1Seeds or Tier2Seeds
            if PlantEvent and seeds and #seeds > 0 then
                -- if user selected a specific seed, plant only that
                local seedListToUse = seeds
                if getgenv().SelectedSeed and type(getgenv().SelectedSeed) == "string" then
                    seedListToUse = { getgenv().SelectedSeed }
                end
                for _, seed in ipairs(seedListToUse) do
                    local pos = hrp.Position
                    if getgenv().PlantMode == "Random Can Plant" then
                        local spots = getPlantLocations()
                        if #spots > 0 then pos = spots[math.random(1,#spots)] end
                    end
                    pcall(function() PlantEvent:FireServer(pos, seed) end)
                    task.wait(0.06)
                end
            end
        end

        -- Auto Buy Seed
        if getgenv().AutoBuySeed and getgenv().SelectedSeed and (tick() - lastBuy >= BUY_COOLDOWN) then
            lastBuy = tick()
            local BuySeed = safeFind(ReplicatedStorage, "GameEvents", "BuySeedStock")
            if BuySeed then pcall(function() BuySeed:FireServer(getgenv().SeedTier, getgenv().SelectedSeed) end) end
        end

        -- Auto Buy Pet Egg
        if getgenv().AutoBuyPetEgg and getgenv().SelectedEgg and (tick() - lastBuy >= BUY_COOLDOWN) then
            lastBuy = tick()
            local BuyEgg = safeFind(ReplicatedStorage, "GameEvents", "BuyPetEgg")
            if BuyEgg then pcall(function() BuyEgg:FireServer(getgenv().SelectedEgg) end) end
        end

        -- Auto Buy Gear
        if getgenv().AutoBuyGear and getgenv().SelectedGear and (tick() - lastBuy >= BUY_COOLDOWN) then
            lastBuy = tick()
            local BuyGear = safeFind(ReplicatedStorage, "GameEvents", "BuyGearStock")
            if BuyGear then pcall(function() BuyGear:FireServer(getgenv().SelectedGear) end) end
        end
    end
end)

-- Ensure seed dropdown matches current tier at start
if seedListDropdown and type(seedListDropdown.SetValues) == "function" then
    pcall(function()
        local initial = (getgenv().SeedTier == "Tier 1") and Tier1Seeds or Tier2Seeds
        seedListDropdown:SetValues(initial)
    end)
end

WindUI:Notify({Title="MangoHub",Content="Script loaded (fixed) ✅",Duration=2})
print("[MangoHub] Fixed script loaded")