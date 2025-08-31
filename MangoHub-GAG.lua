-- =================================
-- 🟣 MangoHub Full Auto Mobile (Settings Dark/Light + Language, No Water, Misc Empty)
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
-- Global Variables
-- =========================
getgenv().AutoClickSeedPack = false
getgenv().AutoOpenMode = "None"
getgenv().AutoSellInventory = false
getgenv().AutoBuySeed = false
getgenv().SeedTier = "Tier 1"
getgenv().AutoPlant = false
getgenv().PlantMode = "Player Positions"
getgenv().AutoBuyPetEgg = false
getgenv().AutoBuyGear = false

local DarkMode = true
local CurrentLanguage = "Vietnamese"

local Tier1Seeds = {"Carrot","Strawberry","Blueberry","Tomato","Daffodil","Watermelon","Pumpkin","Apple","Bamboo","Coconut","Cactus","Dragon Fruit","Mango","Grape","Mushroom","Pepper","Cacao","Beanstalk","Ember Lily","Sugar Apple","Burning Bud","Giant Pinecone","Elder Strawberry","Romanesco"}
local Tier2Seeds = {"Potato","Cocomango","Broccoli","Brussels Sprouts"}
local GearList = {"Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler","Master Sprinkler","Grandmaster Sprinkler","Magnifying Glass","Tanning Mirror","Cleaning Spray","Cleansing Pet Shard","Favorite Tool","Harvest Tool","Friendship Pot","Level-Up Lollipop","Trading Ticket","Medium Treat","Medium Toy"}
local PetEggs = {"Common Egg","Uncommon Egg","Rare Egg","Legendary Egg","Bug Egg"}

local SelectedSeeds = {}
local SelectedPets = {}
local SelectedGears = {}

-- =========================
-- Create Window
-- =========================
local Window = WindUI:CreateWindow({Title="MangoHub Full Auto",Icon="zap",Author="Vinreach",Folder="Mango",Size=UDim2.fromOffset(340,400),Theme="Dark"})
local MainSection = Window:Section({Title="Main Features",Opened=true})
local AutoTab = MainSection:Tab({Title="Automatic",Icon="mouse-pointer-click"})
local MiscSection = Window:Section({Title="Misc",Opened=true}) -- trống

-- =========================
-- Auto Click / Open
-- =========================
AutoTab:Toggle({Title="Auto Click Seed Pack",Desc="Click items automatically",Value=false,Callback=function(state)getgenv().AutoClickSeedPack=state end})
AutoTab:Dropdown({Title="Select Mode Open",Desc="Choose item",Values={"None","Seed Pack","Chest"},Callback=function(val)getgenv().AutoOpenMode=val end})

-- =========================
-- Auto Sell
-- =========================
AutoTab:Toggle({Title="Auto Sell Inventory",Desc="Sell all items automatically",Value=false,Callback=function(state)getgenv().AutoSellInventory=state end})

-- =========================
-- Auto Plant
-- =========================
AutoTab:Toggle({Title="Auto Plant Seed",Desc="Plant seeds automatically",Value=false,Callback=function(state)getgenv().AutoPlant=state end})
AutoTab:Dropdown({Title="Plant Mode",Desc="Choose planting mode",Values={"Player Positions","Random Can Plant"},Callback=function(val)getgenv().PlantMode=val end})

-- =========================
-- Auto Buy Pet / Gear / Seed
-- =========================
AutoTab:Toggle({Title="Auto Buy Seed",Desc="Buy seeds automatically",Value=false,Callback=function(state)getgenv().AutoBuySeed=state end})
AutoTab:Toggle({Title="Auto Buy Pet Egg",Desc="Buy pet eggs automatically",Value=false,Callback=function(state)getgenv().AutoBuyPetEgg=state end})
AutoTab:Toggle({Title="Auto Buy Gear",Desc="Buy gears automatically",Value=false,Callback=function(state)getgenv().AutoBuyGear=state end})

