-- 🍋 MangoHub - Slap Battle 🍋
-- Full Script by Red 😎

-- ===========================
-- Anti Cheat Bypass cơ bản
-- ===========================
local rs = game:GetService("ReplicatedStorage")
local sp = game:GetService("StarterPlayer")

for _,v in pairs({"AdminGUI","Ban","GRAB","SpecialGloveAccess","WalkSpeedChanged"}) do
    if rs:FindFirstChild(v) then
        rs[v]:Destroy()
    end
end
if sp:FindFirstChild("StarterPlayerScripts") and sp.StarterPlayerScripts:FindFirstChild("ClientAnticheat") then
    sp.StarterPlayerScripts.ClientAnticheat:Destroy()
end

-- ===========================
-- Load Rayfield
-- ===========================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "MangoHub - Slap Battle",
    LoadingTitle = "MangoHub Loader",
    LoadingSubtitle = "by Red",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MangoHub",
        FileName = "SlapBattle"
    },
})

-- ===========================
-- Combat Tab
-- ===========================
local CombatTab = Window:CreateTab("Combat")

-- Auto Farm Teleport + Spam Click
local autoFarmSpam = false
CombatTab:CreateToggle({
    Name = "Auto Farm (Teleport + Spam Click)",
    CurrentValue = false,
    Callback = function(v)
        autoFarmSpam = v
        task.spawn(function()
            while autoFarmSpam do
                local lp = game:GetService("Players").LocalPlayer
                local char = lp.Character or lp.CharacterAdded:Wait()
                -- Auto equip first tool
                if lp.Backpack and lp.Backpack:FindFirstChildOfClass("Tool") then
                    lp.Backpack:FindFirstChildOfClass("Tool").Parent = char
                end
                -- Tele tới từng player và spam click
                for _,plr in pairs(game.Players:GetPlayers()) do
                    if not autoFarmSpam then break end
                    if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        char:PivotTo(plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3))
                        task.wait(0.1)
                        for i = 1,5 do
                            pcall(function() mouse1click() end)
                            task.wait(0.05)
                        end
                        task.wait(1.1)
                    end
                end
                task.wait(0.2)
            end
        end)
    end,
})

