local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
if not player then Players.PlayerAdded:Wait(); player = Players.LocalPlayer end

local character = player.Character or player.CharacterAdded:Wait()
local hrp
local function updateCharacter(c)
    character = c or player.Character
    if character then hrp = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart",5) end
end
updateCharacter(character)
player.CharacterAdded:Connect(function(c) task.wait(0.05); updateCharacter(c) end)

local function safeLoadWindUI()
    local ok, ui = pcall(function()
        local src = game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua")
        return loadstring(src)()
    end)
    if ok and ui then return ui end
    local stubDropdown = { SetValues=function() end }
    local stubTab = { Paragraph=function() return {} end, Button=function() return {} end, Toggle=function() return {} end, Dropdown=function() return stubDropdown end }
    local stubSection = { Tab=function() return stubTab end }
    return { CreateWindow=function() return stubSection end, Notify=function(data) print(data.Content or "") end, SetTheme=function() end }
end

local WindUI = safeLoadWindUI()

getgenv().AutoClickSeedPack = false
getgenv().AutoOpenMode = "None"
getgenv().AutoPlant = false
getgenv().PlantMode = "Player Positions"
getgenv().AutoSellMode = "None"
getgenv().InventoryLimit = 200
getgenv().AutoBuySeed = false
getgenv().SelectedSeed = nil
getgenv().AutoBuyPetEgg = false
getgenv().SelectedEgg = nil
getgenv().AutoBuyGear = false
getgenv().SelectedGear = nil

local DarkMode = true
local lastSell,lastBuy,lastClick,lastPlant=0,0,0,0
local SELL_COOLDOWN,BUY_COOLDOWN,CLICK_COOLDOWN,PLANT_COOLDOWN=1.25,0.6,0.35,0.12

local Tier1Seeds={
"Carrot","Strawberry","Blueberry","Orange Tulip","Tomato","Corn","Daffodil",
"Watermelon","Pumpkin","Apple","Bamboo","Coconut","Cactus","Dragon Fruit",
"Mango","Grape","Mushroom","Pepper","Beanstalk","Ember Lily","Sugar Apple",
"Burning Bud","Giant Pinecone","Elder Strawberry","Romanesco"
}

local Tier2Seeds={"Potato","Brussels Sprouts","Cocomango","Broccoli"}

local GearList={
"Watering Can","Trowel","Trading Ticket","Recall Wrench","Basic Sprinkler",
"Advanced Sprinkler","Medium Toy","Medium Treat","Godly Sprinkler",
"Magnifying Glass","Master Sprinkler","Cleaning Spray","Cleaning Pet Shard",
"Favorite Tool","Harvest Tool","Friendship Pot","Grandmaster Sprinkler","Level Up Lollipop"
}

local PetEggs={
"Common Egg","Uncommon Egg","Rare Egg","Mythical Egg","Legendary Egg","Bug Egg"
}

local Window=WindUI:CreateWindow({Title="MangoHub Full Auto",Icon="zap",Author="Vinreach",Folder="Mango",Size=UDim2.fromOffset(350,420),Theme=(DarkMode and "Dark" or "Light")})
local MainSection=Window:Section({Title="Main Features",Opened=true})
local AutoSection=Window:Section({Title="Automatic Features",Opened=true})
local SettingsSection=Window:Section({Title="Settings",Opened=true})

local MainTab=MainSection:Tab({Title="Main",Icon="house"})
MainTab:Paragraph({Title="MangoHub",Desc="Full Auto Script ✅\nFarm - Sell - Buy - Plant",Image="zap",Color=Color3.fromRGB(0,200,255)})

local AutoTab=AutoSection:Tab({Title="Automatic",Icon="mouse-pointer-click"})
AutoTab:Paragraph({Title="[AUTO CLICK]",Desc="Auto click Seed Pack / Chest",Image="mouse-pointer-click",Color=Color3.fromRGB(255,170,0)})
AutoTab:Toggle({Title="Enable Auto Click",Value=false,Callback=function(s)getgenv().AutoClickSeedPack=s end})
AutoTab:Dropdown({Title="Mode Open",Values={"None","Seed Pack","Chest"},Callback=function(v)getgenv().AutoOpenMode=v end})

