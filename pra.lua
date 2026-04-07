local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Turcja Hub v1.0",
    LoadingTitle = "Turcja Hub",
    LoadingSubtitle = "Loading...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TurcjaHub",
        FileName = "config"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Language System
local Languages = {
    pl = {
        Universal = "Uniwersalne",
        Combat = "Walka",
        Movement = "Ruch",
        Visuals = "Wizualne",
        Settings = "Ustawienia",
        Fly = "Lot",
        FlyEnabled = "Lot Włączony",
        Noclip = "NoClip",
        NoclipEnabled = "NoClip Włączony",
        Speed = "Szybkość",
        SpeedValue = "Wartość Szybkości",
        FlingAll = "Fling All",
        FlingAllEnabled = "Fling All Włączony",
        ESP = "ESP",
        ESPEnabled = "ESP Włączony",
        RainbowESP = "Tęczowy ESP",
        UltimateFling = "Ultimate Fling",
        FPSBoost = "FPS Booster",
        SexTool = "18+ Sex Tool",
        Language = "Język",
        GameDetection = "Wykryto:",
        Brookhaven = "Brookhaven",
        CaseParadise = "Case Paradise",
        None = "Brak gry",
        Toggle = "Przełącz",
        SaveConfig = "Zapisz Konfigurację"
    },
    en = {
        Universal = "Universal",
        Combat = "Combat",
        Movement = "Movement",
        Visuals = "Visuals",
        Settings = "Settings",
        Fly = "Fly",
        FlyEnabled = "Fly Enabled",
        Noclip = "Noclip",
        NoclipEnabled = "Noclip Enabled",
        Speed = "Speed",
        SpeedValue = "Speed Value",
        FlingAll = "Fling All",
        FlingAllEnabled = "Fling All Enabled",
        ESP = "ESP",
        ESPEnabled = "ESP Enabled",
        RainbowESP = "Rainbow ESP",
        UltimateFling = "Ultimate Fling",
        FPSBoost = "FPS Booster",
        SexTool = "18+ Sex Tool",
        Language = "Language",
        GameDetection = "Detected:",
        Brookhaven = "Brookhaven",
        CaseParadise = "Case Paradise",
        None = "No Game",
        Toggle = "Toggle",
        SaveConfig = "Save Config"
    }
}

local CurrentLang = "pl" -- Default Polish
local Lang = Languages[CurrentLang]

-- Game Detection
local GameName = "None"
if game.PlaceId == 4924922222 then
    GameName = "Brookhaven"
elseif game.PlaceId == 8777340150 then
    GameName = "Case Paradise"
end

-- Flags for languages
local LanguageFlags = {
    ["pl"] = "🇵🇱 Polski",
    ["en"] = "🇺🇸 English"
}

-- State variables
local FlyEnabled = false
local NoclipEnabled = false
local FlingAllEnabled = false
local ESPEnabled = false
local RainbowESPEnabled = false
local SpeedValue = 16
local FPSBoostEnabled = false
local Connections = {}

-- Perfect Fly (BodyVelocity + BodyGyro, no drift)
local FlyConnection
local BodyVelocity, BodyGyro