-- Auto Farm Stand Still
local standFarm = false
CombatTab:CreateToggle({
    Name = "Auto Farm (Stand Still)",
    CurrentValue = false,
    Callback = function(v)
        standFarm = v
        task.spawn(function()
            while standFarm do
                task.wait(0.2)
                local lp = game:GetService("Players").LocalPlayer
                local char = lp.Character or lp.CharacterAdded:Wait()
                if lp.Backpack and lp.Backpack:FindFirstChildOfClass("Tool") then
                    lp.Backpack:FindFirstChildOfClass("Tool").Parent = char
                end
                for _,plr in pairs(game.Players:GetPlayers()) do
                    if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (plr.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                        if dist < 10 then
                            pcall(function()
                                firetouchinterest(char.HumanoidRootPart, plr.Character.HumanoidRootPart, 0)
                                firetouchinterest(char.HumanoidRootPart, plr.Character.HumanoidRootPart, 1)
                            end)
                        end
                    end
                end
            end
        end)
    end,
})

-- Expand Enemy Hitbox
local hitbox = false
CombatTab:CreateToggle({
    Name = "Expand Enemy Hitbox (Big Hitbox)",
    CurrentValue = false,
    Callback = function(v)
        hitbox = v
        task.spawn(function()
            while hitbox do
                task.wait(0.3)
                for _,plr in pairs(game.Players:GetPlayers()) do
                    if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = plr.Character.HumanoidRootPart
                        hrp.Size = Vector3.new(50,50,50)
                        hrp.Transparency = 0.7
                        hrp.BrickColor = BrickColor.new("Bright red")
                        hrp.CanCollide = false
                    end
                end
            end
            -- reset
            for _,plr in pairs(game.Players:GetPlayers()) do
                if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = plr.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(2,2,1)
                    hrp.Transparency = 1
                end
            end
        end)
    end,
})

-- Safe Kick
CombatTab:CreateButton({
    Name = "Stop & Kick Safe",
    Callback = function()
        autoFarmSpam, standFarm, hitbox = false, false, false
        game.Players.LocalPlayer:Kick("Stopped AutoFarm - Safe Exit 😎")
    end,
})

-- ===========================
-- Visuals Tab
-- ===========================
local VisualTab = Window:CreateTab("Visuals")

local function addESP(plr)
    if plr.Character and not plr.Character:FindFirstChild("MangoESP") then
        -- Highlight
        local hl = Instance.new("Highlight")
        hl.Name = "MangoESP"
        hl.Parent = plr.Character
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        -- Billboard Name
        if plr.Character:FindFirstChild("Head") then
            local bb = Instance.new("BillboardGui")
            bb.Name = "MangoESPName"
            bb.Adornee = plr.Character.Head
            bb.Size = UDim2.new(0,200,0,50)
            bb.StudsOffset = Vector3.new(0,2,0)
            bb.AlwaysOnTop = true
            bb.Parent = plr.Character
            local nameLabel = Instance.new("TextLabel", bb)
            nameLabel.Size = UDim2.new(1,0,1,0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = plr.DisplayName .. " (" .. plr.Name .. ")"
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            nameLabel.TextStrokeTransparency = 0
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextScaled = true
        end
    end
end

local function removeESP(plr)
    if plr.Character and plr.Character:FindFirstChild("MangoESP") then
        plr.Character.MangoESP:Destroy()
    end
    if plr.Character and plr.Character:FindFirstChild("MangoESPName") then
        plr.Character.MangoESPName:Destroy()
    end
end

local espConnections = {}

VisualTab:CreateToggle({
    Name = "ESP Players (Name + Highlight)",
    CurrentValue = false,
    Callback = function(v)
        if v then
            for _,plr in pairs(game.Players:GetPlayers()) do
                if plr ~= game.Players.LocalPlayer then
                    addESP(plr)
                    if not espConnections[plr] then
                        espConnections[plr] = plr.CharacterAdded:Connect(function()
                            task.wait(1)
                            addESP(plr)
                        end)
                    end
                end
            end
            if not espConnections["PlayerAdded"] then
                espConnections["PlayerAdded"] = game.Players.PlayerAdded:Connect(function(plr)
                    espConnections[plr] = plr.CharacterAdded:Connect(function()
                        task.wait(1)
                        addESP(plr)
                    end)
                end)
            end
        else
            for _,plr in pairs(game.Players:GetPlayers()) do
                if plr ~= game.Players.LocalPlayer then
                    removeESP(plr)
                end
            end
            for _,conn in pairs(espConnections) do
                if typeof(conn) == "RBXScriptConnection" then
                    conn:Disconnect()
                end
            end
            espConnections = {}
        end
    end,
})

-- ===========================
-- Fun Tab
-- ===========================
local FunTab = Window:CreateTab("Fun")

FunTab:CreateButton({
    Name = "TeleSlap Spam Click (All Players)",
    Callback = function()
        local lp = game.Players.LocalPlayer
        local char = lp.Character or lp.CharacterAdded:Wait()
        if lp.Backpack and lp.Backpack:FindFirstChildOfClass("Tool") then
            lp.Backpack:FindFirstChildOfClass("Tool").Parent = char
        end
        for _,plr in pairs(game.Players:GetPlayers()) do
            if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                char:PivotTo(plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3))
                task.wait(0.1)
                for i = 1,5 do
                    pcall(function() mouse1click() end)
                    task.wait(0.05)
                end
                task.wait(1.1)
            end
        end
    end,
})

-- ===========================
-- Anti Tab
-- ===========================
local AntiTab = Window:CreateTab("Anti")

local antiRagdoll = false
AntiTab:CreateToggle({
    Name = "Anti Ragdoll",
    CurrentValue = false,
    Callback = function(v)
        antiRagdoll = v
        if v then
            task.spawn(function()
                local lp = game.Players.LocalPlayer
                while antiRagdoll do
                    task.wait(0.2)
                    local char = lp.Character
                    if char and char:FindFirstChildOfClass("Humanoid") then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        hum:ChangeState(Enum.HumanoidStateType.Physics)
                        hum:ChangeState(Enum.HumanoidStateType.None)
                        for _,v in pairs(char:GetDescendants()) do
                            if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then
                                v:Destroy()
                            end
                        end
                        if char:FindFirstChild("HumanoidRootPart") then
                            for _,bv in pairs(char.HumanoidRootPart:GetChildren()) do
                                if bv:IsA("BodyVelocity") or bv:IsA("VectorForce") then
                                    bv:Destroy()
                                end
                            end
                        end
                    end
                end
            end)
        end
    end,
})

-- ===========================
-- Auto Kick on Reset
-- ===========================
local lp = game.Players.LocalPlayer
lp.CharacterAdded:Connect(function()
    game.Players.LocalPlayer:Kick("AutoKick: Reset detected - Safe Exit 😎")
end)