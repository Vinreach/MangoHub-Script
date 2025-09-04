-- =================================
-- 🟣 MangoHub Full Auto Mobile Final (GAG Edition) + EVENT TAB
-- =================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- =========================
-- Load WindUI
-- =========================
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- =========================
-- Globals
-- =========================
getgenv().AutoClickSeedPack = false
getgenv().AutoOpenMode = "None"
getgenv().AutoPlant = false
getgenv().PlantMode = "Player Positions"

-- Auto Sell
getgenv().AutoSellMode = "None" -- None / Always / InventoryFull
getgenv().InventoryLimit = 200 -- fallback

-- Auto Buy
getgenv().AutoBuySeed = false
getgenv().SeedTier = "Tier 1"
getgenv().SelectedSeed = nil
getgenv().AutoBuyPetEgg = false
getgenv().SelectedEgg = nil
getgenv().AutoBuyGear = false
getgenv().SelectedGear = nil

local DarkMode = true
local CurrentLanguage = "Vietnamese"

-- =========================
-- Data Lists
-- =========================
local Tier1Seeds = {"Carrot","Strawberry","Blueberry","Tomato","Daffodil","Watermelon","Pumpkin","Apple","Bamboo","Coconut","Cactus","Dragon Fruit","Mango","Grape","Mushroom","Pepper","Cacao","Bean","Pea","Pineapple"}
local Tier2Seeds = {"Potato","Cocomango","Broccoli","Brussels Sprouts"}
local GearList = {"Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler","Master Sprinkler","Grandmaster Sprinkler","Magnifying Glass","Tanning Mirror","Crown"}
local PetEggs = {"Common Egg","Uncommon Egg","Rare Egg","Legendary Egg","Bug Egg"}

-- Sell Location
local SellCFrame = CFrame.new(
    86.174316, 4.266193, 0.386498,
    0, 0.990634, -0.136543,
    -0.000332, 0.136543, 0.990634,
    1, 0, 0
)

-- =========================
-- Create Window & Sections
-- =========================
local Window = WindUI:CreateWindow({Title="MangoHub Full Auto",Icon="zap",Author="Vinreach",Folder="Mango",Size=UDim2.fromOffset(350,420),Theme="Dark"})
local MainSection = Window:Section({Title="Main Features",Opened=true})
local AutoSection = Window:Section({Title="Automatic Features",Opened=true})
local SettingsSection = Window:Section({Title="Settings",Opened=true})

-- =========================
-- MainTab
-- =========================
local MainTab = MainSection:Tab({Title="Main",Icon="house"})
MainTab:Paragraph({Title="MangoHub",Desc="Full Auto Script ✅\nFarm - Sell - Buy - Plant",Image="zap",Color=Color3.fromRGB(0,200,255)})

-- =========================
-- Event Tab
-- =========================
local EventTab = MainSection:Tab({Title="Event",Icon="gift"})
EventTab:Button({
    Title = "Auto Submit All Plants (Fairy Fountain)",
    Description = "Nộp tất cả cây vào Fairy Fountain (sự kiện)",
    Callback = function()
        ReplicatedStorage.GameEvents.FairyService.SubmitFairyFountainAllPlants:FireServer()
    end
})

-- =========================
-- AutoTab
-- =========================
local AutoTab = AutoSection:Tab({Title="Automatic",Icon="mouse-pointer-click"})

-- Auto Click
AutoTab:Paragraph({Title="[AUTO CLICK]",Desc="Tự động click Seed Pack / Chest",Image="mouse-pointer-click",Color=Color3.fromRGB(255,170,0)})
AutoTab:Toggle({Title="Enable Auto Click",Value=false,Callback=function(s)getgenv().AutoClickSeedPack=s end})
AutoTab:Dropdown({Title="Mode Open",Values={"None","Seed Pack","Chest"},Callback=function(v)getgenv().AutoOpenMode=v end})

-- Auto Sell
AutoTab:Paragraph({Title="[AUTO SELL]",Desc="3 chế độ bán fruit",Image="credit-card",Color=Color3.fromRGB(255,80,80)})
local fruitStatus = AutoTab:Paragraph({Title="Fruit Status",Desc="Đang load...",Color=Color3.fromRGB(80,200,255)})

task.spawn(function()
    while task.wait(1) do
        local count = #(player:FindFirstChild("FruitInventory") or player:FindFirstChild("Inventory") or {}:GetChildren())
        local cap = player:FindFirstChild("MaxFruit") and player.MaxFruit.Value or getgenv().InventoryLimit
        fruitStatus:SetDesc("Fruits: "..count.."/"..cap)
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
        local SellRemote = ReplicatedStorage.GameEvents:FindFirstChild("Sell_Inventory")
        if SellRemote and hrp then
            local oldCFrame = hrp.CFrame
            hrp.CFrame = SellCFrame
            task.wait(2)
            SellRemote:FireServer()
            WindUI:Notify({Title="Sell",Content="Đã bán inventory (1 lần)",Icon="credit-card",Duration=2})
            task.wait(0.5)
            hrp.CFrame = oldCFrame
        end
    end
})

