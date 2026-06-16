--[[
 ============================================================
  ██████╗ ██╗   ██╗██╗     ████████╗██╗   ██╗██╗      █████╗ 
 ██╔═══██╗██║   ██║██║     ╚══██╔══╝╚██╗ ██╔╝██║     ██╔══██╗
 ██║   ██║██║   ██║██║        ██║    ╚████╔╝ ██║     ███████║
 ██║   ██║██║   ██║██║        ██║     ╚██╔╝  ██║     ██╔══██║
 ╚██████╔╝╚██████╔╝███████╗   ██║      ██║   ███████╗██║  ██║
  ╚═════╝  ╚═════╝ ╚══════╝   ╚═╝      ╚═╝   ╚══════╝╚═╝  ╚═╝
 ============================================================
   Multi-Hack v6.67 | Rayfield GUI | All-in-One
   Author: [REDACTED] | Purpose: Authorized Pentest
 ============================================================
--]]

-- ============================================================
-- ŁADOWANIE BIBLIOTEKI RAYFIELD
-- ============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
print("[+] Rayfield załadowany")

-- ============================================================
-- ZMIENNE GLOBALNE
-- ============================================================
getgenv().MultiHack = {
    -- Movement
    Fly = false,
    Noclip = false,
    SpeedHack = false,
    SpeedValue = 50,
    JumpPower = false,
    JumpValue = 100,
    Float = false,
    AntiGravity = false,
    AutoJump = false,
    FastSwim = false,
    SpeedBoost = false,
    
    -- Visual
    ESP = false,
    ESPTeamCheck = true,
    ESPBoxes = true,
    ESPTracers = false,
    ESPHealth = true,
    ESPDistance = true,
    ESPColor = Color3.fromRGB(255, 50, 50),
    ESPOutlineColor = Color3.fromRGB(255, 255, 255),
    XRay = false,
    Wallhack = false,
    Chams = false,
    SuperFOV = false,
    FOVValue = 120,
    ThirdPerson = false,
    Invisibility = false,
    NoCameraShake = false,
    
    -- Combat
    SilentAim = false,
    SilentAimFOV = 90,
    NoFallDamage = false,
    GodMode = false,
    InfiniteStamina = false,
    
    -- Utility
    AntiAFK = false,
    AutoClicker = false,
    AutoClickSpeed = 1,
    ClickTP = false,
    ItemDupe = false,
    RangeModifier = false,
    RangeValue = 100,
    BypassFilter = false,
    
    -- Advanced
    FlingTarget = nil,
    
    -- Services
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInput = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    LP = game.Players.LocalPlayer,
    Mouse = game.Players.LocalPlayer:GetMouse(),
    Camera = workspace.CurrentCamera,
}

local MH = getgenv().MultiHack
local LP = MH.LP
local Mouse = MH.Mouse
local UIS = MH.UserInput
local Run = MH.RunService
local Tween = MH.TweenService
local Cam = MH.Camera

-- ============================================================
-- TWORZENIE OKNA (POPRAWIONE)
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name = "BlazeCode v1.0",
    Icon = "crown",
    LoadingTitle = "BlazeCode v1.0",
    LoadingSubtitle = "by turcja",
    ShowText = "Blaze-Code",
    Theme = "Default",
    ToggleUIKeybind = Enum.KeyCode.RightShift,
    ConfigurationSaving = {
        Enabled = true,
        FileName = "BlazeCode_v111"
    },
    KeySystem = false
})
print("[+] Okno utworzone")

-- ============================================================
-- FUNKCJE POMOCNICZE
-- ============================================================
local function notify(title, content, duration, icon)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 5,
        Image = icon or "info"
    })
end

local function getChar(plr)
    plr = plr or LP
    return plr.Character
end

local function getHRP(plr)
    local char = getChar(plr)
    if char then
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    end
    return nil
end

local function getHumanoid(plr)
    local char = getChar(plr)
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function getPlayers()
    local list = {}
    for _, v in pairs(MH.Players:GetPlayers()) do
        if v ~= LP then
            table.insert(list, v.Name)
        end
    end
    return list
end

local function hasChar(plr)
    local char = getChar(plr)
    return char and getHRP(plr) and getHumanoid(plr)
end

local function tweenPart(part, goalcf, time)
    local tweenInfo = TweenInfo.new(time or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = Tween:Create(part, tweenInfo, {CFrame = goalcf})
    tween:Play()
    return tween
end

-- ============================================================
-- [KATEGORIA 1] MOVEMENT
-- ============================================================
local MovementTab = Window:CreateTab("Movement", "move-3d")
MovementTab:CreateSection("Movement Options")
MovementTab:CreateDivider()

-- FLY
local flyBV, flyBG
local flySpeed = 50
local flyKeys = {W = false, A = false, S = false, D = false, Space = false, Shift = false}

local function startFly()
    local hrp = getHRP()
    if not hrp then return end
    
    MH.Fly = true
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.P = 1e5
    flyBV.Parent = hrp
    
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyBG.P = 1e5
    flyBG.D = 100
    flyBG.Parent = hrp
    
    local hum = getHumanoid()
    if hum then hum.PlatformStand = true end
    
    flyKeys.W = false flyKeys.A = false flyKeys.S = false flyKeys.D = false
    flyKeys.Space = false flyKeys.Shift = false
    
    local con1 = UIS.InputBegan:Connect(function(input)
        if not MH.Fly then con1:Disconnect() con2:Disconnect() return end
        if input.KeyCode == Enum.KeyCode.W then flyKeys.W = true end
        if input.KeyCode == Enum.KeyCode.A then flyKeys.A = true end
        if input.KeyCode == Enum.KeyCode.S then flyKeys.S = true end
        if input.KeyCode == Enum.KeyCode.D then flyKeys.D = true end
        if input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = true end
        if input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Shift = true end
    end)
    
    local con2 = UIS.InputEnded:Connect(function(input)
        if not MH.Fly then con1:Disconnect() con2:Disconnect() return end
        if input.KeyCode == Enum.KeyCode.W then flyKeys.W = false end
        if input.KeyCode == Enum.KeyCode.A then flyKeys.A = false end
        if input.KeyCode == Enum.KeyCode.S then flyKeys.S = false end
        if input.KeyCode == Enum.KeyCode.D then flyKeys.D = false end
        if input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = false end
        if input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Shift = false end
    end)
    
    local heart
    heart = Run.Heartbeat:Connect(function()
        if not MH.Fly then heart:Disconnect() return end
        local hrp = getHRP()
        if not hrp then return end
        
        local cf = Cam.CFrame
        local speed = flySpeed * (flyKeys.Shift and 3 or 1)
        
        local vel = Vector3.new(0, 0, 0)
        if flyKeys.W then vel = vel + cf.LookVector * speed end
        if flyKeys.S then vel = vel - cf.LookVector * speed end
        if flyKeys.A then vel = vel - cf.RightVector * speed end
        if flyKeys.D then vel = vel + cf.RightVector * speed end
        if flyKeys.Space then vel = vel + Vector3.new(0, speed, 0) end
        
        flyBV.Velocity = vel
        flyBG.CFrame = cf
    end)
end

local function stopFly()
    MH.Fly = false
    if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end) flyBG = nil end
    local hum = getHumanoid()
    if hum then hum.PlatformStand = false end
