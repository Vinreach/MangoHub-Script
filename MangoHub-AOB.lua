local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/SansYT789/Library/refs/heads/main/Esp.lua"))()

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
local hum = nil
local hrp = nil

-- // Game Check
local GameId = game.GameId
local GameLoader = {
    [7832036655] = {
        Folder = "AOB",
        Main = "Arena Of Blox",
        Name = "Arena Of Blox"
    }
}

local CurrentGame = GameLoader[GameId]
local GameName = CurrentGame and CurrentGame.Name or tostring(GameId)

if GameId ~= 7832036655 then
    warn("[MangoHub] Unsupported Experience")
    error("This script only supports Arena Of Blox!")
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
local CurrentWalkSpeed = hum and hum.WalkSpeed or 22
local CurrentJumpHeight = hum and hum.JumpHeight or 0
local CurrentJumpPower = hum and hum.JumpPower or 0

local function SendMessage(msg)
    local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
    if channel and channel.SendAsync then
        channel:SendAsync(msg)
    else
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
    end
end

local function Notify(title, desc, duration, icon)
    WindUI:Notify({
        Title = title or "MangoHub",
        Content = desc or "No description provided",
        Icon = icon or "zap",
        Duration = duration or 3,
    })
end

-- =========================
-- Flight System
-- =========================
local function setupChar(character)
    char = character
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end
if player.Character then
    setupChar(player.Character)
end

player.CharacterAdded:Connect(function(character)
    setupChar(character)
end)
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
            local root = char and char:FindFirstChild("HumanoidRootPart")
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
    if hum then
        hum.PlatformStand = false
    end
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    if self.FlyBody then
        self.FlyBody:Destroy()
        self.FlyBody = nil
    end
    if self.FlyGyro then
        self.FlyGyro:Destroy()
        self.FlyGyro = nil
    end
end

function Fly:Set(value)
    if not char or not hrp then return warn("HumanoidRootPart is nil.") end

    self.Enabled = value
    hum.PlatformStand = value

    if value then
        self.FlyBody.Parent = hrp
        self.FlyGyro.Parent = hrp
    else
        if self.FlyBody then self.FlyBody.Parent = nil end
        if self.FlyGyro then self.FlyGyro.Parent = nil end
    end
end

function Fly:Enable() self:Set(true) end
function Fly:Disable() self:Set(false) end
function Fly:Toggle() self:Set(not self.Enabled) end
function Fly:SetSpeed(speed) self.Speed = speed end
local M1Event = ReplicatedStorage:WaitForChild("M1Event")
local ESPTable = {
    Player = {},
    Entity = {}
}
local FeatureConnections = {
    Player = {}
}
function ESP(args)
    if not args.Object then return warn("ESP Object is nil") end

    local ESPManager = {
        Object = args.Object,
        Text = args.Text or "No Text",
        Color = args.Color or Color3.new(),
        MaxDistance = args.MaxDistance or 5000,
        Offset = args.Offset or Vector3.zero,
        IsEntity = args.IsEntity or false,
        IsDoubleDoor = args.IsDoubleDoor or false,
        Type = args.Type or "None",
        OnDestroy = args.OnDestroy or nil,
        Invisible = false,
        Humanoid = nil
    }

    if ESPManager.IsEntity and ESPManager.Object.PrimaryPart then
        if ESPManager.Object.PrimaryPart.Transparency == 1 then
            ESPManager.Invisible = true
            ESPManager.Object.PrimaryPart.Transparency = 0.99
        end

        local humanoid = ESPManager.Object:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            humanoid = Instance.new("Humanoid", ESPManager.Object)
        end
        ESPManager.Humanoid = humanoid
    end

    local ESPInstance =
        ESPLibrary.ESP.Highlight(
        {
            Name = ESPManager.Text,
            Model = ESPManager.Object,
            MaxDistance = ESPManager.MaxDistance,
            StudsOffset = ESPManager.Offset,
            FillColor = ESPManager.Color,
            OutlineColor = ESPManager.Color,
            TextColor = ESPManager.Color,
            TextSize = 22,
            FillTransparency = 0.75,
            OutlineTransparency = 0,
            Tracer = {
                Enabled = false,
                From = "Bottom",
                Color = ESPManager.Color
            },
            Arrow = {
                Enabled = false,
                CenterOffset = 300,
                Color = ESPManager.Color
            },
            OnDestroy = ESPManager.OnDestroy or function()
                    if ESPManager.Object.PrimaryPart and ESPManager.Invisible then
                        ESPManager.Object.PrimaryPart.Transparency = 1
                    end
                    if ESPManager.Humanoid then
                        ESPManager.Humanoid:Destroy()
                    end
                end
        }
    )

    table.insert(ESPTable[args.Type], ESPInstance)

    return ESPInstance