local fruitStatus=AutoTab:Paragraph({Title="Fruit Status",Desc="Đang load...",Color=Color3.fromRGB(80,200,255)})
task.spawn(function() while task.wait(1) do local inv=(player:FindFirstChild("FruitInventory") or player:FindFirstChild("Inventory")) local count=inv and #inv:GetChildren() or 0 pcall(function() fruitStatus:SetDesc("Fruits: "..tostring(count).."/"..tostring(getgenv().InventoryLimit)) end) end end)

AutoTab:Dropdown({Title="Auto Sell Mode",Values={"None","Always","InventoryFull"},Callback=function(v)getgenv().AutoSellMode=v end})
AutoTab:Paragraph({Title="[AUTO PLANT]",Desc="Trồng tự động",Image="seedling",Color=Color3.fromRGB(0,220,100)})
AutoTab:Toggle({Title="Enable Auto Plant",Value=false,Callback=function(s)getgenv().AutoPlant=s end})
AutoTab:Dropdown({Title="Plant Mode",Values={"Player Positions","Random Can Plant"},Callback=function(v)getgenv().PlantMode=v end})
AutoTab:Paragraph({Title="[AUTO BUY]",Desc="Mua Seed / Pet / Gear",Image="shopping-cart",Color=Color3.fromRGB(255,200,0)})
AutoTab:Toggle({Title="Auto Buy Seed",Value=false,Callback=function(s)getgenv().AutoBuySeed=s end})

local seedTierDropdown, seedListDropdown
seedTierDropdown = AutoTab:Dropdown({
    Title="Seed Tier",
    Values={"Tier 1","Tier 2"},
    Callback=function(v)
        local list = (v=="Tier 1") and Tier1Seeds or Tier2Seeds
        if seedListDropdown and type(seedListDropdown.SetValues)=="function" then
            pcall(function() seedListDropdown:SetValues(list) end)
        end
    end
})

seedListDropdown = AutoTab:Dropdown({
    Title="Select Seed",
    Values=Tier1Seeds,
    Callback=function(v) getgenv().SelectedSeed=v end
})

AutoTab:Toggle({Title="Auto Buy Pet Egg",Value=false,Callback=function(s)getgenv().AutoBuyPetEgg=s end})
AutoTab:Dropdown({Title="Select Pet Egg",Values=PetEggs,Callback=function(v)getgenv().SelectedEgg=v end})

AutoTab:Toggle({Title="Auto Buy Gear",Value=false,Callback=function(s)getgenv().AutoBuyGear=s end})
AutoTab:Dropdown({Title="Select Gear",Values=GearList,Callback=function(v)getgenv().SelectedGear=v end})

local SettingsTab=SettingsSection:Tab({Title="Settings",Icon="cog"})
SettingsTab:Toggle({Title="Dark / Light Mode",Value=DarkMode,Callback=function(state) DarkMode=state; pcall(function() WindUI:SetTheme(DarkMode and "Dark" or "Light") end) end})

task.spawn(function()
    while task.wait(0.45) do
        local now=tick()
        if getgenv().AutoClickSeedPack and getgenv().AutoOpenMode~="None" and now-lastClick>=CLICK_COOLDOWN then
            lastClick=now
            local containers={player:FindFirstChild("Backpack") or player}
            for _,cont in ipairs(containers) do
                for _,item in ipairs(cont:GetChildren()) do
                    if item:IsA("Tool") and (item.Name:match(getgenv().AutoOpenMode) or item.Name==getgenv().AutoOpenMode) then
                        pcall(function() item:Activate() end)
                    end
                end
            end
        end
        if getgenv().AutoSellMode~="None" and now-lastSell>=SELL_COOLDOWN then
            lastSell=now
            local SellRemote=ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("Sell_Inventory")
            if SellRemote and hrp then pcall(function() local old=hrp.CFrame; hrp.CFrame=CFrame.new(86,4,0); task.wait(1); SellRemote:FireServer(); task.wait(0.6); if old then hrp.CFrame=old end end) end
        end
        if getgenv().AutoPlant and hrp and now-lastPlant>=PLANT_COOLDOWN then
            lastPlant=now
            local PlantEvent=ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("Plant_RE")
            if PlantEvent and getgenv().SelectedSeed then pcall(function() PlantEvent:FireServer(hrp.Position,getgenv().SelectedSeed) end) end
        end
        if getgenv().AutoBuySeed and getgenv().SelectedSeed and now-lastBuy>=BUY_COOLDOWN then
            lastBuy=now
            local BuySeed=ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("BuySeedStock")
            if BuySeed then pcall(function() BuySeed:FireServer(getgenv().SelectedSeed) end) end
        end
        if getgenv().AutoBuyPetEgg and getgenv().SelectedEgg and now-lastBuy>=BUY_COOLDOWN then
            lastBuy=now
            local BuyEgg=ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("BuyPetEgg")
            if BuyEgg then pcall(function() BuyEgg:FireServer(getgenv().SelectedEgg) end) end
        end
        if getgenv().AutoBuyGear and getgenv().SelectedGear and now-lastBuy>=BUY_COOLDOWN then
            lastBuy=now
            local BuyGear=ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("BuyGearStock")
            if BuyGear then pcall(function() BuyGear:FireServer(getgenv().SelectedGear) end) end
        end
    end
end)

WindUI:Notify({Title="MangoHub",Content="Script loaded ✅",Duration=2})