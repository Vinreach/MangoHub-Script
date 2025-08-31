-- =================================
-- 🟣 MangoHub Full Auto Mobile Final
-- =================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- =========================
-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- =========================
-- Globals
getgenv().AutoClickSeedPack = false
getgenv().AutoOpenMode = "None"
getgenv().AutoSellInventory = false
getgenv().AutoPlant = false
getgenv().PlantMode = "Player Positions"
getgenv().AutoBuySeed = false
getgenv().AutoBuyPetEgg = false
getgenv().AutoBuyGear = false
getgenv().SeedTier = "Tier 1"

local DarkMode = true
local CurrentLanguage = "Vietnamese"

local Tier1Seeds = {"Carrot","Strawberry","Blueberry","Tomato","Daffodil","Watermelon","Pumpkin","Apple","Bamboo","Coconut","Cactus","Dragon Fruit","Mango","Grape","Mushroom","Pepper","Cacao","Beanstalk","Ember Lily","Sugar Apple","Burning Bud","Giant Pinecone","Elder Strawberry","Romanesco"}
local Tier2Seeds = {"Potato","Cocomango","Broccoli","Brussels Sprouts"}
local GearList = {"Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler","Master Sprinkler","Grandmaster Sprinkler","Magnifying Glass","Tanning Mirror","Cleaning Spray","Cleansing Pet Shard","Favorite Tool","Harvest Tool","Friendship Pot","Level-Up Lollipop","Trading Ticket","Medium Treat","Medium Toy"}
local PetEggs = {"Common Egg","Uncommon Egg","Rare Egg","Legendary Egg","Bug Egg"}

local SellCFrame = CFrame.new(
    86.17431640625, 4.266193389892578, 0.3864983320236206,
    3.637978807091713e-12, 0.9906342029571533, -0.13654328882694244,
    -0.0003319779352750629, 0.13654328882694244, 0.9906340837478638,
    1, 0.00004532935417955741, 0.00032886865665204823
)

-- =========================
-- Create Window
local Window = WindUI:CreateWindow({Title="MangoHub Full Auto",Icon="zap",Author="Vinreach",Folder="Mango",Size=UDim2.fromOffset(340,400),Theme="Dark"})
local MainSection = Window:Section({Title="Main Features",Opened=true})
local AutoSection = Window:Section({Title="Automatic Features",Opened=true})
local SettingsSection = Window:Section({Title="Settings",Opened=true})
local MiscSection = Window:Section({Title="Misc",Opened=true}) -- trống

-- =========================
-- MainTab
local MainTab = MainSection:Tab({Title="Main",Icon="house"})
MainTab:Button({
    Title="Join Discord",
    Desc="Click để tham gia Discord",
    Callback=function()
        setclipboard("https://discord.gg/yourserver")
        WindUI:Notify({Title="Discord",Content="Link copied!",Icon="check",Duration=2})
    end
})
MainTab:Paragraph({Title="Coming Soon",Desc="Tính năng mới sẽ xuất hiện ở đây!",Image="sparkles",Color=Color3.fromHex("#00ffcc")})

-- =========================
-- AutoTab
local AutoTab = AutoSection:Tab({Title="Automatic",Icon="mouse-pointer-click"})

-- Auto Click
AutoTab:Paragraph({Title="[ AUTOMATIC: AUTO CLICK ]",Desc="Tự động click Seed Pack / Chest",Image="mouse-pointer-click",Color=Color3.fromHex("#ffaa00")})
AutoTab:Toggle({Title="Enable Auto Click",Desc="",Value=false,Callback=function(state)getgenv().AutoClickSeedPack=state end})
AutoTab:Dropdown({Title="Mode Open",Desc="",Values={"None","Seed Pack","Chest"},Callback=function(val)getgenv().AutoOpenMode=val end})

-- Auto Sell
AutoTab:Paragraph({Title="[ AUTOMATIC: AUTO SELL ]",Desc="Auto Sell Inventory: teleport tới điểm bán rồi về chỗ cũ",Image="credit-card",Color=Color3.fromHex("#ff5555")})
AutoTab:Toggle({Title="Enable Auto Sell",Desc="",Value=false,Callback=function(state)getgenv().AutoSellInventory=state end})

