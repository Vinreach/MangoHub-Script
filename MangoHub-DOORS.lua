local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/SansYT789/Library/refs/heads/main/Esp.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/addons/SaveManager.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:FindFirstChildOfClass("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")
local GameId = game.GameId
local GameLoader = {
    [2440500124] = {
        ["Folder"] = "Doors",
        ["Main"] = "Doors",
        ["Name"] = "DOORS"
    }
}

local CurrentGame = GameLoader[GameId]
local GameName = CurrentGame and CurrentGame.Name or tostring(GameId)

if not GameName == "DOORS" then
    warn("Experiences other than this source will not support.")
    print("If there is an error, it is because your experience does not support full functionality")
    error("NOT SUPPORT!!!")
    error("NOT SUPPORT!!!")
    error("NOT SUPPORT!!!")
    error("No support!!!, don't try to ask the developer to fix the error!!!")
    warn("Found you using this source in another experience!!!")
end

local Window = Library:CreateWindow({
    Title = "MangoHub",
    Footer = "v1.0 | Mango Hub | Game: " .. GameName .. " | Floor: " .. ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Floor").Value,
    Center = true,
    AutoShow = true
})

local MainTab = Window:AddTab("Main", "home")
local ExploitTab = Window:AddTab("Exploits", "main")
local VisualTab = Window:AddTab("Visuals", "utility")
local FloorTab = Window:AddTab("Floor", "floor")

local EntityTable = {
    ["Names"] = {
        "BackdoorRush",
        "BackdoorLookman",
        "RushMoving",
        "AmbushMoving",
        "Eyes",
        "JeffTheKiller",
        "Dread",
        "A60",
        "A120",
        "Groundskeeper",
        "MonumentEntity",
        "SurgePart"
    },
    ["SideNames"] = {"FigureRig", "GiggleCeiling", "GrumbleRig", "Snare", "Mandrake"},
    ["ShortNames"] = {["BackdoorRush"] = "Blitz", ["JeffTheKiller"] = "Jeff The Killer"},
    ["NotifyMessage"] = {["GloombatSwarm"] = "Gloombats in next room!"}
}
local VoidThresholdValues = {
    ["Hotel"] = 3,
    ["Mines"] = 3,
    ["Retro"] = 3,
    ["Garden"] = 4,
    ["Rooms"] = 4,
    ["Fools"] = 3,
    ["Backdoor"] = 2
}
local HideTimeValues = {
    {min = 1, max = 5, a = -1 / 6, b = 1, c = 20},
    {min = 6, max = 19, a = -1 / 13, b = 6, c = 19},
    {min = 19, max = 22, a = -1 / 4, b = 19, c = 18},
    {min = 23, max = 26, a = 1 / 3, b = 23, c = 18},
    {min = 26, max = 30, a = -1 / 4, b = 26, c = 19},
    {min = 30, max = 35, a = -1 / 3, b = 30, c = 18},
    {min = 36, max = 60, a = -1 / 12, b = 36, c = 18},
    {min = 60, max = 90, a = -1 / 30, b = 60, c = 16},
    {min = 90, max = 99, a = -1 / 6, b = 90, c = 15}
}

local Connections = {}
local SuffixPrefixes = {
    ["Backdoor"] = "",
    ["Ceiling"] = "",
    ["Moving"] = "",
    ["Ragdoll"] = "",
    ["Rig"] = "",
    ["Wall"] = "",
    ["Item"] = "",
    ["Part"] = "",
    ["Entity"] = "",
    ["Pickup"] = "",
    ["ForCrypt"] = "",
    ["Petal"] = " Petal",
    ["Holder"] = "",
    ["Clock"] = " Clock",
    ["Key"] = " Key",
    ["Pack"] = " Pack",
    ["Pointer"] = " Pointer",
    ["Swarm"] = " Swarm"
}
local FeatureConnections = {
    Character = {},
    Clip = {},
    Door = {},
    DoorGate = {},
    Humanoid = {},
    Player = {},
    Pump = {},
    RootPart = {}
}
local ESPTable = {
    Chest = {},
    Door = {},
    Entity = {},
    SideEntity = {},
    Gold = {},
    DroppedItem = {},
    Item = {},
    Objective = {},
    Player = {},
    HidingSpot = {},
    None = {}
}

local Temp = {
    AnchorFinished = {},
    CollisionSize = Vector3.new(5.5, 3, 3),
    PaintingDebounce = {},
    UsedBreakers = {},
    VoidGlitchNotifiedRooms = {}
}
local SlotsName = {"Oval", "Square", "Tall", "Wide"}
local PromptTable = {
    GamePrompts = {},
    Aura = {
        ["ActivateEventPrompt"] = true,
        ["AwesomePrompt"] = true,
        ["FusesPrompt"] = true,
        ["HerbPrompt"] = true,
        ["LeverPrompt"] = true,
        ["LootPrompt"] = true,
        ["ModulePrompt"] = true,
        ["SkullPrompt"] = true,
        ["UnlockPrompt"] = true,
        ["ValvePrompt"] = true,
        ["PropPrompt"] = true
    },
    AuraObjects = {"Lock", "Button"},
    Excluded = {
        Prompt = {"HintPrompt", "InteractPrompt"},
        Parent = {"KeyObtainFake", "Padlock"},
        ModelAncestor = {"DoorFake"}
    }
}

local CutsceneExclude = {"FigureHotelChase", "Elevator1", "MinesFinale", "BrambleIntro"}
local HidingPlaceName = {
    ["Hotel"] = "Closet",
    ["Backdoor"] = "Closet",
    ["Fools"] = "Closet",
    ["Retro"] = "Closet",
    ["Garden"] = "Closet",
    ["Rooms"] = "Locker",
    ["Mines"] = "Locker"
}

local GameData = ReplicatedStorage:WaitForChild("GameData")
local LatestRoom = GameData:WaitForChild("LatestRoom")
local Floor = GameData:WaitForChild("Floor")
local LiveModifiers = ReplicatedStorage:WaitForChild("LiveModifiers")
local MainUI = Players.LocalPlayer.PlayerGui:WaitForChild("MainUI")
local MainGame = MainUI:WaitForChild("Initiator"):WaitForChild("Main_Game")
local EntityModules = ReplicatedStorage:WaitForChild("ModulesClient"):WaitForChild("EntityModules")

local IsMines = Floor.Value == "Mines"
local IsRooms = Floor.Value == "Rooms"
local IsHotel = Floor.Value == "Hotel"
local IsBackdoor = Floor.Value == "Backdoor"
local IsFools = Floor.Value == "Fools"
local IsRetro = Floor.Value == "Retro"
local IsOutdoor = Floor.Value == "Garden"

local FloorReplicated = if not IsFools then ReplicatedStorage:WaitForChild("FloorReplicated") else nil
local RemotesFolder = if not IsFools then ReplicatedStorage:WaitForChild("RemotesFolder") else ReplicatedStorage:WaitForChild("EntityInfo")
local NoCharRaycastParam = RaycastParams.new()

local Collision = nil
local CollisionClone = nil
local LastSpeed = if hum then hum.WalkSpeed else 15
local LastClimbSpeed = 15
local SpeedBypassing = false
local isnetworkowner = nil
if not isnetworkowner then
    function isnetowner(part)
        if not part:IsA("BasePart") then
            return error("BasePart expected, got " .. typeof(part))
        end

        return part.ReceiveAge == 0
    end

    isnetworkowner = isnetowner
else
    isnetworkowner = isnetworkowner
end
local Alive = player:GetAttribute("Alive")
player:GetAttributeChangedSignal("Alive"):Connect(function()
    Alive = player:GetAttribute("Alive")
end)
local Modifiers = false
local function UpdateModifiers()
    Modifiers = #LiveModifiers:GetChildren() > 0
end
UpdateModifiers()
LiveModifiers.ChildAdded:Connect(UpdateModifiers)
LiveModifiers.ChildRemoved:Connect(UpdateModifiers)
local Voicelines = {}
if ReplicatedStorage:FindFirstChild("VoiceActing") and ReplicatedStorage.VoiceActing:FindFirstChild("Voicelines") then
    for _, voiceline in pairs(ReplicatedStorage.VoiceActing.Voicelines:GetDescendants()) do
        if not voiceline:IsA("Sound") then continue end
        table.insert(Voicelines, voiceline.SoundId)
    end
end
local CurrentRoom = tonumber(player:GetAttribute("CurrentRoom"))
if not CurrentRoom then
    CurrentRoom = LatestRoom.Value
    player:SetAttribute("CurrentRoom", CurrentRoom)
end
if not workspace.CurrentRooms:FindFirstChild(tostring(CurrentRoom)) then
    CurrentRoom = LatestRoom.Value
    player:SetAttribute("CurrentRoom", CurrentRoom)
end
local NextRoom = (tonumber(CurrentRoom) or 0) + 1
Library:OnUnload(function()
        if char then
            char:SetAttribute("CanJump", false)

            local speedBoostAssignObj = IsFools and hum or char
            speedBoostAssignObj:SetAttribute("SpeedBoostBehind", 0)
        end

        if Alive then
            Lighting.Ambient = workspace.CurrentRooms[CurrentRoom]:GetAttribute("Ambient")
        else
            Lighting.Ambient = Color3.new(0, 0, 0)
        end

        local voicelines = ReplicatedStorage:FindFirstChild("_Voicelines", true)
        if voicelines then
            voicelines.Name = "Voicelines"
        end

        if MainGame then
            local modules = MainGame:FindFirstChild("Modules", true)

            local dreadModule = modules and modules:FindFirstChild("_Dread", true)
            local screechModule = modules and modules:FindFirstChild("_Screech", true)
            local spiderModule = modules and modules:FindFirstChild("_SpiderJumpscare", true)

            if dreadModule then
                dreadModule.Name = "Dread"
            end
            if screechModule then
                screechModule.Name = "Screech"
            end
            if spiderModule then
                spiderModule.Name = "SpiderJumpscare"
            end
        end
        workspace.Camera.FieldOfView = 70

        if hrp then
            local existingProperties = hrp.CustomPhysicalProperties
            hrp.CustomPhysicalProperties =
                PhysicalProperties.new(
                Temp.NoAccelValue,
                existingProperties.Friction,
                existingProperties.Elasticity,
                existingProperties.FrictionWeight,
                existingProperties.ElasticityWeight
            )
        end

        if IsBackdoor then
            local clientRemote = FloorReplicated.ClientRemote
            local storage = clientRemote:FindFirstChild("_EntityCantEscape")

            if storage and #storage:GetChildren() ~= 0 then
                for i, v in pairs(storage:GetChildren()) do
                    v.Parent = clientRemote.Haste
                end
            end

            storage:Destroy()
        end

        if IsRooms then
            if workspace:FindFirstChild("_minthub_pathfinding_nodepart") then
                workspace:FindFirstChild("_minthub_pathfinding_nodepart"):Destroy()
            end
            if workspace:FindFirstChild("_minthub_pathfinding_blockpart") then
                workspace:FindFirstChild("_minthub_pathfinding_blockpart"):Destroy()
            end
        end

        if doorshubCustomCaptions then
            doorshubCustomCaptions:Destroy()
        end

        if Collision then
            Collision.CanCollide = not char:GetAttribute("Crouching")

            if Collision:FindFirstChild("CollisionCrouch") then
                Collision.CollisionCrouch.CanCollide = char:GetAttribute("Crouching")
            end
        end

        if CollisionClone then
            CollisionClone:Destroy()
        end

        for _, espType in pairs(ESPTable) do
            for _, esp in pairs(espType) do
                esp.Destroy()
            end
        end

        for _, category in pairs(FeatureConnections) do
            for _, connection in pairs(category) do
                connection:Disconnect()
            end
        end

        for _, object in pairs(workspace.CurrentRooms:GetDescendants()) do
            if PromptCondition(object) then
                if not object:GetAttribute("Hold") then
                    object:SetAttribute("Hold", object.HoldDuration)
                end
                if not object:GetAttribute("Distance") then
                    object:SetAttribute("Distance", object.MaxActivationDistance)
                end
                if not object:GetAttribute("Clip") then
                    object:SetAttribute("Clip", object.RequiresLineOfSight)
                end

                object.HoldDuration = object:GetAttribute("Hold")
                object.MaxActivationDistance = object:GetAttribute("Distance")
                object.RequiresLineOfSight = object:GetAttribute("Clip")
            elseif object:IsA("BasePart") then
                if not object:GetAttribute("Material") then
                    object:SetAttribute("Material", object.Material)
                end
                if not object:GetAttribute("Reflectance") then
                    object:SetAttribute("Reflectance", object.Reflectance)
                end

                object.Material = object:GetAttribute("Material")
                object.Reflectance = object:GetAttribute("Reflectance")
            elseif object:IsA("Decal") then
                if not object:GetAttribute("Transparency") then
                    object:SetAttribute("Transparency", object.Transparency)
                end

                object.Transparency = object:GetAttribute("Transparency")
            end
        end

        workspace.Terrain.WaterReflectance = 1
        workspace.Terrain.WaterTransparency = 1
        workspace.Terrain.WaterWaveSize = 0.05
        workspace.Terrain.WaterWaveSpeed = 8
        Lighting.GlobalShadows = true
end)
local doorshubCustomCaptions = Instance.new("ScreenGui")
doorshubCustomCaptions.Name = "DoorsHubCustomCaptions"
doorshubCustomCaptions.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
doorshubCustomCaptions.Enabled = false

local Frame = Instance.new("Frame")
Frame.Parent = doorshubCustomCaptions
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.BackgroundColor3 = Library.MainColor or Color3.fromRGB(30, 30, 30)
Frame.BorderColor3 = Library.AccentColor or Color3.fromRGB(0, 170, 255)
Frame.BorderSizePixel = 2
Frame.Position = UDim2.new(0.5, 0, 0.8, 0)
Frame.Size = UDim2.new(0, 200, 0, 75)

Library:AddToRegistry(Frame, {
        BackgroundColor3 = "MainColor",
        BorderColor3 = "AccentColor"
})

local TextLabel = Instance.new("TextLabel")
TextLabel.Parent = Frame
TextLabel.BackgroundTransparency = 1
TextLabel.Size = UDim2.new(1, 0, 1, 0)
TextLabel.Font = Enum.Font.Code
TextLabel.Text = ""
TextLabel.TextColor3 = Library.FontColor or Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.TextWrapped = true

Library:AddToRegistry(TextLabel, {
        TextColor3 = "FontColor"
})

local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
UITextSizeConstraint.MaxTextSize = 35
UITextSizeConstraint.Parent = TextLabel

local CaptionsLastUsed = os.time()

local function HideCaptions()
    doorshubCustomCaptions.Enabled = false
end

local function Captions(caption)
    CaptionsLastUsed = os.time()

    if not doorshubCustomCaptions.Parent or doorshubCustomCaptions.Parent == game then
        local success = pcall(function()
                doorshubCustomCaptions.Parent = gethui and gethui() or CoreGui
        end)

        if not success or doorshubCustomCaptions.Parent ~= CoreGui then
            doorshubCustomCaptions.Parent = player:WaitForChild("PlayerGui")
        end
    end

    TextLabel.Text = caption
    doorshubCustomCaptions.Enabled = true

    task.spawn(function()
            task.wait(5)
            if os.time() - CaptionsLastUsed >= 5 then
                HideCaptions()
            end
    end)
end

local DoorsHubCaptions = {
    Show = Captions,
    Hide = HideCaptions
}

local function SendMessage(msg)
    local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
    if channel and channel.SendAsync then
        channel:SendAsync(msg)
    else
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
    end
end
local function Notify(title, desc, time)
    Library:Notify({
            Title = title or "Mango Hub",
            Description = desc or "",
            Time = time or 3
    })
end
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
            if not self.Enabled then
                return
            end
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then
                return
            end

            local moveVector = Vector3.zero
            local success, cm =pcall(function()
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
            if
                UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.Q) or
                    UserInputService:IsKeyDown(Enum.KeyCode.C)
             then
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
    if not char or not hrp then
        return warn("HumanoidRootPart is nil.")
    end

    self.Enabled = value
    hum.PlatformStand = value

    if value then
        self.FlyBody.Parent = hrp
        self.FlyGyro.Parent = hrp
    else
        self.FlyBody.Parent = nil
        self.FlyGyro.Parent = nil
    end