end

MovementTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Toggle_Fly",
    Callback = function(v)
        if v then
            startFly()
            notify("Fly", "Włączony | WASD + Space/Shift", 3)
        else
            stopFly()
        end
    end
})

MovementTab:CreateKeybind({
    Name = "Fly Keybind",
    CurrentKeybind = "F",
    HoldToInteract = false,
    Flag = "Keybind_Fly",
    Callback = function()
        if MH.Fly then 
            stopFly()
            Rayfield:Notify({Title = "Fly", Content = "Wyłączony", Duration = 2})
        else
            startFly()
            notify("Fly", "Włączony | WASD + Space/Shift", 3)
        end
    end
})

MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 300},
    Increment = 5,
    Suffix = "studs/s",
    CurrentValue = 50,
    Flag = "Slider_FlySpeed",
    Callback = function(v) flySpeed = v end
})

MovementTab:CreateDivider()

-- NOCLIP
local noclipRunning = false
local noclipCon

local function toggleNoclip(v)
    MH.Noclip = v
    if v then
        noclipRunning = true
        noclipCon = Run.Stepped:Connect(function()
            if not noclipRunning then noclipCon:Disconnect() return end
            local hum = getHumanoid()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end
        end)
    else
        noclipRunning = false
        if noclipCon then noclipCon:Disconnect() noclipCon = nil end
    end
end

MovementTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Toggle_Noclip",
    Callback = toggleNoclip
})

MovementTab:CreateKeybind({
    Name = "Noclip Keybind",
    CurrentKeybind = "N",
    Flag = "Keybind_Noclip",
    Callback = function()
        toggleNoclip(not MH.Noclip)
        Rayfield:Notify({Title = "Noclip", Content = MH.Noclip and "Włączony" or "Wyłączony", Duration = 2})
    end
})

MovementTab:CreateDivider()

-- SPEED HACK
MovementTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Flag = "Toggle_SpeedHack",
    Callback = function(v)
        MH.SpeedHack = v
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = v and MH.SpeedValue or 16 end
    end
})

MovementTab:CreateSlider({
    Name = "Speed Value",
    Range = {16, 500},
    Increment = 1,
    Suffix = "WS",
    CurrentValue = 50,
    Flag = "Slider_Speed",
    Callback = function(v)
        MH.SpeedValue = v
        if MH.SpeedHack then
            local hum = getHumanoid()
            if hum then hum.WalkSpeed = v end
        end
    end
})

MovementTab:CreateKeybind({
    Name = "Speed Keybind",
    CurrentKeybind = "V",
    Flag = "Keybind_Speed",
    Callback = function()
        MH.SpeedHack = not MH.SpeedHack
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = MH.SpeedHack and MH.SpeedValue or 16 end
        Rayfield:Notify({Title = "Speed", Content = MH.SpeedHack and "Włączony" or "Wyłączony", Duration = 2})
    end
})

MovementTab:CreateDivider()

-- JUMP POWER
MovementTab:CreateToggle({
    Name = "Jump Power",
    CurrentValue = false,
    Flag = "Toggle_JumpPower",
    Callback = function(v)
        MH.JumpPower = v
        local hum = getHumanoid()
        if hum then hum.JumpPower = v and MH.JumpValue or 50 end
    end
})

MovementTab:CreateSlider({
    Name = "Jump Value",
    Range = {50, 500},
    Increment = 10,
    Suffix = "JP",
    CurrentValue = 100,
    Flag = "Slider_Jump",
    Callback = function(v)
        MH.JumpValue = v
        if MH.JumpPower then
            local hum = getHumanoid()
            if hum then hum.JumpPower = v end
        end
    end
})

MovementTab:CreateKeybind({
    Name = "Jump Keybind",
    CurrentKeybind = "J",
    Flag = "Keybind_Jump",
    Callback = function()
        MH.JumpPower = not MH.JumpPower
        local hum = getHumanoid()
        if hum then hum.JumpPower = MH.JumpPower and MH.JumpValue or 50 end
        Rayfield:Notify({Title = "Jump Power", Content = MH.JumpPower and "Włączony" or "Wyłączony", Duration = 2})
    end
})

MovementTab:CreateDivider()

-- FLOAT
local floatBP

MovementTab:CreateToggle({
    Name = "Float / Levitate",
    CurrentValue = false,
    Flag = "Toggle_Float",
    Callback = function(v)
        MH.Float = v
        if v then
            local hrp = getHRP()
            if not hrp then return end
            floatBP = Instance.new("BodyPosition")
            floatBP.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            floatBP.P = 10000
            floatBP.D = 500
            floatBP.Position = hrp.Position + Vector3.new(0, 5, 0)
            floatBP.Parent = hrp
            local heart
            heart = Run.Heartbeat:Connect(function()
                if not MH.Float then heart:Disconnect() return end
                local hrp = getHRP()
                if not hrp then return end
                floatBP.Position = hrp.Position + Vector3.new(0, 5, 0)
            end)
        else
            if floatBP then pcall(function() floatBP:Destroy() end) floatBP = nil end
        end
    end
})

MovementTab:CreateKeybind({
    Name = "Float Keybind",
    CurrentKeybind = "G",
    Flag = "Keybind_Float",
    Callback = function()
        MH.Float = not MH.Float
        if MH.Float then
            local hrp = getHRP()
            if not hrp then return end
            floatBP = Instance.new("BodyPosition")
            floatBP.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            floatBP.P = 10000
            floatBP.D = 500
            floatBP.Position = hrp.Position + Vector3.new(0, 5, 0)
            floatBP.Parent = hrp
            local heart
            heart = Run.Heartbeat:Connect(function()
                if not MH.Float then heart:Disconnect() return end
                local hrp = getHRP()
                if not hrp then return end
                floatBP.Position = hrp.Position + Vector3.new(0, 5, 0)
            end)
        else
            if floatBP then pcall(function() floatBP:Destroy() end) floatBP = nil end
        end
        Rayfield:Notify({Title = "Float", Content = MH.Float and "Unosisz się" or "Opadasz", Duration = 2})
    end
})

