local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- // Player
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = nil
local hrp = nil

-- // Global Variables
getgenv().WalkSpeedEnabled = false
getgenv().JumpEnabled = false

-- =========================
-- UI Window
-- =========================
local Window = WindUI:CreateWindow({
    Title = "MangoHub — Universal",
    Icon = "zap",
    Author = "Vinreach Group",
    Folder = "MangoUniversal",
    Size = UDim2.fromOffset(370, 400),
    Theme = "Dark"
})

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
-- Utilities
-- =========================
local function Notify(msg)
    WindUI:Notify({
        Title = "MangoHub",
        Content = msg,
        Icon = "zap",
        Duration = 3,
    })
end

local function getPlayerList()
    local playerList = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(playerList, plr.Name)
        end
    end
    return playerList
end

-- =========================
-- Main Tab
-- =========================
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "house"
})

-- Walk Speed
local CurrentWalkSpeed = 22
local WalkSpeedSection = MainTab:Section({
    Title = "Walk Speed",
    Icon = "gauge"
})

WalkSpeedSection:Toggle({
    Title = "Enable Walk Speed",
    Value = false,
    Callback = function(state)
        getgenv().WalkSpeedEnabled = state
        if not state and hum then
            hum.WalkSpeed = 16
        end
    end
})

WalkSpeedSection:Slider({
    Title = "Speed Value",
    Value = {
        Min = 0,
        Max = 150,
        Default = 22
    },
    Callback = function(value)
        CurrentWalkSpeed = value
    end
})

-- Apply WalkSpeed
local walkSpeedConnection
walkSpeedConnection = RunService.Stepped:Connect(function()
    if getgenv().WalkSpeedEnabled and hum and hum.Parent then
        hum.WalkSpeed = CurrentWalkSpeed
    end
end)

-- Jump Power
local CurrentJumpPower = 50
local JumpSection = MainTab:Section({
    Title = "Jump Settings",
    Icon = "arrow-up"
})

JumpSection:Toggle({
    Title = "Enable Jump Power",
    Value = false,
    Callback = function(state)
        getgenv().JumpEnabled = state
        if not state and hum then
            hum.JumpPower = 50
        end
    end
})

JumpSection:Slider({
    Title = "Jump Power Value",
    Value = {
        Min = 0,
        Max = 200,
        Default = 50
    },
    Callback = function(value)
        CurrentJumpPower = value
    end
})

-- Apply Jump Power
local jumpConnection
jumpConnection = RunService.Stepped:Connect(function()
    if getgenv().JumpEnabled and hum and hum.Parent then
        hum.JumpPower = CurrentJumpPower
    end
end)

-- NoClip
local noclip = false
local noclipConnection

MainTab:Toggle({
    Title = "NoClip",
    Value = false,
    Callback = function(state)
        noclip = state
        if not state then
            -- Re-enable collision for all parts
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                        v.CanCollide = true
                    end
                end
            end
        end
    end
})