-- Auto Plant
AutoTab:Paragraph({Title="[ AUTOMATIC: AUTO PLANT ]",Desc="Tự động trồng các seed chỉ ở farm của bạn",Image="seedling",Color=Color3.fromHex("#00ff66")})
AutoTab:Toggle({Title="Enable Auto Plant",Desc="",Value=false,Callback=function(state)getgenv().AutoPlant=state end})
AutoTab:Dropdown({Title="Plant Mode",Desc="",Values={"Player Positions","Random Can Plant"},Callback=function(val)getgenv().PlantMode=val end})

-- Auto Buy
AutoTab:Paragraph({Title="[ AUTOMATIC: AUTO BUY ]",Desc="Tự động mua tất cả Seed / Pet / Gear",Image="shopping-cart",Color=Color3.fromHex("#ffaa00")})
AutoTab:Toggle({Title="Auto Buy Seed",Desc="",Value=false,Callback=function(state)getgenv().AutoBuySeed=state end})
AutoTab:Toggle({Title="Auto Buy Pet Egg",Desc="",Value=false,Callback=function(state)getgenv().AutoBuyPetEgg=state end})
AutoTab:Toggle({Title="Auto Buy Gear",Desc="",Value=false,Callback=function(state)getgenv().AutoBuyGear=state end})

-- =========================
-- SettingsTab
local SettingsTab = SettingsSection:Tab({Title="Settings",Icon="cog"})
SettingsTab:Toggle({
    Title="Dark / Light Mode",
    Desc="Chuyển đổi giao diện",
    Value=DarkMode,
    Callback=function(state)
        DarkMode=state
        Window:ChangeTheme(DarkMode and "Dark" or "Light")
        WindUI:Notify({Title="Settings",Content=DarkMode and "Dark Mode" or "Light Mode",Icon="zap",Duration=2})
    end
})
SettingsTab:Dropdown({
    Title="Language",
    Desc="Chọn ngôn ngữ UI",
    Values={"Vietnamese","English"},
    Callback=function(val)
        CurrentLanguage=val
        WindUI:Notify({Title="Settings",Content="Language set to "..CurrentLanguage,Icon="zap",Duration=2})
    end
})

-- =========================
-- Auto Loop
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
            local farmOwner = workspace.Farm.Farm.Important.Data.Owner.Value
            if farmOwner == player.Name then
                local originalPos = hrp.Position
                hrp.CFrame = SellCFrame
                task.wait(2)
                ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
                task.wait(0.5)
                hrp.CFrame = CFrame.new(originalPos)
            end
        end

        -- Auto Plant
        if getgenv().AutoPlant then
            local farmOwner = workspace.Farm.Farm.Important.Data.Owner.Value
            if farmOwner == player.Name then
                local PlantEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("PlantSeed")
                local allSeeds = {}
                for _, s in ipairs(Tier1Seeds) do table.insert(allSeeds,s) end
                for _, s in ipairs(Tier2Seeds) do table.insert(allSeeds,s) end
                for _, seed in ipairs(allSeeds) do
                    local pos = hrp.Position
                    if getgenv().PlantMode=="Random Can Plant" then
                        local locations = {}
                        local plantFolder = workspace.Farm.Farm.Important:FindFirstChild("Plant_Locations")
                        if plantFolder then
                            local canPlant = plantFolder:FindFirstChild("Can_Plant")
                            if canPlant then table.insert(locations,canPlant.Position) end
                        end
                        if #locations>0 then pos=locations[math.random(1,#locations)] end
                    end
                    PlantEvent:FireServer(seed,pos)
                end
            end
        end

        -- Auto Buy Seed
        if getgenv().AutoBuySeed then
            local BuySeed = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock")
            for _, seed in ipairs(Tier1Seeds) do BuySeed:FireServer(getgenv().SeedTier,seed) end
            for _, seed in ipairs(Tier2Seeds) do BuySeed:FireServer(getgenv().SeedTier,seed) end
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