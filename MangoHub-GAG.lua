-- =================================
-- 🟣 MangoHub Full Auto + ESP Mobile
-- =================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- =========================
-- Load WindUI
-- =========================
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
getgenv().ESP_Enabled = false
getgenv().AutoClickSeedPack = false
getgenv().AutoOpenMode = "None"
getgenv().AutoSellInventory = false
getgenv().AutoBuySeed = false
getgenv().SeedTier = "Tier 1"
getgenv().SeedName = "Carrot"
getgenv().AutoPlant = false
getgenv().PlantMode = "Player Positions" -- "Player Positions" hoặc "Random Can Plant"
getgenv().AutoBuyPetEgg = false
getgenv().SelectedPetEgg = "Common Egg"
getgenv().AutoBuyGear = false
getgenv().SelectedGear = "Watering Can"
getgenv().AutoWaterCan = false
getgenv().WaterPosition = Vector3.new(-1.1754, 0.1355, 66.7037)
getgenv().AutoSellTeleport = false
getgenv().SellPosition = CFrame.new(86.3885, 4.2662, 0.9605)

-- Tier seeds
local Tier1Seeds = {
    "Carrot", "Strawberry", "Blueberry", "Tomato", "Daffodil",
    "Watermelon", "Pumpkin", "Apple", "Bamboo", "Coconut",
    "Cactus", "Dragon Fruit", "Mango", "Grape", "Mushroom",
    "Pepper", "Cacao", "Beanstalk", "Ember Lily", "Sugar Apple",
    "Burning Bud", "Giant Pinecone", "Elder Strawberry", "Romanesco"
}

local Tier2Seeds = {
    "Potato", "Cocomango", "Broccoli", "Brussels Sprouts"
}

-- =========================
-- Create Window (mobile size)
-- =========================
local Window = WindUI:CreateWindow({
    Title = "MangoHub Full Auto",
    Icon = "zap",
    Author = "Vinreach",
    Folder = "Mango",
    Size = UDim2.fromOffset(380, 650),
    Theme = "Dark"
})

-- =========================
-- Sections & Tabs
-- =========================
local MainSection = Window:Section({ Title = "Main Features", Opened = true })
local MiscSection = Window:Section({ Title = "Misc", Opened = true })

local MainTab = MainSection:Tab({ Title = "Main", Icon = "house" })
local AutoTab = MainSection:Tab({ Title = "Automatic", Icon = "mouse-pointer-click" })
local MiscTab = MiscSection:Tab({ Title = "ESP Egg", Icon = "eye" })

-- =========================
-- MainTab
-- =========================
MainTab:Button({
    Title = "Join Discord",
    Desc = "Click to join our Discord server",
    Callback = function()
        local url = "https://discord.gg/yourserver"
        if syn and syn.request then
            syn.request({Url = url, Method = "GET"})
        else
            setclipboard(url)
            WindUI:Notify({Title="Discord", Content="Link copied!", Icon="check", Duration=2})
        end
    end
})

MainTab:Paragraph({Title = "Coming Soon", Desc = "New features will appear here!", Image = "sparkles", Color = Color3.fromHex("#00ffcc")})

-- =========================
-- Automatic Tab
-- =========================
AutoTab:Paragraph({Title = "Automatic Features", Desc = "Auto-click, buy, plant, sell, water", Image = "zap", Color = Color3.fromHex("#ffaa00")})

-- Auto Click Seed Pack / Chest
AutoTab:Toggle({
    Title = "Auto Click Seed Pack",
    Desc = "Automatically click items",
    Value = false,
    Callback = function(state)
        getgenv().AutoClickSeedPack = state
        WindUI:Notify({Title="Auto Click", Content=state and "Enabled!" or "Disabled!", Icon="check", Duration=2})
    end
})
AutoTab:Dropdown({
    Title = "Select mode open",
    Desc = "Choose item to auto click",
    Values = {"None", "Seed Pack", "Chest"},
    Callback = function(val)
        getgenv().AutoOpenMode = val
        WindUI:Notify({Title="Mode", Content="Selected: "..val, Icon="zap", Duration=2})
    end
})

-- Auto Sell Inventory
AutoTab:Toggle({
    Title = "Auto Sell Inventory",
    Desc = "Sell all items automatically",
    Value = false,
    Callback = function(state)
        getgenv().AutoSellInventory = state
        WindUI:Notify({Title="Auto Sell", Content=state and "Enabled!" or "Disabled!", Icon="check", Duration=2})
    end
})

