-- 🍋 MangoHub - Slap Battle 🍋
-- Rayfield UI + AutoFarm + ESP
-- by Red 😎

-- Anti Cheat Bypass cơ bản
local rs = game:GetService("ReplicatedStorage")
if rs:FindFirstChild("AdminGUI") then rs.AdminGUI:Destroy() end
if rs:FindFirstChild("Ban") then rs.Ban:Destroy() end
if rs:FindFirstChild("GRAB") then rs.GRAB:Destroy() end
if rs:FindFirstChild("SpecialGloveAccess") then rs.SpecialGloveAccess:Destroy() end
if rs:FindFirstChild("WalkSpeedChanged") then rs.WalkSpeedChanged:Destroy() end

-- Load Rayfield
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

local autoFarm = false

CombatTab:CreateToggle({
    Name = "Auto Farm Slap",
    CurrentValue = false,
    Callback = function(v)
        autoFarm = v
        task.spawn(function()
            while autoFarm do
                task.wait(0.3)
                local lp = game.Players.LocalPlayer
                local char = lp.Character or lp.CharacterAdded:Wait()

                -- Auto equip first tool
                if lp.Backpack:FindFirstChildOfClass("Tool") then
                    lp.Backpack:FindFirstChildOfClass("Tool").Parent = char
                end

                for _,plr in pairs(game.Players:GetPlayers()) do
                    if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        -- Tele tới player
                        char:PivotTo(plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3))
                        task.wait(0.1)

                        -- Slap
                        pcall(function()
                            firetouchinterest(char.HumanoidRootPart, plr.Character.HumanoidRootPart, 0)
                            firetouchinterest(char.HumanoidRootPart, plr.Character.HumanoidRootPart, 1)
                        end)
                    end
                end
            end
        end)
    end,
})

CombatTab:CreateButton({
    Name = "Stop AutoFarm (Kick Safe)",
    Callback = function()
        autoFarm = false
        game.Players.LocalPlayer:Kick("Stopped AutoFarm - Safe Exit 😎")
    end,
})

-- ===========================
-- Visuals Tab
-- ===========================
local VisualTab = Window:CreateTab("Visuals")

VisualTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = false,
    Callback = function(v)
        if v then
            for _,plr in pairs(game.Players:GetPlayers()) do
                if plr ~= game.Players.LocalPlayer and plr.Character then
                    local hl = Instance.new("Highlight")
                    hl.Name = "MangoESP"
                    hl.Parent = plr.Character
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end
        else
            for _,plr in pairs(game.Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("MangoESP") then
                    plr.Character.MangoESP:Destroy()
                end
            end
        end
    end,
})

-- ===========================
-- Fun Tab
-- ===========================
local FunTab = Window:CreateTab("Fun")

FunTab:CreateButton({
    Name = "TeleSlap All Players",
    Callback = function()
        local lp = game.Players.LocalPlayer
        local char = lp.Character or lp.CharacterAdded:Wait()

        -- Auto equip first tool
        if lp.Backpack:FindFirstChildOfClass("Tool") then
            lp.Backpack:FindFirstChildOfClass("Tool").Parent = char
        end

        for _,plr in pairs(game.Players:GetPlayers()) do
            if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                char:PivotTo(plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3))
                task.wait(0.2)
                pcall(function() mouse1click() end)
                task.wait(0.3)
            end
        end
    end,
})