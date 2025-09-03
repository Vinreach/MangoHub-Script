local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local CoreGui = game:GetService("CoreGui")

-- // Player
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum, hrp = nil, nil

-- // Game Check
local GameId = game.GameId
local GameLoader = {
    [7932671830] = {
        Folder = "POOP",
        Main = "POOP",
        Name = "POOP"
    }
}

local CurrentGame = GameLoader[GameId]
local GameName = CurrentGame and CurrentGame.Name or tostring(GameId)

if GameId ~= 7932671830 then
    warn("[MangoHub] Unsupported Game")
    error("This script only supports POOP!")
end

-- =========================
-- UI Window
-- =========================
local Window = WindUI:CreateWindow({
    Title = "MangoHub — " .. GameName,
    Icon = "zap",
    Author = "Vinreach Group",
    Folder = "Mango",
    Size = UDim2.fromOffset(340, 360),
    Theme = "Dark"
})

-- =========================
-- Utilities
-- =========================
local CurrentWalkSpeed = hum and hum.WalkSpeed or 15
local CurrentJumpHeight = hum and hum.JumpHeight or 7.2
local CurrentJumpPower = hum and hum.JumpPower or 50

local function SendMessage(msg)
    local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
    if channel and channel.SendAsync then
        channel:SendAsync(msg)
    elseif ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
    end
end

local function Notify(title, desc, duration, icon)
    WindUI:Notify({
        Title = title or "MangoHub",
        Content = desc or "No details provided",
        Icon = icon or "zap",
        Duration = duration or 3,
    })
end

-- =========================
-- Character Setup
-- =========================
local function setupChar(character)
    char = character
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end
if player.Character then
    setupChar(player.Character)
end
player.CharacterAdded:Connect(setupChar)

-- =========================
-- Flight System
-- =========================
local Fly = {Enabled = false, Speed = 15, FlyBody = nil, FlyGyro = nil, Connection = nil}

function Fly:Setup()
    local flyBody = Instance.new("BodyVelocity")
    flyBody.Velocity = Vector3.zero
    flyBody.MaxForce = Vector3.one * 9e9

    local flyGyro = Instance.new("BodyGyro")
    flyGyro.P = 9e4
    flyGyro.MaxTorque = Vector3.one * 9e9

    self.FlyBody = flyBody
    self.FlyGyro = flyGyro

    self.Connection = RunService.RenderStepped:Connect(function()
        if not self.Enabled then return end
        local root = hrp
        if not root then return end

        local moveVector = Vector3.zero
        local success, cm = pcall(function()
            return require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
        end)
        if success and cm then
            moveVector = cm:GetMoveVector()
        end

        local cam = workspace.CurrentCamera
        local forward = cam.CFrame.LookVector
        local velocity = forward * -moveVector.Z

        local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z).Unit
        velocity = velocity + right * moveVector.X

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            velocity = velocity + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.Q) or UserInputService:IsKeyDown(Enum.KeyCode.C) then
            velocity = velocity - Vector3.new(0, 1, 0)
        end

        self.FlyBody.Velocity = velocity * self.Speed

        local flatLook = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
        if flatLook.Magnitude > 0 then
            self.FlyGyro.CFrame = CFrame.new(root.Position, root.Position + flatLook)
        end
    end)
end

function Fly:Stop()
    if hum then hum.PlatformStand = false end
    if self.Connection then self.Connection:Disconnect() self.Connection = nil end
    if self.FlyBody then self.FlyBody:Destroy() self.FlyBody = nil end
    if self.FlyGyro then self.FlyGyro:Destroy() self.FlyGyro = nil end
end

function Fly:Set(value)
    if not hrp then return warn("HumanoidRootPart not found") end
    self.Enabled = value
    hum.PlatformStand = value
    if value then
        if self.FlyBody then self.FlyBody.Parent = hrp end
        if self.FlyGyro then self.FlyGyro.Parent = hrp end
    else
        if self.FlyBody then self.FlyBody.Parent = nil end
        if self.FlyGyro then self.FlyGyro.Parent = nil end
    end
end

function Fly:Enable() self:Set(true) end
function Fly:Disable() self:Set(false) end
function Fly:Toggle() self:Set(not self.Enabled) end
function Fly:SetSpeed(speed) self.Speed = speed end

-- =========================
-- Game Remotes
-- =========================
local PoopChargeStart = ReplicatedStorage:WaitForChild("PoopChargeStart")
local PoopEvent = ReplicatedStorage:WaitForChild("PoopEvent")
local PoopResponseChosen = ReplicatedStorage:WaitForChild("PoopResponseChosen")
local PurchaseItemEvent = ReplicatedStorage:WaitForChild("PurchaseItemEvent")

-- =========================
-- Tabs
-- =========================
local MainTab = Window:Tab({ Title = "Main", Icon = "house" })
local AutoTab = Window:Tab({ Title = "Automation", Icon = "cpu" })

-- Walk Speed
local WalkSpeedSection = MainTab:Section({ Title = "Walk Speed", Icon = "gauge" })
WalkSpeedSection:Toggle({
    Title = "Enable Walk Speed",
    Desc = "Manually adjust walking speed",
    Value = false,
    Callback = function(state)
        getgenv().WalkSpeedEnabled = state
        if not state and hum then hum.WalkSpeed = 22 end
    end
})
WalkSpeedSection:Slider({
    Title = "Speed Value",
    Desc = "Adjust your walking/running speed",
    Value = { Min = 0, Max = 100, Default = 15 },
    Callback = function(value) CurrentWalkSpeed = value end
})

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().WalkSpeedEnabled and hum then
            hum.WalkSpeed = math.min(CurrentWalkSpeed, 100)
        end
    end