end

function Fly:Enable()
    self:Set(true)
end
function Fly:Disable()
    self:Set(false)
end
function Fly:Toggle()
    self:Set(not self.Enabled)
end
function Fly:SetSpeed(speed)
    self.Speed = speed
end

local MainLeftGroupbox = MainTab:AddLeftGroupbox("Player")
local SpeedHackToggle = MainLeftGroupbox:AddToggle("SpeedHackToggle", {Text = "Enable Speed Hack", Default = false})
local WalkSpeedSlider = MainLeftGroupbox:AddSlider("WalkSpeedSlider",{
        Text = "Walk Speed",
        Default = 15,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            LastSpeed = Value
        end
})
local LadderSpeedSlider = MainLeftGroupbox:AddSlider("LadderSpeedSlider", {
        Text = "Ladder Speed",
        Default = 15,
        Min = 0,
        Max = 75,
        Rounding = 0,
        Visible = IsMines,
        Callback = function(Value)
            LastClimbSpeed = Value
        end
})
local EnableJumpToggle = MainLeftGroupbox:AddToggle("EnableJumpToggle", {Text = "Enable Jump", Default = false})
local JumpBoostSlider = MainLeftGroupbox:AddSlider("JumpBoostSlider", {Text = "Jump Boost", Default = 5, Min = 0, Max = 50, Rounding = 0})
local NoAccelToggle = MainLeftGroupbox:AddToggle("NoAccelToggle", {Text = "No Acceleration", Default = false})
MainLeftGroupbox:AddDivider()
local InstantInteractToggle = MainLeftGroupbox:AddToggle("InstantInteractToggle", {Text = "Instant Interact", Default = false})
local FastClosetExitToggle = MainLeftGroupbox:AddToggle("FastClosetExitToggle", {Text = "Fast Closet Exit", Default = false})
local AntiAfkToggle = MainLeftGroupbox:AddToggle("AntiAfkToggle", {Text = "Anti Afk", Default = false})
MainLeftGroupbox:AddDivider()
local NoclipToggle = MainLeftGroupbox:AddToggle("NoclipToggle", {Text = "Noclip", Default = false})
local EnableFlyToggle = MainLeftGroupbox:AddToggle("EnableFlyToggle", {Text = "Enable Fly", Default = false})
local FlySpeedSlider = MainLeftGroupbox:AddSlider("FlySpeedSlider", {
        Text = "Fly Speed",
        Default = 15,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            Fly:SetSpeed(Value)
        end
})

SpeedHackToggle:OnChanged(function(value)
        if not char then
            return
        end

        if value then
            task.spawn(function()
                    while value do
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if not hum then continue end

                        local climb = char:GetAttribute("Climbing")
                        hum.WalkSpeed = climb and LastClimbSpeed or math.min(16, LastSpeed)
                        task.wait(0.1)
                    end
                end)
        else
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
            end
        end
end)

EnableJumpToggle:OnChanged(function(value)
        if char then
            char:SetAttribute("CanJump", value)
        end
end)

JumpBoostSlider:OnChanged(function(value)
        if not EnableJumpToggle.Value then
            return
        end
        if hum then
            hum.JumpHeight = Value
        end
end)

NoAccelToggle:OnChanged(function(value)
        local root = hrp
        if not root then
            return
        end

        if value then
            Temp.NoAccelProperties = root.CustomPhysicalProperties
            local props = root.CustomPhysicalProperties
            root.CustomPhysicalProperties =
                PhysicalProperties.new(
                100,
                props.Friction,
                props.Elasticity,
                props.FrictionWeight,
                props.ElasticityWeight
            )
        else
            if Temp.NoAccelProperties then
                root.CustomPhysicalProperties = Temp.NoAccelProperties
            end
        end
end)

local NoclipConnection
NoclipToggle:OnChanged(function(value)
        if value then
            NoclipConnection =
                RunService.Stepped:Connect(function()
                    if char then
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
            end)
        else
            if NoclipConnection then
                NoclipConnection:Disconnect()
                NoclipConnection = nil
            end
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
end)

EnableFlyToggle:OnChanged(function(value)
        if value then
            if not Fly.FlyBody then
                Fly:Setup()
            end
            Fly:Enable()
        else
            Fly:Disable()
            Fly:Stop()
        end
end)

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
        if InstantInteractToggle.Value then
            fireproximityprompt(prompt)
        end
end)

InstantInteractToggle:OnChanged(function(value)
        for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                if value then
                    if not prompt:GetAttribute("Hold") then
                        prompt:SetAttribute("Hold", prompt.HoldDuration)
                    end
                    prompt.HoldDuration = 0
                else
                    prompt.HoldDuration = prompt:GetAttribute("Hold") or 0
                end
            end
        end
end)

local MainLeft2Groupbox = MainTab:AddLeftGroupbox("Reach")
local DoorReachToggle = MainLeft2Groupbox:AddToggle("DoorReachToggle", {Text = "Door Reach", Default = false})
local PromptClipToggle = MainLeft2Groupbox:AddToggle("PromptClipToggle", {Text = "Prompt Clip", Default = false})
local PromtReachMultiplerSlider =
    MainLeft2Groupbox:AddSlider(
    "PromtReachMultiplerSlider",
    {Text = "Promt Reach Multipler", Default = 1, Min = 1, Max = 3, Rounding = 1}
)

PromptClipToggle:OnChanged(
    function(value)
        task.spawn(
            function()
                while value do
                    pcall(
                        function()
                            for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do
                                if PromptCondition(prompt) then
                                    if value then
                                        prompt.RequiresLineOfSight = false
                                    else
                                        prompt.RequiresLineOfSight = prompt:GetAttribute("Clip") or true
                                    end
                                end
                            end
                        end
                    )
                    task.wait()
                end
            end
        )
    end
)

PromtReachMultiplerSlider:OnChanged(
    function(value)
        task.spawn(
            function()
                while value do
                    pcall(
                        function()
                            for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do
                                if PromptCondition(prompt) then
                                    if not prompt:GetAttribute("Distance") then
                                        prompt:SetAttribute("Distance", prompt.MaxActivationDistance)
                                    end

                                    prompt.MaxActivationDistance = prompt:GetAttribute("Distance") * value
                                end
                            end
                        end
                    )
                    task.wait()
                end
            end
        )
    end
)

local MainRightGroupbox = MainTab:AddRightGroupbox("Automation")
local AutoInteractToggle = MainRightGroupbox:AddToggle("AutoInteractToggle", {Text = "Auto Interact", Default = false})
MainRightGroupbox:AddDivider()
local AutoHeartbeatMinigameToggle =
    MainRightGroupbox:AddToggle("AutoHeartbeatMinigameToggle", {Text = "Auto Heartbeat Minigame", Default = false})
local AutoSolverLibraryCodeToggle =
    MainRightGroupbox:AddToggle(
    "AutoSolverLibraryCodeToggle",
    {Text = "Auto Library Code", Default = false, Visible = IsHotel}
)
local AutoSolverLibraryCodeDistanceSlider =
    MainRightGroupbox:AddSlider(
    "AutoSolverLibraryCodeDistanceSlider",
    {Text = "Unlock Distance", Default = 20, Min = 1, Max = 100, Rounding = 0, Visible = IsHotel}
)
local AutoSolverBreakerBoxToggle =
    MainRightGroupbox:AddToggle(
    "AutoSolverBreakerBoxToggle",
    {Text = "Auto Breaker Box", Default = false, Visible = IsHotel}
)
if IsMines then
    MainRightGroupbox:AddDivider()
end
local AutoAnchorSolverToggle =
    MainRightGroupbox:AddToggle(
    "AutoAnchorSolverToggle",
    {Text = "Auto Anchor Solver", Default = false, Visible = IsMines}
)

AutoSolverLibraryCodeToggle:OnChanged(
    function(value)
        task.spawn(
            function()
                while value do
                    pcall(
                        function()
                            for _, plr in pairs(game.Players:GetPlayers()) do
                                if plr.Character then
                                    local tool = plr.Character:FindFirstChildOfClass("Tool")
                                    if tool and tool.Name:match("LibraryHintPaper") then
                                        local code = GetPadlockCode(tool)
                                        local padlock = workspace:FindFirstChild("Padlock", true)
                                        if
                                            tonumber(code) and
                                                DistanceFromCharacter(padlock) <=
                                                    AutoSolverLibraryCodeDistanceSlider.Value
                                         then
                                            RemotesFolder.PL:FireServer(code)
                                        end
                                    end
                                end
                            end
                        end
                    )
                    task.wait()
                end
            end
        )
    end
)

AutoSolverBreakerBoxToggle:OnChanged(
    function(value)
        task.spawn(
            function()
                while value do
                    pcall(
                        function()
                            local elevatorBreaker = workspace.CurrentRooms:FindFirstChild("ElevatorBreaker", true)
                            if not elevatorBreaker then
                                return
                            end
                            SolveBreakerBox(elevatorBreaker)
                        end
                    )
                    task.wait()
                end
            end
        )
    end
)

local MainRight2Groupbox = MainTab:AddRightGroupbox("Misc")
local ReviveButton =
    MainRight2Groupbox:AddButton(
    {
        Text = "Revive",
        DoubleClick = true,
        Func = function()
            RemotesFolder.Revive:FireServer()
        end
    }
)
local LobbyButton =
    MainRight2Groupbox:AddButton(
    {
        Text = "Play Again",
        DoubleClick = true,
        Func = function()
            RemotesFolder.PlayAgain:FireServer()
        end
    }
)
local LobbyButton =
    MainRight2Groupbox:AddButton(
    {
        Text = "Lobby",
        DoubleClick = true,
        Func = function()
            RemotesFolder.Lobby:FireServer()
        end
    }
)

-- Exploits
local ExploitLeftGroupbox = ExploitTab:AddLeftGroupbox("Anti Entity")
local AntiDreadToggle = ExploitLeftGroupbox:AddToggle("AntiDreadToggle", {Text = "Anti Dread", Default = false})
local AntiHaltToggle = ExploitLeftGroupbox:AddToggle("AntiHaltToggle", {Text = "Anti Halt", Default = false})
local AntiScreechToggle = ExploitLeftGroupbox:AddToggle("AntiScreechToggle", {Text = "Anti Screech", Default = false})
local AntiDupeToggle =
    ExploitLeftGroupbox:AddToggle(
    "AntiDupeToggle",
    {Text = "Anti " .. (IsBackdoor and "Vacuum" or "Dupe"), Default = false}
)
local AntiEyesToggle =
    ExploitLeftGroupbox:AddToggle(
    "AntiEyesToggle",
    {Text = "Anti " .. (IsBackdoor and "Lookman" or "Eyes"), Default = false, Visible = not (IsRooms or IsOutdoor)}
)
local AntiSnareToggle = ExploitLeftGroupbox:AddToggle("AntiSnareToggle", {Text = "Anti Snare", Default = false})
local AntiFigureHearingToggle =
    ExploitLeftGroupbox:AddToggle(
    "AntiFigureHearingToggle",
    {Text = "Anti Figure Hearing", Default = false, Visible = not (IsRooms or IsOutdoor)}
)

AntiDreadToggle:OnChanged(
    function(value)
        task.spawn(
            function()
                while value do
                    pcall(
                        function()
                            AntiEntityToggle("Dread", value)
                        end
                    )
                    task.wait()
                end
            end
        )
    end
)

AntiHaltToggle:OnChanged(
    function(value)
        task.spawn(
            function()
                while value do
                    pcall(
                        function()
                            AntiEntityToggle("Halt", value)
                        end
                    )
                    task.wait()
                end
            end
        )
    end
)

AntiScreechToggle:OnChanged(
    function(value)
        task.spawn(
            function()
                while value do
                    pcall(
                        function()
                            AntiEntityToggle("Screech", value)
                        end
                    )
                    task.wait()
                end
            end
        )
    end
)

AntiDupeToggle:OnChanged(
    function(value)
        task.spawn(
            function()
                while value do
                    pcall(
                        function()
                            AntiEntityToggle(IsBackdoor and "Vacuum" or "Dupe", value)
                        end
                    )
                    task.wait()
                end
            end
        )
    end
)

AntiEyesToggle:OnChanged(
    function(value)
        task.spawn(
            function()
                while value do
                    pcall(
                        function()
                            AntiEntityToggle(IsBackdoor and "Lookman" or "Eyes", value)
                        end
                    )
                    task.wait()
                end
            end
        )
    end
)

AntiSnareToggle:OnChanged(
    function(value)
        task.spawn(
            function()
                while value do
                    pcall(
                        function()
                            AntiEntityToggle("Snare", value)
                        end
                    )
                    task.wait()
                end
            end
        )
    end
)

local mtHook
mtHook =
    hookmetamethod(
    game,
    "__namecall",
    function(self, ...)
        local args = {...}
        local namecallMethod = getnamecallmethod()

        if namecallMethod == "FireServer" then
            if self.Name == "ClutchHeartbeat" and AutoHeartbeatMinigameToggle.Value then
                return
            elseif self.Name == "Crouch" and AntiFigureHearingToggle.Value then
                args[1] = true
                return mtHook(self, unpack(args))
            end
        elseif namecallMethod == "Destroy" and self.Name == "RunnerNodes" then
            return
        end

        return mtHook(self, ...)
    end
)

char:GetAttributeChangedSignal("Crouching"):Connect(
    function()
        if not char:GetAttribute("Crouching") then
            RemotesFolder.Crouch:FireServer(AntiFigureHearingToggle.Value)
        end
    end
)

local ExploitRightGroupbox = ExploitTab:AddRightGroupbox("Bypass")
local EnableSpeedBypassToggle =
    ExploitRightGroupbox:AddToggle("EnableSpeedBypassToggle", {Text = "Enable Speed Bypass", Default = false})
local SpeedBypassDelaySlider =
    ExploitRightGroupbox:AddSlider(
    "SpeedBypassDelaySlider",
    {Text = "Speed Bypass Delay", Default = 0.23, Min = 0.22, Max = 0.25, Rounding = 3}
)

function SpeedBypass()
    if SpeedBypassing or not CollisionClone then
        return
    end
    SpeedBypassing = true

    task.spawn(
        function()
            while EnableSpeedBypassToggle.Value and CollisionClone and not Library.Unloaded do
                if hrp.Anchored then
                    CollisionClone.Massless = true
                    repeat
                        task.wait()
                    until not hrp.Anchored
                    task.wait(0.15)
                else
                    CollisionClone.Massless = not CollisionClone.Massless
                end
                task.wait(SpeedBypassDelaySlider.Value)
            end

            SpeedBypassing = false
            if CollisionClone then
                CollisionClone.Massless = true
            end
        end
    )
end

EnableSpeedBypassToggle:OnChanged(
    function(value)
        if value then
            WalkSpeedSlider:SetMax(75)
            FlySpeedSlider:SetMax(75)

            SpeedBypass()
        else
            local speed = if Bypassed then 75 elseif EnableJumpToggle.Value then 18 else 22
            local flySpeed = if Bypassed then 75 else 22

            WalkSpeedSlider:SetMax(speed)
            FlySpeedSlider:SetMax(flySpeed)
        end
    end
)

-- Visual
local VisualLeftTabbox = VisualTab:AddLeftTabbox("Esp")
local VisualEspTab = VisualLeftTabbox:AddTab("Esp")
local VisualSettingsEspTab = VisualLeftTabbox:AddTab("Settings")
local espToggles = {"Door", "Gold", "Objective", "Chest", "Item", "Hiding Spot", "Entity", "Player"}
local ActiveEspToggle = {}
local EspColors = {}
local EspKeyMap = {
    ["Hiding Spot"] = "HidingSpot"
}

