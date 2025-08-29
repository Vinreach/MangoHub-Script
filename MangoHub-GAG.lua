-- =================================
-- 🟣 MangoHub - WindUI + Auto Click Seed Pack/Chest + ESP Egg (Billboard)
-- =================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- =========================
-- Load WindUI
-- =========================
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
getgenv().ESP_Enabled = false
getgenv().AutoClickSeedPack = false
getgenv().AutoOpenMode = "None"

-- =========================
-- Create Window
-- =========================
local Window = WindUI:CreateWindow({
    Title = "MangoHub",
    Icon = "zap",
    Author = "Made By Group Vinreach",
    Folder = "Mango",
    Size = UDim2.fromOffset(340, 360),
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
-- MainTab content (Chỉ Discord + future features)
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
            WindUI:Notify({
                Title="Discord",
                Content="Link copied!",
                Icon="check",
                Duration=2
            })
        end
    end
})

MainTab:Paragraph({
    Title = "Coming Soon",
    Desc = "New features will appear here!",
    Image = "sparkles",
    Color = Color3.fromHex("#00ffcc")
})

-- =========================
-- Automatic Tab
-- =========================
AutoTab:Paragraph({
    Title = "Automatic Features",
    Desc = "Automatically click items based on selected mode",
    Image = "zap",
    Color = Color3.fromHex("#ffaa00")
})

-- Toggle Auto Click Seed Pack
AutoTab:Toggle({
    Title = "Auto Click Seed Pack",
    Desc = "Automatically click items when enabled",
    Value = false,
    Callback = function(state)
        getgenv().AutoClickSeedPack = state
        WindUI:Notify({
            Title="Auto Click Seed Pack",
            Content=state and "Enabled!" or "Disabled!",
            Icon="check",
            Duration=2
        })
    end
})

-- Dropdown Select Mode Open
AutoTab:Dropdown({
    Title = "Select mode open",
    Desc = "Choose which item to auto click",
    Values = {"None", "Seed Pack", "Chest"},
    Callback = function(val)
        getgenv().AutoOpenMode = val
        WindUI:Notify({
            Title="Automatic Mode",
            Content="Selected: "..val,
            Icon="zap",
            Duration=2
        })
    end
})

-- Auto loop click (0.5s check 1 lần)
task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().AutoClickSeedPack and getgenv().AutoOpenMode ~= "None" then
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, item in pairs(backpack:GetChildren()) do
                    if item:IsA("Tool") and item.Name:match(getgenv().AutoOpenMode) then
                        if item:FindFirstChild("Activate") then
                            item.Activate:Fire()
                        elseif item:IsA("Tool") then
                            item:Activate()
                        end
                    end
                end
            end
        end
    end
end)

-- =========================
-- Misc Tab: ESP Egg (Billboard)
-- =========================
local function createBillboard(model)
    if model:FindFirstChild("EggBillboard") then return end
    local part = model:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "EggBillboard"
    bb.Size = UDim2.new(0, 180, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
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

-- Toggle ESP Egg
MiscTab:Button({
    Title = "Toggle ESP Egg",
    Desc = "Show/hide Egg + Pet overlay (client-only)",
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

-- Render loop
RunService.RenderStepped:Connect(function()
    if getgenv().ESP_Enabled then
        for _, egg in pairs(Workspace:GetDescendants()) do
            if egg:IsA("Model") and egg:FindFirstChild("PetName") then
                createBillboard(egg)
            end
        end
    end
end)
