-- =================================
-- 🟣 MangoHub Full Auto + ESP
-- =================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- =========================
-- Load WindUI
-- =========================
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
getgenv().ESP_Enabled = false
getgenv().AutoClickSeedPack = false
getgenv().AutoOpenMode = "None"
getgenv().AutoSellInventory = false
getgenv().AutoBuySeed = false
getgenv().AutoWaterCan = false
getgenv().SeedTier = "Tier 1"
getgenv().SeedName = "Tên seed"
getgenv().WaterPosition = Vector3.new(-1.175445556640625, 0.1355232298374176, 66.70378875732422)

-- =========================
-- Create Window
-- =========================
local Window = WindUI:CreateWindow({
    Title = "MangoHub Full Auto",
    Icon = "zap",
    Author = "Made By Group Vinreach",
    Folder = "Mango",
    Size = UDim2.fromOffset(340, 400),
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
-- Automatic Tab
-- =========================
AutoTab:Paragraph({Title = "Automatic Features", Desc = "Auto-click, buy, sell, water", Image = "zap", Color = Color3.fromHex("#ffaa00")})

-- Auto Click Seed Pack
AutoTab:Toggle({Title = "Auto Click Seed Pack", Desc = "Automatically click items", Value = false, Callback = function(state) getgenv().AutoClickSeedPack = state WindUI:Notify({Title="Auto Click Seed Pack", Content=state and "Enabled!" or "Disabled!", Icon="check", Duration=2}) end})
AutoTab:Dropdown({Title = "Select mode open", Desc = "Choose item to auto click", Values = {"None", "Seed Pack", "Chest"}, Callback = function(val) getgenv().AutoOpenMode = val WindUI:Notify({Title="Automatic Mode", Content="Selected: "..val, Icon="zap", Duration=2}) end})

-- Auto Sell Inventory
AutoTab:Toggle({Title = "Auto Sell Inventory", Desc = "Automatically sell all items", Value = false, Callback = function(state) getgenv().AutoSellInventory = state WindUI:Notify({Title="Auto Sell", Content=state and "Enabled!" or "Disabled!", Icon="check", Duration=2}) end})

-- Auto Buy Seed
AutoTab:Toggle({Title = "Auto Buy Seed", Desc = "Automatically buy selected seed", Value = false, Callback = function(state) getgenv().AutoBuySeed = state WindUI:Notify({Title="Auto Buy Seed", Content=state and "Enabled!" or "Disabled!", Icon="check", Duration=2}) end})
AutoTab:Dropdown({Title = "Select Seed Tier", Desc = "Choose the tier", Values = {"Tier 1","Tier 2","Tier 3"}, Callback = function(val) getgenv().SeedTier = val WindUI:Notify({Title="Seed Tier", Content="Selected: "..val, Icon="zap", Duration=2}) end})
AutoTab:Textbox({Title = "Seed Name", Desc = "Enter seed name", Callback = function(val) getgenv().SeedName = val end})

-- Auto Water Can
AutoTab:Toggle({Title = "Auto Water Can", Desc = "Automatically water tree", Value = false, Callback = function(state) getgenv().AutoWaterCan = state WindUI:Notify({Title="Auto Water", Content=state and "Enabled!" or "Disabled!", Icon="check", Duration=2}) end})

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

MiscTab:Button({Title = "Toggle ESP Egg", Desc = "Show/hide Egg overlay", Callback = function() getgenv().ESP_Enabled = not getgenv().ESP_Enabled WindUI:Notify({Title="ESP Egg", Content=getgenv().ESP_Enabled and "Enabled" or "Disabled", Icon="eye", Duration=2}) end})

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

        -- Auto Sell Inventory
        if getgenv().AutoSellInventory then
            local SellInventory = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Inventory")
            SellInventory:FireServer()
        end

        -- Auto Buy Seed
        if getgenv().AutoBuySeed then
            local BuySeed = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock")
            BuySeed:FireServer(getgenv().SeedTier, getgenv().SeedName)
        end

        -- Auto Water Can
        if getgenv().AutoWaterCan then
            local WaterRE = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Water_RE")
            WaterRE:FireServer(vector.create(getgenv().WaterPosition.X,getgenv().WaterPosition.Y,getgenv().WaterPosition.Z))
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