local DefaultEspColors = {
    Door = Color3.new(0, 1, 1),
    Gold = Color3.new(1, 1, 0),
    Objective = Color3.new(0, 1, 0),
    Chest = Color3.new(1, 1, 0),
    Item = Color3.new(1, 0, 1),
    HidingSpot = Color3.new(0, 0.5, 0),
    Entity = Color3.new(1, 0, 0),
    Player = Color3.new(1, 1, 1)
}

function IsEspActive(name)
    return ActiveEspToggle[name] or false
end

function GetEspColor(name)
    return EspColors[name] or DefaultEspColors[name] or Color3.new(1, 1, 1)
end

for _, name in ipairs(espToggles) do
    local key = EspKeyMap[name] or name

    local toggle =
        VisualEspTab:AddToggle(
        "ESP_" .. name .. "Toggle",
        {
            Text = name,
            Default = false,
            Callback = function(Value)
                ActiveEspToggle[key] = Value
                ToggleEsp(key, Value)
            end
        }
    )

    toggle:AddColorPicker(
        "ESP_" .. name .. "ColorPicker",
        {
            Default = DefaultEspColors[name] or Color3.new(1, 1, 1),
            Callback = function(Color)
                EspColors[key] = Color
                if ESPTable[key] then
                    for _, esp in pairs(ESPTable[key]) do
                        esp.Update({FillColor = Color, OutlineColor = Color, TextColor = Color})
                    end
                end
            end
        }
    )
end
local EnableRainbowEspToggle =
    VisualSettingsEspTab:AddToggle("EnableRainbowEspToggle", {Text = "Enable Rainbow Esp", Default = false})
VisualSettingsEspTab:AddDivider()
local EnableHighlightEspToggle =
    VisualSettingsEspTab:AddToggle("EnableHighlightEspToggle", {Text = "Enable Highlight", Default = true})
local FillTransparencyEspSlider =
    VisualSettingsEspTab:AddSlider(
    "FillTransparencyEspSlider",
    {Text = "Fill Transparency", Default = 0.75, Min = 0, Max = 1, Rounding = 2}
)
local OutlineTransparencyEspSlider =
    VisualSettingsEspTab:AddSlider(
    "OutlineTransparencyEspSlider",
    {Text = "Outline Transparency", Default = 0, Min = 0, Max = 1, Rounding = 2}
)
VisualSettingsEspTab:AddDivider()
local EnableDistanceEspToggle =
    VisualSettingsEspTab:AddToggle("EnableDistanceEspToggle", {Text = "Enable Show Distance", Default = false})
local TextSizeChangerEspSlider =
    VisualSettingsEspTab:AddSlider(
    "TextSizeChangerEspSlider",
    {Text = "Text Size", Default = 22, Min = 16, Max = 26, Rounding = 0}
)
VisualSettingsEspTab:AddDivider()
local EnableTracerEspToggle =
    VisualSettingsEspTab:AddToggle("EnableTracerEspToggle", {Text = "Enable Tracer", Default = true})
local TracerStartPositionDropdown =
    VisualSettingsEspTab:AddDropdown(
    "TracerStartPositionDropdown",
    {Values = {"Bottom", "Center", "Top", "Mouse"}, Default = {"Bottom"}, Multi = false, Text = "Tracer Start Position"}
)
VisualSettingsEspTab:AddDivider()
local EnableArrowEspToggle =
    VisualSettingsEspTab:AddToggle("EnableArrowEspToggle", {Text = "Enable Arrow", Default = true})
local ArrowCenterOffsetSlider =
    VisualSettingsEspTab:AddSlider(
    "ArrowCenterOffsetSlider",
    {Text = "Arrow Center Offset", Default = 300, Min = 0, Max = 500, Rounding = 0}
)

EnableRainbowEspToggle:OnChanged(
    function(value)
        ESPLibrary.Rainbow.Set(value)
    end
)

EnableHighlightEspToggle:OnChanged(
    function(value)
        for _, espType in pairs(ESPTable) do
            for _, esp in pairs(espType) do
                esp.SetVisible(value, false)
            end
        end
    end
)

FillTransparencyEspSlider:OnChanged(
    function(value)
        for _, espType in pairs(ESPTable) do
            for _, esp in pairs(espType) do
                esp.Update({FillTransparency = value})
            end
        end
    end
)

OutlineTransparencyEspSlider:OnChanged(
    function(value)
        for _, espType in pairs(ESPTable) do
            for _, esp in pairs(espType) do
                esp.Update({OutlineTransparency = value})
            end
        end
    end
)

EnableDistanceEspToggle:OnChanged(
    function(value)
        ESPLibrary.Distance.Set(value)
    end
)

TextSizeChangerEspSlider:OnChanged(
    function(value)
        for _, espType in pairs(ESPTable) do
            for _, esp in pairs(espType) do
                esp.Update({TextSize = value})
            end
        end
    end
)

EnableTracerEspToggle:OnChanged(
    function(value)
        ESPLibrary.Tracers.Set(value)
    end
)

TracerStartPositionDropdown:OnChanged(
    function(value)
        for _, espType in pairs(ESPTable) do
            for _, esp in pairs(espType) do
                esp.Update({Tracer = {From = value}})
            end
        end
    end
)

EnableArrowEspToggle:OnChanged(
    function(value)
        ESPLibrary.Arrows.Set(value)
    end
)

ArrowCenterOffsetSlider:OnChanged(
    function(value)
        for _, espType in pairs(ESPTable) do
            for _, esp in pairs(espType) do
                esp.Update({Arrow = {CenterOffset = value}})
            end
        end
    end
)

local VisualLeft2Groupbox = VisualTab:AddLeftGroupbox("Ambient")
local BrightnessSlider =
    VisualLeft2Groupbox:AddSlider(
    "BrightnessSlider",
    {
        Text = "Brightness",
        Default = 0,
        Min = 0,
        Max = 3,
        Rounding = 0,
        Callback = function(Value)
            Lighting.Brightness = Value
        end
    }
)
local FullbrightToggle = VisualLeft2Groupbox:AddToggle("FullbrightToggle", {Text = "Fullbright", Default = false})
local NoFogToggle = VisualLeft2Groupbox:AddToggle("NoFogToggle", {Text = "No Fog", Default = false})
local AntiLagToggle = VisualLeft2Groupbox:AddToggle("AntiLagToggle", {Text = "Anti Lag", Default = false})

FullbrightToggle:OnChanged(
    function(value)
        if value then
            Lighting.Ambient = Color3.new(1, 1, 1)
        else
            if Alive then
                local room = workspace.CurrentRooms[player:GetAttribute("CurrentRoom")]
                Lighting.Ambient = room and room:GetAttribute("Ambient") or Color3.new(0, 0, 0)
            else
                Lighting.Ambient = Color3.new(0, 0, 0)
            end
        end
    end
)

NoFogToggle:OnChanged(
    function(value)
        if not Lighting:GetAttribute("FogStart") then
            Lighting:SetAttribute("FogStart", Lighting.FogStart)
        end
        if not Lighting:GetAttribute("FogEnd") then
            Lighting:SetAttribute("FogEnd", Lighting.FogEnd)
        end

        Lighting.FogStart = if value then 0 else Lighting:GetAttribute("FogStart")
        Lighting.FogEnd = if value then math.huge else Lighting:GetAttribute("FogEnd")

        local fog = Lighting:FindFirstChildOfClass("Atmosphere")
        if fog then
            if not fog:GetAttribute("Density") then
                fog:SetAttribute("Density", fog.Density)
            end
            fog.Density = if value then 0 else fog:GetAttribute("Density")
        end
    end
)

Lighting:GetPropertyChangedSignal("Ambient"):Connect(
    function()
        if FullbrightToggle.Value then
            Lighting.Ambient = Color3.new(1, 1, 1)
        end
    end
)

Lighting:GetPropertyChangedSignal("FogStart"):Connect(
    function()
        if NoFogToggle.Value then
            Lighting.FogStart = 0
        end
    end
)

Lighting:GetPropertyChangedSignal("FogEnd"):Connect(
    function()
        if NoFogToggle.Value then
            Lighting.FogEnd = math.huge
        end
    end
)

Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(
    function()
        if FullbrightToggle.Value then
            Lighting.GlobalShadows = FullbrightToggle.Value
        end
    end
)

AntiLagToggle:OnChanged(
    function(value)
        for _, object in pairs(workspace:GetDescendants()) do
            if object:IsA("BasePart") then
                if not object:GetAttribute("Material") then
                    object:SetAttribute("Material", object.Material)
                end
                if not object:GetAttribute("Reflectance") then
                    object:SetAttribute("Reflectance", object.Reflectance)
                end

                object.Material = if value then Enum.Material.Plastic else object:GetAttribute("Material")
                object.Reflectance = if value then 0 else object:GetAttribute("Reflectance")
            elseif object:IsA("Decal") then
                if not object:GetAttribute("Transparency") then
                    object:SetAttribute("Transparency", object.Transparency)
                end
                object.Transparency = if value then 1 else object:GetAttribute("Transparency")
            end
        end

        workspace.Terrain.WaterReflectance = if value then 0 else 1
        workspace.Terrain.WaterTransparency = if value then 0 else 1
        workspace.Terrain.WaterWaveSize = if value then 0 else 0.05
        workspace.Terrain.WaterWaveSpeed = if value then 0 else 8
        Lighting.GlobalShadows = not value
    end
)

local VisualRightTabbox = VisualTab:AddRightTabbox("Entity")
local VisualNotifierTab = VisualRightTabbox:AddTab("Notifier")
local VisualNotifierSettingTab = VisualRightTabbox:AddTab("Setting")
local NotifyEntityMap = {
    Outdoor = {"Groundskeeper", "Monument", "Void/Glitch", "Surge"},
    Hotel = {"Rush", "Ambush", "Eyes", "Halt Room", "Void/Glitch"},
    Mines = {"Rush", "Ambush", "Eyes", "Halt Room", "Gloombat Swarm", "Void/Glitch"},
    Rooms = {"A60", "A120", "Void/Glitch"},
    Backdoor = {"Blitz", "Lookman", "Void/Glitch"}
}
local ModifierExtras = {"A60", "A120"}

local function GetNotifyEntities()
    local area =
        (IsHotel and "Hotel") or (IsMines and "Mines") or (IsOutdoor and "Outdoor") or (IsRooms and "Rooms") or
        (IsBackdoor and "Backdoor")
    if not area then
        return {"Void/Glitch"}
    end
    local entities = {table.unpack(NotifyEntityMap[area])}
    if Modifiers and (area == "Hotel" or area == "Mines") then
        for _, e in ipairs(ModifierExtras) do
            table.insert(entities, e)
        end
    end
    return entities
end
local NotifyEntityDropdown =
    VisualNotifierTab:AddDropdown(
    "NotifyEntityDropdown",
    {Values = GetNotifyEntities(), Default = {}, Multi = true, Text = "Notify Entity"}
)
local NotifyLibraryCodeToggle =
    VisualNotifierTab:AddToggle(
    "NotifyLibraryCodeToggle",
    {Text = "Notify Library Code", Default = false, Visible = not IsOutdoor}
)
local NotifyOxygenToggle = VisualNotifierTab:AddToggle("NotifyOxygenToggle", {Text = "Notify Oxygen", Default = false})
local NotifyHideTimeToggle =
    VisualNotifierTab:AddToggle("NotifyHideTimeToggle", {Text = "Notify Hide Time", Default = false})

local NotifyChatToggle =
    VisualNotifierSettingTab:AddToggle(
    "NotifyChatToggle",
    {Text = "Enable Chat", Tooltip = "Entity and Padlock Code", Default = false}
)
local NotifyEntityInput =
    VisualNotifierSettingTab:AddInput(
    "NotifyEntityInput",
    {
        Text = "Entity Notifier Message",
        Default = "has spawned!",
        Numeric = false,
        Finished = true,
        ClearTextOnFocus = false
    }
)

local VisualRight2Tabbox = VisualTab:AddRightTabbox("Camera")
local VisualSelfTab = VisualRight2Tabbox:AddTab("Self")
local VisualEffectTab = VisualRight2Tabbox:AddTab("Effects")
local ThirdPersonToggle = VisualSelfTab:AddToggle("ThirdPersonToggle", {Text = "Enable Third Person", Default = false})
local ThirdPersonOffsetXSlider =
    VisualSelfTab:AddSlider("ThirdPersonOffsetXSlider", {Text = "X", Default = 1.5, Min = 0, Max = 500, Rounding = 0})
local ThirdPersonOffsetYSlider =
    VisualSelfTab:AddSlider("ThirdPersonOffsetYSlider", {Text = "Y", Default = -0.5, Min = 0, Max = 500, Rounding = 0})
local ThirdPersonOffsetZSlider =
    VisualSelfTab:AddSlider("ThirdPersonOffsetZSlider", {Text = "Z", Default = 6.5, Min = 0, Max = 500, Rounding = 0})
VisualSelfTab:AddDivider()
local FieldOfViewSlider =
    VisualSelfTab:AddSlider(
    "FieldOfViewSlider",
    {
        Text = "Field of View",
        Default = 70,
        Min = 70,
        Max = 120,
        Rounding = 0,
        Callback = function(Value)
            workspace.CurrentCamera.FieldOfView = Value or 70
        end
    }
)
local NoCameraBobbingToggle =
    VisualSelfTab:AddToggle("NoCameraBobbingToggle", {Text = "No Camera Bobbing", Default = false})
local NoCameraShakeToggle = VisualSelfTab:AddToggle("NoCameraShakeToggle", {Text = "No Camera Shake", Default = false})
local NoCutscenesToggle = VisualSelfTab:AddToggle("NoCutscenesToggle", {Text = "Skip Cutscenes", Default = false})
local HidingSpotTranslucent = 0.5
local TranslucentHidingSpotToggle =
    VisualSelfTab:AddToggle(
    "TranslucentHidingSpotToggle",
    {Text = "Translucent " .. HidingPlaceName[Floor.Value], Default = false}
)
local TranslucentHidingSpotSlider =
    VisualSelfTab:AddSlider(
    "TranslucentHidingSpot",
    {
        Text = "Hiding Transparency",
        Default = 0.5,
        Min = 0,
        Max = 1,
        Rounding = 0,
        Callback = function(Value)
            HidingSpotTranslucent = Value or 0.5
        end
    }
)

NoCutscenesToggle:OnChanged(
    function(value)
        if MainGame then
            local cutscenes = MainGame:FindFirstChild("Cutscenes", true)
            if cutscenes then
                for _, cutscene in pairs(cutscenes:GetChildren()) do
                    if table.find(CutsceneExclude, cutscene.Name) then
                        local defaultName = cutscene.Name:gsub("_", "")
                        cutscene.Name = if value then "_" .. defaultName else defaultName
                    end
                end
            end
        end

        if FloorReplicated then
            for _, cutscene in pairs(FloorReplicated:GetChildren()) do
                if cutscene:IsA("ModuleScript") or table.find(CutsceneExclude, cutscene.Name) then
                    local defaultName = cutscene.Name:gsub("_", "")
                    cutscene.Name = if value then "_" .. defaultName else defaultName
                end
            end
        end
    end
)

TranslucentHidingSpotToggle:OnChanged(function(value)
        if value and char:GetAttribute("Hiding") then
            for _, obj in pairs(workspace.CurrentRooms:GetDescendants()) do
                if not obj:IsA("ObjectValue") and obj.Name ~= "HiddenPlayer" then continue end
 
                    if obj.Value == char then
                        task.spawn(function()
                                local affectedParts = {}
                                for _, v in pairs(obj.Parent:GetChildren()) do
                                    if not v:IsA("BasePart") then continue end

                                    v.Transparency = HidingSpotTranslucent
                                    table.insert(affectedParts, v)
                                end

                                repeat task.wait()
                                    for _, part in pairs(affectedParts) do
                                        task.wait()
                                        part.Transparency = HidingSpotTranslucent
                                    end
                                until not char:GetAttribute("Hiding") or not TranslucentHidingSpotToggle.Value

                                for _, v in pairs(affectedParts) do
                                    v.Transparency = 0
                                end
                        end)

                    break
                end
            end
        end
end)

-- Effect
local NoSurgeVignetteToggle =
    VisualEffectTab:AddToggle("NoSurgeVignetteToggle", {Text = "No Surge Effect", Default = false, Visible = IsOutdoor})