local function CreateFly()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local RootPart = LocalPlayer.Character.HumanoidRootPart
        
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.Parent = RootPart
        
        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
        BodyGyro.CFrame = RootPart.CFrame
        BodyGyro.Parent = RootPart
        
        FlyConnection = RunService.Heartbeat:Connect(function()
            if FlyEnabled and RootPart.Parent then
                local CameraCFrame = Camera.CFrame
                local Speed = SpeedValue
                
                local Direction = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then Direction = Direction + CameraCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then Direction = Direction - CameraCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then Direction = Direction - CameraCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then Direction = Direction + CameraCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then Direction = Direction + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then Direction = Direction - Vector3.new(0, 1, 0) end
                
                BodyVelocity.Velocity = (Direction.Unit * Speed)
                BodyGyro.CFrame = CameraCFrame
            else
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    end
end

-- Perfect Noclip
local NoclipConnection
local function ToggleNoclip()
    NoclipEnabled = not NoclipEnabled
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not NoclipEnabled
            end
        end
    end
end

local function NoclipLoop()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- Ultimate Fling All (BodyVelocity + AngularVelocity loop)
local FlingConnection
local function StartFlingAll()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local RootPart = player.Character.HumanoidRootPart
            local BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            BodyVelocity.Velocity = Vector3.new(0, 5000, 0)
            BodyVelocity.Parent = RootPart
            
            local AngularVelocity = Instance.new("AngularVelocity")
            AngularVelocity.AngularVelocity = Vector3.new(0, math.random(-500, 500), 0)
            AngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
            AngularVelocity.Parent = RootPart
            
            game:GetService("Debris"):AddItem(BodyVelocity, 0.1)
            game:GetService("Debris"):AddItem(AngularVelocity, 0.1)
        end
    end
end

-- Rainbow ESP (HSV cycle + cleanup)
local ESPBoxes = {}
local ESPConnection
local RainbowHue = 0

local function CreateESP(player)
    if player == LocalPlayer or not player.Character then return end
    
    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Transparency = 1
    Box.Color = Color3.fromHSV(0, 1, 1)
    Box.Visible = false
    
    ESPBoxes[player] = Box
    
    local UpdateESP = RunService.Heartbeat:Connect(function()
        if not ESPEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") then
            Box:Remove()
            UpdateESP:Disconnect()
            ESPBoxes[player] = nil
            return
        end
        
        local RootPart = player.Character.HumanoidRootPart
        local Humanoid = player.Character.Humanoid
        
        local Vector, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
        local Head = RootPart.Position + Vector3.new(0, 3, 0)
        local Leg = RootPart.Position - Vector3.new(0, 4, 0)
        
        local HeadVector, HeadOnScreen = Camera:WorldToViewportPoint(Head)
        local LegVector, LegOnScreen = Camera:WorldToViewportPoint(Leg)
        
        if OnScreen then
            Box.Size = Vector2.new(1 / Vector.Z * 1000, (HeadVector.Y - LegVector.Y))
            Box.Position = Vector2.new(Vector.X - Box.Size.X / 2, Vector.Y - Box.Size.Y / 2)
            Box.Visible = true
            
            if RainbowESPEnabled then
                RainbowHue = (RainbowHue + 0.01) % 1
                Box.Color = Color3.fromHSV(RainbowHue, 1, 1)
            end
        else
            Box.Visible = false
        end
    end)
end

-- FPS Booster
local function FPSBoost()
    if FPSBoostEnabled then
        settings().Rendering.QualityLevel = Enum.SavedQualitySetting.PeerPresets10
        Lighting.FogEnd = 9e9
        Lighting.GlobalShadows = false
        Lighting.FogStart = 9e9
        game.Lighting.DecalTransparency = 1
        game.Lighting.DepthOfField.Enabled = false
        game.Lighting.AmbientOcclusion = Enum.EnviromentalSpecularScale.Disabled
        game.Lighting.Bloom.Enabled = false
        game.Lighting.SunRays.Enabled = false
    else
        settings().Rendering.QualityLevel = Enum.SavedQualitySetting.Automatic
    end
end

-- Speed (consistent across all games)
local SpeedConnection
LocalPlayer.CharacterAdded:Connect(function()
    if SpeedConnection then SpeedConnection:Disconnect() end
    wait(1)
    local Humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
    SpeedConnection = RunService.Heartbeat:Connect(function()
        Humanoid.WalkSpeed = SpeedValue
    end)
end)

-- BROOKHAVEN SCRIPTS
local BrookhavenAdmin = nil
local function LoadBrookhaven()
    local args = {
        [1] = "Rise",
        [2] = LocalPlayer,
        [3] = "SuperAdmin"
    }
    pcall(function()
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("!rise Zosia", "All")
        wait(1)
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("!ml Zosia", "All")
    end)
end

-- CASE PARADISE SCRIPTS (New working auto-farm)
local CaseParadiseScripts = [[
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.AutoFarm = true
while _G.AutoFarm do
    pcall(function()
        for _, case in pairs(workspace.Cases:GetChildren()) do
            if case.Name:find("Case") then
                fireclickdetector(case.ClickDetector)
            end
        end
        for _, npc in pairs(workspace.NPCs:GetChildren()) do
            if npc:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame
                fireclickdetector(npc.ClickDetector)
            end
        end
    end)
    wait(0.1)
end
]]
local CaseParadiseLoaded = false
local function LoadCaseParadise()
    if not CaseParadiseLoaded then
        loadstring(CaseParadiseScripts)()
        CaseParadiseLoaded = true
    end
    _G.AutoFarm = true
end

-- 18+ Sex Tool (External GUI)
local function LoadSexTool()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CatExec/NSFW/main/SexTool.lua"))()
end

-- TABS & SECTIONS
local UniversalTab = Window:CreateTab("🌐 " .. Lang.Universal, 4483362458)
local CombatTab = Window:CreateTab("⚔️ " .. Lang.Combat, 4483362458)
local MovementTab = Window:CreateTab("🏃 " .. Lang.Movement, 4483362458)
local VisualsTab = Window:CreateTab("👁️ " .. Lang.Visuals, 4483362458)

-- Language Tab
local SettingsTab = Window:CreateTab("⚙️ " .. Lang.Settings, 4483362458)
local LanguageSection = SettingsTab:CreateSection("Język / Language")
local LanguageDropdown = SettingsTab:CreateDropdown({
    Name = Lang.Language,
    Options = {"🇵🇱 Polski", "🇺🇸 English"},
    CurrentOption = LanguageFlags[CurrentLang],
    Callback = function(Option)
        if Option == "🇵🇱 Polski" then
            CurrentLang = "pl"
        else
            CurrentLang = "en"
        end
        Lang = Languages[CurrentLang]
        Rayfield:Destroy()
        loadstring(game:HttpGet('https://sirius.menu/rayfield'))():LoadConfig("TurcjaHub/config")
    end
})

-- Universal Section
local UniversalSection = UniversalTab:CreateSection(Lang.Universal)
UniversalTab:CreateLabel("📱 " .. Lang.GameDetection .. " " .. (GameName == "Brookhaven" and Lang.Brookhaven or GameName == "Case Paradise" and Lang.CaseParadise or Lang.None))

-- Movement Section (All tabs visible)
local MovementSection = MovementTab:CreateSection(Lang.Movement)
local FlyToggle = MovementTab:CreateToggle({
    Name = Lang.Fly,
    CurrentValue = false,
    Callback = function(Value)
        FlyEnabled = Value
        if Value then
            CreateFly()
        else
            if FlyConnection then FlyConnection:Disconnect() end
            if BodyVelocity then BodyVelocity:Destroy() end
            if BodyGyro then BodyGyro:Destroy() end
        end
    end
})

local NoclipToggle = MovementTab:CreateToggle({
    Name = Lang.Noclip,
    CurrentValue = false,
    Callback = function(Value)
        NoclipEnabled = Value
        if Value then
            NoclipConnection = RunService.Stepped:Connect(NoclipLoop)
        else
            if NoclipConnection then NoclipConnection:Disconnect() end
        end
    end
})

local SpeedSlider = MovementTab:CreateSlider({
    Name = Lang.Speed,
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        SpeedValue = Value
    end
})

-- Combat Section
local CombatSection = CombatTab:CreateSection(Lang.Combat)
local FlingAllToggle = CombatTab:CreateToggle({
    Name = Lang.FlingAll,
    CurrentValue = false,
    Callback = function(Value)
        FlingAllEnabled = Value
        if Value then
            FlingConnection = RunService.Heartbeat:Connect(StartFlingAll)
        else
            if FlingConnection then FlingConnection:Disconnect() end
        end
    end
})

local UltimateFlingButton = CombatTab:CreateButton({
    Name = Lang.UltimateFling,
    Callback = function()
        StartFlingAll()
    end
})

-- Visuals Section
local VisualsSection = VisualsTab:CreateSection(Lang.Visuals)
local ESPToggle = VisualsTab:CreateToggle({
    Name = Lang.ESP,
    CurrentValue = false,
    Callback = function(Value)
        ESPEnabled = Value
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                CreateESP(player)
            end
        else
            for player, box in pairs(ESPBoxes) do
                box:Remove()
            end
            ESPBoxes = {}
        end
    end
})

local RainbowESPToggle = VisualsTab:CreateToggle({
    Name = Lang.RainbowESP,
    CurrentValue = false,
    Callback = function(Value)
        RainbowESPEnabled = Value
    end
})

-- Game Specific Tabs
if GameName == "Brookhaven" then
    local BrookhavenTab = Window:CreateTab("🏘️ Brookhaven", 4483362458)
    local BHSection = BrookhavenTab:CreateSection("Brookhaven Admin")
    BrookhavenTab:CreateButton({
        Name = "Admin Panel",
        Callback = function()
            LoadBrookhaven()
        end
    })
end

if GameName == "Case Paradise" then
    local CaseTab = Window:CreateTab("💼 Case Paradise", 4483362458)
    local CaseSection = CaseTab:CreateSection("Auto Farm")
    CaseTab:CreateButton({
        Name = "Start Auto Farm",
        Callback = function()
            LoadCaseParadise()
        end
    })
    CaseTab:CreateButton({
        Name = "Stop Auto Farm",
        Callback = function()
            _G.AutoFarm = false
        end
    })
end

-- Settings
local BoostSection = SettingsTab:CreateSection("Boostery")
local FPSBoostToggle = SettingsTab:CreateToggle({
    Name = Lang.FPSBoost,
    CurrentValue = false,
    Callback = function(Value)
        FPSBoostEnabled = Value
        FPSBoost()
    end
})

local SexToolButton = SettingsTab:CreateButton({
    Name = Lang.SexTool,
    Callback = function()
        LoadSexTool()
    end
})

SettingsTab:CreateButton({
    Name = Lang.SaveConfig,
    Callback = function()
        Rayfield:SaveConfiguration()
    end
})

-- Player connections
Players.PlayerAdded:Connect(function(player)
    if ESPEnabled then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Remove()
        ESPBoxes[player] = nil
    end
end)

print("Turcja Hub v8.0 loaded successfully - All categories fixed!")
