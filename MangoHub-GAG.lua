-- =================================
-- 🟣 MangoHub Full Auto Mobile (Dark/Light + Language, No Water, Misc Empty)
-- =================================

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- =========================
-- Load WindUI
-- =========================
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- =========================
-- Globals (getgenv for external togglers)
-- =========================
getgenv().AutoClickSeedPack = false
getgenv().AutoOpenMode      = "None"       -- None | Seed Pack | Chest
getgenv().AutoSellInventory = false        -- (Nếu cần sau này, vẫn để sẵn)
getgenv().AutoBuySeed       = false
getgenv().SeedTier          = "Tier 1"     -- Tier 1 | Tier 2
getgenv().AutoPlant         = false
getgenv().PlantMode         = "Player Positions" -- Player Positions | Random Can Plant
getgenv().AutoBuyPetEgg     = false
getgenv().AutoBuyGear       = false

local DarkMode = true
local CurrentLanguage = "Vietnamese"

-- =========================
-- Data Lists
-- =========================
local Tier1Seeds = {
    "Carrot","Strawberry","Blueberry","Tomato","Daffodil","Watermelon","Pumpkin","Apple","Bamboo",
    "Coconut","Cactus","Dragon Fruit","Mango","Grape","Mushroom","Pepper","Cacao","Beanstalk",
    "Ember Lily","Sugar Apple","Burning Bud","Giant Pinecone","Elder Strawberry","Romanesco"
}
local Tier2Seeds = { "Potato","Cocomango","Broccoli","Brussels Sprouts" }

local GearList = {
    "Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler",
    "Master Sprinkler","Grandmaster Sprinkler","Magnifying Glass","Tanning Mirror","Cleaning Spray",
    "Cleansing Pet Shard","Favorite Tool","Harvest Tool","Friendship Pot","Level-Up Lollipop",
    "Trading Ticket","Medium Treat","Medium Toy"
}

local PetEggs = {"Common Egg","Uncommon Egg","Rare Egg","Legendary Egg","Bug Egg"}

-- =========================
-- UI
-- =========================
local Window = WindUI:CreateWindow({
    Title = "MangoHub Full Auto",
    Icon = "zap",
    Author = "Vinreach",
    Folder = "Mango",
    Size = UDim2.fromOffset(340, 420),
    Theme = "Dark"
})

local MainSection = Window:Section({Title = "Main Features", Opened = true})
local AutoTab     = MainSection:Tab({Title = "Automatic", Icon = "mouse-pointer-click"})
local MiscSection = Window:Section({Title = "Misc", Opened = true}) -- trống theo yêu cầu

-- Auto Click / Open
AutoTab:Toggle({
    Title = "Auto Click Seed Pack",
    Desc  = "Click items automatically",
    Value = false,
    Callback = function(state) getgenv().AutoClickSeedPack = state end
})
AutoTab:Dropdown({
    Title = "Select Mode Open",
    Desc  = "Choose item",
    Values = {"None","Seed Pack","Chest"},
    Callback = function(val) getgenv().AutoOpenMode = val end
})

-- Auto Sell (để sẵn, nếu game có)
AutoTab:Toggle({
    Title = "Auto Sell Inventory",
    Desc  = "Sell all items automatically",
    Value = false,
    Callback = function(state) getgenv().AutoSellInventory = state end
})

-- Auto Plant
AutoTab:Toggle({
    Title = "Auto Plant Seed",
    Desc  = "Plant seeds automatically",
    Value = false,
    Callback = function(state) getgenv().AutoPlant = state end
})
AutoTab:Dropdown({
    Title = "Plant Mode",
    Desc  = "Choose planting mode",
    Values = {"Player Positions","Random Can Plant"},
    Callback = function(val) getgenv().PlantMode = val end
})

-- Auto Buy Seed / Pet / Gear
AutoTab:Dropdown({
    Title = "Seed Tier",
    Desc  = "Chọn Tier để mua",
    Values = {"Tier 1","Tier 2"},
    Callback = function(val) getgenv().SeedTier = val end
})
AutoTab:Toggle({
    Title = "Auto Buy Seed",
    Desc  = "Buy seeds automatically",
    Value = false,
    Callback = function(state) getgenv().AutoBuySeed = state end
})
AutoTab:Toggle({
    Title = "Auto Buy Pet Egg",
    Desc  = "Buy pet eggs automatically",
    Value = false,
    Callback = function(state) getgenv().AutoBuyPetEgg = state end
})
AutoTab:Toggle({
    Title = "Auto Buy Gear",
    Desc  = "Buy gears automatically",
    Value = false,
    Callback = function(state) getgenv().AutoBuyGear = state end
})

