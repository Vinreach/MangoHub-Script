-- =================================
-- 🟣 MangoHub Full Auto Mobile Fix All (No ESP)
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

-- =========================
-- Global Variables
-- =========================
getgenv().AutoClickSeedPack = false
getgenv().AutoOpenMode = "None"
getgenv().AutoSellInventory = false
getgenv().AutoBuySeed = false
getgenv().SeedTier = "Tier 1"
getgenv().SeedName = "Carrot"
getgenv().AutoPlant = false
getgenv().PlantMode = "Player Positions" -- or "Random Can Plant"
getgenv().AutoBuyPetEgg = false
getgenv().SelectedPetEgg = "Common Egg"
getgenv().AutoBuyGear = false
getgenv().SelectedGear = "Watering Can"
getgenv().AutoWaterCan = false
getgenv().WaterPosition = Vector3.new(-1.1754,0.1355,66.7037)
getgenv().AutoSellTeleport = false
getgenv().SellPosition = CFrame.new(86.3885,4.2662,0.9605)
getgenv().ReturnPosition = hrp.CFrame

local Tier1Seeds = {"Carrot","Strawberry","Blueberry","Tomato","Daffodil","Watermelon","Pumpkin","Apple","Bamboo","Coconut","Cactus","Dragon Fruit","Mango","Grape","Mushroom","Pepper","Cacao","Beanstalk","Ember Lily","Sugar Apple","Burning Bud","Giant Pinecone","Elder Strawberry","Romanesco"}
local Tier2Seeds = {"Potato","Cocomango","Broccoli","Brussels Sprouts"}
local GearList = {"Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler","Master Sprinkler","Grandmaster Sprinkler","Magnifying Glass","Tanning Mirror","Cleaning Spray","Cleansing Pet Shard","Favorite Tool","Harvest Tool","Friendship Pot","Level-Up Lollipop","Trading Ticket","Medium Treat","Medium Toy"}
local PetEggs = {"Common Egg","Uncommon Egg","Rare Egg","Legendary Egg","Bug Egg"}

-- =========================
-- Create Window (mobile size)
-- =========================
local Window = WindUI:CreateWindow({Title="MangoHub Full Auto",Icon="zap",Author="Vinreach",Folder="Mango",Size=UDim2.fromOffset(380,650),Theme="Dark"})
local MainSection = Window:Section({Title="Main Features",Opened=true})
local AutoTab = MainSection:Tab({Title="Automatic",Icon="mouse-pointer-click"})

-- =========================
-- Automatic Tab
-- =========================
AutoTab:Toggle({Title="Auto Click Seed Pack",Desc="Click items automatically",Value=false,Callback=function(state)getgenv().AutoClickSeedPack=state end})
AutoTab:Dropdown({Title="Select Mode Open",Desc="Choose item",Values={"None","Seed Pack","Chest"},Callback=function(val)getgenv().AutoOpenMode=val end})

AutoTab:Toggle({Title="Auto Sell Inventory",Desc="Sell all items automatically",Value=false,Callback=function(state)getgenv().AutoSellInventory=state end})

AutoTab:Toggle({Title="Auto Buy Seed",Desc="Buy seed automatically",Value=false,Callback=function(state)getgenv().AutoBuySeed=state end})
AutoTab:Dropdown({Title="Select Seed Tier",Desc="Tier 1 or 2",Values={"Tier 1","Tier 2"},Callback=function(val)getgenv().SeedTier=val getgenv().SeedName=(val=="Tier 1" and Tier1Seeds or Tier2Seeds)[1] end})
AutoTab:Dropdown({Title="Select Seed Name",Desc="Seed will auto buy and plant",Values=Tier1Seeds,Callback=function(val)getgenv().SeedName=val end})

AutoTab:Toggle({Title="Auto Plant Seed",Desc="Plant seeds automatically",Value=false,Callback=function(state)getgenv().AutoPlant=state end})
AutoTab:Dropdown({Title="Plant Mode",Desc="Choose planting mode",Values={"Player Positions","Random Can Plant"},Callback=function(val)getgenv().PlantMode=val end})

AutoTab:Toggle({Title="Auto Buy Pet Egg",Desc="Buy selected egg automatically",Value=false,Callback=function(state)getgenv().AutoBuyPetEgg=state end})
AutoTab:Dropdown({Title="Select Pet Egg",Desc="Choose egg type",Values=PetEggs,Callback=function(val)getgenv().SelectedPetEgg=val end})

AutoTab:Toggle({Title="Auto Buy Gear",Desc="Buy selected gear automatically",Value=false,Callback=function(state)getgenv().AutoBuyGear=state end})
AutoTab:Dropdown({Title="Select Gear",Desc="Choose gear",Values=GearList,Callback=function(val)getgenv().SelectedGear=val end})

AutoTab:Toggle({Title="Auto Water Can",Desc="Automatically water tree",Value=false,Callback=function(state)getgenv().AutoWaterCan=state end})

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
            if getgenv().AutoSellTeleport then
                local oldCFrame = hrp.CFrame
                hrp.CFrame = getgenv().SellPosition
                task.wait(2)
                SellInventory:FireServer()
                task.wait(0.5)
                hrp.CFrame = oldCFrame
            else
                SellInventory:FireServer()
            end
        end

        -- Auto Buy Seed
        if getgenv().AutoBuySeed then
            local BuySeed = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock")
            BuySeed:FireServer(getgenv().SeedTier,getgenv().SeedName)
        end

        -- Auto Plant Seed
        if getgenv().AutoPlant then
            local seeds = getgenv().SeedTier=="Tier 1" and Tier1Seeds or Tier2Seeds
            if table.find(seeds,getgenv().SeedName) then
                local PlantEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("PlantSeed")
                if getgenv().PlantMode=="Player Positions" then
                    PlantEvent:FireServer(getgenv().SeedName, hrp.Position)
                elseif getgenv().PlantMode=="Random Can Plant" then
                    local locations = getPlantLocations()
                    if #locations>0 then
                        local randomSpot = locations[math.random(1,#locations)]
                        PlantEvent:FireServer(getgenv().SeedName, randomSpot.Position)
                    end
                end
            end
        end

        -- Auto Buy Pet Egg
        if getgenv().AutoBuyPetEgg then
            local BuyEgg = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyPetEgg")
            BuyEgg:FireServer(getgenv().SelectedPetEgg)
        end

        -- Auto Buy Gear
        if getgenv().AutoBuyGear then
            local BuyGear = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyGearShop")
            BuyGear:FireServer(getgenv().SelectedGear)
        end

        -- Auto Water Can
        if getgenv().AutoWaterCan then
            local WaterRE = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Water_RE")
            WaterRE:FireServer(getgenv().WaterPosition)
        end
    end
end)