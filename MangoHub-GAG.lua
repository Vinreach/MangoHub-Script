local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local player=Players.LocalPlayer
if not player then Players.PlayerAdded:Wait(); player=Players.LocalPlayer end

local character=player.Character or player.CharacterAdded:Wait()
local hrp
local function updateCharacter(c)
    character=c or player.Character
    if character then hrp=character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart",5) end
end
updateCharacter(character)
player.CharacterAdded:Connect(function(c) task.wait(0.05); updateCharacter(c) end)

local function safeLoadWindUI()
    local ok, ui=pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
    if ok and ui then return ui end
    local stub={ CreateWindow=function() return { Tab=function() return { Paragraph=function() end, Button=function() end, Toggle=function() end, Dropdown=function() return { SetValues=function() end } end } end } end, Notify=function(data) print(data.Content or "") end, SetTheme=function() end }
    return stub
end

local WindUI=safeLoadWindUI()

-- Globals
getgenv().AutoClickSeedPack=false
getgenv().AutoOpenMode="None"
getgenv().AutoPlant=false
getgenv().PlantMode="Player Positions"
getgenv().AutoSellMode="None"
getgenv().InventoryLimit=200
getgenv().AutoBuySeed=false
getgenv().SelectedSeed=nil
getgenv().AutoBuyPetEgg=false
getgenv().SelectedEgg=nil
getgenv().AutoBuyGear=false
getgenv().SelectedGear=nil
getgenv().AutoFairyWish=false
getgenv().AutoSubmitFairyFountain=false

local DarkMode=true
local lastSell,lastBuy,lastClick,lastPlant=0,0,0,0
local SELL_COOLDOWN,BUY_COOLDOWN,CLICK_COOLDOWN,PLANT_COOLDOWN=1.25,0.6,0.35,0.12

-- Seeds
local Tier1Seeds={
"Carrot","Strawberry","Blueberry","Orange Tulip","Tomato","Corn","Daffodil",
"Watermelon","Pumpkin","Apple","Bamboo","Coconut","Cactus","Dragon Fruit",
"Mango","Grape","Mushroom","Pepper","Beanstalk","Ember Lily","Sugar Apple",
"Burning Bud","Giant Pinecone","Elder Strawberry","Romanesco"
}
local Tier2Seeds={"Potato","Brussels Sprouts","Cocomango","Broccoli"}

-- Gear / Pet
local GearList={
"Watering Can","Trowel","Trading Ticket","Recall Wrench","Basic Sprinkler",
"Advanced Sprinkler","Medium Toy","Medium Treat","Godly Sprinkler",
"Magnifying Glass","Master Sprinkler","Cleaning Spray","Favorite Tool",
"Harvest Tool","Friendship Pot","Grandmaster Sprinkler","Level Up Lollipop"
}
local PetEggs={
"Common Egg","Uncommon Egg","Rare Egg","Mythical Egg","Legendary Egg","Bug Egg"
}

-- UI
local Window=WindUI:CreateWindow({Title="MangoHub Full Auto + Event",Icon="zap",Author="Vinreach",Folder="Mango",Size=UDim2.fromOffset(350,500),Theme=(DarkMode and "Dark" or "Light")})
local AutoSection=Window:Section({Title="Automatic Features",Opened=true})
local AutoTab=AutoSection:Tab({Title="Automatic",Icon="mouse-pointer-click"})

-- Seed Dropdown
local seedTierDropdown,seedListDropdown
seedTierDropdown=AutoTab:Dropdown({Title="Seed Tier",Values={"Tier 1","Tier 2"},Callback=function(v)
    local list=(v=="Tier 1") and Tier1Seeds or Tier2Seeds
    if seedListDropdown and type(seedListDropdown.SetValues)=="function" then pcall(function() seedListDropdown:SetValues(list) end) end
end})
seedListDropdown=AutoTab:Dropdown({Title="Select Seed",Values=Tier1Seeds,Callback=function(v)getgenv().SelectedSeed=v end})

-- Toggles / Dropdowns
AutoTab:Toggle({Title="Auto Click",Value=false,Callback=function(s)getgenv().AutoClickSeedPack=s end})
AutoTab:Dropdown({Title="Mode Open",Values={"None","Seed Pack","Chest"},Callback=function(v)getgenv().AutoOpenMode=v end})
AutoTab:Dropdown({Title="Auto Sell Mode",Values={"None","Always","InventoryFull"},Callback=function(v)getgenv().AutoSellMode=v end})
AutoTab:Toggle({Title="Auto Plant",Value=false,Callback=function(s)getgenv().AutoPlant=s end})
AutoTab:Dropdown({Title="Plant Mode",Values={"Player Positions","Random Can Plant"},Callback=function(v)getgenv().PlantMode=v end})
AutoTab:Toggle({Title="Auto Buy Seed",Value=false,Callback=function(s)getgenv().AutoBuySeed=s end})
AutoTab:Toggle({Title="Auto Buy Pet Egg",Value=false,Callback=function(s)getgenv().AutoBuyPetEgg=s end})
AutoTab:Dropdown({Title="Select Pet Egg",Values=PetEggs,Callback=function(v)getgenv().SelectedEgg=v end})
AutoTab:Toggle({Title="Auto Buy Gear",Value=false,Callback=function(s)getgenv().AutoBuyGear=s end})
AutoTab:Dropdown({Title="Select Gear",Values=GearList,Callback=function(v)getgenv().SelectedGear=v end})
AutoTab:Toggle({Title="Auto Make Fairy Wish",Value=false,Callback=function(s)getgenv().AutoFairyWish=s end})