end

local function EntityESP(entity)
    if not entity then return end
    local espObj = ESP({
        Type = "Entity",
        Object = entity,
        Text = entity.Name,
        Color = Color3.new(1, 0, 0)
    })
end

local function PlayerESP(character)
    if not (character and character.PrimaryPart and character:FindFirstChild("Humanoid")) then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    local playerName = character.Name
    local espObj = ESP({
        Type = "Player",
        Object = character,
        Text = string.format("%s [%.0f/%.0f]", playerName, humanoid.Health, humanoid.MaxHealth),
        TextParent = character.PrimaryPart,
        Color = Color3.new(0, 1, 0)
    })

    FeatureConnections.Player[playerName] = humanoid.HealthChanged:Connect(function(hp)
        if hp > 0 then
            espObj:SetText(string.format("%s [%.0f/%.0f]", playerName, hp, humanoid.MaxHealth))
        else
            if FeatureConnections.Player[playerName] then
                FeatureConnections.Player[playerName]:Disconnect()
                FeatureConnections.Player[playerName] = nil
            end
            espObj:Destroy()
        end
    end)

    local function updateToolStatus()
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            espObj:SetText(string.format("%s [%.0f/%.0f] | Skill: %s", playerName, humanoid.Health, humanoid.MaxHealth, tool.Name))
            espObj:SetColor(Color3.new(1, 1, 0))
        else
            espObj:SetText(string.format("%s [%.0f/%.0f]", playerName, humanoid.Health, humanoid.MaxHealth))
            espObj:SetColor(Color3.new(0, 1, 0))
        end
    end

    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            updateToolStatus()
        end
    end)
    character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then
            updateToolStatus()
        end
    end)

    updateToolStatus()
end
-- =========================
-- Tabs
-- =========================
local MainTab = Window:Tab({ Title = "Main", Icon = "house" })
local AutoTab = Window:Tab({ Title = "Automation", Icon = "cpu" })
local VisualTab = Window:Tab({ Title = "Visual", Icon = "eye" })

-- Walk Speed Section
local WalkSpeedSection = MainTab:Section({ Title = "Walk Speed Control", Icon = "gauge" })
WalkSpeedSection:Toggle({
    Title = "Activate Walk Speed",
    Desc = "Enable manual walk speed adjustment",
    Value = false,
    Callback = function(state)
        getgenv().WalkSpeedEnabled = state
        if not state and hum then
            hum.WalkSpeed = 22
        end
    end
})
WalkSpeedSection:Slider({
    Title = "Walk Speed Value",
    Desc = "Adjust walking/running speed",
    Value = { Min = 0, Max = 100, Default = 22 },
    Callback = function(value) CurrentWalkSpeed = value end
})

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().WalkSpeedEnabled and hum then
            hum.WalkSpeed = math.min(CurrentWalkSpeed, 100)
        end
    end
end)

local JumpSection = MainTab:Section({ Title = "Jump Control", Icon = "arrow-up" })
JumpSection:Toggle({
    Title = "Activate Jump",
    Desc = "Allows manual jumper enable",
    Value = false,
    Callback = function(state)
        getgenv().JumpButtonEnabled = state
        if state and hum then
            if CurrentJumpHeight == 0 then
                CurrentJumpHeight = 7.2
            end
            if CurrentJumpPower == 0 then
                CurrentJumpPower = 50
            end
            hum.JumpHeight = CurrentJumpHeight
            hum.JumpPower = CurrentJumpPower
        elseif not state and hum then
            hum.JumpHeight = 0
            hum.JumpPower = 0
        end
    end
})
JumpSection:Slider({
    Title = "Jump Height Value",
    Desc = "Adjust jump height",
    Value = { Min = 0, Max = 100, Default = 7.2 },
    Callback = function(value)
        CurrentJumpHeight = value
        if getgenv().JumpButtonEnabled and hum then
            hum.JumpHeight = math.min(value, 100)
        end
    end
})