-- Auto Buy Seed
AutoTab:Toggle({
    Title = "Auto Buy Seed",
    Desc = "Automatically buy selected seed",
    Value = false,
    Callback = function(state)
        getgenv().AutoBuySeed = state
        WindUI:Notify({Title="Auto Buy Seed", Content=state and "Enabled!" or "Disabled!", Icon="check", Duration=2})
    end
})
AutoTab:Dropdown({
    Title = "Select Seed Tier",
    Desc = "Tier 1 or Tier 2",
    Values = {"Tier 1","Tier 2"},
    Callback = function(val)
        getgenv().SeedTier = val
        local seeds = val=="Tier 1" and Tier1Seeds or Tier2Seeds
        getgenv().SeedName = seeds[1]
        WindUI:Notify({Title="Seed Tier", Content="Selected: "..val.." | Default: "..seeds[1], Icon="zap", Duration=2})
    end
})
AutoTab:Dropdown({
    Title = "Select Seed Name",
    Desc = "Seed will auto buy and plant",
    Values = Tier1Seeds,
    Callback = function(val)
        getgenv().SeedName = val
        WindUI:Notify({Title="Seed Name", Content="Selected: "..val, Icon="zap", Duration=2})
    end
})

-- Auto Plant Seed
AutoTab:Toggle({
    Title = "Auto Plant Seed",
    Desc = "Automatically plant seeds",
    Value = false,
    Callback = function(state)
        getgenv().AutoPlant = state
        WindUI:Notify({Title="Auto Plant", Content=state and "Enabled!" or "Disabled!", Icon="check", Duration=2})
    end
})
AutoTab:Dropdown({
    Title = "Plant Mode",
    Desc = "Choose planting mode",
    Values = {"Player Positions","Random Can Plant"},
    Callback = function(val)
        getgenv().PlantMode = val
        WindUI:Notify({Title="Plant Mode", Content="Selected: "..val, Icon="zap", Duration=2})
    end
})

-- Auto Buy Pet Egg
AutoTab:Toggle({
    Title = "Auto Buy Pet Egg",
    Desc = "Automatically buy selected egg",
    Value = false,
    Callback = function(state)
        getgenv().AutoBuyPetEgg = state
        WindUI:Notify({Title="Pet Egg", Content=state and "Enabled!" or "Disabled!", Icon="check", Duration=2})
    end
})
AutoTab:Dropdown({
    Title = "Select Pet Egg",
    Desc = "Choose egg type",
    Values = {"Common Egg","Uncommon Egg","Rare Egg","Legendary Egg","Bug Egg"},
    Callback = function(val)
        getgenv().SelectedPetEgg = val
        WindUI:Notify({Title="Pet Egg", Content="Selected: "..val, Icon="zap", Duration=2})
    end
})

-- Auto Buy Gear
AutoTab:Toggle({
    Title = "Auto Buy Gear",
    Desc = "Automatically buy selected gear",
    Value = false,
    Callback = function(state)
        getgenv().AutoBuyGear = state
        WindUI:Notify({Title="Gear", Content=state and "Enabled!" or "Disabled!", Icon="check", Duration=2})
    end
})
AutoTab:Dropdown({
    Title = "Select Gear",
    Desc = "Choose gear",
    Values = {
        "Watering Can", "Trowel", "Recall Wrench", "Basic Sprinkler", "Advanced Sprinkler",
        "Godly Sprinkler", "Master Sprinkler", "Grandmaster Sprinkler", "Magnifying Glass",
        "Tanning Mirror", "Cleaning Spray", "Cleansing Pet Shard", "Favorite Tool", "Harvest Tool",
        "Friendship Pot", "Level-Up Lollipop", "Trading Ticket", "Medium Treat", "Medium Toy"
    },
    Callback = function(val)
        getgenv().SelectedGear = val
        WindUI:Notify({Title="Gear", Content="Selected: "..val, Icon="zap", Duration=2})
    end
})

-- Auto Water Can
AutoTab:Toggle({
    Title = "Auto Water Can",
    Desc = "Automatically water tree",
    Value = false,
    Callback = function(state)
        getgenv().AutoWaterCan = state
        WindUI:Notify({Title="Auto Water", Content=state and "Enabled!" or "Disabled!", Icon="check", Duration=2})
    end
})

-- =========================
-- Misc Tab: ESP Egg
-- =========================
local function createBillboard(model)
    if model:FindFirstChild("EggBillboard") then return end
    local part = model:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "EggBillboard"
    bb.Size = UDim