-- Event Tab: Auto Submit Fairy Fountain
local EventTab=Window:Section({Title="Event Features",Opened=true}):Tab({Title="Event",Icon="gift"})
EventTab:Toggle({
    Title="Auto Submit All Fairy Fountain",
    Value=false,
    Callback=function(s) getgenv().AutoSubmitFairyFountain=s end
})

-- Settings
local SettingsTab=Window:Section({Title="Settings",Opened=true}):Tab({Title="Settings",Icon="cog"})
SettingsTab:Toggle({Title="Dark / Light Mode",Value=DarkMode,Callback=function(state) DarkMode=state; pcall(function() WindUI:SetTheme(DarkMode and "Dark" or "Light") end) end})

-- Helper
local function getInventoryCount()
    local inv=player:FindFirstChild("FruitInventory") or player:FindFirstChild("Inventory")
    if inv and type(inv.GetChildren)=="function" then return #inv:GetChildren() end
    return 0
end
local function safeActivateTool(tool)
    if not tool then return end
    pcall(function()
        if typeof(tool.Activate)=="function" then tool:Activate() end
    end)
end
local function getPlantLocations()
    local folder=Workspace:FindFirstChild("Farm") and Workspace.Farm:FindFirstChild("Farm") and Workspace.Farm.Farm:FindFirstChild("Important") and Workspace.Farm.Farm.Important:FindFirstChild("Plant_Locations")
    local parts={}
    if folder then for _,m in ipairs(folder:GetChildren()) do local can=m:FindFirstChild("Can_Plant") if can then table.insert(parts,can.Position) end end end
    return parts
end

-- Main auto loop
task.spawn(function()
    while task.wait(0.45) do
        local now=tick()
        -- Auto Click
        if getgenv().AutoClickSeedPack and getgenv().AutoOpenMode~="None" and now-lastClick>=CLICK_COOLDOWN then
            lastClick=now
            local containers={player:FindFirstChild("Backpack") or player,character}
            for _,cont in ipairs(containers) do
                for _,item in ipairs(cont:GetChildren()) do
                    if item:IsA("Tool") and (item.Name:match(getgenv().AutoOpenMode) or item.Name==getgenv().AutoOpenMode) then safeActivateTool(item) end
                end
            end
        end
        -- Auto Sell
        local count=getInventoryCount()
        if getgenv().AutoSellMode~="None" and now-lastSell>=SELL_COOLDOWN then
            lastSell=now
            local SellRemote=ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("Sell_Inventory")
            if SellRemote and hrp then pcall(function() local old=hrp.CFrame; hrp.CFrame=CFrame.new(86,4,0); task.wait(1); SellRemote:FireServer(); task.wait(0.6); if old then hrp.CFrame=old end end) end
        end
        -- Auto Plant
        if getgenv().AutoPlant and hrp and now-lastPlant>=PLANT_COOLDOWN and getgenv().SelectedSeed then
            lastPlant=now
            local PlantEvent=ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("Plant_RE")
            if PlantEvent then
                local pos=hrp.Position
                if getgenv().PlantMode=="Random Can Plant" then
                    local spots=getPlantLocations()
                    if #spots>0 then pos=spots[math.random(1,#spots)] end
                end
                pcall(function() PlantEvent:FireServer(pos,getgenv().SelectedSeed) end)
            end
        end
        -- Auto Buy Seed
        if getgenv().AutoBuySeed and getgenv().SelectedSeed and now-lastBuy>=BUY_COOLDOWN then
            lastBuy=now
            local BuySeed=ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("BuySeedStock")
            if BuySeed then pcall(function() BuySeed:FireServer(getgenv().SelectedSeed) end) end
        end
        -- Auto Buy Pet Egg
        if getgenv().AutoBuyPetEgg and getgenv().SelectedEgg and now-lastBuy>=BUY_COOLDOWN then
            lastBuy=now
            local BuyEgg=ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("BuyPetEgg")
            if BuyEgg then pcall(function() BuyEgg:FireServer(getgenv().SelectedEgg) end) end
        end
        -- Auto Buy Gear
        if getgenv().AutoBuyGear and getgenv().SelectedGear and now-lastBuy>=BUY_COOLDOWN then
            lastBuy=now
            local BuyGear=ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("BuyGearStock")
            if BuyGear then pcall(function() BuyGear:FireServer(getgenv().SelectedGear) end) end
        end
        -- Auto Make Fairy Wish
        if getgenv().AutoFairyWish then
            local ok,fairyRemote=pcall(function()
                return ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("FairyService"):WaitForChild("MakeFairyWish")
            end)
            if ok and fairyRemote then task.spawn(function() task.wait(0.2); pcall(function() fairyRemote:FireServer() end) end) end
        end
        -- Auto Submit Fairy Fountain
        if getgenv().AutoSubmitFairyFountain then
            local ok,submitRemote=pcall(function()
                return ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("FairyService"):WaitForChild("SubmitFairyFountainAllPlants")
            end)
            if ok and submitRemote then task.spawn(function() task.wait(0.2); pcall(function() submitRemote:FireServer() end) end) end
        end
    end
end)

WindUI:Notify({Title="MangoHub",Content="Script loaded ✅",Duration=2})