JumpSection:Slider({
    Title = "Jump Power Value",
    Desc = "Adjust jump power",
    Value = { Min = 0, Max = 100, Default = 50 },
    Callback = function(value)
        CurrentJumpPower = value
        if getgenv().JumpButtonEnabled and hum then
            hum.JumpPower = math.min(value, 100)
        end
    end
})

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().JumpButtonEnabled and hum then
            hum.JumpHeight = math.min(CurrentJumpHeight, 100)
            hum.JumpPower = math.min(CurrentJumpPower, 100)
        end
    end
end)

-- Fly Section
local FlySection = MainTab:Section({ Title = "Flight Mode", Icon = "feather" })
FlySection:Toggle({
    Title = "Enable Flight",
    Desc = "Toggle flying ability",
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
    Title = "Flight Speed",
    Desc = "Adjust flying speed",
    Value = { Min = 0, Max = 100, Default = 15 },
    Callback = function(value) Fly:SetSpeed(value) end
})

-- Pick Hero
local HeroSelectionSection = AutoTab:Section({ Title = "Hero Selection", Icon = "swords" })
local HeroList = {"Bijan","Elsu","Florentino","Gildur","Hayate","Ignis","Krixi","Nakroth","Omen","Raz","Steve","Toro","Tulen","Valhein","Veera","Wukong","Y'bneth","Yaxuo","Yorn","Zilong"}
local ChosenHero = "Bijan"

HeroSelectionSection:Dropdown({
    Title = "Choose Hero",
    Values = HeroList,
    Value = ChosenHero,
    Callback = function(option) ChosenHero = option end
})

HeroSelectionSection:Toggle({
    Title = "Auto Pick Hero",
    Desc = "Auto select hero in dropdown, Warning: This function may not work as intended!",
    Value = false,
    Callback = function(state) 
        getgenv().AutoPickHero = state
    end
})

HeroSelectionSection:Button({
    Title = "Confirm Hero",
    Icon = "check",
    Callback = function()
        ReplicatedStorage.SelectHeroEvent:FireServer(ChosenHero)
        task.wait(0.1)
        ReplicatedStorage.PickHeroEvent:FireServer(ChosenHero)
        Notify("Hero Selection", "Chosen hero: " .. ChosenHero, 3, "star")
    end
})

-- Auto Section
local AutoSection = AutoTab:Section({ Title = "Automation Features", Icon = "settings" })
AutoSection:Toggle({
    Title = "Auto M1 Click",
    Desc = "Continuously perform M1 attack",
    Value = false,
    Callback = function(state) 
        getgenv().AutoM1Click = state
        Notify("Auto Click", state and "M1 Auto enabled" or "M1 Auto disabled", 3, state and "check" or "x")
    end
})

local AutoHealSection = AutoTab:Section({ Title = "Auto Healing", Icon = "heart" })
AutoHealSection:Slider({
    Title = "Heal Threshold (%)",
    Desc = "Heal when HP below this percentage",
    Value = { Min = 0, Max = 100, Default = 15 },
    Callback = function(value) getgenv().HealThreshold = value end
})
AutoHealSection:Toggle({ Title = "Auto Heal in Blue Zone", Value = false, Callback = function(state) getgenv().AutoHealBlue = state end })
AutoHealSection:Toggle({ Title = "Auto Heal in Red Zone", Value = false, Callback = function(state) getgenv().AutoHealRed = state end })