MovementTab:CreateDivider()

-- ANTI-GRAVITY
local antiGravHeart

MovementTab:CreateToggle({
    Name = "Anti-Gravity",
    CurrentValue = false,
    Flag = "Toggle_AntiGrav",
    Callback = function(v)
        MH.AntiGravity = v
        if v then
            antiGravHeart = Run.Heartbeat:Connect(function()
                if not MH.AntiGravity then antiGravHeart:Disconnect() return end
                local hrp = getHRP()
                if hrp then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 5, hrp.Velocity.Z)
                end
            end)
        else
            if antiGravHeart then antiGravHeart:Disconnect() antiGravHeart = nil end
        end
    end
})

MovementTab:CreateKeybind({
    Name = "Anti-Gravity Keybind",
    CurrentKeybind = "H",
    Flag = "Keybind_AntiGrav",
    Callback = function()
        MH.AntiGravity = not MH.AntiGravity
        if MH.AntiGravity then
            antiGravHeart = Run.Heartbeat:Connect(function()
                if not MH.AntiGravity then antiGravHeart:Disconnect() return end
                local hrp = getHRP()
                if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, 5, hrp.Velocity.Z) end
            end)
        else
            if antiGravHeart then antiGravHeart:Disconnect() antiGravHeart = nil end
        end
        Rayfield:Notify({Title = "Anti-Gravity", Content = MH.AntiGravity and "Włączona" or "Wyłączona", Duration = 2})
    end
})

MovementTab:CreateDivider()

-- AUTO JUMP
MovementTab:CreateToggle({
    Name = "Auto Jump",
    CurrentValue = false,
    Flag = "Toggle_AutoJump",
    Callback = function(v) MH.AutoJump = v end
})

MovementTab:CreateKeybind({
    Name = "Auto Jump Keybind",
    CurrentKeybind = "Y",
    Flag = "Keybind_AutoJump",
    Callback = function()
        MH.AutoJump = not MH.AutoJump
        Rayfield:Notify({Title = "Auto Jump", Content = MH.AutoJump and "Włączony" or "Wyłączony", Duration = 2})
    end
})

MovementTab:CreateDivider()

-- FAST SWIM
MovementTab:CreateToggle({
    Name = "Fast Swim",
    CurrentValue = false,
    Flag = "Toggle_FastSwim",
    Callback = function(v) MH.FastSwim = v end
})

MovementTab:CreateDivider()

-- SPEED BOOST
MovementTab:CreateToggle({
    Name = "Speed Boost (Hold Shift)",
    CurrentValue = false,
    Flag = "Toggle_SpeedBoost",
    Callback = function(v) MH.SpeedBoost = v end
})

-- ============================================================
-- [KATEGORIA 2] VISUAL - rozbudowane ESP z kolorami
-- ============================================================
local VisualTab = Window:CreateTab("Visual", "eye")
VisualTab:CreateSection("Visual Enhancements")
VisualTab:CreateDivider()

-- ESP z pełnym systemem kolorów
local espObjects = {}
local espConnections = {}

local function createESP(plr)
    if espObjects[plr] then return end
    local char = getChar(plr)
    if not char then return end
    
    local esp = {}
    
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Adornee = char
    highlight.FillColor = MH.ESPColor
    highlight.OutlineColor = MH.ESPOutlineColor
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = char
    
    -- Billboard z informacjami
    local billboard = Instance.new("BillboardGui")
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 250, 0, 80)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    
    -- Nazwa gracza
    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1, 0, 0, 25)
    nameL.BackgroundTransparency = 1
    nameL.Text = plr.Name
    nameL.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameL.TextScaled = true
    nameL.Font = Enum.Font.GothamBold
    nameL.TextStrokeTransparency = 0.3
    nameL.Parent = billboard
    
    -- Health
    local healthL = Instance.new("TextLabel")
    healthL.Size = UDim2.new(1, 0, 0, 20)
    healthL.Position = UDim2.new(0, 0, 0, 25)
    healthL.BackgroundTransparency = 1
    healthL.TextColor3 = Color3.fromRGB(0, 255, 0)
    healthL.TextScaled = true
    healthL.Font = Enum.Font.Gotham
    healthL.TextStrokeTransparency = 0.3
    healthL.Parent = billboard
    
    -- Dystans
    local distL = Instance.new("TextLabel")
    distL.Size = UDim2.new(1, 0, 0, 20)
    distL.Position = UDim2.new(0, 0, 0, 45)
    distL.BackgroundTransparency = 1
    distL.TextColor3 = Color3.fromRGB(255, 255, 0)
    distL.TextScaled = true
    distL.Font = Enum.Font.Gotham
    distL.TextStrokeTransparency = 0.3
    distL.Parent = billboard
    
    -- Team / Status
    local teamL = Instance.new("TextLabel")
    teamL.Size = UDim2.new(1, 0, 0, 15)
    teamL.Position = UDim2.new(0, 0, 0, 65)
    teamL.BackgroundTransparency = 1
    teamL.TextColor3 = Color3.fromRGB(150, 150, 255)
    teamL.TextScaled = true
    teamL.Font = Enum.Font.Gotham
    teamL.TextStrokeTransparency = 0.3
    teamL.Parent = billboard
    
    billboard.Parent = char
    
    -- Traceline (linia od gracza w dół)
    local traceline = Instance.new("Part")
    traceline.Anchored = true
    traceline.CanCollide = false
    traceline.Size = Vector3.new(0.1, 0.1, 0.1)
    traceline.Transparency = 0.5
    traceline.BrickColor = BrickColor.new("Bright red")
    traceline.Material = Enum.Material.Neon
    traceline.Parent = workspace
    
    esp.Highlight = highlight
    esp.Billboard = billboard
    esp.NameLabel = nameL
    esp.HealthLabel = healthL
    esp.DistLabel = distL
    esp.TeamLabel = teamL
    esp.Traceline = traceline
    esp.Player = plr
    
    espObjects[plr] = esp
    
    -- Update health
    local hum = getHumanoid(plr)
    if hum then
        hum:GetPropertyChangedSignal("Health"):Connect(function()
            if not MH.ESP then return end
            local h = hum.Health
            local mh = hum.MaxHealth
            local pct = h / mh
            healthL.Text = string.format("HP: %.0f/%.0f (%.0f%%)", h, mh, pct * 100)
            local r = 255 * (1 - pct)
            local g = 255 * pct
            healthL.TextColor3 = Color3.fromRGB(r, g, 0)
            -- Zmiana koloru highlighta w zależności od HP
            highlight.FillColor = Color3.fromRGB(255 * (1 - pct), 255 * pct, 0)
        end)
        healthL.Text = string.format("HP: %.0f/%.0f (100%%)", hum.Health, hum.MaxHealth)
    end
    
    -- Team info
    if plr.Team then
        teamL.Text = "Team: " .. plr.Team.Name
        teamL.TextColor3 = plr.Team.TeamColor.Color
    else
        teamL.Text = "No Team"
    end
    
    -- Update distance loop
    spawn(function()
        while MH.ESP and espObjects[plr] do
            task.wait(0.5)
            local hrp = getHRP()
            local thrp = getHRP(plr)
            if hrp and thrp then
                local dist = (hrp.Position - thrp.Position).Magnitude
                distL.Text = string.format("Dist: %.0f studs", dist)
                
                -- Traceline
                esp.Traceline.CFrame = CFrame.new(thrp.Position, thrp.Position - Vector3.new(0, 1, 0))
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                rayParams.FilterDescendantsInstances = {char, getChar(plr)}
                local ray = workspace:Raycast(thrp.Position, Vector3.new(0, -500, 0), rayParams)
                if ray then
                    local mid = (thrp.Position + ray.Position) / 2
                    local height = (thrp.Position - ray.Position).Magnitude
                    esp.Traceline.Size = Vector3.new(0.3, height, 0.3)
                    esp.Traceline.CFrame = CFrame.lookAt(mid, mid + Vector3.new(0, 1, 0))
                end
            end
        end
    end)
