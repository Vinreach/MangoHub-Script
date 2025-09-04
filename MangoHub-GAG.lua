local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
if not player then
    Players.PlayerAdded:Wait()
    player = Players.LocalPlayer
end

local character = player.Character or player.CharacterAdded:Wait()
local hrp = nil
if character then
    hrp = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
end

player.CharacterAdded:Connect(function(char)
    character = char
    hrp = character:WaitForChild("HumanoidRootPart")
end)

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
        game:GetService("StarterGui"):SetCore("SendNotification", {Title="Lỗi", Text="Không tải được WindUI!", Duration=5})
    end)
    return
end

getgenv().AutoClickSeedPack = false
getgenv().AutoOpenMode = "None"
getgenv().AutoPlant = false
getgenv().PlantMode = "Player Positions"
getgenv().AutoSellMode = "None"
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

local function safeFind(obj, ...)
    for i = 1, select("#", ...) do
        if not obj then return nil end
        obj = obj:FindFirstChild(select(i, ...))
    end
    return obj
end

local Tier1Seeds, Tier2Seeds, GearList, PetEggs = {}, {}, {}, {}

local seedShop = safeFind(Workspace, "Farm", "Farm", "Important", "SeedShop")
if seedShop then
    for _, tierFolder in pairs(seedShop:GetChildren()) do
        if tierFolder.Name == "Tier 1" then
            for _, seed in pairs(tierFolder:GetChildren()) do
                table.insert(Tier1Seeds, seed.Name)
            end
        elseif tierFolder.Name == "Tier 2" then
            for _, seed in pairs(tierFolder:GetChildren()) do
                table.insert(Tier2Seeds, seed.Name)
            end
        end
    end
end

local gearShop = safeFind(Workspace, "Farm", "Farm", "Important", "GearShop")
if gearShop then
    for _, gear in pairs(gearShop:GetChildren()) do
        table.insert(GearList, gear.Name)
    end
end

local eggShop = safeFind(Workspace, "Farm", "Farm", "Important", "EggShop")
if eggShop then
    for _, egg in pairs(eggShop:GetChildren()) do
        table.insert(PetEggs, egg.Name)
    end
end

if #Tier1Seeds == 0 then Tier1Seeds = {"Carrot","Tomato"} end
if #Tier2Seeds == 0 then Tier2Seeds = {"Strawberry","Corn"} end
if #GearList == 0 then GearList = {"Watering Can","Sprinkler"} end
if #PetEggs == 0 then PetEggs = {"Common Egg","Rare Egg"} end

local SellCFrame = CFrame.new(86.174316, 4.266193, 0.386498, 0, 0.990634, -0.136543, -0.000332, 0.136543, 0.990634, 1, 0, 0)

local Window = WindUI:CreateWindow({Title="MangoHub Full Auto",Icon="zap",Author="Vinreach",Folder="Mango",Size=UDim2.fromOffset(350,420),Theme="Dark"})
local MainSection = Window:Section({Title="Main Features",Opened=true})
local AutoSection = Window:Section({Title="Automatic Features",Opened=true})
local SettingsSection = Window:Section({Title="Settings",Opened=true})

local MainTab = MainSection:Tab({Title="Main",Icon="house"})
MainTab:Paragraph({Title="MangoHub",Desc="Full Auto Script ✅\nFarm - Sell - Buy - Plant",Image="zap",Color=Color3.fromRGB(0,200,255)})

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

local AutoTab = AutoSection:Tab({Title="Automatic",Icon="mouse-pointer-click"})

local function getInventoryCount()
    local inv = player:FindFirstChild("FruitInventory") or player:FindFirstChild("Inventory")
    if inv then
        return #inv:GetChildren()
    end
    return 0
end

AutoTab:Paragraph({Title="[AUTO CLICK]",Desc="Tự động click Seed Pack / Chest",Image="mouse-pointer-click",Color=Color3.fromRGB(255,170,0)})
AutoTab:Toggle({Title="Enable Auto Click",Value=false,Callback=function(s)getgenv().AutoClickSeedPack=s end})
AutoTab:Dropdown({Title="Mode Open",Values={"None","Seed Pack","Chest"},Callback=function(v)getgenv().AutoOpenMode=v end})

AutoTab:Paragraph({Title="[AUTO SELL]",Desc="3 chế độ bán fruit",Image="credit-card",Color=Color3.fromRGB(255,80,80)})
local fruitStatus = AutoTab:Paragraph({Title="Fruit Status",Desc="Đang load...",Color=Color3.fromRGB(80,200,255)})

task.spawn(function()
    while task.wait(1) do
        local count = getInventoryCount()
        local cap = (player:FindFirstChild("MaxFruit") and player.MaxFruit.Value) or getgenv().InventoryLimit
        fruitStatus:SetDesc("Fruits: "..tostring(count).."/"..tostring(cap))
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
            local success, err = pcall(function()
                local oldCFrame = hrp.CFrame
                hrp.CFrame = SellCFrame
                task.wait(2)
                SellRemote:FireServer()
                WindUI:Notify({Title="Sell",Content="Đã bán inventory (1 lần)",Icon="credit-card",Duration=2})
                task.wait(0.5)
                hrp.CFrame = oldCFrame
            end)
            if not success then
                WindUI:Notify({Title="Lỗi",Content="Sell failed: "..tostring(err),Icon="x",Duration=3})
            end
        else
            WindUI:Notify({Title="Lỗi",Content="Không tìm thấy Sell_Inventory hoặc HRP!",Icon="x",Duration=2})
        end
    end
})