local NoGlitchEffectToggle =
    VisualEffectTab:AddToggle("NoGlitchEffectToggle", {Text = "No Glitch Effect", Default = false})
local NoVoidEffectToggle = VisualEffectTab:AddToggle("NoVoidEffectToggle", {Text = "No Void Effect", Default = false})
local NoJumpscareToggle = VisualEffectTab:AddToggle("NoJumpscareToggle", {Text = "No Jumpscare", Default = false})
local NoSpiderJumpscareToggle =
    VisualEffectTab:AddToggle("NoSpiderJumpscareToggle", {Text = "No Spider Jumpscare", Default = false})

NoSurgeVignetteToggle:OnChanged(
    function(value)
        task.spawn(
            function()
                while value do
                    pcall(
                        function()
                            local mainFrame =
                                player:WaitForChild("PlayerGui"):WaitForChild("MainUi"):WaitForChild("MainFrame")
                            local surgeFolder =
                                mainFrame:FindFirstChild("SurgeVignette") or
                                mainFrame:FindFirstChild("SurgeVignetteLive")

                            if surgeFolder and surgeFolder:IsA("GuiObject") then
                                surgeFolder.Visible = false
                            end
                        end
                    )
                    task.wait(0.1)
                end
            end
        )
    end
)

NoGlitchEffectToggle:OnChanged(
    function(value)
        task.spawn(
            function()
                while value do
                    pcall(
                        function()
                            AntiEntityListChosen("Void", Value)
                        end
                    )
                    task.wait()
                end
            end
        )
    end
)

NoVoidEffectToggle:OnChanged(
    function(value)
        task.spawn(
            function()
                while value do
                    pcall(
                        function()
                            AntiEntityListChosen("Void", Value)
                        end
                    )
                    task.wait()
                end
            end
        )
    end
)

NoJumpscareToggle:OnChanged(
    function(value)
        task.spawn(
            function()
                while value do
                    pcall(
                        function()
                            AntiEntityListChosen("Jumpscares", Value)
                        end
                    )
                    task.wait()
                end
            end
        )
    end
)

NoSpiderJumpscareToggle:OnChanged(
    function(value)
        task.spawn(
            function()
                while value do
                    pcall(
                        function()
                            AntiEntityListChosen("SpiderJumpscare", Value)
                        end
                    )
                    task.wait()
                end
            end
        )
    end
)

-- Floor
function TimerFormat(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return string.format("%02d:%02d", minutes, remainingSeconds)
end

if IsMines then
    local MinesFloorLeftGroupbox = FloorTab:AddLeftGroupbox("Movement")
    local MaxFloorAngleSlider =
        MinesFloorLeftGroupbox:AddSlider(
        "MaxFloorAngleSlider",
        {Text = "Max Floor Angle", Default = 45, Min = 0, Max = 90, Rounding = 0}
    )

    local MinesFloorLeft2Groupbox = FloorTab:AddLeftGroupbox("Anti Entity")
    local AntiGiggleToggle =
        MinesFloorLeft2Groupbox:AddToggle("AntiGiggleToggle", {Text = "Anti Giggle", Default = false})
    local AntiGloomEggToggle =
        MinesFloorLeft2Groupbox:AddToggle("AntiGloomEggToggle", {Text = "Anti Gloom Egg", Default = false})
    local AntiFiredampToggle =
        MinesFloorLeft2Groupbox:AddToggle("AntiFiredampToggle", {Text = "Anti Firedamp", Default = false})
    local AntiSeekFloodToggle =
        MinesFloorLeft2Groupbox:AddToggle("AntiSeekFloodToggle", {Text = "Anti Seek Flooding", Default = false})

    local MinesFloorLeft3Groupbox = FloorTab:AddLeftGroupbox("Modifiers")
    local NoVoiceActingToggle =
        MinesFloorLeft3Groupbox:AddToggle("NoVoiceActingToggle", {Text = "No Voice Acting", Default = false})
    local AntiA90Toggle = MinesFloorLeft3Groupbox:AddToggle("AntiA90Toggle", {Text = "Anti A-90", Default = false})
    local NoJamminToggle = MinesFloorLeft3Groupbox:AddToggle("NoJamminToggle", {Text = "No Jammin", Default = false})

    local MinesFloorRightGroupbox = FloorTab:AddRightGroupbox("Bypass")
    local AutoBeatDoor200Toggle =
        MinesFloorRightGroupbox:AddToggle("AutoBeatDoor200Toggle", {Text = "Auto Beat Door 200", Default = false})

    MaxFloorAngleSlider:OnChanged(
        function(value)
            if hum then
                hum.MaxSlopeAngle = value
            end
        end
    )

    AutoBeatDoor200Toggle:OnChanged(
        function(Value)
            if (LatestRoom.Value or 0) < 99 then
                Notify("Complete Door 200", "You haven't reached door 200...", 5)
                return
            end
            local bypassing = EnableSpeedBypassToggle.Value
            local startPos = hrp.CFrame
            EnableSpeedBypassToggle:SetValue(false)

            local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(LatestRoom.Value))
            if currentRoom then
                local damHandler = currentRoom:FindFirstChild("_DamHandler")
                if damHandler then
                    local function handleFlood(floodName, delayTime)
                        local flood = damHandler:FindFirstChild(floodName)
                        if flood and flood:FindFirstChild("Pumps") then
                            for _, pump in ipairs(flood.Pumps:GetChildren()) do
                                if pump:FindFirstChild("Wheel") and pump.Wheel:FindFirstChild("ValvePrompt") then
                                    char:PivotTo(pump.Wheel.CFrame)
                                    task.wait(0.25)
                                    forcefireproximityprompt(pump.Wheel.ValvePrompt)
                                    task.wait(0.25)
                                end
                            end
                            task.wait(delayTime or 8)
                        end
                    end

                    handleFlood("Flood1", 8)
                    handleFlood("Flood2", 8)
                    handleFlood("Flood3", 10)
                end
            end

            local generator = workspace.CurrentRooms:FindFirstChild(tostring(LatestRoom.Value), true)
            if generator then
                generator = generator:FindFirstChild("MinesGenerator", true)
                if generator and generator:FindFirstChild("Lever") and generator.Lever:FindFirstChild("LeverPrompt") then
                    if generator.PrimaryPart then
                        char:PivotTo(generator.PrimaryPart.CFrame)
                    end
                    task.wait(0.25)
                    forcefireproximityprompt(generator.Lever.LeverPrompt)
                    task.wait(0.25)
                end
            end
            EnableSpeedBypassToggle:SetValue(bypassing)
            if startPos then
                char:PivotTo(startPos)
            end
        end
    )

    AntiSeekFloodToggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                AntiEntityToggle("Seek Flood", value)
                            end
                        )
                        task.wait()
                    end
                end
            )
        end
    )

    AntiFiredampToggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                AntiEntityToggle("Firedamp", value)
                            end
                        )
                        task.wait()
                    end
                end
            )
        end
    )

    NoVoiceActingToggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                local voiceActing = ReplicatedStorage:FindFirstChild("VoiceActing")
                                if not voiceActing then
                                    return
                                end

                                local voicelines =
                                    voiceActing:FindFirstChild("Voicelines") or
                                    voiceActing:FindFirstChild("_Voicelines")
                                if voicelines then
                                    voicelines.Name = if value then "_Voicelines" else "Voicelines"
                                end
                            end
                        )
                        task.wait()
                    end
                end
            )
        end
    )

    AntiA90Toggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                AntiEntityToggle("A-90", value)
                            end
                        )
                        task.wait()
                    end
                end
            )
        end
    )

    NoJamminToggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                if not LiveModifiers:FindFirstChild("Jammin") then
                                    return
                                end

                                if MainGame then
                                    local jamSound = MainGame:FindFirstChild("Jam", true)
                                    if jamSound then
                                        jamSound.Playing = not Value
                                    end
                                end

                                local jamminEffect = game.SoundService:FindFirstChild("Jamming", true)
                                if jamminEffect then
                                    jamminEffect.Enabled = not value
                                end
                            end
                        )
                        task.wait()
                    end
                end
            )
        end
    )
elseif IsBackdoor then
    local BackdoorFloorLeftGroupbox = FloorTab:AddLeftGroupbox("Anti Entity")
    local AntiHasteJumpToggle =
        BackdoorFloorLeftGroupbox:AddToggle("AntiHasteJumpToggle", {Text = "Anti Haste Jumpscare", Default = false})

    local BackdoorFloorRightGroupbox = FloorTab:AddRightGroupbox("Visual")
    local HasteClockToggle =
        BackdoorFloorRightGroupbox:AddToggle("HasteClockToggle", {Text = "Haste Clock", Default = false})

    AntiHasteJumpToggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                local clientRemote =
                                    ReplicatedStorage:WaitForChild("FloorReplicated"):WaitForChild("ClientRemote")
                                local hasteFolder = clientRemote:FindFirstChild("Haste")
                                if not hasteFolder then
                                    return
                                end

                                local storage = clientRemote:FindFirstChild("_EntityCantEscape")
                                if not storage then
                                    storage = Instance.new("Folder")
                                    storage.Name = "_EntityCantEscape"
                                    storage.Parent = clientRemote
                                end

                                for _, obj in ipairs(hasteFolder:GetChildren()) do
                                    if not obj:IsA("RemoteEvent") then
                                        obj.Parent = storage
                                    end
                                end
                            end
                        )
                        task.wait()
                    end

                    pcall(
                        function()
                            local clientRemote =
                                ReplicatedStorage:WaitForChild("FloorReplicated"):WaitForChild("ClientRemote")
                            local hasteFolder = clientRemote:FindFirstChild("Haste")
                            local storage = clientRemote:FindFirstChild("_EntityCantEscape")

                            if storage and hasteFolder then
                                for _, obj in ipairs(storage:GetChildren()) do
                                    obj.Parent = hasteFolder
                                end
                            end
                        end
                    )
                end
            )
        end
    )

    HasteClockToggle:OnChanged(
        function(value)
            if not value then
                HideCaptions()
            end
        end
    )

    if FloorReplicated:FindFirstChild("DigitalTimer") then
        FloorReplicated.DigitalTimer:GetPropertyChangedSignal("Value"):Connect(
            function()
                if HasteClockToggle.Value and FloorReplicated.ScaryStartsNow.Value then
                    Captions(TimerFormat(FloorReplicated.DigitalTimer.Value))
                end
            end
        )
    end

    AntiGiggleToggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                AntiEntityToggle("Giggle", value)
                            end
                        )
                        task.wait()
                    end
                end
            )
        end
    )

    AntiGloomEggToggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                AntiEntityToggle("Gloom Egg", value)
                            end
                        )
                        task.wait()
                    end
                end
            )
        end
    )
elseif IsHotel then
    local HotelFloorLeftGroupbox = FloorTab:AddLeftGroupbox("Anti Obstruction")
    local AntiSeekObstructionToggle =
        HotelFloorLeftGroupbox:AddToggle("AntiSeekObstructionToggle", {Text = "Anti Seek Obstruction", Default = false})

    local HotelFloorRightGroupbox = FloorTab:AddRightGroupbox("Modifiers")
    local NoVoiceActingToggle =
        HotelFloorRightGroupbox:AddToggle("NoVoiceActingToggle", {Text = "No Voice Acting", Default = false})
    local AntiA90Toggle = HotelFloorRightGroupbox:AddToggle("AntiA90Toggle", {Text = "Anti A-90", Default = false})
    local NoJamminToggle = HotelFloorRightGroupbox:AddToggle("NoJamminToggle", {Text = "No Jammin", Default = false})
    local AntiGiggleToggle =
        HotelFloorRightGroupbox:AddToggle("AntiGiggleToggle", {Text = "Anti Giggle", Default = false})
    local AntiGloomEggToggle =
        HotelFloorRightGroupbox:AddToggle("AntiGloomEggToggle", {Text = "Anti Gloom Egg", Default = false})
    local AntiHasteJumpToggle =
        HotelFloorRightGroupbox:AddToggle("AntiHasteJumpToggle", {Text = "Anti Haste Jumpscare", Default = false})
    local HasteClockToggle =
        HotelFloorRightGroupbox:AddToggle("HasteClockToggle", {Text = "Haste Clock", Default = false})

    AntiSeekObstructionToggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                AntiEntityToggle("Seek Obstruction", value)
                            end
                        )
                        task.wait()
                    end
                end
            )
        end
    )

    NoVoiceActingToggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                local voiceActing = ReplicatedStorage:FindFirstChild("VoiceActing")
                                if not voiceActing then
                                    return
                                end

                                local voicelines =
                                    voiceActing:FindFirstChild("Voicelines") or
                                    voiceActing:FindFirstChild("_Voicelines")
                                if voicelines then
                                    voicelines.Name = if value then "_Voicelines" else "Voicelines"
                                end
                            end
                        )
                        task.wait()
                    end
                end
            )
        end
    )

    AntiA90Toggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                AntiEntityToggle("A-90", value)
                            end
                        )
                        task.wait()
                    end
                end
            )
        end
    )

    NoJamminToggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                if not LiveModifiers:FindFirstChild("Jammin") then
                                    return
                                end

                                if MainGame then
                                    local jamSound = MainGame:FindFirstChild("Jam", true)
                                    if jamSound then
                                        jamSound.Playing = not Value
                                    end
                                end

                                local jamminEffect = game.SoundService:FindFirstChild("Jamming", true)
                                if jamminEffect then
                                    jamminEffect.Enabled = not value
                                end
                            end
                        )
                        task.wait()
                    end
                end
            )
        end
    )

    AntiHasteJumpToggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                local clientRemote =
                                    ReplicatedStorage:WaitForChild("FloorReplicated"):WaitForChild("ClientRemote")
                                local hasteFolder = clientRemote:FindFirstChild("Haste")
                                if not hasteFolder then
                                    return
                                end

                                local storage = clientRemote:FindFirstChild("_EntityCantEscape")
                                if not storage then
                                    storage = Instance.new("Folder")
                                    storage.Name = "_EntityCantEscape"
                                    storage.Parent = clientRemote
                                end

                                for _, obj in ipairs(hasteFolder:GetChildren()) do
                                    if not obj:IsA("RemoteEvent") then
                                        obj.Parent = storage
                                    end
                                end
                            end
                        )
                        task.wait()
                    end

                    pcall(
                        function()
                            local clientRemote =
                                ReplicatedStorage:WaitForChild("FloorReplicated"):WaitForChild("ClientRemote")
                            local hasteFolder = clientRemote:FindFirstChild("Haste")
                            local storage = clientRemote:FindFirstChild("_EntityCantEscape")

                            if storage and hasteFolder then
                                for _, obj in ipairs(storage:GetChildren()) do
                                    obj.Parent = hasteFolder
                                end
                            end
                        end
                    )
                end
            )
        end
    )

    HasteClockToggle:OnChanged(
        function(value)
            if not value then
                HideCaptions()
            end
        end
    )

    if FloorReplicated:FindFirstChild("DigitalTimer") then
        FloorReplicated.DigitalTimer:GetPropertyChangedSignal("Value"):Connect(
            function()
                if HasteClockToggle.Value and FloorReplicated.ScaryStartsNow.Value then
                    Captions(TimerFormat(FloorReplicated.DigitalTimer.Value))
                end
            end
        )
    end

    AntiGiggleToggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                AntiEntityToggle("Giggle", value)
                            end
                        )
                        task.wait()
                    end
                end
            )
        end
    )

    AntiGloomEggToggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                AntiEntityToggle("Gloom Egg", value)
                            end
                        )
                        task.wait()
                    end
                end
            )
        end
    )