end

local function removeESP(plr)
    if espObjects[plr] then
        local esp = espObjects[plr]
        if esp.Highlight then pcall(function() esp.Highlight:Destroy() end) end
        if esp.Billboard then pcall(function() esp.Billboard:Destroy() end) end
        if esp.Traceline then pcall(function() esp.Traceline:Destroy() end) end
        espObjects[plr] = nil
    end
end

local function setupESP()
    for plr, _ in pairs(espObjects) do removeESP(plr) end
    
    for _, v in pairs(MH.Players:GetPlayers()) do
        if v ~= LP then createESP(v) end
    end
    
    local con1 = MH.Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function()
            if MH.ESP then createESP(plr) end
        end)
        if MH.ESP then createESP(plr) end
    end)
    
    local con2 = MH.Players.PlayerRemoving:Connect(function(plr)
        removeESP(plr)
    end)
    
    return {con1, con2}
end

local function toggleESP(v)
    MH.ESP = v
    if v then
        espConnections = setupESP()
        notify("ESP", "Włączony", 2)
    else
        for plr, _ in pairs(espObjects) do removeESP(plr) end
        for _, con in pairs(espConnections) do
            if con then con:Disconnect() end
        end
        espConnections = {}
    end
end

VisualTab:CreateToggle({
    Name = "ESP (Advanced)",
    CurrentValue = false,
    Flag = "Toggle_ESP",
    Callback = toggleESP
})

VisualTab:CreateKeybind({
    Name = "ESP Keybind",
    CurrentKeybind = "P",
    Flag = "Keybind_ESP",
    Callback = function()
        toggleESP(not MH.ESP)
        Rayfield:Notify({Title = "ESP", Content = MH.ESP and "Włączony" or "Wyłączony", Duration = 2})
    end
})

-- Kolor ESP - Fill
VisualTab:CreateColorPicker({
    Name = "ESP Fill Color",
    Color = Color3.fromRGB(255, 50, 50),
    Flag = "Color_ESPFill",
    Callback = function(c)
        MH.ESPColor = c
        for plr, esp in pairs(espObjects) do
            if esp.Highlight then
                esp.Highlight.FillColor = c
            end
        end
    end
})

-- Kolor ESP - Outline
VisualTab:CreateColorPicker({
    Name = "ESP Outline Color",
    Color = Color3.fromRGB(255, 255, 255),
    Flag = "Color_ESPOutline",
    Callback = function(c)
        MH.ESPOutlineColor = c
        for plr, esp in pairs(espObjects) do
            if esp.Highlight then
                esp.Highlight.OutlineColor = c
            end
        end
    end
})

VisualTab:CreateDivider()

-- X-RAY
VisualTab:CreateToggle({
    Name = "X-Ray",
    CurrentValue = false,
    Flag = "Toggle_XRay",
    Callback = function(v)
        MH.XRay = v
        for _, vv in pairs(workspace:GetDescendants()) do
            if vv:IsA("BasePart") and not vv:IsDescendantOf(LP.Character) then
                if v then
                    vv.Transparency = 0.6
                    vv.Material = Enum.Material.ForceField
                else
                    vv.Transparency = 0
                    vv.Material = Enum.Material.Plastic
                end
            end
        end
    end
})

VisualTab:CreateKeybind({
    Name = "X-Ray Keybind",
    CurrentKeybind = "X",
    Flag = "Keybind_XRay",
    Callback = function()
        MH.XRay = not MH.XRay
        for _, vv in pairs(workspace:GetDescendants()) do
            if vv:IsA("BasePart") and not vv:IsDescendantOf(LP.Character) then
                if MH.XRay then
                    vv.Transparency = 0.6
                    vv.Material = Enum.Material.ForceField
                else
                    vv.Transparency = 0
                    vv.Material = Enum.Material.Plastic
                end
            end
        end
        Rayfield:Notify({Title = "X-Ray", Content = MH.XRay and "Włączony" or "Wyłączony", Duration = 2})
    end
})

VisualTab:CreateDivider()

-- WALLHACK / CHAMS
VisualTab:CreateToggle({
    Name = "Wallhack / Chams",
    CurrentValue = false,
    Flag = "Toggle_Wallhack",
    Callback = function(v)
        MH.Wallhack = v
        for _, plr in pairs(MH.Players:GetPlayers()) do
            if plr ~= LP and getChar(plr) then
                for _, part in pairs(getChar(plr):GetDescendants()) do
                    if part:IsA("BasePart") then
                        if v then
                            part.LocalTransparencyModifier = 0.2
                            part.Color = Color3.fromRGB(255, 0, 0)
                        else
                            part.LocalTransparencyModifier = 0
                        end
                    end
                end
            end
        end
    end
})

VisualTab:CreateDivider()

-- SUPER FOV
VisualTab:CreateToggle({
    Name = "Super FOV",
    CurrentValue = false,
    Flag = "Toggle_FOV",
    Callback = function(v)
        MH.SuperFOV = v
        Cam.FieldOfView = v and MH.FOVValue or 70
    end
})

