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
getgenv().AutoSellInventory = false
getgenv().AutoPlant = false
getgenv().PlantMode = "Player Positions"
getgenv().AutoBuySeed = false
getgenv().SeedTier = "Tier 1"
getgenv().AutoBuyPetEgg = false
getgenv().AutoBuyGear = false

local DarkMode = true
local CurrentLanguage = "Vietnamese"

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
local MiscSection = Window:Section({Title="Misc",Opened=false})

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
        game:GetService("ReplicatedStorage")
            :WaitForChild("GameEvents")
            :WaitForChild("FairyService")
            :WaitForChild("SubmitFairyFountainAllPlants")
            :FireServer()
    end
})

-- =========================
-- AutoTab
-- =========================
local AutoTab = AutoSection:Tab({Title="Automatic",Icon="mouse-pointer-click"})

AutoTab:Paragraph({Title="[AUTO CLICK]",Desc="Tự động click Seed Pack / Chest",Image="mouse-pointer-click",Color=Color3.fromRGB(255,170,0)})
AutoTab:Toggle({Title="Enable Auto Click",Value=false,Callback=function(s)getgenv().AutoClickSeedPack=s end})
AutoTab:Dropdown({Title="Mode Open",Values={"None","Seed Pack","Chest"},Callback=function(v)getgenv().AutoOpenMode=v end})

AutoTab:Paragraph({Title="[AUTO SELL]",Desc="Teleport bán rương rồi quay về",Image="credit-card",Color=Color3.fromRGB(255,80,80)})
AutoTab:Toggle({Title="Enable Auto Sell",Value=false,Callback=function(s)getgenv().AutoSellInventory=s end})

AutoTab:Paragraph({Title="[AUTO PLANT]",Desc="Chỉ trồng trong farm của bạn",Image="seedling",Color=Color3.fromRGB(0,220,100)})
AutoTab:Toggle({Title="Enable Auto Plant",Value=false,Callback=function(s)getgenv().AutoPlant=s end})
AutoTab:Dropdown({Title="Plant Mode",Values={"Player Positions","Random Can Plant"},Callback=function(v)getgenv().PlantMode=v end})

AutoTab:Paragraph({Title="[AUTO BUY]",Desc="Tự động mua Seed / Pet / Gear",Image="shopping-cart",Color=Color3.fromRGB(255,200,0)})
AutoTab:Toggle({Title="Auto Buy Seed",Value=false,Callback=function(s)getgenv().AutoBuySeed=s end})
AutoTab:Dropdown({Title="Seed Tier",Values={"Tier 1","Tier 2"},Callback=function(v)getgenv().SeedTier=v end})
AutoTab:Toggle({Title="Auto Buy Pet Egg",Value=false,Callback=function(s)getgenv().AutoBuyPetEgg=s end})
AutoTab:Toggle({Title="Auto Buy Gear",Value=false,Callback=function(s)getgenv().AutoBuyGear=s end})

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
        WindUI:Notify({Title="Theme",Content=DarkMode and "Dark Mode" or "Light Mode",Icon="zap",Duration=2})
    end
})
SettingsTab:Dropdown({
    Title="Language",
    Values={"Vietnamese","English"},
    Callback=function(v)
        CurrentLanguage=v
        WindUI:Notify({Title="Language",Content="Set to "..v,Icon="check",Duration=2})
    end
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
        if getgenv().AutoSellInventory then
            if workspace.Farm.Farm.Important.Data.Owner.Value == player.Name then
                local oldCFrame=hrp.CFrame
                hrp.CFrame=SellCFrame
                task.wait(2)
                ReplicatedStorage.GameEvents.Sell_Inventory:FireServer()
                WindUI:Notify({Title="Auto Sell",Content="Đã bán toàn bộ!",Icon="credit-card",Duration=2})
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
        if getgenv().AutoBuySeed then
            local BuySeed=ReplicatedStorage.GameEvents.BuySeedStock
            local seeds=(getgenv().SeedTier=="Tier 1") and Tier1Seeds or Tier2Seeds
            for _, seed in ipairs(seeds) do BuySeed:FireServer(getgenv().SeedTier,seed) end
        end

        -- Auto Buy Pet Egg
        if getgenv().AutoBuyPetEgg then
            local BuyEgg=ReplicatedStorage.GameEvents.BuyPetEgg
            for _, egg in ipairs(PetEggs) do BuyEgg:FireServer(egg) end
        end

        -- Auto Buy Gear
        if getgenv().AutoBuyGear then
            local BuyGear=ReplicatedStorage.GameEvents.BuyGearStock
            for _, gear in ipairs(GearList) do BuyGear:FireServer(gear) end
        end
    end
end)