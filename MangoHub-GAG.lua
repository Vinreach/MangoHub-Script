-- =================================
-- 🟣 MangoHub Full Auto + ESP
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
getgenv().AutoBuyPetEgg = false
getgenv().SelectedPetEgg = "Common Egg"
getgenv().AutoBuyGear = false
getgenv().SelectedGear = "Watering Can"
getgenv().AutoWaterCan = false
getgenv().WaterPosition = Vector3.new(-1.1754, 0.1355, 66.7037)
getgenv().AutoSellTeleport = false
getgenv().SellPosition = CFrame.new(86.3885, 4.2662, 0.9605) -- thay tọa độ bán đồ

-- =========================
-- Create Window
-- =========================
local Window = WindUI:CreateWindow({
    Title = "MangoHub Full Auto",
    Icon = "zap",
    Author = "Made By Group Vinreach",
    Folder = "Mango",
    Size = UDim2.fromOffset(360, 450),
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
-- MainTab content
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
-- Automatic Tab content
-- =========================
AutoTab:Paragraph({Title = "Automatic Features", Desc = "Auto-click, buy, sell, water", Image = "zap", Color = Color3.fromHex("#ffaa00")})

-- Auto Click Seed Pack / Chest
AutoTab:Toggle({
    Title = "Auto Click Seed Pack",
    Desc = "Automatically click items",
    Value = false,
    Callback = function(state) 
        getgenv().AutoClickSeedPack = state
        WindUI:Notify({Title="Auto Click Seed Pack", Content=state and "Enabled!" or "Disabled!", Icon="check", Duration=2}) 
    end
})
AutoTab:Dropdown({
    Title = "Select mode open",
    Desc = "Choose item to auto click",
    Values = {"None", "Seed Pack", "Chest"},
    Callback = function(val) 
        getgenv().AutoOpenMode = val
        WindUI:Notify({Title="Automatic Mode", Content="Selected: "..val, Icon="zap", Duration=2}) 
    end
})

-- Auto Sell Inventory with teleport
AutoTab:Toggle({
    Title = "Auto Sell Inventory",
    Desc = "Automatically sell all items",
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
    Desc = "Choose Tier (only 2 tiers)",
    Values = {"Tier 1", "Tier 2"},
    Callback = function(val) 
        getgenv().SeedTier = val
        WindUI:Notify({Title="Seed Tier", Content="Selected: "..val, Icon="zap", Duration=2}) 
    end
})
AutoTab:Dropdown({
    Title = "Select Seed Name",
    Desc = "Choose seed to buy",
    Values = {
        "Carrot", "Strawberry", "Blueberry", "Tomato", "Daffodil",
        "Watermelon", "Pumpkin", "Apple", "Bamboo", "Coconut",
        "Cactus", "Dragon Fruit", "Mango", "Grape", "Mushroom",
        "Pepper", "Cacao", "Beanstalk", "Ember Lily", "Sugar Apple",
        "Burning Bud", "Giant Pinecone", "Elder Strawberry", "Romanesco"
    },
    Callback = function(val) 
        getgenv().SeedName = val
        WindUI:Notify({Title="Seed Name", Content="Selected: "..val, Icon="zap", Duration=2}) 
    end
})

-- Auto Buy Pet Egg
AutoTab:Toggle({
    Title = "Auto Buy Pet Egg",
    Desc = "Automatically buy selected pet egg",
    Value = false,
    Callback = function(state) 
        getgenv().AutoBuyPetEgg = state
        WindUI:Notify({Title="Auto Buy Pet Egg", Content=state and "Enabled!" or "Disabled!", Icon="check", Duration=2}) 
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
        WindUI:Notify({Title="Auto Buy Gear", Content=state and "Enabled!" or "Disabled!", Icon="check", Duration=2}) 
    end
})
AutoTab:Dropdown({
    Title = "Select Gear",
    Desc = "Choose gear to buy",
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
    bb.Size = UDim2.new(0, 180, 0, 40)
    bb.StudsOffset = Vector3.new(0,3,0)
    bb.AlwaysOnTop = true
    bb.Parent = part
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.FredokaOne
    lbl.Text = model.Name .. " • " .. (model:FindFirstChild("PetName") and model.PetName.Value or "???")
    lbl.TextColor3 = Color3.fromRGB(255,255,0)
    lbl.TextStrokeTransparency = 0.2
    lbl.TextScaled = true
    lbl.Parent = bb
end

MiscTab:Button({
    Title = "Toggle ESP Egg",
    Desc = "Show/hide Egg overlay",
    Callback = function()
        getgenv().ESP_Enabled = not getgenv().ESP_Enabled
        WindUI:Notify({
            Title="ESP Egg", 
            Content=getgenv().ESP_Enabled and "Enabled" or "Disabled", 
            Icon="eye", 
            Duration=2
        })
    end
})

-- =========================
-- Auto Features Loop
-- =========================
task.spawn(function()
    while true do
        task.wait(0.5)

        -- Auto Click Seed / Chest
        if getgenv().AutoClickSeedPack and getgenv().AutoOpenMode ~= "None" then
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, item in pairs(backpack:GetChildren()) do
                    if item:IsA("Tool") and item.Name:match(getgenv().AutoOpenMode) then
                        if item:FindFirstChild("Activate") then item.Activate:Fire()
                        elseif item:IsA("Tool") then item:Activate() end
                    end
                end
            end
        end

        -- Auto Sell Inventory with teleport
        if getgenv().AutoSellInventory then
            local originalCFrame = hrp.CFrame
            hrp.CFrame = getgenv().SellPosition
            local SellInventory = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Inventory")
            SellInventory:FireServer()
            task.wait(2)
            hrp.CFrame = originalCFrame
        end

        -- Auto Buy Seed
        if getgenv().AutoBuySeed then
            local BuySeed = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock")
            BuySeed:FireServer(getgenv().SeedTier, getgenv().SeedName)
        end

        -- Auto Buy Pet Egg
        if getgenv().AutoBuyPetEgg then
            local args = { getgenv().SelectedPetEgg }
            ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyPetEgg"):FireServer(unpack(args))
        end

        -- Auto Buy Gear
        if getgenv().AutoBuyGear then
            local args = { getgenv().SelectedGear }
            ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyGearShop"):FireServer(unpack(args))
        end

        -- Auto Water Can
        if getgenv().AutoWaterCan then
            local WaterRE = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Water_RE")
            WaterRE:FireServer(Vector3.new(getgenv().WaterPosition.X,getgenv().WaterPosition.Y,getgenv().WaterPosition.Z))
        end
    end
end)

-- =========================
-- ESP Render Loop
-- =========================
RunService.RenderStepped:Connect(function()
    if getgenv().ESP_Enabled then
        for _, egg in pairs(Workspace:GetDescendants()) do
            if egg:IsA("Model") and egg:FindFirstChild("PetName") then
                createBillboard(egg)
            end
        end
    end
end)