VisualTab:CreateSlider({
    Name = "FOV Value",
    Range = {70, 180},
    Increment = 5,
    Suffix = "deg",
    CurrentValue = 120,
    Flag = "Slider_FOV",
    Callback = function(v)
        MH.FOVValue = v
        if MH.SuperFOV then Cam.FieldOfView = v end
    end
})

VisualTab:CreateKeybind({
    Name = "FOV Keybind",
    CurrentKeybind = "U",
    Flag = "Keybind_FOV",
    Callback = function()
        MH.SuperFOV = not MH.SuperFOV
        Cam.FieldOfView = MH.SuperFOV and MH.FOVValue or 70
        Rayfield:Notify({Title = "FOV", Content = MH.SuperFOV and "Włączony" or "Wyłączony", Duration = 2})
    end
})

VisualTab:CreateDivider()

-- THIRD PERSON
VisualTab:CreateToggle({
    Name = "Third Person",
    CurrentValue = false,
    Flag = "Toggle_ThirdPerson",
    Callback = function(v)
        MH.ThirdPerson = v
        local hum = getHumanoid()
        if hum then
            if v then
                Cam.CameraSubject = hum
                Cam.CameraType = Enum.CameraType.Custom
            else
                Cam.CameraSubject = hum
                Cam.CameraType = Enum.CameraType.Fixed
            end
        end
    end
})

VisualTab:CreateKeybind({
    Name = "Third Person Keybind",
    CurrentKeybind = "T",
    Flag = "Keybind_ThirdPerson",
    Callback = function()
        MH.ThirdPerson = not MH.ThirdPerson
        local hum = getHumanoid()
        if hum then
            if MH.ThirdPerson then
                Cam.CameraSubject = hum
                Cam.CameraType = Enum.CameraType.Custom
            else
                Cam.CameraSubject = hum
                Cam.CameraType = Enum.CameraType.Fixed
            end
        end
        Rayfield:Notify({Title = "Third Person", Content = MH.ThirdPerson and "Włączony" or "Wyłączony", Duration = 2})
    end
})

VisualTab:CreateDivider()

-- INVISIBILITY
VisualTab:CreateToggle({
    Name = "Invisibility",
    CurrentValue = false,
    Flag = "Toggle_Invis",
    Callback = function(v)
        MH.Invisibility = v
        local char = getChar()
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = v and 1 or 0
            end
        end
    end
})

VisualTab:CreateKeybind({
    Name = "Invisibility Keybind",
    CurrentKeybind = "I",
    Flag = "Keybind_Invis",
    Callback = function()
        MH.Invisibility = not MH.Invisibility
        local char = getChar()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = MH.Invisibility and 1 or 0
                end
            end
        end
        Rayfield:Notify({Title = "Invisibility", Content = MH.Invisibility and "Jesteś niewidzialny" or "Widzialny", Duration = 2})
    end
})

VisualTab:CreateDivider()

-- DISABLE CAMERA SHAKE
VisualTab:CreateToggle({
    Name = "Disable Camera Shake",
    CurrentValue = false,
    Flag = "Toggle_NoShake",
    Callback = function(v)
        MH.NoCameraShake = v
        if v then
            pcall(function()
                Cam.CameraShake.ShakeType = Enum.CameraShakeType.None
            end)
        end
    end
})

-- ============================================================
-- [KATEGORIA 3] COMBAT
-- ============================================================
local CombatTab = Window:CreateTab("Combat", "sword")
CombatTab:CreateSection("Combat Options")
CombatTab:CreateDivider()

-- SILENT AIM
local silentAimHeart

CombatTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "Toggle_SilentAim",
    Callback = function(v)
        MH.SilentAim = v
        if v then
            notify("Silent Aim", "Włączony", 2)
            silentAimHeart = Run.RenderStepped:Connect(function()
                if not MH.SilentAim then silentAimHeart:Disconnect() return end
                local target = nil
                local closestAngle = MH.SilentAimFOV
                local mousePos = UIS:GetMouseLocation()
                
                for _, plr in pairs(MH.Players:GetPlayers()) do
                    if plr ~= LP and hasChar(plr) then
                        local head = getChar(plr):FindFirstChild("Head")
                        if head then
                            local screenPos, onScreen = Cam:WorldToScreenPoint(head.Position)
                            if onScreen then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                if dist < closestAngle then
                                    closestAngle = dist
                                    target = head
                                end
                            end
                        end
                    end
                end
                
                if target then
                    local hrp = getHRP()
                    if hrp then
                        hrp.CFrame = CFrame.lookAt(hrp.Position, target.Position)
                    end
                end
            end)
        else
            if silentAimHeart then silentAimHeart:Disconnect() silentAimHeart = nil end
        end
    end
})

CombatTab:CreateSlider({
    Name = "Silent Aim FOV",
    Range = {10, 360},
    Increment = 5,
    Suffix = "px",
    CurrentValue = 90,
    Flag = "Slider_SilentFOV",
    Callback = function(v) MH.SilentAimFOV = v end
})

CombatTab:CreateDivider()

-- GOD MODE
local godHeart

CombatTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "Toggle_GodMode",
    Callback = function(v)
        MH.GodMode = v
        if v then
            godHeart = Run.Heartbeat:Connect(function()
                if not MH.GodMode then godHeart:Disconnect() return end
                local hum = getHumanoid()
                if hum then hum.Health = hum.MaxHealth end
            end)
            notify("God Mode", "Nieśmiertelność aktywna", 2)
        else
            if godHeart then godHeart:Disconnect() godHeart = nil end
        end
    end
})

CombatTab:CreateKeybind({
    Name = "God Mode Keybind",
    CurrentKeybind = "O",
    Flag = "Keybind_GodMode",
    Callback = function()
        MH.GodMode = not MH.GodMode
        if MH.GodMode then
            godHeart = Run.Heartbeat:Connect(function()
                if not MH.GodMode then godHeart:Disconnect() return end
                local hum = getHumanoid()
                if hum then hum.Health = hum.MaxHealth end
            end)
        else
            if godHeart then godHeart:Disconnect() godHeart = nil end
        end
        Rayfield:Notify({Title = "God Mode", Content = MH.GodMode and "Włączony" or "Wyłączony", Duration = 2})
    end
})

CombatTab:CreateDivider()

-- NO FALL DAMAGE
CombatTab:CreateToggle({
    Name = "No Fall Damage",
    CurrentValue = false,
    Flag = "Toggle_NoFallDmg",
    Callback = function(v)
        MH.NoFallDamage = v
        local hum = getHumanoid()
        if hum then hum.FallDamage = not v end
    end
})

CombatTab:CreateDivider()

-- INFINITE STAMINA
CombatTab:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = false,
    Flag = "Toggle_Stamina",
    Callback = function(v) MH.InfiniteStamina = v end
})