-- Settings (Dark/Light + Language)
AutoTab:Toggle({
    Title = "Settings",
    Desc  = "Chỉnh Dark/Light Mode & Language",
    Value = DarkMode,
    Callback = function(state)
        DarkMode = state
        WindUI:SetTheme(DarkMode and "Dark" or "Light")
        WindUI:Notify({Title="Settings", Content = DarkMode and "Dark Mode" or "Light Mode", Icon="zap", Duration=2})
    end
})
AutoTab:Dropdown({
    Title = "Language",
    Desc  = "Chọn ngôn ngữ UI",
    Values = {"Vietnamese","English"},
    Callback = function(val)
        CurrentLanguage = val
        WindUI:Notify({Title="Settings", Content = "Language set to "..CurrentLanguage, Icon="zap", Duration=2})
    end
})

-- =========================
-- Remotes (cache)
-- =========================
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")

-- Các remote theo bạn cung cấp:
local Plant_RE         = GameEvents:WaitForChild("Plant_RE")          -- (Vector3, SeedName)
local BuySeedStock     = GameEvents:WaitForChild("BuySeedStock")      -- (Tier, SeedName)
local BuyGearStock     = GameEvents:WaitForChild("BuyGearStock")      -- (GearName)
local BuyPetEgg        = GameEvents:WaitForChild("BuyPetEgg")         -- (EggName)

-- Có thể có/không tuỳ game, vẫn để sẵn cho AutoSellInventory:
local Sell_Inventory = GameEvents:FindFirstChild("Sell_Inventory")    -- (Không rõ tham số -> FireServer() trống)

-- =========================
-- Helpers
-- =========================

-- Tìm vườn thuộc về player (Owner.Value có thể là tên (string) hoặc userId (number))
local function getOwnFarmModel()
    local farmRoot = Workspace:FindFirstChild("Farm")
    if not farmRoot then return nil end

    -- Có thể cấu trúc: Workspace.Farm.<SomeFarmModel(s)>
    for _, farm in ipairs(farmRoot:GetChildren()) do
        local important = farm:FindFirstChild("Important")
        if important then
            local data = important:FindFirstChild("Data")
            if data then
                local ownerVal = data:FindFirstChild("Owner")
                if ownerVal and ownerVal.Value ~= nil then
                    local ok = false
                    if typeof(ownerVal.Value) == "string" then
                        ok = (ownerVal.Value == player.Name)
                    elseif typeof(ownerVal.Value) == "number" then
                        ok = (ownerVal.Value == player.UserId)
                    end
                    if ok then
                        return farm -- Đây chính là vườn của mình
                    end
                end
            end
        end
    end

    -- Fallback: nếu map chỉ có 1 model tên "Farm" như bạn ghi thì vẫn trả về
    local singleFarm = farmRoot:FindFirstChild("Farm")
    if singleFarm then
        -- Kiểm tra Owner nếu có:
        local important = singleFarm:FindFirstChild("Important")
        local data = important and important:FindFirstChild("Data")
        local ownerVal = data and data:FindFirstChild("Owner")
        if ownerVal and ownerVal.Value ~= nil then
            local ok = false
            if typeof(ownerVal.Value) == "string" then
                ok = (ownerVal.Value == player.Name)
            elseif typeof(ownerVal.Value) == "number" then
                ok = (ownerVal.Value == player.UserId)
            end
            if ok then return singleFarm end
        end
    end
    return nil
end

-- Lấy danh sách Can_Plant trong vườn của mình
local function getPlantSpots()
    local myFarm = getOwnFarmModel()
    if not myFarm then return {} end
    local important = myFarm:FindFirstChild("Important")
    if not important then return {} end
    local plantFolder = important:FindFirstChild("Plant_Locations")
    if not plantFolder then return {} end

    local spots = {}
    for _, obj in ipairs(plantFolder:GetChildren()) do
        local canPart = obj:FindFirstChild("Can_Plant")
        if canPart and canPart:IsA("BasePart") then
            table.insert(spots, canPart)
        end
    end
    return spots
end