elseif IsRooms then
    local RoomsFloorLeftGroupbox = FloorTab:AddLeftGroupbox("Anti Entity")
    local AntiA90Toggle = RoomsFloorLeftGroupbox:AddToggle("AntiA90Toggle", {Text = "Anti A-90", Default = false})

    local RoomsFloorRightGroupbox = FloorTab:AddRightGroupbox("Automation")
    local AutoRoomsToggle = RoomsFloorRightGroupbox:AddToggle("AutoRoomsToggle", {Text = "Auto Rooms", Default = false})
    RoomsFloorRightGroupbox:AddDivider()
    local ShowDebugInfoRoomsToggle =
        RoomsFloorRightGroupbox:AddToggle("ShowDebugInfoRoomsToggle", {Text = "Show Debug Info", Default = false})
    local ShowPathNodeRoomsToggle =
        RoomsFloorRightGroupbox:AddToggle("ShowPathNodeRoomsToggle", {Text = "Show Pathfinding Nodes", Default = false})

    AntiA90Toggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                AntiEntityToggle("A-90", value)
                            end
                        )
                        task.wait()
                    end
                end
            )
        end
    )

    function GetAutoRoomsPathfindingGoal()
        local entity = workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120")
        local isEntitySpawned = (entity and entity.PrimaryPart and entity.PrimaryPart.Position.Y > -10)

        if isEntitySpawned then
            local GoalLocker =
                GetNearestAssetWithCondition(
                function(asset)
                    return asset.Name == "Rooms_Locker" and asset:FindFirstChild("HiddenPlayer") and
                        not asset.HiddenPlayer.Value and
                        asset.PrimaryPart and
                        asset.PrimaryPart.Position.Y > -10
                end
            )

            if GoalLocker and GoalLocker.PrimaryPart then
                return GoalLocker.PrimaryPart
            end
        end

        return workspace.CurrentRooms[LatestRoom.Value].RoomExit
    end

    -- Folder chứa node và block
    local nodesFolder = Instance.new("Folder", workspace)
    nodesFolder.Name = "_minthub_pathfinding_nodepart"

    local blockFolder = Instance.new("Folder", workspace)
    blockFolder.Name = "_minthub_pathfinding_blockpart"

    -- Danh sách waypoint bị kẹt (blacklist)
    local BlockedWaypointList = {}

    -- Cleanup function
    local function cleanupNodes()
        nodesFolder:ClearAllChildren()
        blockFolder:ClearAllChildren()
        BlockedWaypointList = {} -- reset blacklist khi off
    end

    -- Convert Vector3 -> key string
    local function vecToKey(vec)
        return string.format("%d_%d_%d", math.floor(vec.X), math.floor(vec.Y), math.floor(vec.Z))
    end

    RunService.RenderStepped:Connect(
        function()
            if not AutoRoomsToggle.Value then
                return
            end

            local entity = workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120")
            local isEntitySpawned = (entity and entity.PrimaryPart and entity.PrimaryPart.Position.Y > -10)

            if not hrp then
                return
            end

            if isEntitySpawned and not hrp.Anchored then
                local goal = GetAutoRoomsPathfindingGoal()
                if goal and goal.Parent:FindFirstChild("HidePrompt") and IsPromptInRange(goal.Parent.HidePrompt) then
                    forcefireproximityprompt(goal.Parent.HidePrompt)
                end
            elseif not isEntitySpawned and hrp.Anchored then
                for _ = 1, 10 do
                    RemotesFolder.CamLock:FireServer()
                end
            end
        end
    )

    ShowPathNodeRoomsToggle:OnChanged(
        function(Value)
            task.spawn(
                function()
                    while Value do
                        pcall(
                            function()
                                for _, node in ipairs(nodesFolder:GetChildren()) do
                                    node.Transparency = Value and 0.5 or 1
                                end
                                for _, block in ipairs(blockFolder:GetChildren()) do
                                    block.Transparency = Value and 0.9 or 1
                                end
                            end
                        )
                        task.wait()
                    end
                end
            )
        end
    )

    -- AutoRooms
    AutoRoomsToggle:OnChanged(
        function(enabled)
            if not enabled then
                cleanupNodes()
                return
            end

            AntiA90Toggle:SetValue(true)
            if ShowDebugInfoRoomsToggle.Value then
                Notify("Auto Rooms", "Automatically enabled anti a-90")
            end
            local lastRoom = 0
            local lastWaypoints = {}
            local recalculating = false

            local function moveToCleanup()
                if hum and hrp then
                    hum:MoveTo(hrp.Position)
                    hum.WalkToPart = nil
                    hum.WalkToPoint = hrp.Position
                end
                cleanupNodes()
            end

            local function createBlockedPoint(waypoint)
                -- thêm vào blacklist
                local key = vecToKey(waypoint.Position)
                BlockedWaypointList[key] = true

                -- spawn part để debug
                local block = Instance.new("Part", blockFolder)
                block.Name = "_minthub_blocked_path"
                block.Shape = Enum.PartType.Block
                block.Anchored = true
                block.CanCollide = false
                block.Material = Enum.Material.Neon
                block.Color = Color3.fromRGB(255, 130, 30)

                local sizeY = 10
                block.Size = Vector3.new(1, sizeY, 1)
                block.Position = waypoint.Position + Vector3.new(0, sizeY / 2, 0)

                local pathMod = Instance.new("PathfindingModifier", block)
                pathMod.Label = "_minthub_pathBlock"

                block.Transparency = ShowPathNodeRoomsToggle.Value and 0.9 or 1
            end

            local function doPath()
                if recalculating then
                    return
                end
                local goal = GetAutoRoomsPathfindingGoal()
                if not goal then
                    return
                end

                -- reset block khi qua phòng mới
                if LatestRoom.Value ~= lastRoom then
                    blockFolder:ClearAllChildren()
                    BlockedWaypointList = {} -- reset khi sang phòng mới
                    lastRoom = LatestRoom.Value
                end

                if ShowDebugInfoRoomsToggle.Value then
                    Notify("Auto Rooms", "Calculating path to " .. tostring(goal.Parent.Name) .. "...")
                end

                if not (hum and hrp) then
                    return
                end

                local path =
                    PathfindingService:CreatePath(
                    {
                        AgentCanJump = false,
                        AgentCanClimb = false,
                        WaypointSpacing = 2,
                        AgentRadius = 1,
                        Costs = {_minthub_pathBlock = 8}
                    }
                )

                path:ComputeAsync(hrp.Position - Vector3.new(0, 2.5, 0), goal.Position)
                if path.Status ~= Enum.PathStatus.Success then
                    if ShowDebugInfoRoomsToggle.Value then
                        Notify("Auto Rooms", "Path failed: " .. tostring(path.Status))
                    end
                    return
                end

                local waypoints = path:GetWaypoints()

                -- tránh spam node nếu waypoint không đổi
                local hash = tostring(waypoints[1] and waypoints[1].Position or "")
                if lastWaypoints[1] == hash then
                    return
                end
                lastWaypoints[1] = hash

                cleanupNodes()

                -- spawn node để debug
                for i, wp in ipairs(waypoints) do
                    local node = Instance.new("Part", nodesFolder)
                    node.Name = "_node_" .. i
                    node.Size = Vector3.new(1, 1, 1)
                    node.Position = wp.Position
                    node.Anchored = true
                    node.CanCollide = false
                    node.Shape = Enum.PartType.Ball
                    node.Color = Color3.new(1, 0, 0)
                    node.Transparency = ShowPathNodeRoomsToggle.Value and 0.5 or 1
                end

                -- di chuyển theo path
                task.spawn(
                    function()
                        for i, wp in ipairs(waypoints) do
                            if not enabled then
                                return moveToCleanup()
                            end

                            local done = false
                            local conn
                            conn =
                                hum.MoveToFinished:Connect(
                                function()
                                    done = true
                                    conn:Disconnect()
                                    if ShowDebugInfoRoomsToggle.Value then
                                        Notify("Auto Rooms", "Completed a waypoint.")
                                        Notify("Auto Rooms", "Completed door " .. LatestRoom.Value .. ".")
                                    end
                                end
                            )

                            hum:MoveTo(wp.Position)

                            task.delay(
                                1.5,
                                function()
                                    if not done and enabled and not recalculating then
                                        if ShowDebugInfoRoomsToggle.Value then
                                            Notify("Auto Rooms", "Stuck at waypoint, recalculating...")
                                        end
                                        recalculating = true
                                        createBlockedPoint(wp)
                                        task.delay(
                                            0.5,
                                            function()
                                                recalculating = false
                                            end
                                        )
                                        doPath()
                                    end
                                end
                            )

                            repeat
                                task.wait()
                            until done or not enabled
                            local n = nodesFolder:FindFirstChild("_node_" .. i)
                            if n then
                                n:Destroy()
                            end
                        end
                    end
                )
            end

            -- Main loop
            task.spawn(
                function()
                    while enabled do
                        if LatestRoom.Value >= 1000 then
                            if ShowDebugInfoRoomsToggle.Value then
                                Notify("Auto Rooms", "You reached A-1000")
                            end
                            break
                        end
                        doPath()
                        task.wait(0.5)
                    end
                    moveToCleanup()
                end
            )
        end
    )