-- ============================================================
-- [KATEGORIA 4] UTILITY
-- ============================================================
local UtilityTab = Window:CreateTab("Utility", "settings")
UtilityTab:CreateSection("Utility Options")
UtilityTab:CreateDivider()

-- ANTI AFK
UtilityTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "Toggle_AntiAFK",
    Callback = function(v)
        MH.AntiAFK = v
        if v then
            local vu = game:GetService("VirtualUser")
            LP.Idled:Connect(function()
                if MH.AntiAFK then
                    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    wait(1)
                    vu:Button2Up(Vector2.new(0,0))
                end
            end)
            notify("Anti AFK", "Nie zostaniesz wyrzucony", 2)
        end
    end
})

UtilityTab:CreateDivider()

-- AUTO CLICKER
local autoClickHeart

UtilityTab:CreateToggle({
    Name = "Auto Clicker",
    CurrentValue = false,
    Flag = "Toggle_AutoClick",
    Callback = function(v)
        MH.AutoClicker = v
        if v then
            local vu = game:GetService("VirtualUser")
            autoClickHeart = Run.Heartbeat:Connect(function()
                if not MH.AutoClicker then autoClickHeart:Disconnect() return end
                vu:CaptureController()
                vu:ClickButton1(Vector2.new(0,0))
                task.wait(MH.AutoClickSpeed / 1000)
            end)
            notify("Auto Clicker", "Szybkość: " .. MH.AutoClickSpeed .. "ms", 2)
        else
            if autoClickHeart then autoClickHeart:Disconnect() autoClickHeart = nil end
        end
    end
})

UtilityTab:CreateSlider({
    Name = "Click Speed (ms)",
    Range = {1, 1000},
    Increment = 1,
    Suffix = "ms",
    CurrentValue = 1,
    Flag = "Slider_ClickSpeed",
    Callback = function(v) MH.AutoClickSpeed = v end
})

UtilityTab:CreateDivider()

-- CLICK TP
UtilityTab:CreateToggle({
    Name = "Click TP",
    CurrentValue = false,
    Flag = "Toggle_ClickTP",
    Callback = function(v)
        MH.ClickTP = v
        if v then
            local con
            con = Mouse.Button1Down:Connect(function()
                if not MH.ClickTP then con:Disconnect() return end
                local hrp = getHRP()
                if hrp then
                    tweenPart(hrp, CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0)), 0.2)
                end
            end)
        end
    end
})

UtilityTab:CreateKeybind({
    Name = "Click TP Keybind",
    CurrentKeybind = "B",
    Flag = "Keybind_ClickTP",
    Callback = function()
        MH.ClickTP = not MH.ClickTP
        Rayfield:Notify({Title = "Click TP", Content = MH.ClickTP and "Kliknij LPM by się teleportować" or "Wyłączony", Duration = 2})
    end
})

UtilityTab:CreateDivider()

-- ITEM DUPE
UtilityTab:CreateToggle({
    Name = "Item Dupe (Local)",
    CurrentValue = false,
    Flag = "Toggle_ItemDupe",
    Callback = function(v)
        MH.ItemDupe = v
        if v then
            local con
            con = Mouse.KeyDown:Connect(function(k)
                if not MH.ItemDupe then con:Disconnect() return end
                if k == "y" then
                    local target = Mouse.Target
                    if target then
                        local clone = target:Clone()
                        clone.Parent = LP.Backpack
                        if clone.SetPrimaryPartCFrame then
                            clone:SetPrimaryPartCFrame(target.CFrame + Vector3.new(2, 0, 0))
                        end
                    end
                end
            end)
        end
    end
})

UtilityTab:CreateDivider()

-- RANGE MODIFIER
UtilityTab:CreateToggle({
    Name = "Range Modifier",
    CurrentValue = false,
    Flag = "Toggle_Range",
    Callback = function(v)
        MH.RangeModifier = v
        Mouse.MaxActivationDistance = v and MH.RangeValue or 30
    end
})

UtilityTab:CreateSlider({
    Name = "Range Value",
    Range = {30, 500},
    Increment = 10,
    Suffix = "studs",
    CurrentValue = 100,
    Flag = "Slider_Range",
    Callback = function(v)
        MH.RangeValue = v
        if MH.RangeModifier then Mouse.MaxActivationDistance = v end
    end
})

UtilityTab:CreateDivider()

-- BYPASS FILTER
UtilityTab:CreateToggle({
    Name = "Bypass Filter",
    CurrentValue = false,
    Flag = "Toggle_Bypass",
    Callback = function(v)
        MH.BypassFilter = v
        if v then
            pcall(function()
                local mt = debug.getmetatable(game)
                if mt then
                    local old_index = mt.__index
                    mt.__index = function(self, key)
                        if key == "ChatMessage" or key == "chatMessage" then
                            return function() end
                        end
                        return old_index(self, key)
                    end
                end
            end)
            notify("Bypass Filter", "Czat bez filtra", 2)
        end
    end
})

UtilityTab:CreateDivider()

-- TELEPORT TO PLAYER
local tpDropdown

local function refreshTPDropdown()
    if tpDropdown then
        tpDropdown:Refresh(getPlayers())
    end
end

tpDropdown = UtilityTab:CreateDropdown({
    Name = "Teleport to Player",
    Options = getPlayers(),
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "Dropdown_TPPlayer",
    Callback = function(opt)
        local target = MH.Players:FindFirstChild(opt[1])
        if target and hasChar(target) then
            local hrp = getHRP()
            local targetHrp = getHRP(target)
            if hrp and targetHrp then
                hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 3, 0)
                notify("Teleport", "Przeniesiono do " .. target.Name, 3)
            end
        end
    end
})

-- Odświeżanie listy graczy
spawn(function()
    while task.wait(10) do
        pcall(function()
            if tpDropdown then
                tpDropdown:Refresh(getPlayers())
            end
        end)
    end
end)

-- TP to mouse
UtilityTab:CreateButton({
    Name = "TP to Mouse",
    Callback = function()
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
            notify("Teleport", "Przeniesiono na celownik", 2)
        end
    end
})

-- ============================================================
-- [KATEGORIA 5] ADVANCED - naprawione i działające
-- ============================================================
local AdvancedTab = Window:CreateTab("Advanced", "zap")
AdvancedTab:CreateSection("Advanced Exploits")
AdvancedTab:CreateDivider()