-- Random vị trí planting từ Can_Plant hoặc vị trí người chơi
local function getPlantPosition()
    if getgenv().PlantMode == "Player Positions" then
        return hrp and hrp.Position or Vector3.new()
    else
        local spots = getPlantSpots()
        if #spots > 0 then
            local pick = spots[math.random(1, #spots)]
            -- Có thể cộng chút offset nhỏ để tránh trùng đúng tâm
            return pick.Position + Vector3.new(0, 0.1, 0)
        else
            -- fallback về vị trí người chơi nếu không có spot
            return hrp and hrp.Position or Vector3.new()
        end
    end
end

-- Trợ giúp: bắn notify an toàn
local function notify(title, content, dur)
    pcall(function()
        WindUI:Notify({Title = title, Content = content, Icon = "zap", Duration = dur or 2})
    end)
end

-- =========================
-- Throttle (tránh spam server)
-- =========================
local last = {
    click  = 0,
    sell   = 0,
    buySeed= 0,
    plant  = 0,
    buyEgg = 0,
    buyGear= 0
}
local function canDo(key, cooldown)
    if (time() - (last[key] or 0)) >= cooldown then
        last[key] = time()
        return true
    end
    return false
end

-- =========================
-- Main Loop
-- =========================
task.spawn(function()
    math.randomseed(tick())
    while true do
        task.wait(0.25)

        -- Auto Click openables in Backpack
        if getgenv().AutoClickSeedPack and getgenv().AutoOpenMode ~= "None" then
            if canDo("click", 0.35) then
                local backpack = player:FindFirstChild("Backpack")
                if backpack then
                    for _, item in ipairs(backpack:GetChildren()) do
                        if item:IsA("Tool") and item.Name:find(getgenv().AutoOpenMode) then
                            -- Ưu tiên :Activate() của Tool
                            pcall(function() item:Activate() end)
                            -- Một số tool có Remote/Bindable "Activate"
                            local act = item:FindFirstChild("Activate")
                            if act and act.Fire then pcall(function() act:Fire() end) end
                        end
                    end
                end
            end
        end

        -- Auto Sell Inventory (nếu có remote)
        if getgenv().AutoSellInventory and Sell_Inventory then
            if canDo("sell", 3.0) then
                pcall(function() Sell_Inventory:FireServer() end)
            end
        end

        -- Auto Buy Seed
        if getgenv().AutoBuySeed then
            if canDo("buySeed", 2.0) then
                local tier = getgenv().SeedTier
                local list = (tier == "Tier 2") and Tier2Seeds or Tier1Seeds
                for _, seedName in ipairs(list) do
                    pcall(function()
                        -- ĐÚNG CHUẨN: BuySeedStock(Tier, SeedName)
                        BuySeedStock:FireServer(tier, seedName)
                    end)
                    task.wait(0.05)
                end
            end
        end

        -- Auto Plant (trồng đúng vườn của mình & đúng tham số)
        if getgenv().AutoPlant then
            if canDo("plant", 1.0) then
                local tier = getgenv().SeedTier
                local list = (tier == "Tier 2") and Tier2Seeds or Tier1Seeds
                -- Trồng mỗi tick 1-2 hạt để tránh spam (tuỳ biến)
                local tries = math.min(2, #list)
                for i = 1, tries do
                    local seedName = list[((math.random(1, #list)))]
                    local pos = getPlantPosition()
                    pcall(function()
                        -- ĐÚNG CHUẨN: Plant_RE(Vector3, SeedName)
                        Plant_RE:FireServer(pos, seedName)
                    end)
                    task.wait(0.1)
                end
            end
        end

        -- Auto Buy Pet Egg
        if getgenv().AutoBuyPetEgg then
            if canDo("buyEgg", 2.0) then
                for _, egg in ipairs(PetEggs) do
                    pcall(function()
                        -- ĐÚNG CHUẨN: BuyPetEgg(EggName)
                        BuyPetEgg:FireServer(egg)
                    end)
                    task.wait(0.05)
                end
            end
        end

        -- Auto Buy Gear
        if getgenv().AutoBuyGear then
            if canDo("buyGear", 2.0) then
                for _, gear in ipairs(GearList) do
                    pcall(function()
                        -- ĐÚNG CHUẨN: BuyGearStock(GearName)
                        BuyGearStock:FireServer(gear)
                    end)
                    task.wait(0.05)
                end
            end
        end

    end
end)