noclipConnection = RunService.Stepped:Connect(function()
    if noclip and char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

-- ESP + Tracers
local espEnabled = false
local espConnection

MainTab:Toggle({
    Title = "Player ESP",
    Value = false,
    Callback = function(state)
        espEnabled = state
        if not state then
            -- Clean up existing ESP
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("ESP") then
                    plr.Character.ESP:Destroy()
                end
            end
        end
    end
})

espConnection = RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local Billboard = plr.Character:FindFirstChild("ESP")
                if not Billboard then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "ESP"
                    bb.Parent = plr.Character
                    bb.Size = UDim2.new(0, 200, 0, 50)
                    bb.AlwaysOnTop = true
                    bb.LightInfluence = 0
                    
                    local label = Instance.new("TextLabel")
                    label.Parent = bb
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = plr.Name .. " [" .. plr.DisplayName .. "]"
                    label.TextColor3 = Color3.fromRGB(255, 0, 0)
                    label.TextScaled = true
                    label.Font = Enum.Font.SourceSansBold
                    label.TextStrokeTransparency = 0.5
                    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    
                    -- Distance label
                    local distLabel = Instance.new("TextLabel")
                    distLabel.Parent = bb
                    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
                    distLabel.BackgroundTransparency = 1
                    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    distLabel.TextScaled = true
                    distLabel.Font = Enum.Font.SourceSans
                    distLabel.TextStrokeTransparency = 0.5
                    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                else
                    -- Update distance
                    if hrp and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = math.floor((hrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude)
                        local distLabel = Billboard:FindFirstChild("TextLabel") and Billboard:GetChildren()[3]
                        if distLabel then
                            distLabel.Text = distance .. " studs"
                        end
                    end
                end
            end
        end
    end
end)

-- Teleport to Player
local TeleportSection = MainTab:Section({
    Title = "Teleport",
    Icon = "map-pin"
})

local playerDropdown = TeleportSection:Dropdown({
    Title = "Teleport to Player",
    List = getPlayerList(),
    Callback = function(choice)
        local target = Players:FindFirstChild(choice)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and hrp then
            hrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            Notify("Teleported to " .. choice)
        else
            Notify("Failed to teleport to " .. choice)
        end
    end
})

-- Update player list when players join/leave
local function updatePlayerDropdown()
    local newList = getPlayerList()
    playerDropdown:Set(newList)
end

Players.PlayerAdded:Connect(updatePlayerDropdown)
Players.PlayerRemoving:Connect(updatePlayerDropdown)

-- =========================
-- Server Tab
-- =========================
local ServerTab = Window:Tab({
    Title = "Server",
    Icon = "server"
})

ServerTab:Button({
    Title = "Rejoin Server",
    Callback = function()
        Notify("Rejoining server...")
        wait(1)
        TeleportService:Teleport(game.PlaceId, player)
    end
})

ServerTab:Button({
    Title = "Server Hop",
    Callback = function()
        Notify("Finding new server...")
        
        local success, result = pcall(function()
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            local serverList = {}
            
            for _, server in pairs(servers.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(serverList, server.id)
                end
            end
            
            if #serverList > 0 then
                local randomServer = serverList[math.random(1, #serverList)]
                TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer)
            else
                TeleportService:Teleport(game.PlaceId)
            end
        end)
        
        if not success then
            -- Fallback to simple teleport
            TeleportService:Teleport(game.PlaceId)
        end
    end
})

ServerTab:Button({
    Title = "Copy Game Link",
    Callback = function()
        if setclipboard then
            setclipboard("https://www.roblox.com/games/" .. game.PlaceId)
            Notify("Game link copied to clipboard!")
        else
            Notify("Clipboard not supported")
        end
    end
})

-- =========================
-- Fun Tab
-- =========================
local FunTab = Window:Tab({
    Title = "Fun",
    Icon = "smile"
})

FunTab:Button({
    Title = "Fling Tool",
    Callback = function()
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "Fling"
        tool.Parent = player.Backpack
        
        tool.Activated:Connect(function()
            if hrp then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(4000, 4000, 4000)
                bv.Velocity = Vector3.new(0, 50, 0)
                bv.Parent = hrp
                
                game:GetService("Debris"):AddItem(bv, 0.5)
            end
        end)
        
        Notify("Fling Tool Added!")
    end
})

FunTab:Button({
    Title = "Reset Character",
    Callback = function()
        if hum then
            hum.Health = 0
            Notify("Character reset!")
        end
    end
})

FunTab:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(state)
        if state then
            _G.InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if _G.InfiniteJumpConnection then
                _G.InfiniteJumpConnection:Disconnect()
                _G.InfiniteJumpConnection = nil
            end
        end
    end
})

-- =========================
-- Settings Tab
-- =========================
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings"
})

SettingsTab:Button({
    Title = "Destroy GUI",
    Callback = function()
        -- Clean up connections
        if walkSpeedConnection then walkSpeedConnection:Disconnect() end
        if jumpConnection then jumpConnection:Disconnect() end
        if noclipConnection then noclipConnection:Disconnect() end
        if espConnection then espConnection:Disconnect() end
        if _G.InfiniteJumpConnection then _G.InfiniteJumpConnection:Disconnect() end
        
        -- Clean up ESP
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("ESP") then
                plr.Character.ESP:Destroy()
            end
        end
        
        -- Reset values
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
        
        getgenv().WalkSpeedEnabled = false
        getgenv().JumpEnabled = false
        
        Window:Destroy()
        Notify("GUI Destroyed!")
    end
})

-- =========================
-- Cleanup on character reset
-- =========================
player.CharacterRemoving:Connect(function()
    -- Clean up ESP when character is removed
    if char then
        for _, v in pairs(char:GetChildren()) do
            if v.Name == "ESP" then
                v:Destroy()
            end
        end
    end
end)