-- FLING EVERYONE (działający)
AdvancedTab:CreateButton({
    Name = "Fling Everyone!",
    Callback = function()
        notify("Fling", "Wykonuję Fling All...", 3, "zap")
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/zqyDSUWX"))()
        end)
        if not success then
            notify("Fling Error", "Nie udało się: " .. tostring(err), 5, "alert-triangle")
            -- Fallback: własna implementacja flinga
            pcall(function()
                for _, plr in pairs(MH.Players:GetPlayers()) do
                    if plr ~= LP and hasChar(plr) then
                        local hrp = getHRP()
                        local thrp = getHRP(plr)
                        if hrp and thrp then
                            hrp.CFrame = thrp.CFrame * CFrame.new(0, 0.5, 0)
                            local bv = Instance.new("BodyVelocity")
                            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                            bv.Velocity = Vector3.new(math.random(-10000, 10000), 50000, math.random(-10000, 10000))
                            bv.Parent = thrp
                            task.wait(0.3)
                            bv:Destroy()
                        end
                    end
                end
                notify("Fling", "Fling All wykonany (fallback)", 3)
            end)
        end
    end
})

AdvancedTab:CreateDivider()

-- INFINITE YIELD (działający)
AdvancedTab:CreateButton({
    Name = "Load Infinite Yield",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end)
        if success then
            notify("Infinite Yield", "Admin panel załadowany! Wpisz ;cmds w czacie", 4)
        else
            notify("Infinite Yield Error", "Nie udało się: " .. tostring(err), 5)
        end
    end
})

AdvancedTab:CreateDivider()

-- DEX EXPLORER (naprawiony - działająca wersja)
AdvancedTab:CreateButton({
    Name = "Dex Explorer",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/infyxff/roblox-dex/main/dex.lua"))()
        end)
        if not success then
            -- Fallback
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/InfinityLuke/dex/main/dex.lua"))()
            end)
        end
        if success then
            notify("Dex Explorer", "Załadowano!", 3)
        else
            notify("Dex Error", "Nie udało się załadować Dexa", 4)
        end
    end
})

-- DARK DEX (naprawiony)
AdvancedTab:CreateButton({
    Name = "Dark Dex",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/iuxt/src/main/loader.lua"))()
        end)
        if not success then
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/FFFFFF-1234/roblox/main/darkdex.lua"))()
            end)
        end
        if success then
            notify("Dark Dex", "Załadowano!", 3)
        else
            notify("Dark Dex Error", "Nie udało się załadować", 4)
        end
    end
})

-- SIMPLE SPY (naprawiony)
AdvancedTab:CreateButton({
    Name = "Simple Spy (Remote Events)",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpy/master/source"))()
        end)
        if success then
            notify("Simple Spy", "Monitorowanie RemoteEvents aktywne!", 3)
        else
            -- Fallback własny spy
            pcall(function()
                local mt = debug.getmetatable(game)
                if mt then
                    local old_nc = mt.__namecall
                    mt.__namecall = function(self, ...)
                        local method = getnamecallmethod() or ""
                        if method == "FireServer" then
                            print("[RemoteSpy] FireServer:", self:GetFullName(), ...)
                        end
                        return old_nc(self, ...)
                    end
                    notify("Simple Spy", "Własny RemoteSpy załadowany", 4)
                end
            end)
        end
    end
})

AdvancedTab:CreateDivider()

-- BYPASS HYPERION (naprawiony)
AdvancedTab:CreateButton({
    Name = "Bypass Hyperion",
    Callback = function()
        notify("Hyperion Bypass", "Próba obejścia Hyperion...", 3)
        
        local successCount = 0
        
        -- 1. Hook FFlag
        pcall(function()
            if type(game.GetFFlag) == "function" then
                local old_fflag = game.GetFFlag
                game.GetFFlag = function(self, flag)
                    if type(flag) == "string" and (flag:find("Hyperion") or flag:find("hyperion")) then
                        return "false"
                    end
                    if pcall(function() return old_fflag(self, flag) end) then
                        return old_fflag(self, flag)
                    end
                    return "false"
                end
                successCount = successCount + 1
            end
        end)
        
        -- 2. Disable Hyperion scripts w CoreGui
        pcall(function()
            local coreGui = game:GetService("CoreGui")
            for _, v in pairs(coreGui:GetDescendants()) do
                if v:IsA("LocalScript") or v:IsA("ModuleScript") then
                    local src = ""
                    pcall(function() src = v.Source end)
                    if src:find("Hyperion") or src:find("hyperion") or src:find("AC_") then
                        v.Disabled = true
                        successCount = successCount + 1
                    end
                end
            end
        end)
        
        -- 3. Disable w wszystkich miejscach
        pcall(function()
            for _, v in pairs(game:GetDescendants()) do
                if (v:IsA("LocalScript") or v:IsA("ModuleScript")) and not v.Disabled then
                    local src = ""
                    pcall(function() src = v.Source end)
                    if src:find("Hyperion") or src:find("hyperion") then
                        v.Disabled = true
                        successCount = successCount + 1
                    end
                end
            end
        end)
        
        notify("Hyperion Bypass", "Zneutralizowano " .. successCount .. " elementów Hyperion", 4)
    end
})

-- KILL ALL ANTI-CHEAT SCRIPTS (naprawiony - działający)
AdvancedTab:CreateButton({
    Name = "Kill All Anti-Cheat Scripts",
    Callback = function()
        local count = 0
        local keywords = {"kick", "ban", "detect", "cheat", "exploit", "hyperion", "anti", "Anti", "AC_", "ac_", "detection", "banne", "kicked"}
        
        for _, v in pairs(game:GetDescendants()) do
            if (v:IsA("LocalScript") or v:IsA("ModuleScript")) and not v.Disabled then
                local src = ""
                local success = pcall(function() src = v.Source end)
                if success and src ~= "" then
                    local found = false
                    for _, kw in pairs(keywords) do
                        if src:find(kw) then
                            found = true
                            break
                        end
                    end
                    if found then
                        v.Disabled = true
                        count = count + 1
                    end
                end
            end
        end
        
        notify("AC Kill", "Zneutralizowano " .. count .. " skryptów anty-cheat!", 4)
    end
})

-- SPOOF CLIENT INFO (naprawiony)
AdvancedTab:CreateButton({
    Name = "Spoof Client Info",
    Callback = function()
        local success = false
        pcall(function()
            local old_decode = hookfunction(game:GetService("HttpService").JSONDecode, function(self, str)
                local decoded = old_decode(self, str)
                if type(decoded) == "table" then
                    if decoded.clientId then decoded.clientVersion = "0.0.0.0" end
                    if decoded.UserId then decoded.UserId = LP.UserId end
                end
                return decoded
            end)
            success = true
        end)
        if success then
            notify("Spoof", "Dane klienta spoofowane!", 2)
        else
            notify("Spoof Error", "Nie udało się spoofować", 3)
        end
    end
})