elseif IsOutdoor then
    local GardenFloorLeftGroupbox = FloorTab:AddLeftGroupbox("Anti Entity")
    local AntiSurgeToggle = GardenFloorLeftGroupbox:AddToggle("AntiSurgeToggle", {Text = "Anti Surge", Default = false})
    local LookAtMonumentToggle =
        GardenFloorLeftGroupbox:AddToggle("LookAtMonumentToggle", {Text = "Look At Monument", Default = false})
    local AutoMandrakeToggle =
        GardenFloorLeftGroupbox:AddToggle("AutoMandrakeToggle", {Text = "Auto Mandrake", Default = false})

    AntiSurgeToggle:OnChanged(
        function(value)
            task.spawn(
                function()
                    while value do
                        pcall(
                            function()
                                local SurgeCheck = require(ReplicatedStorage.ModulesShared.SurgeCheck)
                                local oldIsCharacterSheltered = SurgeCheck.IsCharacterSheltered
                                local oldGetUncoveredPosition = SurgeCheck.GetUncoveredPosition

                                SurgeCheck.IsCharacterSheltered = function(player)
                                    return true, nil
                                end
                            end
                        )
                        task.wait()
                    end
                end
            )
        end
    )

    local oldIndex
    local targets = {}
    local current = 1

    task.spawn(
        function()
            while true do
                targets = {}
                for _, v in ipairs(workspace:GetChildren()) do
                    if v:IsA("Model") and v.PrimaryPart and v.Name:match("Monument") then
                        table.insert(targets, v)
                    end
                end
                task.wait(1)
            end
        end
    )

    oldIndex =
        hookmetamethod(
        game,
        "__index",
        function(self, key)
            if key == "LookVector" and self == workspace.CurrentCamera then
                if #targets > 0 and LookAtMonumentToggle.Value then
                    if current > #targets then
                        current = 1
                    end
                    local monster = targets[current]
                    current = current + 1

                    return (monster.PrimaryPart.Position - self.CFrame.Position).Unit
                end
            end
            return oldIndex(self, key)
        end
    )

    local pickedMandrakes = {}
    local placedMandrakes = {}

    local function findMandrakes()
        local list = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.CollisionGroup == "Entity" and not pickedMandrakes[obj] then
                for _, prompt in pairs(obj:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        table.insert(list, {part = obj, prompt = prompt})
                    end
                end
            end
            if obj:IsA("ProximityPrompt") and obj.Parent and string.find(obj.Parent.Name:lower(), "mandrake") then
                if obj.Parent:GetAttribute("MandrakeLive") and not placedMandrakes[obj] then
                    table.insert(list, {part = obj.Parent, prompt = obj})
                end
            end
        end
        return list
    end

    local function findNearestHole(pos)
        local nearest, dist
        for _, prompt in pairs(workspace:GetDescendants()) do
            if
                prompt:IsA("ProximityPrompt") and prompt.Parent and
                    (string.find(prompt.Parent.Name:lower(), "mandrake") or
                        string.find(prompt.Parent.Name:lower(), "hole"))
             then
                local root =
                    prompt.Parent:FindFirstChild("HumanoidRootPart") or prompt.Parent:FindFirstChildWhichIsA("BasePart") or
                    prompt.Parent
                local d = (pos - root.Position).Magnitude
                if not dist or d < dist then
                    nearest, dist = prompt, d
                end
            end
        end
        return nearest
    end

    local function pickAndPlace(prompt)
        if not prompt.part or not prompt.prompt then
            return
        end

        prompt.prompt.MaxActivationDistance = math.huge
        prompt.prompt.RequiresLineOfSight = false

        if not pickedMandrakes[prompt.part] then
            pickedMandrakes[prompt.part] = true
            fireproximityprompt(prompt.prompt)
        end

        local holePrompt = findNearestHole(prompt.part.Position)
        if holePrompt and not placedMandrakes[holePrompt] then
            placedMandrakes[holePrompt] = true
            fireproximityprompt(holePrompt)
        end
    end

    spawn(
        function()
            while true do
                if AutoMandrakeToggle.Value then
                    local mandrakes = findMandrakes()
                    for _, prompt in pairs(mandrakes) do
                        pickAndPlace(prompt)
                    end
                    task.wait(0.05)
                else
                    task.wait(0.2)
                end
            end
        end
    )

    AutoMandrakeToggle:OnChanged(
        function(value)
            if not value then
                pickedMandrakes = {}
                placedMandrakes = {}
            end
        end
    )
end

function ESP(args)
    if not args.Object then
        return warn("ESP Object is nil")
    end

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
            TextSize = TextSizeChangerEspSlider.Value or 16,
            FillTransparency = FillTransparencyEspSlider.Value,
            OutlineTransparency = OutlineTransparencyEspSlider.Value,
            Tracer = {
                Enabled = true,
                From = TracerStartPositionDropdown.Value,
                Color = ESPManager.Color
            },
            Arrow = {
                Enabled = true,
                CenterOffset = ArrowCenterOffsetSlider.Value,
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

function RandomString()
    local chars, len, arr = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", math.random(10, 20), {}
    for i = 1, len do
        arr[i] = chars:sub(math.random(#chars), math.random(#chars))
    end
    return table.concat(arr)
end

function GetShortName(name)
    if EntityTable.ShortNames[name] then
        return EntityTable.ShortNames[name]
    end
    for suf, fix in pairs(SuffixPrefixes) do
        name = name:gsub(suf, fix)
    end
    return name
end

function DoorESP(room)
    if not room then
        return
    end

    local door = room:FindFirstChild("Door")
    local doorGate =
        room:FindFirstChild("Assets") and room.Assets:FindFirstChild("GateSetup") and
        room.Assets.GateSetup:FindFirstChild("GardenGate")

    local doorPart = door and door:FindFirstChild("Door")
    if not doorPart then
        return
    end

    local doorNumber = tonumber(room.Name) or 0
    if IsMines then
        doorNumber += 100
    end
    doorNumber += 1

    local opened = door:GetAttribute("Opened")
    local locked = room:GetAttribute("RequiresKey")
    local doorState = opened and "[Opened]" or (locked and "[Locked]" or "")

    local idx = RandomString()
    local doorEsp =
        ESP(
        {
            Type = "Door",
            Object = doorPart,
            Text = string.format("Door %s %s", doorNumber, doorState),
            Color = GetEspColor("Door"),
            OnDestroy = function()
                if FeatureConnections.Door[idx] then
                    FeatureConnections.Door[idx]:Disconnect()
                end
            end
        }
    )

    FeatureConnections.Door[idx] =
        door:GetAttributeChangedSignal("Opened"):Connect(
        function()
            if doorEsp then
                doorEsp:SetText(string.format("Door %s [Opened]", doorNumber))
            end
            if FeatureConnections.Door[idx] then
                FeatureConnections.Door[idx]:Disconnect()
            end
        end
    )

    if doorGate then
        local doorGateEsp =
            ESP(
            {
                Type = "Door",
                Object = doorGate,
                Text = "Garden Gate",
                Color = GetEspColor("Door"),
                IsDoubleDoor = true,
                OnDestroy = function()
                    if FeatureConnections.DoorGate[idx] then
                        FeatureConnections.DoorGate[idx]:Disconnect()
                    end
                end
            }
        )
    end
end

function ObjectiveESP(child)
    local color = GetEspColor("Objective")
    local objText = child.Name

    if child.Name == "TimerLever" then
        local takeTimer = child:FindFirstChild("TakeTimer")
        local label = takeTimer and takeTimer:FindFirstChild("TextLabel")
        objText = label and string.format("Timer Lever [+%s]", label.Text) or "Timer Lever"
    elseif child.Name == "KeyObtain" then
        objText = "Key"
    elseif child.Name == "IronKeyForCrypt" then
        objText = "Iron Key"
    elseif child.Name == "ElectricalKeyObtain" then
        objText = "Electrical Key"
    elseif child.Name == "LeverForGate" then
        objText = "Gate Lever"
    elseif child.Name == "LiveHintBook" then
        objText = "Book"
    elseif child.Name == "LiveBreakerPolePickup" then
        objText = "Breaker"
    elseif child.Name == "MinesGenerator" then
        objText = "Generator"
    elseif child.Name == "MinesGateButton" then
        objText = "Gate Power Button"
    elseif child.Name == "GardenGateButton" then
        objText = "Garden Gate Button"
    elseif child.Name == "FuseObtain" then
        objText = "Fuse"
    elseif child.Name == "MinesAnchor" then
        local sign = child:FindFirstChild("Sign")
        local label = sign and sign:FindFirstChild("TextLabel")
        objText = label and string.format("Anchor %s", label.Text) or "Anchor"
    elseif child.Name == "WaterPump" then
        local wheel = child:FindFirstChild("Wheel")
        local onFrame = child:FindFirstChild("OnFrame", true)
        if wheel and onFrame then
            local idx = tostring(child)
            local pumpEsp =
                ESP(
                {
                    Type = "Objective",
                    Object = wheel,
                    Text = "Water Pump",
                    Color = color,
                    OnDestroy = function()
                        if FeatureConnections.Pump[idx] then
                            FeatureConnections.Pump[idx]:Disconnect()
                        end
                    end
                }
            )
            FeatureConnections.Pump[idx] =
                onFrame:GetPropertyChangedSignal("Visible"):Connect(
                function()
                    if not onFrame.Visible then
                        pumpEsp.Destroy()
                    end
                end
            )
        end
    else
        return false
    end

    if child.Name ~= "WaterPump" then
        ESP({Type = "Objective", Object = child, Text = objText, Color = color})
    end
    return true
end

function EntityESP(entity)
    if not entity then
        return
    end
    local shortName = GetShortName(entity.Name) or entity.Name

    local espObj =
        ESP(
        {
            Type = "Entity",
            Object = entity,
            Text = shortName,
            Color = GetEspColor("Entity"),
            IsEntity = entity.Name ~= "JeffTheKiller"
        }
    )
end

function SideEntityESP(entity)
    if not entity then
        return
    end
    if entity.Name == "Snare" and not entity:FindFirstChild("Hitbox") then
        return
    end

    local shortName = GetShortName(entity.Name) or entity.Name
    local textParent = entity.PrimaryPart or entity:FindFirstChildWhichIsA("BasePart")

    local espObj =
        ESP(
        {
            Type = "SideEntity",
            Object = entity,
            Text = shortName,
            TextParent = textParent,
            Color = GetEspColor("Entity")
        }
    )
end

function ItemESP(item, dropped)
    ESP(
        {
            Type = dropped and "DroppedItem" or "Item",
            Object = item,
            Text = GetShortName(item.Name) or item.Name,
            Color = GetEspColor("Item")
        }
    )
end

function ChestESP(chest)
    local text =
        chest.Name:gsub("Box", ""):gsub("_Vine", " Vine"):gsub("_Small", ""):gsub("Locked", ""):gsub("%s+", " ")
    local locked = chest:GetAttribute("Locked")
    local state = locked and "[Locked]" or ""
    ESP(
        {
            Type = "Chest",
            Object = chest,
            Text = string.format("%s %s", text, state),
            Color = GetEspColor("Chest")
        }
    )
end

function PlayerESP(character)
    if not (character and character.PrimaryPart and character:FindFirstChild("Humanoid")) then
        return
    end
    local humanoid = character.Humanoid
    if humanoid.Health <= 0 then
        return
    end

    local espObj =
        ESP(
        {
            Type = "Player",
            Object = character,
            Text = string.format("%s [%.1f]", character.Name, humanoid.Health),
            TextParent = character.PrimaryPart,
            Color = GetEspColor("Player")
        }
    )

    FeatureConnections.Player[character.Name] =
        humanoid.HealthChanged:Connect(
        function(hp)
            if hp > 0 then
                espObj:SetText(string.format("%s [%.1f]", character.Name, hp))
            else
                if FeatureConnections.Player[character.Name] then
                    FeatureConnections.Player[character.Name]:Disconnect()
                end
                espObj:Destroy()
            end
        end
    )
end

function HidingSpotESP(spot)
    local text = (spot:GetAttribute("LoadModule") == "Bed") and "Bed" or (HidingPlaceName[Floor.Value] or spot.Name)
    ESP(
        {
            Type = "HidingSpot",
            Object = spot,
            Text = text,
            Color = GetEspColor("Hiding Spot")
        }
    )
end

function GoldESP(gold)
    local value = gold:GetAttribute("GoldValue") or "?"
    ESP(
        {
            Type = "Gold",
            Object = gold,
            Text = string.format("Gold [%s]", value),
            Color = GetEspColor("Gold")
        }
    )
end

function NotifyGlitch()
    if
        NotifyEntityDropdown.Value["Void/Glitch"] and LatestRoom.Value > CurrentRoom + VoidThresholdValues[Floor.Value] and
            Alive and
            not table.find(Temp.VoidGlitchNotifiedRooms, CurrentRoom)
     then
        table.insert(Temp.VoidGlitchNotifiedRooms, CurrentRoom)

        local message = "Void/Glitch is coming once the next door is opened."

        if IsRooms then
            local roomsLeft = (6 - (LatestRoom.Value - CurrentRoom))
            message =
                "Void/Glitch is coming " ..
                (roomsLeft == 0 and "once the next door is opened." or "in " .. roomsLeft .. " rooms") .. "."
        end

        Notify("Entities", message)
    end
end

function CalculateHideTime(room)
    for _, range in ipairs(HideTimeValues) do
        if room >= range.min and room <= range.max then
            return math.round(range.a * (room - range.b) + range.c)
        end
    end

    return nil
end

function DisableDupe(dupeRoom, value, isSpaceRoom)
    if isSpaceRoom then
        local collision = dupeRoom:WaitForChild("Collision", 5)

        if collision then
            collision.CanCollide = value
            collision.CanTouch = not value
        end
    else
        local doorFake = dupeRoom:WaitForChild("DoorFake", 5)

        if doorFake then
            doorFake:WaitForChild("Hidden", 5).CanTouch = not value

            local lock = doorFake:WaitForChild("Lock", 5)
            if lock and lock:FindFirstChild("UnlockPrompt") then
                lock.UnlockPrompt.Enabled = not value
            end
        end
    end
end

function GetPadlockCode(paper)
    if paper:FindFirstChild("UI") then
        local code = {}

        for _, image in pairs(paper.UI:GetChildren()) do
            if image:IsA("ImageLabel") and tonumber(image.Name) then
                code[image.ImageRectOffset.X .. image.ImageRectOffset.Y] = {tonumber(image.Name), "_"}
            end
        end

        for _, image in pairs(player.PlayerGui.PermUI.Hints:GetChildren()) do
            if image.Name == "Icon" then
                local key = image.ImageRectOffset.X .. image.ImageRectOffset.Y
                if code[key] then
                    code[key][2] = image.TextLabel.Text
                end
            end
        end

        local normalizedCode = {}
        for _, num in pairs(code) do
            normalizedCode[num[1]] = num[2]
        end

        return table.concat(normalizedCode)
    end
    return "_____"
end

function EnableBreaker(breaker, value)
    breaker:SetAttribute("Enabled", value)

    if value then
        breaker:FindFirstChild("PrismaticConstraint", true).TargetPosition = -0.2
        breaker.Light.Material = Enum.Material.Neon
        breaker.Light.Attachment.Spark:Emit(1)
        breaker.Sound.Pitch = 1.3
    else
        breaker:FindFirstChild("PrismaticConstraint", true).TargetPosition = 0.2
        breaker.Light.Material = Enum.Material.Glass
        breaker.Sound.Pitch = 1.2
    end

    breaker.Sound:Play()
end

function SolveBreakerBox(breakerBox)
    if not breakerBox then
        return
    end

    local code = breakerBox:FindFirstChild("Code", true)
    local correct = breakerBox:FindFirstChild("Correct", true)
    local methodSolve = "Legit"

    repeat
        task.wait()
    until code.Text ~= "..." or not breakerBox:IsDescendantOf(workspace)
    if not breakerBox:IsDescendantOf(workspace) then
        return
    end

    Notify("Auto Breaker Solver", "Solving the breaker box...")

    if methodSolve == "Legit" then
        Temp.UsedBreakers = {}
        if Connections["Reset"] then
            Connections["Reset"]:Disconnect()
        end
        if Connections["Code"] then
            Connections["Code"]:Disconnect()
        end

        local breakers = {}
        for _, breaker in pairs(breakerBox:GetChildren()) do
            if breaker.Name == "BreakerSwitch" then
                local id = string.format("%02d", breaker:GetAttribute("ID"))
                breakers[id] = breaker
            end
        end

        if code:FindFirstChild("Frame") then
            AutoBreaker(code, breakers)

            Connections["Reset"] =
                correct:GetPropertyChangedSignal("Playing"):Connect(
                function()
                    if correct.Playing then
                        table.clear(Temp.UsedBreakers)
                    end
                end
            )

            Connections["Code"] =
                code:GetPropertyChangedSignal("Text"):Connect(
                function()
                    task.delay(
                        0.1,
                        function()
                            AutoBreaker(code, breakers)
                        end
                    )
                end
            )
        end
    else
        repeat
            task.wait(0.1)
            RemotesFolder.EBF:FireServer()
        until not workspace.CurrentRooms["100"]:FindFirstChild("DoorToBreakDown")

        Notify("Auto Breaker Solver", "The breaker box has been successfully solved.")
    end
end

function AutoBreaker(code, breakers)
    local newCode = code.Text
    if not tonumber(newCode) and newCode ~= "??" then
        return
    end

    local isEnabled = code.Frame.BackgroundTransparency == 0
    local breaker = breakers[newCode]

    if newCode == "??" and #Temp.UsedBreakers == 9 then
        for i = 1, 10 do
            local id = string.format("%02d", i)
            if not table.find(Temp.UsedBreakers, id) then
                breaker = breakers[id]
            end
        end
    end

    if breaker then
        table.insert(Temp.UsedBreakers, newCode)
        if breaker:GetAttribute("Enabled") ~= isEnabled then
            EnableBreaker(breaker, isEnabled)
        end
    end
end

function GetAllPromptsWithCondition(condition)
    assert(typeof(condition) == "function", "Expected a function as condition argument but got " .. typeof(condition))

    local validPrompts = {}
    for _, prompt in pairs(PromptTable.GamePrompts) do
        if prompt or prompt:IsDescendantOf(workspace) then
            local success, returnData =
                pcall(
                function()
                    return condition(prompt)
                end
            )
            assert(success, "An error has occured while running condition function.\n" .. tostring(returnData))
            assert(typeof(returnData) == "boolean", "Expected condition function to return a boolean")
            if returnData then
                table.insert(validPrompts, prompt)
            end
        end
    end

    return validPrompts
end

function PromptCondition(prompt)
    local modelAncestor = prompt:FindFirstAncestorOfClass("Model")
    return prompt:IsA("ProximityPrompt") and not table.find(PromptTable.Excluded.Prompt, prompt.Name) and
        not table.find(PromptTable.Excluded.Parent, prompt.Parent and prompt.Parent.Name or "") and
        not table.find(PromptTable.Excluded.ModelAncestor, modelAncestor and modelAncestor.Name or "")
end

function DistanceFromCharacter(position, getPositionFromCamera)
    if not position then
        return 9e9
    end
    if typeof(position) == "Instance" then
        if position:IsA("Model") then
            position = position:GetPivot().Position
        elseif position:IsA("BasePart") then
            position = position.Position
        else
            return 9e9
        end
    end

    if getPositionFromCamera and (workspace.Camera or workspace.CurrentCamera) then
        local cameraPosition = (workspace.Camera or workspace.CurrentCamera).CFrame.Position
        return (cameraPosition - position).Magnitude
    end

    if hrp then
        return (hrp.Position - position).Magnitude
    end

    return 9e9
end

function GetNearestAssetWithCondition(condition)
    local nearestDistance = math.huge
    local nearest
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        if room:FindFirstChild("Assets") then
            for _, asset in pairs(room.Assets:GetChildren()) do
                if condition(asset) and DistanceFromCharacter(asset) < nearestDistance then
                    nearestDistance = DistanceFromCharacter(asset)
                    nearest = asset
                end
            end
        end
    end

    return nearest
end

function IsPromptInRange(prompt)
    return DistanceFromCharacter(
        prompt:FindFirstAncestorWhichIsA("BasePart") or prompt:FindFirstAncestorWhichIsA("Model") or prompt.Parent
    ) <= prompt.MaxActivationDistance
end

function ItemCondition(item)
    return item:IsA("Model") and (item:GetAttribute("Pickup") or item:GetAttribute("PropType")) and
        not item:GetAttribute("FuseID")
end

function VoiceCondition(sound)
    return sound:IsA("Sound") and table.find(Voicelines, sound.SoundId)
end

function ChildCheck(child)
    if (child.Name == "AnimSaves" or child.Name == "Keyframe" or child:IsA("KeyframeSequence")) then
        child:Destroy()
        return
    end

    if
        not (child:IsA("ProximityPrompt") or child:IsA("Model") or child:IsA("BasePart") or child:IsA("Decal") or
            child:IsA("Sound"))
     then
        return
    end

    if PromptCondition(child) then
        task.defer(
            function()
                if not child:GetAttribute("Hold") then
                    child:SetAttribute("Hold", child.HoldDuration)
                end
                if not child:GetAttribute("Distance") then
                    child:SetAttribute("Distance", child.MaxActivationDistance)
                end
                if not child:GetAttribute("Clip") then
                    child:SetAttribute("Clip", child.RequiresLineOfSight)
                end
            end
        )

        task.defer(
            function()
                child.MaxActivationDistance = child:GetAttribute("Distance") * PromtReachMultiplerSlider.Value

                if InstantInteractToggle.Value then
                    child.HoldDuration = 0
                end

                if PromptClipToggle.Value then
                    child.RequiresLineOfSight = false
                end
            end
        )

        table.insert(PromptTable.GamePrompts, child)
    elseif child:IsA("Model") then
        if child.Name == "ElevatorBreaker" and AutoSolverBreakerBoxToggle.Value then
            SolveBreakerBox(child)
        end

        if
            (child.Name == "GiggleCeiling" and AntiGiggleToggle.Value) or
                (child.Name == "Snare" and AntiSnareToggle.Value)
         then
            local hitbox = child:WaitForChild("Hitbox", 5)
            if hitbox then
                hitbox.CanTouch = false
            end
        elseif
            (child:GetAttribute("LoadModule") == "DupeRoom" or child:GetAttribute("LoadModule") == "SpaceSideroom") and
                AntiDupeToggle.Value
         then
            DisableDupe(child, true, child:GetAttribute("LoadModule") == "SpaceSideroom")
        end

        if
            (IsHotel or IsFools) and (child.Name == "ChandelierObstruction" or child.Name == "Seek_Arm") and
                AntiSeekObstructionToggle.Value
         then
            for i, v in pairs(child:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanTouch = false
                end
            end
        end
    elseif child:IsA("BasePart") then
        if child.Parent then
            if tonumber(child.Name) and child.Name == child.Parent.Name then
                child.Size = child.Size * Vector3.new(1, 100, 1)
            elseif child.Name == "Egg" and AntiGloomEggToggle.Value then
                child.CanTouch = false
            end
        else
            if child.Name == "Egg" and AntiGloomEggToggle.Value then
                child.CanTouch = false
            end
        end

        if AntiLagToggle.Value then
            if not child:GetAttribute("Material") then
                child:SetAttribute("Material", child.Material)
            end
            if not child:GetAttribute("Reflectance") then
                child:SetAttribute("Reflectance", child.Reflectance)
            end

            child.Material = Enum.Material.Plastic
            child.Reflectance = 0
        end

        if IsMines and AntiSeekFloodToggle.Value and child.Name == "SeekFloodline" then
            child.CanCollide = false
        end
    elseif child:IsA("Decal") and AntiLagToggle.Value then
        if not child:GetAttribute("Transparency") then
            child:SetAttribute("Transparency", child.Transparency)
        end

        if not table.find(SlotsName, child.Name) then
            child.Transparency = 1
        end
    elseif VoiceCondition(child) and NoVoiceActingModifierToggle.Value then
        child:Destroy()
    end
end

RemotesFolder.HideMonster.OnClientEvent:Connect(
    function()
        if IsBackdoor or IsRooms or IsRetro then
            return
        end

        local hideTime = CalculateHideTime(CurrentRoom) or math.huge
        local finalTime = tick() + math.round(hideTime)

        if NotifyHideTimeToggle.Value and hideTime ~= math.huge then
            while char:GetAttribute("Hiding") and Alive and not Library.Unloaded and NotifyHideTimeToggle.Value do
                local remainingTime = math.max(0, finalTime - tick())
                Captions(string.format("%.1f", remainingTime))
                task.wait()
            end
        end
    end
)

local function isMandrakeBlockedPrompt(prompt)
    local obj = prompt.Parent
    while obj do
        if string.find(obj.Name:lower(), "mandrake") then
            return true
        end
        obj = obj.Parent
    end
    return false
end

RunService.RenderStepped:Connect(
    function()
        local isThirdPersonEnabled = ThirdPersonToggle.Value
        local OffsetThirdPerson =
            CFrame.new(
            ThirdPersonOffsetXSlider.Value or 1.5,
            ThirdPersonOffsetYSlider.Value or -0.5,
            ThirdPersonOffsetZSlider.Value or 6.5
        )
        local MainGameScript = require(MainGame)
        if MainGameScript then
            if isThirdPersonEnabled then
                workspace.CurrentCamera.CFrame = MainGameScript.finalCamCFrame * OffsetThirdPerson
            end
            MainGameScript.fovtarget = FieldOfViewSlider.Value

            if NoCameraBobbingToggle.Value then
                MainGameScript.bobspring.Position = Vector3.zero
                MainGameScript.spring.Position = Vector3.zero
            end

            if NoCameraShakeToggle.Value then
                MainGameScript.csgo = CFrame.new()
            end
        elseif workspace.CurrentCamera then
            if isThirdPersonEnabled then
                workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * OffsetThirdPerson
            end

            workspace.CurrentCamera.FieldOfView = FieldOfViewSlider.Value
        end

        if char then
            if
                char:FindFirstChild("Head") and
                    not (MainGameScript and MainGameScript.stopcam or
                        (hrp and hrp.Anchored) and not char:GetAttribute("Hiding"))
             then
                char:SetAttribute("ShowInFirstPerson", isThirdPersonEnabled)
                char.Head.LocalTransparencyModifier = isThirdPersonEnabled and 0 or 1
            end

            if hum and SpeedHackToggle.Value then
                hum.WalkSpeed = char:GetAttribute("Climbing") and LadderSpeedSlider.Value or WalkSpeedSlider.Value
            end

            if hrp then
                hrp.CanCollide = not NoclipToggle.Value
            end

            if Collision then
                if NoclipToggle.Value then
                    Collision.CanCollide = not NoclipToggle.Value and not GodmodeFoolsToggle.Value
                    if Collision:FindFirstChild("CollisionCrouch") then
                        Collision.CollisionCrouch.CanCollide = not NoclipToggle.Value and not GodmodeFoolsToggle.Value
                    end
                end
            end

            if char:FindFirstChild("UpperTorso") then
                char.UpperTorso.CanCollide = not NoclipToggle.Value
            end
            if char:FindFirstChild("LowerTorso") then
                char.LowerTorso.CanCollide = not NoclipToggle.Value
            end

            if DoorReachToggle.Value and workspace.CurrentRooms:FindFirstChild(LatestRoom.Value) then
                local door = workspace.CurrentRooms[LatestRoom.Value]:FindFirstChild("Door")

                if door and door:FindFirstChild("ClientOpen") then
                    door.ClientOpen:FireServer()
                end
            end

            if AutoInteractToggle.Value then
                local prompts =
                    GetAllPromptsWithCondition(
                    function(prompt)
                        if not prompt.Parent then
                            return false
                        end

                        if isMandrakeBlockedPrompt(prompt) then
                            return false
                        end
                        if
                            prompt.Parent:GetAttribute("PropType") == "Battery" and
                                not (char:FindFirstChildOfClass("Tool") and
                                    (char:FindFirstChildOfClass("Tool"):GetAttribute("RechargeProp") == "Battery" or
                                        char:FindFirstChildOfClass("Tool"):GetAttribute("StorageProp") == "Battery"))
                         then
                            return false
                        end
                        if prompt.Parent:GetAttribute("PropType") == "Heal" and hum and hum.Health == hum.MaxHealth then
                            return false
                        end
                        if prompt.Parent.Name == "MinesAnchor" then
                            return false
                        end

                        if IsRetro and prompt.Parent.Parent.Name == "RetroWardrobe" then
                            return false
                        end

                        return PromptTable.Aura[prompt.Name] ~= nil
                    end
                )

                for _, prompt in pairs(prompts) do
                    task.spawn(
                        function()
                            if
                                DistanceFromCharacter(prompt.Parent) < prompt.MaxActivationDistance and
                                    (not prompt:GetAttribute("Interactions" .. player.Name) or
                                        PromptTable.Aura[prompt.Name] or
                                        table.find(PromptTable.AuraObjects, prompt.Parent.Name))
                             then
                                if prompt.Parent.Name == "Slot" and prompt.Parent:GetAttribute("Hint") then
                                    if Temp.PaintingDebounce[prompt] then
                                        return
                                    end

                                    local currentPainting = char:FindFirstChild("Prop")
                                    local slotPainting = prompt.Parent:FindFirstChild("Prop")

                                    local currentHint = (currentPainting and currentPainting:GetAttribute("Hint"))
                                    local slotHint = (slotPainting and slotPainting:GetAttribute("Hint"))
                                    local promptHint = prompt.Parent:GetAttribute("Hint")

                                    if slotHint ~= promptHint and (currentHint == promptHint or slotPainting) then
                                        Temp.PaintingDebounce[prompt] = true
                                        fireproximityprompt(prompt)
                                        task.wait(0.3)
                                        Temp.PaintingDebounce[prompt] = false
                                    end

                                    return
                                end

                                fireproximityprompt(prompt)
                            end
                        end
                    )
                end
            end

            if IsMines then
                if
                    AutoAnchorSolverToggle.Value and LatestRoom.Value == 50 and
                        MainUI.MainFrame:FindFirstChild("AnchorHintFrame")
                 then
                    local prompts =
                        GetAllPromptsWithCondition(
                        function(prompt)
                            return prompt.Name == "ActivateEventPrompt" and prompt.Parent:IsA("Model") and
                                prompt.Parent.Name == "MinesAnchor" and
                                not prompt.Parent:GetAttribute("Activated")
                    end)

                    local CurrentGameState = {
                        DesignatedAnchor = MainUI.MainFrame.AnchorHintFrame.AnchorCode.Text,
                        AnchorCode = MainUI.MainFrame.AnchorHintFrame.Code.Text
                    }

                    for _, prompt in pairs(prompts) do
                        task.spawn(function()
                                local Anchor = prompt.Parent
                                local CurrentAnchor = Anchor.Sign.TextLabel.Text

                                if not (DistanceFromCharacter(prompt.Parent) < prompt.MaxActivationDistance) then
                                    return
                                end
                                if CurrentAnchor ~= CurrentGameState.DesignatedAnchor then
                                    return
                                end

                                local result = Anchor:FindFirstChildOfClass("RemoteFunction"):InvokeServer(CurrentGameState.AnchorCode)
                                if result then
                                    Notify("Auto Anchor Solver", "Solved Anchor " .. CurrentAnchor .. " successfully!")
                                end
                        end)
                    end
                end
            end

            if AntiEyesToggle.Value and (workspace:FindFirstChild("Eyes") or workspace:FindFirstChild("BackdoorLookman")) then
                if not IsFools then
                    RemotesFolder.MotorReplication:FireServer(-649)
                else
                    RemotesFolder.MotorReplication:FireServer(0, -90, 0, false)
                end
            end
        end
end)

function ToggleEsp(name, value)
    local currentRoom = workspace.CurrentRooms:FindFirstChild(CurrentRoom)
    local nextRoom = workspace.CurrentRooms:FindFirstChild(NextRoom)

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

    if name == "Door" then
        if value then
            if currentRoom and currentRoom:FindFirstChild("Door") then
                DoorESP(currentRoom)
            end
            if nextRoom and nextRoom:FindFirstChild("Door") then
                DoorESP(nextRoom)
            end
        else
            destroyAll(ESPTable.Door)
            disconnectAll(FeatureConnections.Door)
        end
    elseif name == "Gold" then
        if value and currentRoom then
            for _, g in pairs(currentRoom:GetDescendants()) do
                if g.Name == "GoldPile" then
                    GoldESP(g)
                end
            end
        else
            destroyAll(ESPTable.Gold)
        end
    elseif name == "Objective" then
        if value and currentRoom then
            for _, a in pairs(currentRoom:GetDescendants()) do
                task.spawn(function()
                        ObjectiveESP(a)
                end)
            end
        else
            destroyAll(ESPTable.Objective)
        end
    elseif name == "Chest" then
        if value and currentRoom then
            for _, c in pairs(currentRoom:GetDescendants()) do
                if c:GetAttribute("Storage") == "ChestBox" or c.Name == "Toolshed_Small" then
                    ChestESP(c)
                end
            end
        else
            destroyAll(ESPTable.Chest)
        end
    elseif name == "Item" then
        if value then
            for _, i in pairs(workspace.Drops:GetChildren()) do
                if ItemCondition(i) then
                    ItemESP(i, true)
                end
            end
            if currentRoom then
                for _, i in pairs(currentRoom:GetDescendants()) do
                    if ItemCondition(i) then
                        ItemESP(i)
                    end
                end
            end
        else
            destroyAll(ESPTable.Item)
            destroyAll(ESPTable.DroppedItem)
        end
    elseif name == "HidingSpot" then
        if value and currentRoom then
            for _, w in pairs(currentRoom:GetDescendants()) do
                local m = w:GetAttribute("LoadModule")
                if m == "Wardrobe" or m == "Bed" or w.Name == "Rooms_Locker" or w.Name == "RetroWardrobe" then
                    HidingSpotESP(w)
                end
            end
        else
            destroyAll(ESPTable.HidingSpot)
        end
    elseif name == "Entity" then
        if value then
            for _, e in pairs(workspace:GetChildren()) do
                if table.find(EntityTable.Names, e.Name) then
                    EntityESP(e)
                end
            end
            if currentRoom then
                for _, e in pairs(currentRoom:GetDescendants()) do
                    if table.find(EntityTable.SideNames, e.Name) then
                        SideEntityESP(e)
                    end
                end
            end
        else
            destroyAll(ESPTable.Entity)
            destroyAll(ESPTable.SideEntity)
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

function SetupCharacterConnection(newCharacter)
    char = newCharacter
    if char then
        NoCharRaycastParam.FilterDescendantsInstances = {char}

        if EnableJumpToggle.Value then
            char:SetAttribute("CanJump", true)
        end

        for _, oldConnection in pairs(FeatureConnections.Character) do
            oldConnection:Disconnect()
        end

        FeatureConnections.Character["ChildAdded"] = char.ChildAdded:Connect(function(child)
                if not (child:IsA("Tool") and child.Name:match("LibraryHintPaper")) then
                    return
                end

                task.wait(0.1)
                local code = GetPadlockCode(child)
                local output, count = string.gsub(code, "_", "x")
                local padlock = workspace:FindFirstChild("Padlock", true)

                if AutoSolverLibraryCodeToggle.Value and tonumber(code) and DistanceFromCharacter(padlock) <= AutoSolverLibraryCodeDistanceSlider.Value then
                    RemotesFolder.PL:FireServer(code)
                end

                if NotifyLibraryCodeToggle.Value and count < 5 then
                    Notify("Padlock Code", string.format("Library Code: %s", output))

                    if NotifyChatToggle.Value and count == 0 then
                        SendMessage(string.format("Library Code: %s", output))
                    end
                end
        end)

        FeatureConnections.Character["CanJump"] = char:GetAttributeChangedSignal("CanJump"):Connect(function()
                if not EnableJumpToggle.Value then
                    return
                end

                if not char:GetAttribute("CanJump") then
                    char:SetAttribute("CanJump", true)
                end
        end)

        FeatureConnections.Character["Crouching"] = char:GetAttributeChangedSignal("Crouching"):Connect(function()
                if not AntiFigureHearingToggle.Value then
                    return
                end

                if not char:GetAttribute("Crouching") then
                    RemotesFolder.Crouch:FireServer(true)
                end
        end)

        FeatureConnections.Character["Hiding"] = char:GetAttributeChangedSignal("Hiding"):Connect(function()
                if not char:GetAttribute("Hiding") then
                    return
                end
                if not TranslucentHidingSpotToggle.Value then
                    return
                end

                for _, obj in pairs(workspace.CurrentRooms:GetDescendants()) do
                    if not obj:IsA("ObjectValue") and obj.Name ~= "HiddenPlayer" then continue end

                        if obj.Value == char then
                            task.spawn(function()
                                    local affectedParts = {}
                                    for _, part in pairs(obj.Parent:GetChildren()) do
                                        if not part:IsA("BasePart") or part.Name:match("Collision") then continue end
                                        part.Transparency = HidingSpotTranslucent
                                        table.insert(affectedParts, part)
                                    end

                                    repeat task.wait()
                                        for _, part in pairs(affectedParts) do
                                            task.wait()
                                            part.Transparency = HidingSpotTranslucent
                                        end
                                    until not char:GetAttribute("Hiding") or not TranslucentHidingSpotToggle.Value

                                    for _, part in pairs(affectedParts) do
                                        part.Transparency = 0
                                    end
                            end)

                        break
                    end
                end
        end)

        FeatureConnections.Character["Oxygen"] = char:GetAttributeChangedSignal("Oxygen"):Connect(function()
                if not NotifyOxygenToggle.Value then
                    return
                end
                if char:GetAttribute("Oxygen") >= 100 then
                    return
                end
                Captions(string.format("Oxygen: %.1f", char:GetAttribute("Oxygen")))
        end)
    end

    hum = char:WaitForChild("Humanoid")
    if hum then
        for _, oldConnection in pairs(FeatureConnections.Humanoid) do
            oldConnection:Disconnect()
        end

        FeatureConnections.Humanoid["Move"] = hum:GetPropertyChangedSignal("MoveDirection"):Connect(function()
                if not FastClosetExitToggle.Value then
                    return
                end

                if FastClosetExitToggle.Value and hum.MoveDirection.Magnitude > 0 and char:GetAttribute("Hiding") then
                    RemotesFolder.CamLock:FireServer()
                end
        end)

        FeatureConnections.Humanoid["Jump"] = hum:GetPropertyChangedSignal("JumpHeight"):Connect(function()
                if not IsFools and EnableJumpToggle.Value then
                    hum.JumpHeight = JumpBoostSlider.Value
                end

                if not EnableSpeedBypassToggle.Value then
                    return
                end

                if not EnableSpeedBypassToggle.Value and LatestRoom.Value < 100 then
                    if hum.JumpHeight > 0 then
                        LastSpeed = WalkSpeedSlider.Value
                        WalkSpeedSlider:SetMax(18)
                    elseif LastSpeed > 0 then
                        WalkSpeedSlider:SetMax(22)
                        WalkSpeedSlider:SetValue(LastSpeed)
                        LastSpeed = 0
                    end
                end
        end)

        FeatureConnections.Humanoid["Died"] = hum.Died:Connect(function()
                if CollisionClone then
                    CollisionClone:Destroy()
                end
        end)
    end

    local rootpart = hrp
    if rootpart then
        if NoAccelToggle.Value then
            Temp.NoAccelValue = rootpart.CustomPhysicalProperties.Density

            local existingProperties = rootpart.CustomPhysicalProperties
            rootpart.CustomPhysicalProperties =
                PhysicalProperties.new(
                100,
                existingProperties.Friction,
                existingProperties.Elasticity,
                existingProperties.FrictionWeight,
                existingProperties.ElasticityWeight
            )
        end

        FeatureConnections.RootPart["RootChildAdded"] = rootpart.ChildAdded:Connect(function(child)
                if NoVoiceActingModifierToggle.Value and VoiceCondition(child) then
                    child:Destroy()
                end
        end)

        FeatureConnections.RootPart["Touched"] = rootpart.Touched:Connect(function(touchedPart)
                if tonumber(touchedPart.Name) and touchedPart.Name == touchedPart.Parent.Name then
                    Players.LocalPlayer:SetAttribute("CurrentRoom", tonumber(touchedPart.Name))
                end
        end)
    end

    Collision = char:WaitForChild("Collision")
    if Collision then
        Collision.CanQuery = false
        Collision.CollisionCrouch.CanQuery = false

        CollisionClone = Collision:Clone()
        CollisionClone.CanCollide = false
        CollisionClone.Massless = true
        CollisionClone.CanQuery = false
        CollisionClone.Name = "CollisionClone"
        if CollisionClone:FindFirstChild("CollisionCrouch") then
            CollisionClone.CollisionCrouch:Destroy()
        end

        CollisionClone.Parent = char
    end
end

function SetupOtherPlayerConnection(player)
    if player.Character then
        task.spawn(function()
                SetupOtherCharacterConnection(player.Character)
        end)
    end

    player.CharacterAdded:Connect(function(newCharacter)
            if IsEspActive("Player") then
                task.delay(1,function()
                        PlayerESP(newCharacter)
                end)
            end

            task.delay(1,function()
                    SetupOtherCharacterConnection(newCharacter)
            end)
    end)
end

function SetupOtherCharacterConnection(character)
    Connections[character.Name .. "ChildAdded"] = character.ChildAdded:Connect(function(child)
            if not (child:IsA("Tool") and child.Name:match("LibraryHintPaper")) then
                return
            end

            task.wait(0.1)
            local code = GetPadlockCode(child)
            local output, count = string.gsub(code, "_", "x")
            local padlock = workspace:FindFirstChild("Padlock", true)

            if AutoSolverLibraryCodeToggle.Value and tonumber(code) and DistanceFromCharacter(padlock) <= AutoSolverLibraryCodeDistanceSlider.Value then
                RemotesFolder.PL:FireServer(code)
            end

            if NotifyLibraryCodeToggle.Value and count < 5 then
                Notify("Padlock Code", string.format("Library Code: %s", output))

                if NotifyChatToggle.Value and count == 0 then
                    SendMessage(string.format("Library Code: %s", output))
                end
            end
    end)

    local otherRootPart = character:WaitForChild("HumanoidRootPart")
    if otherRootPart then
        Connections[character.Name .. "RootChildAdded"] = otherRootPart.ChildAdded:Connect(function(child)
                if NoVoiceActingModifierToggle.Value and VoiceCondition(child) then
                    child:Destroy()
                end
        end)
    end
end

function SetupRoomConnection(room)
    if NotifyEntityDropdown.Value["Halt Room"] and room:GetAttribute("RawName") == "HaltHallway" then
        Notify("Entities", "Halt will spawn in next room!")
    end

    for _, child in pairs(room:GetDescendants()) do
        task.spawn(function()
                ChildCheck(child)
        end)
    end

    Connections[room.Name .. "DescendantAdded"] = room.DescendantAdded:Connect(function(child)
            if tonumber(room.Name) == CurrentRoom then
                if IsEspActive("Item") and ItemCondition(child) then
                    ItemESP(child)
                elseif IsEspActive("Gold") and child.Name == "GoldPile" then
                    GoldESP(child)
                end
            end

            task.delay(0.1,function()
                    ChildCheck(child)
           end)
    end)
end

function SetupDropConnection(drop)
    if IsEspActive("Item") then
        ItemESP(drop, true)
    end

    task.spawn(function()
            local prompt = drop:WaitForChild("ModulePrompt", 3)

            if prompt then
                table.insert(PromptTable.GamePrompts, prompt)
            end
    end)
end

for _, obj in ipairs(workspace:GetDescendants()) do
    if table.find(EntityTable.Names, obj.Name) and obj:IsA("Model") then
        if IsEspActive("Entity") then
            EntityESP(obj)
        end
    end
end

LatestRoom:GetPropertyChangedSignal("Value"):Connect(function()
        NotifyGlitch()
end)

local pendingSurgeParts = {}
local debounce = false

workspace.Camera.ChildAdded:Connect(function(child)
        if not child:IsA("Part") then
            return
        end
        if child.Name ~= "SurgePart" then
            return
        end

        if not table.find(pendingSurgeParts, child) then
            table.insert(pendingSurgeParts, child)
        end

        if not debounce then
            debounce = true
            task.delay(1,function()
                    if #pendingSurgeParts > 0 then
                        local count = #pendingSurgeParts
                        local shortName = GetShortName("SurgePart")
                        if NotifyEntityDropdown.Value[shortName] then
                            local description
                            if count > 1 then
                                description = string.format("%s x%d %s", shortName, count, NotifyEntityInput.Value)
                            else
                                description = string.format("%s %s", shortName, NotifyEntityInput.Value)
                            end
                            Notify("Entities", description)
                            if NotifyChatToggle.Value then
                                SendMessage(description)
                            end
                        end
                        table.clear(pendingSurgeParts)
                    end
                    debounce = false
            end)
        end
end)

workspace.DescendantAdded:Connect(function(obj)
        task.delay(0.1,function()
                if not obj:IsA("Model") then
                    return
                end

                local shortName = GetShortName(obj.Name)

                if table.find(EntityTable.Names, obj.Name) then
                    if IsFools and obj.Name == "RushMoving" and obj.PrimaryPart then
                        shortName = obj.PrimaryPart.Name:gsub("New", "")
                    end

                    if IsEspActive("Entity") then
                        EntityESP(obj)
                    end
                end

                local notifyEnabled = NotifyEntityDropdown.Value[shortName]
                if notifyEnabled then
                    if table.find(EntityTable.Names, obj.Name) then
                        local msg = string.format("%s %s", shortName, NotifyEntityInput.Value)
                        Notify("Entities", msg)
                        if NotifyChatToggle.Value then
                            SendMessage(msg)
                        end
                    elseif EntityTable.NotifyMessage[obj.Name] then
                        local msg = string.format("%s %s", shortName, NotifyEntityInput.Value)
                        Notify("Entities", msg)
                        if NotifyChatToggle.Value then
                            SendMessage(EntityTable.NotifyMessage[obj.Name])
                        end
                    end
                end

                if NoVoiceActingToggle.Value and table.find(EntityTable.Names, obj.Name) and (IsHotel or IsMines) then
                    local function removeVoice(desc)
                        if VoiceCondition(desc) then
                            desc:Destroy()
                        end
                    end

                    for _, desc in pairs(obj:GetDescendants()) do
                        removeVoice(desc)
                    end

                    obj.DescendantAdded:Connect(removeVoice)
                end
        end)
end)

-- // Drop
for _, drop in pairs(workspace.Drops:GetChildren()) do
    task.spawn(SetupDropConnection, drop)
end
workspace.Drops.ChildAdded:Connect(function(child)
        task.spawn(SetupDropConnection, child)
end)

-- // Room
for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
    task.spawn(SetupRoomConnection, room)
end
workspace.CurrentRooms.ChildAdded:Connect(function(room)
        task.spawn(SetupRoomConnection, room)
end)

-- // Player
for _, player in pairs(Players:GetPlayers()) do
    if player == Players.LocalPlayer then continue end
    SetupOtherPlayerConnection(player)
end
Players.PlayerAdded:Connect(SetupOtherPlayerConnection)
player.CharacterAdded:Connect(function(newCharacter)
        task.delay(1, function()
                SetupCharacterConnection(newCharacter)
        end)
end)

player:GetAttributeChangedSignal("CurrentRoom"):Connect(
    function()
        local newRoom = player:GetAttribute("CurrentRoom")
        if not newRoom or CurrentRoom == newRoom then
            return
        end

        CurrentRoom = newRoom
        NextRoom = CurrentRoom + 1

        NotifyGlitch()

        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(CurrentRoom)
        local nextRoomModel = workspace.CurrentRooms:FindFirstChild(NextRoom)

        local espMappings = {
            Door = ESPTable.Door,
            Objective = ESPTable.Objective,
            Entity = ESPTable.SideEntity,
            Item = ESPTable.Item,
            Chest = ESPTable.Chest,
            HidingSpot = ESPTable.HidingSpot,
            Gold = ESPTable.Gold
        }

        for toggleName, espList in pairs(espMappings) do
            local toggle = IsEspActive(name)
            if toggle then
                for _, esp in pairs(espList) do
                    esp:Destroy()
                end
            end
        end

        if IsEspActive("Door") then
            if currentRoomModel then
                task.spawn(function()
                        DoorESP(currentRoomModel)
                end)
            end
            if nextRoomModel then
                task.spawn(function()
                        DoorESP(nextRoomModel)
                end)
            end
        end

        if currentRoomModel then
            for _, asset in pairs(currentRoomModel:GetDescendants()) do
                if IsEspActive("Objective") then
                    task.spawn(function()
                            ObjectiveESP(asset)
                    end)
                end

                if IsEspActive("Entity") and table.find(EntityTable.SideNames, asset.Name) then
                    task.spawn(function()
                            SideEntityESP(asset)
                    end)
                end

                if IsEspActive("Item") and ItemCondition(asset) then
                    task.spawn(function()
                            ItemESP(asset)
                    end)
                end

                if IsEspActive("Chest") and (asset:GetAttribute("Storage") == "ChestBox" or asset.Name == "Toolshed_Small") then
                    task.spawn(function()
                            ChestESP(asset)
                    end)
                end

                if IsEspActive("HidingSpot") and (asset:GetAttribute("LoadModule") == "Wardrobe" or asset:GetAttribute("LoadModule") == "Bed" or asset.Name == "Rooms_Locker" or asset.Name == "RetroWardrobe") then
                    HidingSpotESP(asset)
                end

                if IsEspActive("Gold") and asset.Name == "GoldPile" then
                    GoldESP(asset)
                end
            end
        end
end)

function AntiEntityToggle(name, value)
    if not MainGame then
        return
    end
    local modules = MainGame:FindFirstChild("Modules", true)

    local shortName = GetShortName(name)

    local moduleEntities = {SpiderJumpscare = true, Jumpscares = true, Dread = true, ["A-90"] = true}
    if moduleEntities[shortName] then
        local module =
            modules and (modules:FindFirstChild(shortName, true) or modules:FindFirstChild("_" .. shortName, true))
        if module then
            module.Name = if value then ("_" .. shortName) else name
        end
        return
    end

    local rooms = {}
    for _, r in ipairs(workspace.CurrentRooms:GetChildren()) do
        rooms[#rooms + 1] = r
    end

    -- Seek Obstructions
    if name == "Seek Obstructions" then
        -- Seek Flood
        for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "ChandelierObstruction" or v.Name == "Seek_Arm" then
                for _, obj in pairs(v:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        obj.CanTouch = not value
                    end
                end
            end
        end
    elseif name == "Seek Flood" then
        local room = workspace.CurrentRooms:FindFirstChild("100")
        if room and room:FindFirstChild("_DamHandler") then
            local seekFlood = room._DamHandler:FindFirstChild("SeekFloodline")
            if seekFlood then
                seekFlood.CanCollide = value
            end
        end
    elseif name == "Glitch" then
        local module = EntityModules:FindFirstChild("Glitch") or EntityModules:FindFirstChild("_Glitch")
        if module then
            module.Name = if value then "_Glitch" else "Glitch"
        end
    elseif name == "Void" then
        local module = EntityModules:FindFirstChild("Void") or EntityModules:FindFirstChild("_Void")
        if module then
            module.Name = if value then "_Void" else "Void"
        end
    elseif name == "Screech" then
        local remoteListener = MainGame:FindFirstChild("RemoteListener")
        local modules = remoteListener:FindFirstChild("Modules")
        local module = modules:FindFirstChild("Screech") or modules:FindFirstChild("_Screech")
        if module then
            module.Name = if value then "_Screech" else "Screech"
        end
    elseif name == "Halt" then
        local module = EntityModules:FindFirstChild("Shade") or EntityModules:FindFirstChild("_Shade")
        if module then
            module.Name = if value then "_Shade" else "Shade"
        end
    elseif name == "Firedamp" then
        -- Gloom Egg
        for _, room in pairs(rooms) do
            if room:GetAttribute("AntiFiredamp") ~= nil then
                room:SetAttribute("AntiFiredamp", value)
            end
        end
    elseif name == "Gloom Egg" then
        -- Giggle
        for _, room in pairs(rooms) do
            for _, gloomPile in pairs(room:GetChildren()) do
                if gloomPile.Name == "GloomPile" then
                    for _, gloomEgg in pairs(gloomPile:GetDescendants()) do
                        if gloomEgg.Name == "Egg" then
                            gloomEgg.CanTouch = not value
                        end
                    end
                end
            end
        end
    elseif name == "Giggle" then
        -- Vacuum / Dupe
        for _, room in pairs(rooms) do
            for _, giggle in pairs(room:GetChildren()) do
                if giggle.Name == "GiggleCeiling" then
                    local hitbox = giggle:FindFirstChild("Hitbox") or giggle:WaitForChild("Hitbox", 5)
                    if hitbox then
                        hitbox.CanTouch = not value
                    end
                end
            end
        end
    elseif name == "Vacuum" or name == "Dupe" then
        -- Lookman / Eyes
        for _, room in pairs(rooms) do
            for _, dupeRoom in pairs(room:GetChildren()) do
                local mod = dupeRoom:GetAttribute("LoadModule")
                if mod == "DupeRoom" or mod == "SpaceSideroom" then
                    task.spawn(function()
                            pcall(function()
                                    DisableDupe(dupeRoom, value, mod == "SpaceSideroom")
                            end)
                    end)
                end
            end
        end
    elseif name == "Lookman" or name == "Eyes" then
        -- Snare
        if value and (workspace:FindFirstChild("Eyes") or workspace:FindFirstChild("BackdoorLookman")) then
            pcall(function()
                    RemotesFolder.MotorReplication:FireServer(not IsFools and -649 or 0, -90, 0, false)
            end)
        end
    elseif name == "Snare" then
        for _, room in pairs(rooms) do
            local container = room:FindFirstChild(IsOutdoor and "Snares" or "Assets")
            if container then
                for _, snare in pairs(container:GetChildren()) do
                    if snare.Name == "Snare" then
                        local hitbox = snare:FindFirstChild("Hitbox") or snare:WaitForChild("Hitbox", 5)
                        if hitbox then
                            hitbox.CanTouch = not value
                        end
                    end
                end
            end
        end
    end
end

Library.ShowCustomCursor = true
Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

local WatermarkConnection = game:GetService("RunService").RenderStepped:Connect(function()
        FrameCounter += 1

        if (tick() - FrameTimer) >= 1 then
            FPS = FrameCounter
            FrameTimer = tick()
            FrameCounter = 0
        end

        Library:SetWatermark(("Mango Hub | %s ms"):format(math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())))
end)

local LibFolder = CurrentGame and CurrentGame.Folder or tostring(GameId)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("MangoHub/Script-Exploits/Game/" .. string.lower(LibFolder))
if ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Floor") then
    SaveManager:SetSubFolder(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Floor").Value)
end
SaveManager:LoadAutoloadConfig()

Notify("Script Loading", "Script loaded successfully", 10)