-- =========================
-- Settings Toggle
-- =========================
AutoTab:Toggle({
    Title = "Settings",
    Desc = "Chỉnh Dark/Light Mode & Language",
    Value = DarkMode,
    Callback = function(state)
        DarkMode = state
        Window:ChangeTheme(DarkMode and "Dark" or "Light")
        WindUI:Notify({Title="Settings", Content=DarkMode and "Dark Mode" or "Light Mode", Icon="zap", Duration=2})
    end
})

-- Language Dropdown
AutoTab:Dropdown({
    Title = "Language",
    Desc = "Chọn ngôn ngữ UI",
    Values = {"Vietnamese","English"},
    Callback = function(val)
        CurrentLanguage = val
        WindUI:Notify({Title="Settings", Content="Language set to "..CurrentLanguage, Icon="zap", Duration=2})
    end
})

-- =========================
-- Plant Locations Function
-- =========================
local function getPlantLocations()
    local farmRoot = Workspace:FindFirstChild("Farm")
    if not farmRoot then return {} end
    local farmFolder = farmRoot:FindFirstChild("Farm")
    if not farmFolder then return {} end
    local importantFolder = farmFolder:FindFirstChild("Important")
    if not importantFolder then return {} end
    local plantFolder = importantFolder:FindFirstChild("Plant_Locations")
    if not plantFolder then return {} end
    local canPlantParts = {}
    for _, model in pairs(plantFolder:GetChildren()) do
        local canPart = model:FindFirstChild("Can_Plant")
        if canPart then table.insert(canPlantParts,canPart) end
    end
    return canPlantParts
end

-- =========================
-- Auto Loop
-- =========================
task.spawn(function()
    while true do
        task.wait(0.5)

        -- Auto Click
        if getgenv().AutoClickSeedPack and getgenv().AutoOpenMode~="None" then
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, item in pairs(backpack:GetChildren()) do
                    if item:IsA("Tool") and item.Name:match(getgenv().AutoOpenMode) then
                        if item:FindFirstChild("Activate") then item.Activate:Fire() elseif item:IsA("Tool") then item:Activate() end
                    end
                end
            end
        end

        -- Auto Sell
        if getgenv().AutoSellInventory then
            local SellInventory = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Inventory")
            SellInventory:FireServer()
        end

        -- Auto Buy Seed
        if getgenv().AutoBuySeed then
            local BuySeed = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock")
            for _, seedName in ipairs(Tier1Seeds) do BuySeed:FireServer(getgenv().SeedTier, seedName) end
            for _, seedName in ipairs(Tier2Seeds) do BuySeed:FireServer(getgenv().SeedTier, seedName) end
        end

        -- Auto Plant
        if getgenv().AutoPlant then
            local PlantEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("PlantSeed")
            for _, seedName in ipairs(Tier1Seeds) do
                if getgenv().PlantMode=="Player Positions" then
                    PlantEvent:FireServer(seedName, hrp.Position)
                else
                    local locations = getPlantLocations()
                    if #locations>0 then
                        local randomSpot = locations[math.random(1,#locations)]
                        PlantEvent:FireServer(seedName, randomSpot.Position)
                    end
                end
            end
            for _, seedName in ipairs(Tier2Seeds) do
                if getgenv().PlantMode=="Player Positions" then
                    PlantEvent:FireServer(seedName, hrp.Position)
                else
                    local locations = getPlantLocations()
                    if #locations>0 then
                        local randomSpot = locations[math.random(1,#locations)]
                        PlantEvent:FireServer(seedName, randomSpot.Position)
                    end
                end
            end
        end

        -- Auto Buy Pet Egg
        if getgenv().AutoBuyPetEgg then
            local BuyEgg = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyPetEgg")
            for _, egg in ipairs(PetEggs) do BuyEgg:FireServer(egg) end
        end

        -- Auto Buy Gear
        if getgenv().AutoBuyGear then
            local BuyGear = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyGearShop")
            for _, gear in ipairs(GearList) do BuyGear:FireServer(gear) end
        end

    end
end)