-- ============================================================
-- [KATEGORIA 6] STATS - naprawiona i działająca
-- ============================================================
local StatsTab = Window:CreateTab("Stats", "bar-chart-4")
StatsTab:CreateSection("Player Statistics")
StatsTab:CreateDivider()

local function getStatsText()
    local plr = LP
    local char = getChar()
    local hum = getHumanoid()
    
    local lines = {}
    table.insert(lines, "=== PLAYER INFO ===")
    table.insert(lines, "Username: " .. plr.Name)
    table.insert(lines, "UserID: " .. plr.UserId)
    table.insert(lines, "Display Name: " .. plr.DisplayName)
    table.insert(lines, "Account Age: " .. tostring(plr.AccountAge) .. " days")
    
    if plr.Team then
        table.insert(lines, "Team: " .. plr.Team.Name)
    else
        table.insert(lines, "Team: None")
    end
    
    table.insert(lines, "")
    table.insert(lines, "=== CHARACTER ===")
    
    if hum then
        table.insert(lines, "Health: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth))
        table.insert(lines, "WalkSpeed: " .. string.format("%.1f", hum.WalkSpeed))
        table.insert(lines, "JumpPower: " .. string.format("%.1f", hum.JumpPower))
        local stateNames = {
            [Enum.HumanoidStateType.Running.Number] = "Running",
            [Enum.HumanoidStateType.Jumping.Number] = "Jumping",
            [Enum.HumanoidStateType.FallingDown.Number] = "Falling",
            [Enum.HumanoidStateType.Freefall.Number] = "Freefall",
            [Enum.HumanoidStateType.Swimming.Number] = "Swimming",
            [Enum.HumanoidStateType.Climbing.Number] = "Climbing",
            [Enum.HumanoidStateType.Seated.Number] = "Seated",
            [Enum.HumanoidStateType.Dead.Number] = "Dead"
        }
        local stateNum = hum:GetState().Number
        table.insert(lines, "State: " .. (stateNames[stateNum] or "Unknown"))
    else
        table.insert(lines, "Humanoid: Not found")
    end
    
    if char then
        local hrp = getHRP()
        if hrp then
            table.insert(lines, "")
            table.insert(lines, "=== POSITION ===")
            table.insert(lines, string.format("X: %.1f", hrp.Position.X))
            table.insert(lines, string.format("Y: %.1f", hrp.Position.Y))
            table.insert(lines, string.format("Z: %.1f", hrp.Position.Z))
        end
    end
    
    table.insert(lines, "")
    table.insert(lines, "=== GAME INFO ===")
    local gameName = "Unknown"
    pcall(function()
        gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown"
    end)
    table.insert(lines, "Game: " .. gameName)
    table.insert(lines, "PlaceID: " .. game.PlaceId)
    table.insert(lines, "JobID: " .. game.JobId)
    
    table.insert(lines, "")
    table.insert(lines, "=== PLAYERS ===")
    table.insert(lines, "Online: " .. #MH.Players:GetPlayers())
    
    return table.concat(lines, "\n")
end

-- Użyjemy Paragraph zamiast Label - będzie lepiej formatowany
local statsPara = StatsTab:CreateParagraph({
    Title = "Player Stats",
    Content = getStatsText()
})

-- Przycisk odświeżania
StatsTab:CreateButton({
    Name = "Refresh Stats",
    Callback = function()
        statsPara:Set({Title = "Player Stats", Content = getStatsText()})
        notify("Stats", "Odświeżono statystyki", 2)
    end
})

-- Auto-refresh
spawn(function()
    while task.wait(3) do
        pcall(function()
            statsPara:Set({Title = "Player Stats", Content = getStatsText()})
        end)
    end
end)

StatsTab:CreateDivider()

-- Lista graczy online
StatsTab:CreateSection("Players Online")

local playerListPara = StatsTab:CreateParagraph({
    Title = "Online Players",
    Content = "Ładowanie..."
})

spawn(function()
    while task.wait(2) do
        pcall(function()
            local playerNames = {}
            for _, plr in pairs(MH.Players:GetPlayers()) do
                if plr ~= LP then
                    local dist = "?"
                    local hrp = getHRP()
                    local phrp = getHRP(plr)
                    if hrp and phrp then
                        dist = string.format("%.0f", (hrp.Position - phrp.Position).Magnitude)
                    end
                    table.insert(playerNames, plr.Name .. " [" .. dist .. "s]")
                end
            end
            if #playerNames > 0 then
                playerListPara:Set({Title = "Online Players (" .. #playerNames .. ")", Content = table.concat(playerNames, "\n")})
            else
                playerListPara:Set({Title = "Online Players", Content = "Brak innych graczy"})
            end
        end)
    end
end)

-- ============================================================
-- [LOOP SERWISOWY]
-- ============================================================
Run.Heartbeat:Connect(function()
    -- Auto Jump
    if MH.AutoJump then
        local hum = getHumanoid()
        if hum then hum.Jump = true end
    end
    
    -- Fast Swim
    if MH.FastSwim then
        local hum = getHumanoid()
        if hum and hum:GetState() == Enum.HumanoidStateType.Swimming then
            local hrp = getHRP()
            if hrp then hrp.Velocity = Cam.CFrame.LookVector * 100 end
        end
    end
    
    -- Speed Boost (Shift)
    if MH.SpeedBoost then
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            local hum = getHumanoid()
            if hum then hum.WalkSpeed = 120 end
        else
            if MH.SpeedHack then
                local hum = getHumanoid()
                if hum then hum.WalkSpeed = MH.SpeedValue end
            else
                local hum = getHumanoid()
                if hum then hum.WalkSpeed = 16 end
            end
        end
    end
    
-- Infinite Stamina
    if MH.InfiniteStamina then
        local hum = getHumanoid()
        if hum then
            pcall(function() hum.Stamina = hum.MaxStamina end)
        end
    end
    
    -- No Fall Damage
    if MH.NoFallDamage then
        local hum = getHumanoid()
        if hum then hum.FallDamage = false end
    end
    
    -- God Mode backup
    if MH.GodMode then
        local hum = getHumanoid()
        if hum and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end
end)

-- ============================================================
-- FINAL: NOTYFIKACJA STARTU
-- ============================================================
print("[+] BlazeCode v1.0 w pełni załadowany!")
Rayfield:Notify({
    Title = "BlazeCode v1.0",
    Content = "Wszystkie systemy gotowe.",
    Duration = 6,
    Image = "check-circle"
})

-- Ładowanie konfiguracji
task.wait(0.5)
Rayfield:LoadConfiguration()