-- Auto Plant
AutoTab:Paragraph({Title="[AUTO PLANT]",Desc="Chỉ trồng trong farm của bạn",Image="seedling",Color=Color3.fromRGB(0,220,100)})
AutoTab:Toggle({Title="Enable Auto Plant",Value=false,Callback=function(s)getgenv().AutoPlant=s end})
AutoTab:Dropdown({Title="Plant Mode",Values={"Player Positions","Random Can Plant"},Callback=function(v)getgenv().PlantMode=v end})

-- Auto Buy
AutoTab:Paragraph({Title="[AUTO BUY]",Desc="Tự động mua Seed / Pet / Gear",Image="shopping-cart",Color=Color3.fromRGB(255,200,0)})

AutoTab:Toggle({Title="Auto Buy Seed",Value=false,Callback=function(s)getgenv().AutoBuySeed=s end})
AutoTab:Dropdown({Title="Seed Tier",Values={"Tier 1","Tier 2"},Callback=function(v)getgenv().SeedTier=v end})
AutoTab:Dropdown({Title="Select Seed",Values=Tier1Seeds,Callback=function(v)getgenv().SelectedSeed=v end})

AutoTab:Toggle({Title="Auto Buy Pet Egg",Value=false,Callback=function(s)getgenv().AutoBuyPetEgg=s end})
AutoTab:Dropdown({Title="Select Pet Egg",Values=PetEggs,Callback=function(v)getgenv().SelectedEgg=v end})

AutoTab:Toggle({Title="Auto Buy Gear",Value=false,Callback=function(s)getgenv().AutoBuyGear=s end})
AutoTab:Dropdown({Title="Select Gear",Values=GearList,Callback=function(v)getgenv().SelectedGear=v end})

-- =========================
-- Settings Tab
-- =========================
local SettingsTab = SettingsSection:Tab({Title="Settings",Icon="cog"})
SettingsTab:Toggle({
    Title="Dark / Light Mode",
    Value=DarkMode,
    Callback=function(state)
        DarkMode=state
        WindUI:SetTheme(DarkMode and "Dark" or "Light")
    end
})
SettingsTab:Dropdown({
    Title="Language",
    Values={"Vietnamese","English"},
    Callback=function(v)CurrentLanguage=v end
})

-- =========================
-- Helper: Get Random Plant Spots
-- =========================
local function getPlantLocations()
    local plantFolder = workspace.Farm.Farm.Important:FindFirstChild("Plant_Locations")
    local canPlantParts = {}
    if plantFolder then
        for _, model in pairs(plantFolder:GetChildren()) do
            local canPart = model:FindFirstChild("Can_Plant")
            if canPart then table.insert(canPlantParts,canPart.Position) end
        end
    end
    return canPlantParts
end

-- =========================
-- Auto Loop
-- =========================
task.spawn(function()
    while task.wait(0.6) do
        -- Auto Click
        if getgenv().AutoClickSeedPack and getgenv().AutoOpenMode~="None" then
            for _, item in pairs(player.Backpack:GetChildren()) do
                if item:IsA("Tool") and item.Name:match(getgenv().AutoOpenMode) then
                    if item:FindFirstChild("Activate") then item.Activate:Fire() else item:Activate() end
                end
            end
        end

        -- Auto Sell
        local count = #(player:FindFirstChild("FruitInventory") or player:FindFirstChild("Inventory") or {}:GetChildren())
        local cap = player:FindFirstChild("MaxFruit") and player.MaxFruit.Value or getgenv().InventoryLimit
        local shouldSell = (getgenv().AutoSellMode=="Always") or (getgenv().AutoSellMode=="InventoryFull" and count>=cap)

        if shouldSell then
            local SellRemote = ReplicatedStorage.GameEvents:FindFirstChild("Sell_Inventory")
            if SellRemote and hrp then
                local oldCFrame=hrp.CFrame
                hrp.CFrame=SellCFrame
                task.wait(2)
                SellRemote:FireServer()
                task.wait(0.5)
                hrp.CFrame=oldCFrame
            end
        end

        -- Auto Plant
        if getgenv().AutoPlant and workspace.Farm.Farm.Important.Data.Owner.Value==player.Name then
            local PlantEvent=ReplicatedStorage.GameEvents.Plant_RE
            local seeds = (getgenv().SeedTier=="Tier 1") and Tier1Seeds or Tier2Seeds
            for _, seed in ipairs(seeds) do
                local pos=hrp.Position
                if getgenv().PlantMode=="Random Can Plant" then
                    local spots=getPlantLocations()
                    if #spots>0 then pos=spots[math.random(1,#spots)] end
                end
                PlantEvent:FireServer(pos,seed)
            end
        end

        -- Auto Buy Seed
        if getgenv().AutoBuySeed and getgenv().SelectedSeed then
            local BuySeed=ReplicatedStorage.GameEvents.BuySeedStock
            BuySeed:FireServer(getgenv().SeedTier,getgenv().SelectedSeed)
        end

        -- Auto Buy Pet Egg
        if getgenv().AutoBuyPetEgg and getgenv().SelectedEgg then
            local BuyEgg=ReplicatedStorage.GameEvents.BuyPetEgg
            BuyEgg:FireServer(getgenv().SelectedEgg)
        end

        -- Auto Buy Gear
        if getgenv().AutoBuyGear and getgenv().SelectedGear then
            local BuyGear=ReplicatedStorage.GameEvents.BuyGearStock
            BuyGear:FireServer(getgenv().SelectedGear)
        end
    end
end)