AutoTab:Paragraph({Title="[AUTO PLANT]",Desc="Chỉ trồng trong farm của bạn",Image="seedling",Color=Color3.fromRGB(0,220,100)})
AutoTab:Toggle({Title="Enable Auto Plant",Value=false,Callback=function(s)getgenv().AutoPlant=s end})
AutoTab:Dropdown({Title="Plant Mode",Values={"Player Positions","Random Can Plant"},Callback=function(v)getgenv().PlantMode=v end})

AutoTab:Paragraph({Title="[AUTO BUY]",Desc="Tự động mua Seed / Pet / Gear",Image="shopping-cart",Color=Color3.fromRGB(255,200,0)})
AutoTab:Toggle({Title="Auto Buy Seed",Value=false,Callback=function(s)getgenv().AutoBuySeed=s end})
AutoTab:Dropdown({Title="Seed Tier",Values={"Tier 1","Tier 2"},Callback=function(v)getgenv().SeedTier=v end})
AutoTab:Dropdown({Title="Select Seed",Values=Tier1Seeds,Callback=function(v)getgenv().SelectedSeed=v end})
AutoTab:Toggle({Title="Auto Buy Pet Egg",Value=false,Callback=function(s)getgenv().AutoBuyPetEgg=s end})
AutoTab:Dropdown({Title="Select Pet Egg",Values=PetEggs,Callback=function(v)getgenv().SelectedEgg=v end})
AutoTab:Toggle({Title="Auto Buy Gear",Value=false,Callback=function(s)getgenv().AutoBuyGear=s end})
AutoTab:Dropdown({Title="Select Gear",Values=GearList,Callback=function(v)getgenv().SelectedGear=v end})

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

local function getPlantLocations()
    local plantFolder = safeFind(Workspace, "Farm", "Farm", "Important", "Plant_Locations")
    local canPlantParts = {}
    if plantFolder then
        for _, model in pairs(plantFolder:GetChildren()) do
            local canPart = model:FindFirstChild("Can_Plant")
            if canPart and canPart:IsA("BasePart") then
                table.insert(canPlantParts, canPart.Position)
            end
        end
    end
    return canPlantParts
end

task.spawn(function()
    while task.wait(0.6) do
        if getgenv().AutoClickSeedPack and getgenv().AutoOpenMode ~= "None" then
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, item in pairs(backpack:GetChildren()) do
                    if item and item:IsA("Tool") and item.Name == getgenv().AutoOpenMode then
                        pcall(function() item:Activate() end)
                    end
                end
            end
            if character then
                for _, item in pairs(character:GetChildren()) do
                    if item and item:IsA("Tool") and item.Name == getgenv().AutoOpenMode then
                        pcall(function() item:Activate() end)
                    end
                end
            end
        end

        local count = getInventoryCount()
        local cap = (player:FindFirstChild("MaxFruit") and player.MaxFruit.Value) or getgenv().InventoryLimit
        local shouldSell = (getgenv().AutoSellMode == "Always") or (getgenv().AutoSellMode == "InventoryFull" and count >= cap)

        if shouldSell then
            local SellRemote = safeFind(ReplicatedStorage, "GameEvents", "Sell_Inventory")
            if SellRemote and hrp then
                pcall(function()
                    local oldCFrame = hrp.CFrame
                    hrp.CFrame = SellCFrame
                    task.wait(2)
                    SellRemote:FireServer()
                    task.wait(0.5)
                    if oldCFrame then hrp.CFrame = oldCFrame end
                end)
            end
        end

        local farmData = safeFind(Workspace, "Farm", "Farm", "Important", "Data")
        local isOwner = farmData and farmData:FindFirstChild("Owner") and farmData.Owner.Value == player.Name
        if getgenv().AutoPlant and isOwner and hrp then
            local PlantEvent = safeFind(ReplicatedStorage,"GameEvents","Plant_RE")
            local seeds = (getgenv().SeedTier == "Tier 1") and Tier1Seeds or Tier2Seeds
            if PlantEvent and seeds and #seeds > 0 then
                for _, seed in ipairs(seeds) do
                    local pos = hrp.Position
                    if getgenv().PlantMode == "Random Can Plant" then
                        local spots = getPlantLocations()
                        if #spots > 0 then pos = spots[math.random(1,#spots)] end
                    end
                    pcall(function() PlantEvent:FireServer(pos, seed) end)
                    task.wait(0.12)
                end
            end
        end

        if getgenv().AutoBuySeed and getgenv().SelectedSeed then
            local BuySeed = safeFind(ReplicatedStorage,"GameEvents","BuySeedStock")
            if BuySeed then pcall(function() BuySeed:FireServer(getgenv().SeedTier,getgenv().SelectedSeed) end) end
        end

        if getgenv().AutoBuyPetEgg and getgenv().SelectedEgg then
            local BuyEgg = safeFind(ReplicatedStorage,"GameEvents","BuyPetEgg")
            if BuyEgg then pcall(function() BuyEgg:FireServer(getgenv().SelectedEgg) end) end
        end

        if getgenv().AutoBuyGear and getgenv().SelectedGear then
            local BuyGear = safeFind(ReplicatedStorage,"GameEvents","BuyGearStock")
            if BuyGear then pcall(function() BuyGear:FireServer(getgenv().SelectedGear) end) end
        end
    end
end)