local TeleportSection = AutoTab:Section({ Title = "Teleport Zones", Icon = "map" })
-- Teleport Section
TeleportSection:Button({
    Title = "Teleport → Blue Zone",
    Icon = "compass",
    Callback = function()
        if workspace:FindFirstChild("BaseHeal") and workspace.BaseHeal:FindFirstChild("BlueHeal") then
            hrp.CFrame = workspace.BaseHeal.BlueHeal.CFrame
            Notify("Teleport", "You have been teleported to Blue Zone", 3, "map")
        end
    end
})
TeleportSection:Button({
    Title = "Teleport → Red Zone",
    Icon = "compass",
    Callback = function()
        if workspace:FindFirstChild("BaseHeal") and workspace.BaseHeal:FindFirstChild("RedHeal") then
            hrp.CFrame = workspace.BaseHeal.RedHeal.CFrame
            Notify("Teleport", "You have been teleported to Red Zone", 3, "map")
        end
    end
})

local EspSection = VisualTab:Section({ Title = "Esp", Icon = "settings" })
local function ToggleEsp(name, value)
    local function destroyAll(tbl)
        for _, v in pairs(tbl) do
            v:Destroy()
        end
    end
    local function disconnectAll(tbl)
        for _, c in pairs(tbl) do
            c:Disconnect()
        end
    end

    if name == "Mount" then
        if value then
            for _, e in pairs(workspace:GetChildren()) do
                if e.Name == "Mount" then
                    EntityESP(e)
                end
            end
        else
            destroyAll(ESPTable.Entity)
        end
    elseif name == "Player" then
        if value then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player and p.Character then
                    PlayerESP(p.Character)
                end
            end
        else
            destroyAll(ESPTable.Player)
            disconnectAll(FeatureConnections.Player)
        end
    end
end
EspSection:Toggle({
    Title = "Esp Player",
    Value = false,
    Callback = function(state)
        getgenv().EspPlayer = state
        ToggleEsp("Player", state)
    end
})
EspSection:Toggle({
    Title = "Esp Mount",
    Value = false,
    Callback = function(state)
        getgenv().EspMount = state
        ToggleEsp("Mount", state)
    end
})

local function TryAutoHeal(zone)
    if not hum or not hrp then return end
    if not workspace:FindFirstChild("BaseHeal") then return end

    local healPart = workspace.BaseHeal:FindFirstChild(zone)
    if not healPart then return end

    local healthPercent = (hum.Health / hum.MaxHealth) * 100

    if healthPercent <= (tonumber(getgenv().HealThreshold) or 15) then
        hrp.CFrame = healPart.CFrame
    end
end

local picked = false
local cooldown = 1
local camPos = workspace.Camera.CFrame.Position
local pickPos = workspace.CameraPickHeroes.CFrame.Position
task.spawn(function()
    while task.wait(0.1) do
        -- Auto Click
        if getgenv().AutoM1Click and M1Event then
            M1Event:FireServer()
        end

        -- Auto Pick Hero
        if getgenv().AutoPickHero and not picked then
            if (camPos - pickPos).Magnitude <= 1 then
                picked = true
                ReplicatedStorage.SelectHeroEvent:FireServer(ChosenHero)
                task.wait(0.1)
                ReplicatedStorage.PickHeroEvent:FireServer(ChosenHero)
                Notify("Hero Selection", "Auto chosen hero: " .. ChosenHero, 3, "star")
                task.delay(cooldown, function()
                    picked = false
                end)
            end
        end
        
        -- Auto Heal Red Zone
        if getgenv().AutoHealRed then
            TryAutoHeal("RedHeal")
        end
        
        -- Auto Heal Blue Zone
        if getgenv().AutoHealBlue then
            TryAutoHeal("BlueHeal")
        end
    end
end)

function SetupOtherPlayerConnection(player)
    player.CharacterAdded:Connect(function(newCharacter)
            if getgenv().EspPlayer then
                task.delay(1,function()
                        PlayerESP(newCharacter)
                end)
            end
    end)
end
for _, player in pairs(Players:GetPlayers()) do
    if player == Players.LocalPlayer then continue end
    SetupOtherPlayerConnection(player)
end
Players.PlayerAdded:Connect(SetupOtherPlayerConnection)

for _, obj in ipairs(workspace:GetDescendants()) do
    if getgenv().EspMount and obj.Name == "Mount" and obj:IsA("Model") then
        EntityESP(obj)
    end
end

workspace.DescendantAdded:Connect(function(obj)
    task.delay(0.1, function()
        if 