end)

-- Jump
local JumpSection = MainTab:Section({ Title = "Jump Settings", Icon = "arrow-up" })
JumpSection:Toggle({
    Title = "Enable Jump",
    Desc = "Enable custom jump control",
    Value = true,
    Callback = function(state)
        getgenv().JumpEnabled = state
        if state and hum then
            hum.JumpHeight = CurrentJumpHeight
            hum.JumpPower = CurrentJumpPower
        elseif not state and hum then
            hum.JumpHeight = 0
            hum.JumpPower = 0
        end
    end
})
JumpSection:Slider({
    Title = "Jump Height",
    Desc = "Set custom jump height",
    Value = { Min = 0, Max = 100, Default = 7.2 },
    Callback = function(value)
        CurrentJumpHeight = value
        if getgenv().JumpEnabled and hum then
            hum.JumpHeight = math.min(value, 100)
        end
    end
})
JumpSection:Slider({
    Title = "Jump Power",
    Desc = "Set custom jump power",
    Value = { Min = 0, Max = 100, Default = 50 },
    Callback = function(value)
        CurrentJumpPower = value
        if getgenv().JumpEnabled and hum then
            hum.JumpPower = math.min(value, 100)
        end
    end
})

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().JumpEnabled and hum then
            hum.JumpHeight = math.min(CurrentJumpHeight, 100)
            hum.JumpPower = math.min(CurrentJumpPower, 100)
        end
    end
end)

-- Fly
local FlySection = MainTab:Section({ Title = "Fly Mode", Icon = "feather" })
FlySection:Toggle({
    Title = "Enable Fly",
    Desc = "Toggle flight ability",
    Value = false,
    Callback = function(state)
        if state then
            if not Fly.FlyBody then Fly:Setup() end
            Fly:Enable()
        else
            Fly:Disable()
            Fly:Stop()
        end
    end
})
FlySection:Slider({
    Title = "Fly Speed",
    Desc = "Adjust flying speed",
    Value = { Min = 0, Max = 100, Default = 15 },
    Callback = function(value) Fly:SetSpeed(value) end
})

-- Auto Poop
local poopSection = AutoTab:Section({ Title = "Poop Automation", Icon = "droplet" })
poopSection:Toggle({ Title="Enable Auto Poop", Desc = "Warning: if delay is below 0.2 there is a chance of being kicked", Value=false, Callback=function(s) getgenv().AutoPoop=s end })
poopSection:Slider({ Title="Poop Delay (sec)", Value={Min=0,Max=1,Default=0.2}, Callback=function(v) getgenv().PoopDelay=v end })
local SellModes = {"Full Backpack","Every 5 sec","At least 1 poop","10 poops"}
local SellPoopMode = SellModes[1]
poopSection:Dropdown({
    Title="Auto-Sell Mode", Values=SellModes, Value=SellPoopMode,
    Callback=function(opt) SellPoopMode=opt end
})
poopSection:Slider({ Title="Max Backpack Limit To Sell", Value={Min=0,Max=5000,Default=50}, Callback=function(v) getgenv().MaxBackPackPoop=v end })
poopSection:Toggle({ Title="Enable Auto Sell", Value=false, Callback=function(s) getgenv().AutoSellPoop=s end })
poopSection:Button({ Title="Sell Current Poop", Callback=function() PoopResponseChosen:FireServer("1. [I want to sell THIS.]") end })
poopSection:Button({ Title="Sell All Poop", Callback=function() PoopResponseChosen:FireServer("2. [I want to sell my inventory.]") end })

local shopSection = AutoTab:Section({ Title = "Shop", Icon = "shopping-cart" })
shopSection:Button({ Title="Buy Can Of Beans", Callback=function() ReplicatedStorage:WaitForChild("PurchaseItemEvent"):FireServer("Item1", 150) end })

local function getPoopCount()
    local count = 0
    if player:FindFirstChild("Backpack") then
        for _, tool in ipairs(player.Backpack:GetChildren()) do
            if tool.Name:lower():find("poop") then
                count += 1
            end
        end
    end
    return count
end

-- Loops
task.spawn(function()
    while task.wait(tonumber(getgenv().PoopDelay) or 0.2) do
        if getgenv().AutoPoop then
            for i = 1, 5 do PoopChargeStart:FireServer() end
            PoopEvent:FireServer(1)
        end
        if getgenv().AutoSellPoop then
            local poopCount = getPoopCount()

            if SellPoopMode == "At least 1 poop" and poopCount >= 1 then
                PoopResponseChosen:FireServer("2. [I want to sell my inventory.]")
            elseif SellPoopMode=="Full Backpack" then
                local maxBackpacks = tonumber(getgenv().MaxBackPackPoop) or 50
                if poopCount >= maxBackpacks then
                    PoopResponseChosen:FireServer("2. [I want to sell my inventory.]")
                end
            elseif SellPoopMode == "10 poops" and poopCount >= 10 then
                PoopResponseChosen:FireServer("2. [I want to sell my inventory.]")
            elseif SellPoopMode=="Every 5 sec" then
                PoopResponseChosen:FireServer("2. [I want to sell my inventory.]")
                task.wait(5)
            end
        end
    end
end)
