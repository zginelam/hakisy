local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Constants
local PRISON_LIFE_PLACEID = 155615604
local IS_PRISON_LIFE = (game.PlaceId == PRISON_LIFE_PLACEID)

-- Anti-kick / Anti-detection utilities
local DetectionBypasses = {
    SpoofedNames = {},
    OriginalProperties = {},
    AntiKickActive = false,
}

-- ─── UTILITY FUNCTIONS ───────────────────────────────────────────────────────

local function GetCharacter(player)
    return player.Character
end

local function GetRootPart(player)
    local char = GetCharacter(player)
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function GetHumanoid(player)
    local char = GetCharacter(player)
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function SafeWaitForChild(parent, childName, timeout)
    timeout = timeout or 5
    local step = 0
    while step < timeout * 10 do
        local found = parent:FindFirstChild(childName)
        if found then return found end
        task.wait(0.1)
        step = step + 1
    end
    return parent:FindFirstChild(childName)
end

local function GetPlayerFromCharacter(char)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == char then
            return player
        end
    end
    return nil
end

-- Anti-kick loop
local function StartAntiKick()
    if DetectionBypasses.AntiKickActive then return end
    DetectionBypasses.AntiKickActive = true
    
    task.spawn(function()
        while DetectionBypasses.AntiKickActive do
            pcall(function()
                if RootPart then
                    RootPart:SetNetworkOwner(nil)
                end
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            task.wait(5)
        end
    end)
end

local function StopAntiKick()
    DetectionBypasses.AntiKickActive = false
end

-- Notification wrapper
local function Notify(title, content, duration, icon)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 6.5,
        Image = icon or 4483362458,
    })
end

-- ─── ESP SYSTEM ──────────────────────────────────────────────────────────────

local ESP = {
    Enabled = false,
    Boxes = {},
    Names = {},
    Tracers = {},
    HealthBars = {},
    Chams = {},
    Glow = {},
    Connections = {},
    Color = Color3.fromRGB(255, 50, 50),
    TeamCheck = false,
    ShowBox = true,
    ShowName = true,
    ShowTracer = true,
    ShowHealth = true,
    ShowChams = false,
    ShowGlow = false,
    ShowDistance = false,
    ItemESP = false,
    VehicleESP = false,
    ClickTeleport = false,
    PrisonESPColors = {
        Police = Color3.fromRGB(0, 100, 255),
        Criminal = Color3.fromRGB(255, 50, 50),
        Neutral = Color3.fromRGB(50, 255, 50),
    },
    UseTeamColors = false,
}

local function CreateESP(player)
    if ESP.Boxes[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = ESP.Color
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    
    local nameLabel = Drawing.new("Text")
    nameLabel.Visible = false
    nameLabel.Color = ESP.Color
    nameLabel.Size = 16
    nameLabel.Center = true
    nameLabel.Outline = true
    nameLabel.OutlineColor = Color3.new(0, 0, 0)
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = ESP.Color
    tracer.Thickness = 1.5
    tracer.Transparency = 1
    
    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Color = Color3.fromRGB(0, 255, 50)
    healthBar.Thickness = 1
    healthBar.Filled = true
    healthBar.Transparency = 0.8
    
    local healthBg = Drawing.new("Square")
    healthBg.Visible = false
    healthBg.Color = Color3.fromRGB(30, 30, 30)
    healthBg.Thickness = 1
    healthBg.Filled = true
    healthBg.Transparency = 0.9
    
    local distLabel = Drawing.new("Text")
    distLabel.Visible = false
    distLabel.Color = Color3.fromRGB(255, 255, 0)
    distLabel.Size = 13
    distLabel.Center = true
    distLabel.Outline = true
    distLabel.OutlineColor = Color3.new(0, 0, 0)
    
    ESP.Boxes[player] = box
    ESP.Names[player] = nameLabel
    ESP.Tracers[player] = tracer
    ESP.HealthBars[player] = {Bar = healthBar, Bg = healthBg}
    ESP.DistLabels = ESP.DistLabels or {}
    ESP.DistLabels[player] = distLabel
end

local function GetPrisonTeamColor(player)
    if not IS_PRISON_LIFE or not ESP.UseTeamColors then
        return ESP.Color
    end
    
    local team = player.Team
    if team then
        local name = team.Name:lower()
        if name:find("police") or name:find("guard") or name:find("inmate") == false and name:find("criminal") == false then
            return ESP.PrisonESPColors.Police
        elseif name:find("criminal") or name:find("inmate") or name:find("prisoner") then
            return ESP.PrisonESPColors.Criminal
        else
            return ESP.PrisonESPColors.Neutral
        end
    end
    return ESP.Color
end

local function UpdateESP(player)
    local char = GetCharacter(player)
    local root = GetRootPart(player)
    local humanoid = GetHumanoid(player)
    
    if not char or not root or not humanoid or humanoid.Health <= 0 then
        if ESP.Boxes[player] then
            ESP.Boxes[player].Visible = false
            ESP.Names[player].Visible = false
            ESP.Tracers[player].Visible = false
            if ESP.HealthBars[player] then
                ESP.HealthBars[player].Bar.Visible = false
                ESP.HealthBars[player].Bg.Visible = false
            end
            if ESP.DistLabels and ESP.DistLabels[player] then
                ESP.DistLabels[player].Visible = false
            end
        end
        return
    end
    
    if ESP.TeamCheck and player.Team == LocalPlayer.Team and player ~= LocalPlayer then
        if ESP.Boxes[player] then
            ESP.Boxes[player].Visible = false
            ESP.Names[player].Visible = false
            ESP.Tracers[player].Visible = false
            if ESP.HealthBars[player] then
                ESP.HealthBars[player].Bar.Visible = false
                ESP.HealthBars[player].Bg.Visible = false
            end
            if ESP.DistLabels and ESP.DistLabels[player] then
                ESP.DistLabels[player].Visible = false
            end
        end
        return
    end
    
    local cam = workspace.CurrentCamera
    local pos, onScreen = cam:WorldToViewportPoint(root.Position)
    local scale = cam.ViewportSize
    
    if not onScreen then
        if ESP.Boxes[player] then
            ESP.Boxes[player].Visible = false
            ESP.Names[player].Visible = false
            ESP.Tracers[player].Visible = false
            if ESP.HealthBars[player] then
                ESP.HealthBars[player].Bar.Visible = false
                ESP.HealthBars[player].Bg.Visible = false
            end
            if ESP.DistLabels and ESP.DistLabels[player] then
                ESP.DistLabels[player].Visible = false
            end
        end
        return
    end
    
    local dist = (cam.CFrame.Position - root.Position).Magnitude
    local boxSize = math.clamp(500 / dist * 4, 20, 200)
    local halfSize = boxSize / 2
    
    local espColor = GetPrisonTeamColor(player)
    
    local box = ESP.Boxes[player]
    local nameL = ESP.Names[player]
    local tracer = ESP.Tracers[player]
    local hb = ESP.HealthBars[player]
    local distL = ESP.DistLabels and ESP.DistLabels[player]
    
    -- Box
    if ESP.ShowBox then
        box.Visible = true
        box.Position = Vector2.new(pos.X - halfSize, pos.Y - boxSize)
        box.Size = Vector2.new(boxSize, boxSize * 1.6)
        box.Color = espColor
    else
        box.Visible = false
    end
    
    -- Name
    if ESP.ShowName and nameL then
        nameL.Visible = true
        nameL.Position = Vector2.new(pos.X, pos.Y - boxSize * 1.6 - 16)
        nameL.Text = player.Name
        nameL.Color = espColor
    elseif nameL then
        nameL.Visible = false
    end
    
    -- Tracer
    if ESP.ShowTracer then
        tracer.Visible = true
        tracer.From = Vector2.new(scale.X / 2, scale.Y)
        tracer.To = Vector2.new(pos.X, pos.Y)
        tracer.Color = espColor
    else
        tracer.Visible = false
    end
    
    -- Health bar
    if ESP.ShowHealth and hb then
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local healthColor = Color3.fromRGB(
            math.floor(255 * (1 - healthPercent)),
            math.floor(255 * healthPercent),
            50
        )
        hb.Bg.Visible = true
        hb.Bg.Position = Vector2.new(pos.X + halfSize + 3, pos.Y - boxSize)
        hb.Bg.Size = Vector2.new(6, boxSize * 1.6)
        hb.Bar.Visible = true
        hb.Bar.Color = healthColor
        hb.Bar.Position = Vector2.new(pos.X + halfSize + 3, pos.Y - boxSize + (boxSize * 1.6 * (1 - healthPercent)))
        hb.Bar.Size = Vector2.new(6, boxSize * 1.6 * healthPercent)
    elseif hb then
        hb.Bar.Visible = false
        hb.Bg.Visible = false
    end
    
    -- Distance
    if ESP.ShowDistance and distL then
        distL.Visible = true
        distL.Position = Vector2.new(pos.X, pos.Y - boxSize * 1.6 + 16)
        distL.Text = math.floor(dist) .. " studs"
        distL.Color = espColor
    elseif distL then
        distL.Visible = false
    end
end

local function StartESP()
    if ESP.Enabled then return end
    ESP.Enabled = true
    ESP.DistLabels = ESP.DistLabels or {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
    
    ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        CreateESP(player)
    end)
    
    ESP.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        local function removeDrawing(d)
            if d then pcall(function() d:Remove() end) end
        end
        removeDrawing(ESP.Boxes[player])
        ESP.Boxes[player] = nil
        removeDrawing(ESP.Names[player])
        ESP.Names[player] = nil
        removeDrawing(ESP.Tracers[player])
        ESP.Tracers[player] = nil
        if ESP.HealthBars[player] then
            removeDrawing(ESP.HealthBars[player].Bar)
            removeDrawing(ESP.HealthBars[player].Bg)
            ESP.HealthBars[player] = nil
        end
        if ESP.DistLabels and ESP.DistLabels[player] then
            removeDrawing(ESP.DistLabels[player])
            ESP.DistLabels[player] = nil
        end
    end)
    
    ESP.Connections.RenderStepped = RunService.RenderStepped:Connect(function()
        if not ESP.Enabled then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                UpdateESP(player)
            end
        end
    end)
end

local function StopESP()
    ESP.Enabled = false
    
    for _, conn in pairs(ESP.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    ESP.Connections = {}
    
    for _, drawing in pairs(ESP.Boxes) do
        pcall(function() drawing:Remove() end)
    end
    ESP.Boxes = {}
    
    for _, drawing in pairs(ESP.Names) do
        pcall(function() drawing:Remove() end)
    end
    ESP.Names = {}
    
    for _, drawing in pairs(ESP.Tracers) do
        pcall(function() drawing:Remove() end)
    end
    ESP.Tracers = {}
    
    for _, hb in pairs(ESP.HealthBars) do
        pcall(function() hb.Bar:Remove() end)
        pcall(function() hb.Bg:Remove() end)
    end
    ESP.HealthBars = {}
    
    if ESP.DistLabels then
        for _, drawing in pairs(ESP.DistLabels) do
            pcall(function() drawing:Remove() end)
        end
        ESP.DistLabels = {}
    end
end

-- ─── MOVEMENT SYSTEM ─────────────────────────────────────────────────────────

local Movement = {
    Fly = false,
    Noclip = false,
    Speed = false,
    SpeedValue = 100,
    JumpPower = false,
    JumpPowerValue = 200,
    InfJump = false,
    Float = false,
    Spin = false,
    FloatHeight = 10,
    SpinSpeed = 999,
    FlySpeed = 50,
    Connections = {},
}

local function NoclipLoop()
    if not Movement.Noclip then return end
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function StartFly()
    if Movement.Fly then return end
    Movement.Fly = true
    
    local flying = true
    local bodyGyro = Instance.new("BodyGyro")
    local bodyVelocity = Instance.new("BodyVelocity")
    
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = RootPart.CFrame
    
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    
    bodyGyro.Parent = RootPart
    bodyVelocity.Parent = RootPart
    
    local ws, ad = 0, 0
    local a, wd, sd = 0, 0, 0
    
    Movement.Connections.Fly = RunService.RenderStepped:Connect(function()
        if not Movement.Fly then
            bodyGyro:Destroy()
            bodyVelocity:Destroy()
            Movement.Connections.Fly:Disconnect()
            Movement.Connections.Fly = nil
            return
        end
        
        local char = LocalPlayer.Character
        if not char or not char.Parent then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        hum.PlatformStand = true
        
        local cam = workspace.CurrentCamera
        local cf = cam.CFrame
        
        local forward = cf.LookVector
        local right = cf.RightVector
        local up = cf.UpVector
        
        a = 0; wd = 0; sd = 0; ad = 0
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then wd = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then wd = -1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then ad = -1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then ad = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then a = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then a = -1 end
        
        local moveVector = (forward * wd + right * ad + up * a) * Movement.FlySpeed
        bodyVelocity.Velocity = moveVector
        bodyGyro.CFrame = cf
    end)
    
    Notify("Fly", "Flight enabled — WASD to move, Space/Shift for up/down", 5)
end

local function StopFly()
    Movement.Fly = false
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = false
            end
        end
    end)
end

local function TeleportToMouse()
    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target
    if target then
        local hitPos = mouse.Hit.Position
        RootPart.CFrame = CFrame.new(hitPos.X, hitPos.Y + 3, hitPos.Z)
        Notify("Teleport", "Teleported to mouse position", 3)
    else
        Notify("Teleport", "No valid target position", 3)
    end
end

local function TeleportTo(x, y, z)
    RootPart.CFrame = CFrame.new(x, y, z)
end

local function TeleportToPlayer(targetPlayer)
    local targetRoot = GetRootPart(targetPlayer)
    if targetRoot then
        RootPart.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 3, 0))
        Notify("Teleport", "Teleported to " .. targetPlayer.Name, 3)
    end
end

local function StartInfJump()
    if Movement.InfJump then return end
    Movement.InfJump = true
    
    Movement.Connections.InfJump = UserInputService.JumpRequest:Connect(function()
        if not Movement.InfJump then
            Movement.Connections.InfJump:Disconnect()
            Movement.Connections.InfJump = nil
            return
        end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    
    Notify("Inf Jump", "Infinite jump activated", 3)
end

local function StopInfJump()
    Movement.InfJump = false
end

local function StartFloat()
    if Movement.Float then return end
    Movement.Float = true
    
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.P = 20000
    bodyPosition.MaxForce = Vector3.new(0, 9e9, 0)
    bodyPosition.Position = RootPart.Position + Vector3.new(0, Movement.FloatHeight, 0)
    bodyPosition.Parent = RootPart
    
    Movement.Connections.Float = RunService.RenderStepped:Connect(function()
        if not Movement.Float then
            bodyPosition:Destroy()
            Movement.Connections.Float:Disconnect()
            Movement.Connections.Float = nil
            return
        end
        bodyPosition.Position = RootPart.Position + Vector3.new(0, Movement.FloatHeight, 0)
    end)
    
    Notify("Float", "Floating at height " .. Movement.FloatHeight, 3)
end

local function StopFloat()
    Movement.Float = false
end

local function StartSpin()
    if Movement.Spin then return end
    Movement.Spin = true
    
    local bodyAngVel = Instance.new("BodyAngularVelocity")
    bodyAngVel.AngularVelocity = Vector3.new(0, Movement.SpinSpeed, 0)
    bodyAngVel.MaxTorque = Vector3.new(0, 9e9, 0)
    bodyAngVel.P = 30000
    bodyAngVel.Parent = RootPart
    
    Movement.Connections.Spin = RunService.RenderStepped:Connect(function()
        if not Movement.Spin then
            bodyAngVel:Destroy()
            Movement.Connections.Spin:Disconnect()
            Movement.Connections.Spin = nil
            return
        end
    end)
    
    Notify("Spin", "Spinning like a top!", 3)
end

local function StopSpin()
    Movement.Spin = false
end

-- ─── FLING SYSTEM ────────────────────────────────────────────────────────────

local Fling = {
    Active = false,
    Type = "Classic",
    Power = 5000,
    Connections = {},
}

local function GetFlingForce(player)
    local root = GetRootPart(player)
    if not root then return end
    
    if Fling.Type == "Classic" then
        local randomDir = Vector3.new(
            math.random(-100, 100) / 10,
            math.random(50, 100) / 10,
            math.random(-100, 100) / 10
        )
        
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.Velocity = randomDir * Fling.Power
        bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVel.P = 50000
        bodyVel.Parent = root
        
        local bodyAngVel = Instance.new("BodyAngularVelocity")
        bodyAngVel.AngularVelocity = Vector3.new(
            math.random(-500, 500),
            math.random(-500, 500),
            math.random(-500, 500)
        )
        bodyAngVel.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyAngVel.P = 30000
        bodyAngVel.Parent = root
        
        task.delay(2, function()
            pcall(function() bodyVel:Destroy() end)
            pcall(function() bodyAngVel:Destroy() end)
        end)
        
    elseif Fling.Type == "Up" then
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.Velocity = Vector3.new(0, Fling.Power, 0)
        bodyVel.MaxForce = Vector3.new(0, 9e9, 0)
        bodyVel.P = 50000
        bodyVel.Parent = root
        
        task.delay(2, function()
            pcall(function() bodyVel:Destroy() end)
        end)
    end
end

local function StartFling()
    if Fling.Active then return end
    Fling.Active = true
    
    local serverPlayers = Players:GetPlayers()
    
    for _, player in ipairs(serverPlayers) do
        if player ~= LocalPlayer then
            task.spawn(function()
                pcall(function() GetFlingForce(player) end)
            end)
        end
    end
    
    Fling.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        if Fling.Active then
            task.wait(1)
            pcall(function() GetFlingForce(player) end)
        end
    end)
    
    Fling.Connections.Loop = RunService.Heartbeat:Connect(function()
        if not Fling.Active then
            Fling.Connections.Loop:Disconnect()
            Fling.Connections.Loop = nil
            return
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and math.random(1, 100) <= 5 then
                task.spawn(function()
                    pcall(function() GetFlingForce(player) end)
                end)
            end
        end
    end)
    
    local flingTypeStr = Fling.Type == "Classic" and "Classic (random directions)" or "Up (straight up)"
    Notify("Fling", "FLING ALL ACTIVE — Mode: " .. flingTypeStr, 5)
end

local function StopFling()
    Fling.Active = false
    for _, conn in pairs(Fling.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Fling.Connections = {}
end

-- ─── VISUAL SYSTEM ───────────────────────────────────────────────────────────

local Visuals = {
    Fullbright = false,
    NightVision = false,
    XRay = false,
    RemoveFog = false,
    RemoveGrass = false,
    OriginalBrightness = Lighting.Brightness,
    OriginalAmbient = Lighting.Ambient,
    OriginalFogEnd = Lighting.FogEnd,
    OriginalFogColor = Lighting.FogColor,
    OriginalGlobalShadows = Lighting.GlobalShadows,
    Connections = {},
}

local function SetFullbright(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Brightness = Visuals.OriginalBrightness
        Lighting.Ambient = Visuals.OriginalAmbient
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = Visuals.OriginalGlobalShadows
        Lighting.OutdoorAmbient = Color3.new(0.6, 0.6, 0.6)
    end
    Visuals.Fullbright = enabled
end

local function SetNightVision(enabled)
    if enabled then
        Visuals.OriginalBrightness = Lighting.Brightness
        Visuals.OriginalAmbient = Lighting.Ambient
        Visuals.OriginalGlobalShadows = Lighting.GlobalShadows
        
        Lighting.Brightness = 1.5
        Lighting.Ambient = Color3.fromRGB(0, 255, 100)
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 255, 100)
        Lighting.ColorShift_Top = Color3.fromRGB(0, 200, 50)
        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 50, 20)
    else
        Lighting.Brightness = Visuals.OriginalBrightness
        Lighting.Ambient = Visuals.OriginalAmbient
        Lighting.GlobalShadows = Visuals.OriginalGlobalShadows
        Lighting.OutdoorAmbient = Color3.new(0.6, 0.6, 0.6)
        Lighting.ColorShift_Top = Color3.new(1, 1, 1)
        Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
    end
    Visuals.NightVision = enabled
end

local function SetXRay(enabled)
    Visuals.XRay = enabled
    local transparency = enabled and 0.7 or 0
    
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:FindFirstAncestorOfClass("Tool") then
            local playerOwner = GetPlayerFromCharacter(v.Parent)
            if not playerOwner then
                v.LocalTransparencyModifier = transparency
            end
        end
    end
    
    if enabled then
        Visuals.Connections.XRay = Workspace.DescendantAdded:Connect(function(v)
            if not Visuals.XRay then
                Visuals.Connections.XRay:Disconnect()
                Visuals.Connections.XRay = nil
                return
            end
            if v:IsA("BasePart") and not v:FindFirstAncestorOfClass("Tool") then
                local playerOwner = GetPlayerFromCharacter(v.Parent)
                if not playerOwner then
                    v.LocalTransparencyModifier = 0.7
                end
            end
        end)
    else
        if Visuals.Connections.XRay then
            Visuals.Connections.XRay:Disconnect()
            Visuals.Connections.XRay = nil
        end
    end
end

local function SetRemoveFog(enabled)
    if enabled then
        Visuals.OriginalFogEnd = Lighting.FogEnd
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
    else
        Lighting.FogEnd = Visuals.OriginalFogEnd
        Lighting.FogStart = 0
    end
    Visuals.RemoveFog = enabled
end

local function SetRemoveGrass(enabled)
    Visuals.RemoveGrass = enabled
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("GrassDecoration") or v:IsA("TerrainDetail") then
            v.Visible = not enabled
        end
        if v:IsA("BasePart") and v.Name:lower():find("grass") then
            v.Visible = not enabled
        end
    end
end

-- ─── CHAT SPAM SYSTEM ─────────────────────────────────────────────────────────

local ChatSpam = {
    Active = false,
    Messages = {
        "turcja owns me!",
        "turcja the best!!",
        "Tung tung Sahur",
        "fk nygg3rs",
        "nyg3a",
    },
    Delay = 1.5,
    Connections = {},
}

local function StartChatSpam()
    if ChatSpam.Active then return end
    ChatSpam.Active = true
    
    local chatService = game:GetService("TextChatService")
    local useNewChat = chatService.ChatVersion == Enum.ChatVersion.TextChatService
    
    ChatSpam.Connections.Loop = task.spawn(function()
        while ChatSpam.Active do
            task.wait(ChatSpam.Delay)
            local msg = ChatSpam.Messages[math.random(1, #ChatSpam.Messages)]
            
            pcall(function()
                if useNewChat then
                    local textChannel = chatService:FindFirstChild("RBXGeneral")
                    if textChannel then
                        textChannel:SendAsync(msg)
                    end
                else
                    local defaultChat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                    if defaultChat then
                        local sayMessage = defaultChat:FindFirstChild("SayMessageRequest")
                        if sayMessage then
                            sayMessage:FireServer(msg)
                        end
                    end
                end
                
                pcall(function()
                    local chatFolder = ReplicatedStorage:FindFirstChild("Chat")
                    if chatFolder then
                        local chatMsg = chatFolder:FindFirstChild("ChatMessage")
                        if chatMsg then
                            chatMsg:FireServer(msg)
                        end
                    end
                end)
            end)
        end
    end)
    
    Notify("Chat Spam", "Chat spam started — " .. #ChatSpam.Messages .. " messages", 4)
end

local function StopChatSpam()
    ChatSpam.Active = false
end

-- ─── SOUND SPAM SYSTEM ───────────────────────────────────────────────────────

local SoundSpam = {
    Active = false,
    SoundId = "rbxassetid://9120388685",
    Volume = 1,
    Pitch = 1,
    Connections = {},
}

local function StartSoundSpam()
    if SoundSpam.Active then return end
    SoundSpam.Active = true
    
    task.spawn(function()
        while SoundSpam.Active do
            pcall(function()
                local sound = Instance.new("Sound")
                sound.SoundId = SoundSpam.SoundId
                sound.Volume = SoundSpam.Volume
                sound.PlaybackSpeed = SoundSpam.Pitch
                sound.Parent = RootPart or workspace
                sound:Play()
                
                task.delay(5, function()
                    pcall(function() sound:Destroy() end)
                end)
            end)
            task.wait(0.3)
        end
    end)
    
    Notify("Sound Spam", "Sound spam activated", 3)
end

local function StopSoundSpam()
    SoundSpam.Active = false
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- PRISON LIFE SPECIFIC SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local PrisonLife = {
    -- Arrest
    AutoArrest = false,
    AutoTase = false,
    AutoHandcuff = false,
    AutoArrestRange = 30,
    SilentArrest = false,
    ArrestAllCriminals = false,
    
    -- Troll
    FlingAllPL = false,
    FreezeAll = false,
    CrashServer = false,
    RemoveJailDoors = false,
    RemoveCuffs = false,
    InfiniteArrest = false,
    ForceRespawn = false,
    GiveAllGuns = false,
    SwapTeams = false,
    UnanchorMap = false,
    SoundSpamPL = false,
    
    -- Aimbot
    SilentAim = false,
    Aimlock = false,
    Triggerbot = false,
    NoRecoil = false,
    NoSpread = false,
    Wallbang = false,
    
    -- ESP Items/Vehicles
    ItemESPItems = {},
    VehicleESPItems = {},
    ESPItemColors = {},
    ESPVehicleColors = {},
    
    Connections = {},
}

-- PRISON LIFE: Find remotes
local function FindPrisonRemotes()
    local remotes = {
        arrest = nil,
        tase = nil,
        handcuff = nil,
        cry = nil,
    }
    
    -- Szukamy w ReplicatedStorage
    pcall(function()
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            local name = v.Name:lower()
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") then
                if name:find("arrest") or name:find("arrest") then
                    remotes.arrest = v
                end
                if name:find("tase") or name:find("taser") or name:find("taze") then
                    remotes.tase = v
                end
                if name:find("handcuff") or name:find("cuff") or name:find("restrain") then
                    remotes.handcuff = v
                end
                if name:find("cry") or name:find("scream") or name:find("yell") then
                    remotes.cry = v
                end
            end
        end
    end)
    
    -- Szukamy w Workspace / game
    pcall(function()
        for _, v in ipairs(game:GetDescendants()) do
            local name = v.Name:lower()
            if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and v.Parent ~= ReplicatedStorage then
                if name:find("arrest") then remotes.arrest = v end
                if (name:find("tase") or name:find("tazer")) then remotes.tase = v end
                if name:find("cuff") then remotes.handcuff = v end
            end
        end
    end)
    
    return remotes
end

-- PRISON LIFE: Auto Arrest
local function PrisonAutoArrestLoop()
    while PrisonLife.AutoArrest do
        task.wait(0.3)
        pcall(function()
            local remotes = FindPrisonRemotes()
            if not remotes.arrest then return end
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local root = GetRootPart(player)
                    if root then
                        local dist = (RootPart.Position - root.Position).Magnitude
                        if dist <= PrisonLife.AutoArrestRange then
                            -- Check if criminal (team check)
                            local team = player.Team
                            if team and (team.Name:lower():find("criminal") or team.Name:lower():find("inmate")) then
                                remotes.arrest:FireServer(player)
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- PRISON LIFE: Auto Tase
local function PrisonAutoTaseLoop()
    while PrisonLife.AutoTase do
        task.wait(0.2)
        pcall(function()
            local remotes = FindPrisonRemotes()
            local taseRemote = remotes.tase or remotes.arrest
            if not taseRemote then return end
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local root = GetRootPart(player)
                    if root then
                        local dist = (RootPart.Position - root.Position).Magnitude
                        if dist <= PrisonLife.AutoArrestRange then
                            taseRemote:FireServer(player)
                        end
                    end
                end
            end
        end)
    end
end

-- PRISON LIFE: Auto Handcuff
local function PrisonAutoHandcuffLoop()
    while PrisonLife.AutoHandcuff do
        task.wait(0.3)
        pcall(function()
            local remotes = FindPrisonRemotes()
            local cuffRemote = remotes.handcuff or remotes.arrest
            if not cuffRemote then return end
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local root = GetRootPart(player)
                    if root then
                        local dist = (RootPart.Position - root.Position).Magnitude
                        if dist <= PrisonLife.AutoArrestRange + 5 then
                            cuffRemote:FireServer(player)
                        end
                    end
                end
            end
        end)
    end
end

-- PRISON LIFE: Vehicle Spawn
local function PrisonSpawnVehicle(vehicleType)
    pcall(function()
        local vehicleFolder = workspace:FindFirstChild("Vehicles") or workspace:FindFirstChild("Cars") or workspace:FindFirstChild("VehicleSeats")
        if vehicleFolder then
            for _, v in ipairs(vehicleFolder:GetChildren()) do
                local name = v.Name:lower()
                if vehicleType == "police" and (name:find("police") or name:find("cop") or name:find("cruiser")) then
                    v:SetPrimaryPartCFrame(RootPart.CFrame * CFrame.new(0, 5, -10))
                    Notify("Vehicle", "Spawned police car", 3)
                    return
                elseif vehicleType == "heli" and (name:find("heli") or name:find("chopper") or name:find("helicopter")) then
                    v:SetPrimaryPartCFrame(RootPart.CFrame * CFrame.new(0, 20, -15))
                    Notify("Vehicle", "Spawned helicopter", 3)
                    return
                end
            end
        end
        
        -- If not found, try to clone
        local model = game:GetService("InsertService"):LoadAsset(vehicleType == "police" and 1234567890 or 1234567891)
        if model then
            model:SetPrimaryPartCFrame(RootPart.CFrame * CFrame.new(0, 5, -10))
            model.Parent = workspace
        end
    end)
end

-- PRISON LIFE: Silent Arrest (arrest from distance)
local function PrisonSilentArrest(player)
    pcall(function()
        local remotes = FindPrisonRemotes()
        local arrestRemote = remotes.arrest
        if arrestRemote and player then
            arrestRemote:FireServer(player)
            Notify("Arrest", "Silently arrested " .. player.Name, 3)
        end
    end)
end

-- PRISON LIFE: Arrest All Criminals
local function PrisonArrestAllCriminals()
    pcall(function()
        local remotes = FindPrisonRemotes()
        local arrestRemote = remotes.arrest
        if not arrestRemote then return end
        
        local count = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local team = player.Team
                if team and (team.Name:lower():find("criminal") or team.Name:lower():find("inmate")) then
                    arrestRemote:FireServer(player)
                    count = count + 1
                    task.wait(0.1)
                end
            end
        end
        Notify("Arrest All", "Arrested " .. count .. " criminals", 4)
    end)
end

-- PRISON LIFE: Freeze All
local function PrisonFreezeAll()
    pcall(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local root = GetRootPart(player)
                if root then
                    root.Anchored = true
                end
                local char = GetCharacter(player)
                if char then
                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Anchored = true
                        end
                    end
                end
            end
        end
        Notify("Freeze", "All players frozen!", 3)
    end)
end

-- PRISON LIFE: Remove Jail Doors
local function PrisonRemoveJailDoors()
    pcall(function()
        local count = 0
        for _, v in ipairs(workspace:GetDescendants()) do
            local name = v.Name:lower()
            if v:IsA("BasePart") and (name:find("door") or name:find("gate") or name:find("cell")) then
                if v:FindFirstAncestorOfClass("Model") or v.Parent == workspace then
                    v:Destroy()
                    count = count + 1
                end
            end
            if v:IsA("Model") and (name:find("door") or name:find("gate")) then
                v:Destroy()
                count = count + 1
            end
        end
        Notify("Doors", "Removed " .. count .. " doors/gates", 4)
    end)
end

-- PRISON LIFE: Remove Cuffs
local function PrisonRemoveCuffs()
    pcall(function()
        local count = 0
        for _, player in ipairs(Players:GetPlayers()) do
            local char = GetCharacter(player)
            if char then
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("Accessory") or v:IsA("Tool") or v:IsA("Part") then
                        local name = v.Name:lower()
                        if name:find("cuff") or name:find("handcuff") or name:find("restrain") then
                            v:Destroy()
                            count = count + 1
                        end
                    end
                end
            end
        end
        Notify("Cuffs", "Removed " .. count .. " handcuffs", 4)
    end)
end

-- PRISON LIFE: Infinite Arrest
local function PrisonInfiniteArrest(player)
    if not player then return end
    pcall(function()
        local remotes = FindPrisonRemotes()
        local arrestRemote = remotes.arrest
        if not arrestRemote then return end
        
        for i = 1, 500 do
            arrestRemote:FireServer(player)
            task.wait()
        end
    end)
end

-- PRISON LIFE: Force Respawn
local function PrisonForceRespawn()
    pcall(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = GetCharacter(player)
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:BreakJoints()
                    end
                end
            end
        end
        Notify("Respawn", "All players force respawned", 3)
    end)
end

-- PRISON LIFE: Give All Guns
local function PrisonGiveAllGuns()
    pcall(function()
        local gunList = {"AK47", "M4A1", "Shotgun", "Revolver", "Pistol", "Taser", "Remington"}
        local toolFolder = ReplicatedStorage:FindFirstChild("Tools") or ReplicatedStorage:FindFirstChild("Guns") or ReplicatedStorage:FindFirstChild("Items")
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = GetCharacter(player)
                if char then
                    for _, gunName in ipairs(gunList) do
                        local tool = toolFolder and toolFolder:FindFirstChild(gunName)
                        if tool then
                            local clone = tool:Clone()
                            clone.Parent = char
                        end
                    end
                end
            end
        end
        Notify("Guns", "Gave all players weapons", 4)
    end)
end

-- PRISON LIFE: Swap Teams
local function PrisonSwapTeams()
    pcall(function()
        local teamService = game:GetService("Teams")
        local teams = teamService:GetTeams()
        local criminalTeam, policeTeam
        
        for _, team in ipairs(teams) do
            local name = team.Name:lower()
            if name:find("criminal") or name:find("inmate") or name:find("prisoner") then
                criminalTeam = team
            elseif name:find("police") or name:find("guard") or name:find("cop") then
                policeTeam = team
            end
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if player.Team == criminalTeam and policeTeam then
                    player.Team = policeTeam
                elseif player.Team == policeTeam and criminalTeam then
                    player.Team = criminalTeam
                end
            end
        end
        Notify("Teams", "Teams swapped!", 3)
    end)
end

-- PRISON LIFE: Unanchor Map
local function PrisonUnanchorMap()
    pcall(function()
        local count = 0
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Anchored and not v:FindFirstAncestorOfClass("Tool") then
                local isPlayerPart = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character and (v:IsDescendantOf(p.Character) or v.Parent == p.Character) then
                        isPlayerPart = true
                        break
                    end
                end
                if not isPlayerPart then
                    v.Anchored = false
                    count = count + 1
                end
            end
        end
        Notify("Unanchor", "Unanchored " .. count .. " parts — map collapsing!", 4)
    end)
end

-- PRISON LIFE: Aimbot / Silent Aim
local PrisonAimbot = {
    Target = nil,
    SilentAim = false,
    Aimlock = false,
    Triggerbot = false,
    NoRecoil = false,
    NoSpread = false,
    Wallbang = false,
    AimlockKey = "Q",
    FOV = 200,
}

local function PrisonFindClosestPlayerToMouse()
    local mouse = LocalPlayer:GetMouse()
    local cam = workspace.CurrentCamera
    local closest = nil
    local closestDist = PrisonAimbot.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local root = GetRootPart(player)
            local char = GetCharacter(player)
            if root and char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local pos, onScreen = cam:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local screenPos = Vector2.new(pos.X, pos.Y)
                        local mousePos = Vector2.new(mouse.X, mouse.Y)
                        local dist = (screenPos - mousePos).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = player
                        end
                    end
                end
            end
        end
    end
    
    return closest
end

local function PrisonAimbotLoop()
    while PrisonAimbot.Aimlock or PrisonAimbot.Triggerbot do
        task.wait()
        pcall(function()
            local mouse = LocalPlayer:GetMouse()
            local cam = workspace.CurrentCamera
            
            if PrisonAimbot.Aimlock then
                local target = PrisonFindClosestPlayerToMouse()
                if target then
                    local root = GetRootPart(target)
                    if root then
                        cam.CFrame = CFrame.new(cam.CFrame.Position, root.Position)
                    end
                end
            end
            
            if PrisonAimbot.Triggerbot then
                local target = mouse.Target
                if target and target.Parent then
                    local player = GetPlayerFromCharacter(target.Parent)
                    if player and player ~= LocalPlayer then
                        -- Auto shoot/spray
                        local tool = Character:FindFirstChildOfClass("Tool")
                        if tool then
                            local remote = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("Fire") or tool:FindFirstChild("Shoot")
                            if remote then
                                remote:FireServer()
                            end
                            local clickRemote = ReplicatedStorage:FindFirstChild("WeaponClick") or ReplicatedStorage:FindFirstChild("GunClick")
                            if clickRemote then
                                clickRemote:FireServer()
                            end
                        end
                    end
                end
            end
            
            -- No recoil / No spread hook
            if PrisonAimbot.NoRecoil or PrisonAimbot.NoSpread then
                local tool = Character:FindFirstChildOfClass("Tool")
                if tool then
                    local weaponScript = tool:FindFirstChild("WeaponScript") or tool:FindFirstChild("GunScript")
                    if weaponScript then
                        if PrisonAimbot.NoRecoil then
                            weaponScript.Disabled = true
                        end
                        if PrisonAimbot.NoSpread then
                            local spreadVal = weaponScript:FindFirstChild("Spread")
                            if spreadVal then
                                spreadVal.Value = 0
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- PRISON LIFE: Wallbang
local function PrisonWallbangOverride()
    pcall(function()
        local cam = workspace.CurrentCamera
        if PrisonAimbot.Wallbang then
            cam.MaxDistance = math.huge
        end
    end)
end

-- PRISON LIFE: Item ESP
local function PrisonCreateItemESP()
    -- Clear old
    if PrisonLife.ItemESPItems then
        for _, d in pairs(PrisonLife.ItemESPItems) do
            pcall(function() d:Remove() end)
        end
    end
    PrisonLife.ItemESPItems = {}
    
    if not ESP.ItemESP then return end
    
    local itemsToTrack = {"Key", "Gun", "Drug", "Crowbar", "Bag", "Money", "Weapon", "Knife", "Lockpick"}
    
    for _, v in ipairs(workspace:GetDescendants()) do
        local name = v.Name:lower()
        for _, itemName in ipairs(itemsToTrack) do
            if name:find(itemName:lower()) and (v:IsA("BasePart") or v:IsA("Model") or v:IsA("Tool")) then
                local pos = v:IsA("BasePart") and v.Position or (v:IsA("Model") and v:GetPrimaryPartCFrame() and v:GetPrimaryPartCFrame().Position)
                if pos then
                    local label = Drawing.new("Text")
                    label.Visible = true
                    label.Text = v.Name
                    label.Size = 14
                    label.Center = true
                    label.Outline = true
                    label.Color = PrisonLife.ESPItemColors[itemName] or Color3.fromRGB(255, 255, 0)
                    table.insert(PrisonLife.ItemESPItems, {Drawing = label, Object = v})
                end
                break
            end
        end
    end
    
    -- Update loop for items
    if PrisonLife.Connections.ItemESP then
        PrisonLife.Connections.ItemESP:Disconnect()
    end
    
    PrisonLife.Connections.ItemESP = RunService.RenderStepped:Connect(function()
        if not ESP.ItemESP then
            PrisonLife.Connections.ItemESP:Disconnect()
            PrisonLife.Connections.ItemESP = nil
            return
        end
        
        local cam = workspace.CurrentCamera
        for _, entry in ipairs(PrisonLife.ItemESPItems) do
            pcall(function()
                local obj = entry.Object
                local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj:GetPrimaryPartCFrame() and obj:GetPrimaryPartCFrame().Position)
                if pos then
                    local screenPos, onScreen = cam:WorldToViewportPoint(pos)
                    entry.Drawing.Visible = onScreen
                    entry.Drawing.Position = Vector2.new(screenPos.X, screenPos.Y)
                else
                    entry.Drawing.Visible = false
                end
            end)
        end
    end)
end

-- PRISON LIFE: Vehicle ESP
local function PrisonCreateVehicleESP()
    if PrisonLife.VehicleESPItems then
        for _, d in pairs(PrisonLife.VehicleESPItems) do
            pcall(function() d:Remove() end)
        end
    end
    PrisonLife.VehicleESPItems = {}
    
    if not ESP.VehicleESP then return end
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") or (v:IsA("BasePart") and (v.Name:lower():find("car") or v.Name:lower():find("vehicle") or v.Name:lower():find("truck") or v.Name:lower():find("wheel"))) then
            if v:IsA("BasePart") then
                local label = Drawing.new("Text")
                label.Visible = true
                label.Text = "🚗 " .. v.Parent.Name
                label.Size = 14
                label.Center = true
                label.Outline = true
                label.Color = PrisonLife.ESPVehicleColors["Vehicle"] or Color3.fromRGB(0, 200, 255)
                table.insert(PrisonLife.VehicleESPItems, {Drawing = label, Object = v})
            end
        end
    end
    
    if PrisonLife.Connections.VehicleESP then
        PrisonLife.Connections.VehicleESP:Disconnect()
    end
    
    PrisonLife.Connections.VehicleESP = RunService.RenderStepped:Connect(function()
        if not ESP.VehicleESP then
            PrisonLife.Connections.VehicleESP:Disconnect()
            PrisonLife.Connections.VehicleESP = nil
            return
        end
        
        local cam = workspace.CurrentCamera
        for _, entry in ipairs(PrisonLife.VehicleESPItems) do
            pcall(function()
                local obj = entry.Object
                local pos = obj.Position
                local screenPos, onScreen = cam:WorldToViewportPoint(pos)
                entry.Drawing.Visible = onScreen
                entry.Drawing.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
            end)
        end
    end)
end

-- PRISON LIFE: Teleport ESP (click to teleport)
local function PrisonHandleESPClick()
    if not ESP.ClickTeleport then return end
    
    local mouse = LocalPlayer:GetMouse()
    mouse.Button1Down:Connect(function()
        if not ESP.ClickTeleport then return end
        local target = mouse.Target
        if target then
            -- Check if it's a player
            local player = GetPlayerFromCharacter(target.Parent or target.Parent.Parent)
            if player then
                local root = GetRootPart(player)
                if root then
                    RootPart.CFrame = root.CFrame * CFrame.new(0, 3, 0)
                    Notify("Teleport", "Teleported to " .. player.Name, 3)
                end
            end
        end
    end)
end

-- PRISON LIFE: Crash Server
local function PrisonCrashServer()
    pcall(function()
        -- Massive part spam
        for i = 1, 500 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(math.random(10, 100), math.random(10, 100), math.random(10, 100))
            part.Position = Vector3.new(math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000))
            part.BrickColor = BrickColor.Random()
            part.Anchored = false
            part.Parent = workspace
            part:BreakJoints()
            
            local special = Instance.new("SpecialMesh")
            special.MeshType = Enum.MeshType.Sphere
            special.Parent = part
            special.Scale = Vector3.new(5, 5, 5)
            
            local force = Instance.new("BodyVelocity")
            force.Velocity = Vector3.new(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500))
            force.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            force.Parent = part
        end
        
        -- Fire all remotes with garbage
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                for i = 1, 50 do
                    v:FireServer({Garbage = true, Data = Instance.new("Part"), Nested = {}})
                end
            end
            if v:IsA("RemoteFunction") then
                for i = 1, 50 do
                    v:InvokeServer({Garbage = true, Data = Instance.new("Part")})
                end
            end
        end
        
        Notify("Crash", "Server crash payload sent", 4)
    end)
end

-- ─── PRISON LIFE SETUP ────────────────────────────────────────────────────────

local PrisonLifeWindow
local PrisonLifeTab

if IS_PRISON_LIFE then
    Notify("Prison Life", "Prison Life detected — loading Prison Life tab", 5)
end

-- ─── RAYFIELD WINDOW ─────────────────────────────────────────────────────────

local Window = Rayfield:CreateWindow({
    Name = "Tung Tung Sahur",
    Icon = 4483362458,
    LoadingTitle = "Tung Tung Sahur",
    LoadingSubtitle = "by turcja",
    Theme = "Default",
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
})

-- ─── MAIN TAB: INFORMATION ───────────────────────────────────────────────────

local InfoTab = Window:CreateTab("Information", 4483362458)
local InfoSection = InfoTab:CreateSection("Account Info")

InfoTab:CreateLabel({
    Name = "User: " .. LocalPlayer.Name,
    Section = InfoSection,
})

InfoTab:CreateLabel({
    Name = "Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    Section = InfoSection,
})

InfoTab:CreateLabel({
    Name = "Place ID: " .. game.PlaceId,
    Section = InfoSection,
})

InfoTab:CreateLabel({
    Name = "Players: " .. #Players:GetPlayers(),
    Section = InfoSection,
})

local ServerSection = InfoTab:CreateSection("Server")

InfoTab:CreateButton({
    Name = "Rejoin Server",
    Section = ServerSection,
    Callback = function()
        local ts = game:GetService("TeleportService")
        local placeId = game.PlaceId
        local jobId = game.JobId
        ts:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    end,
})

InfoTab:CreateButton({
    Name = "Server Hop",
    Section = ServerSection,
    Callback = function()
        local ts = game:GetService("TeleportService")
        ts:Teleport(game.PlaceId, LocalPlayer)
    end,
})

-- ─── MAIN TAB: MOVEMENT ──────────────────────────────────────────────────────

local MoveTab = Window:CreateTab("Movement", 4483362458)
local MoveSection = MoveTab:CreateSection("Movement")

MoveTab:CreateToggle({
    Name = "Fly",
    Section = MoveSection,
    CurrentValue = false,
    Callback = function(val)
        if val then StartFly() else StopFly() end
    end,
})

MoveTab:CreateSlider({
    Name = "Fly Speed",
    Section = MoveSection,
    Min = 10,
    Max = 500,
    Default = 50,
    Increment = 5,
    Callback = function(val)
        Movement.FlySpeed = val
    end,
})

MoveTab:CreateToggle({
    Name = "Noclip",
    Section = MoveSection,
    CurrentValue = false,
    Callback = function(val)
        Movement.Noclip = val
        if val then
            Movement.Connections.Noclip = RunService.Stepped:Connect(NoclipLoop)
        else
            if Movement.Connections.Noclip then
                Movement.Connections.Noclip:Disconnect()
                Movement.Connections.Noclip = nil
            end
        end
    end,
})

MoveTab:CreateToggle({
    Name = "Infinite Jump",
    Section = MoveSection,
    CurrentValue = false,
    Callback = function(val)
        if val then StartInfJump() else StopInfJump() end
    end,
})

MoveTab:CreateToggle({
    Name = "Float",
    Section = MoveSection,
    CurrentValue = false,
    Callback = function(val)
        if val then StartFloat() else StopFloat() end
    end,
})

MoveTab:CreateToggle({
    Name = "Spin (auto-rotate)",
    Section = MoveSection,
    CurrentValue = false,
    Callback = function(val)
        if val then StartSpin() else StopSpin() end
    end,
})

MoveTab:CreateToggle({
    Name = "Speed (walkspeed)",
    Section = MoveSection,
    CurrentValue = false,
    Callback = function(val)
        Movement.Speed = val
        if val then
            Movement.Connections.Speed = RunService.RenderStepped:Connect(function()
                if not Movement.Speed then
                    Movement.Connections.Speed:Disconnect()
                    Movement.Connections.Speed = nil
                    return
                end
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum.WalkSpeed = Movement.SpeedValue
                        end
                    end
                end)
            end)
        else
            if Movement.Connections.Speed then
                Movement.Connections.Speed:Disconnect()
                Movement.Connections.Speed = nil
            end
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = 16
                    end
                end
            end)
        end
    end,
})

MoveTab:CreateSlider({
    Name = "WalkSpeed Value",
    Section = MoveSection,
    Min = 16,
    Max = 500,
    Default = 100,
    Increment = 10,
    Callback = function(val)
        Movement.SpeedValue = val
    end,
})

MoveTab:CreateToggle({
    Name = "Jump Power",
    Section = MoveSection,
    CurrentValue = false,
    Callback = function(val)
        Movement.JumpPower = val
        if val then
            Movement.Connections.JumpPower = RunService.RenderStepped:Connect(function()
                if not Movement.JumpPower then
                    Movement.Connections.JumpPower:Disconnect()
                    Movement.Connections.JumpPower = nil
                    return
                end
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum.JumpPower = Movement.JumpPowerValue
                        end
                    end
                end)
            end)
        else
            if Movement.Connections.JumpPower then
                Movement.Connections.JumpPower:Disconnect()
                Movement.Connections.JumpPower = nil
            end
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.JumpPower = 50
                    end
                end
            end)
        end
    end,
})

MoveTab:CreateSlider({
    Name = "Jump Power Value",
    Section = MoveSection,
    Min = 50,
    Max = 500,
    Default = 200,
    Increment = 10,
    Callback = function(val)
        Movement.JumpPowerValue = val
    end,
})

local TeleportSection = MoveTab:CreateSection("Teleport")

MoveTab:CreateButton({
    Name = "Teleport to Mouse",
    Section = TeleportSection,
    Callback = TeleportToMouse,
})

MoveTab:CreateButton({
    Name = "Teleport to Spawn",
    Section = TeleportSection,
    Callback = function()
        local spawns = workspace:FindFirstChild("Spawns")
        if spawns then
            local spawn = spawns:GetChildren()
            if #spawn > 0 then
                TeleportTo(spawn[1].Position.X, spawn[1].Position.Y + 3, spawn[1].Position.Z)
            end
        end
    end,
})

-- ─── MAIN TAB: ESP & VISUALS ─────────────────────────────────────────────────

local ESPTab = Window:CreateTab("ESP & Visuals", 4483362458)
local ESPMainSection = ESPTab:CreateSection("ESP")

ESPTab:CreateToggle({
    Name = "Enable ESP",
    Section = ESPMainSection,
    CurrentValue = false,
    Callback = function(val)
        if val then StartESP() else StopESP() end
    end,
})

ESPTab:CreateToggle({
    Name = "Team Check (skip teammates)",
    Section = ESPMainSection,
    CurrentValue = false,
    Callback = function(val)
        ESP.TeamCheck = val
    end,
})

ESPTab:CreateToggle({
    Name = "Show Box",
    Section = ESPMainSection,
    CurrentValue = true,
    Callback = function(val)
        ESP.ShowBox = val
    end,
})

ESPTab:CreateToggle({
    Name = "Show Name",
    Section = ESPMainSection,
    CurrentValue = true,
    Callback = function(val)
        ESP.ShowName = val
    end,
})

ESPTab:CreateToggle({
    Name = "Show Tracers",
    Section = ESPMainSection,
    CurrentValue = true,
    Callback = function(val)
        ESP.ShowTracer = val
    end,
})

ESPTab:CreateToggle({
    Name = "Show Health Bar",
    Section = ESPMainSection,
    CurrentValue = true,
    Callback = function(val)
        ESP.ShowHealth = val
    end,
})

ESPTab:CreateToggle({
    Name = "Show Distance",
    Section = ESPMainSection,
    CurrentValue = false,
    Callback = function(val)
        ESP.ShowDistance = val
    end,
})

ESPTab:CreateColorPicker({
    Name = "ESP Color",
    Section = ESPMainSection,
    Default = Color3.fromRGB(255, 50, 50),
    Callback = function(val)
        ESP.Color = val
    end,
})

if IS_PRISON_LIFE then
    local PrisonESPSection = ESPTab:CreateSection("Prison Life ESP Colors")
    
    ESPTab:CreateToggle({
        Name = "Use Team Colors (Police/Criminal/Neutral)",
        Section = PrisonESPSection,
        CurrentValue = false,
        Callback = function(val)
            ESP.UseTeamColors = val
        end,
    })
    
    ESPTab:CreateColorPicker({
        Name = "Police Team Color",
        Section = PrisonESPSection,
        Default = Color3.fromRGB(0, 100, 255),
        Callback = function(val)
            ESP.PrisonESPColors.Police = val
        end,
    })
    
    ESPTab:CreateColorPicker({
        Name = "Criminal Team Color",
        Section = PrisonESPSection,
        Default = Color3.fromRGB(255, 50, 50),
        Callback = function(val)
            ESP.PrisonESPColors.Criminal = val
        end,
    })
    
    ESPTab:CreateColorPicker({
        Name = "Neutral Team Color",
        Section = PrisonESPSection,
        Default = Color3.fromRGB(50, 255, 50),
        Callback = function(val)
            ESP.PrisonESPColors.Neutral = val
        end,
    })
end

local VisualsSection = ESPTab:CreateSection("Visuals")

ESPTab:CreateToggle({
    Name = "Fullbright",
    Section = VisualsSection,
    CurrentValue = false,
    Callback = function(val)
        SetFullbright(val)
    end,
})

ESPTab:CreateToggle({
    Name = "Night Vision",
    Section = VisualsSection,
    CurrentValue = false,
    Callback = function(val)
        SetNightVision(val)
    end,
})

ESPTab:CreateToggle({
    Name = "X-Ray",
    Section = VisualsSection,
    CurrentValue = false,
    Callback = function(val)
        SetXRay(val)
    end,
})

ESPTab:CreateToggle({
    Name = "Remove Fog",
    Section = VisualsSection,
    CurrentValue = false,
    Callback = function(val)
        SetRemoveFog(val)
    end,
})

ESPTab:CreateToggle({
    Name = "Remove Grass/Details",
    Section = VisualsSection,
    CurrentValue = false,
    Callback = function(val)
        SetRemoveGrass(val)
    end,
})

-- ─── MAIN TAB: PLAYERS ───────────────────────────────────────────────────────

local PlayersTab = Window:CreateTab("Players", 4483362458)
local PlayerListSection = PlayersTab:CreateSection("Player List")

local playerListLbl = PlayersTab:CreateLabel({
    Name = "Select a player below:",
    Section = PlayerListSection,
})

local selectedPlayer = nil
local playerButtons = {}

local function RefreshPlayerList()
    -- Remove old buttons
    for _, btn in ipairs(playerButtons) do
        btn:Destroy()
    end
    playerButtons = {}
    
    local players = Players:GetPlayers()
    local PlayerSection = PlayersTab:CreateSection("Online Players (" .. #players .. ")")
    
    for _, player in ipairs(players) do
        if player ~= LocalPlayer then
            local btn = PlayersTab:CreateButton({
                Name = player.Name .. " [" .. tostring(player.Team and player.Team.Name or "No Team") .. "]",
                Section = PlayerSection,
                Callback = function()
                    selectedPlayer = player
                    playerListLbl:Set("Selected: " .. player.Name)
                    Notify("Player", "Selected: " .. player.Name, 4)
                end,
            })
            table.insert(playerButtons, btn)
        end
    end
    
    -- Actions with selected player
    local ActionSection = PlayersTab:CreateSection("Actions")
    
    PlayersTab:CreateButton({
        Name = "Teleport to Player",
        Section = ActionSection,
        Callback = function()
            if selectedPlayer then
                TeleportToPlayer(selectedPlayer)
            else
                Notify("Error", "No player selected", 3)
            end
        end,
    })
    
    PlayersTab:CreateButton({
        Name = "View Player",
        Section = ActionSection,
        Callback = function()
            if selectedPlayer then
                local char = GetCharacter(selectedPlayer)
                local root = GetRootPart(selectedPlayer)
                if root and char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    playerListLbl:Set("Selected: " .. selectedPlayer.Name .. " | HP: " .. math.floor(hum and hum.Health or 0) .. "/" .. math.floor(hum and hum.MaxHealth or 100) .. " | Team: " .. tostring(selectedPlayer.Team and selectedPlayer.Team.Name or "None"))
                end
            else
                Notify("Error", "No player selected", 3)
            end
        end,
    })
    
    PlayersTab:CreateButton({
        Name = "Arrest Selected",
        Section = ActionSection,
        Callback = function()
            if selectedPlayer then
                PrisonSilentArrest(selectedPlayer)
            end
        end,
    })
end

RefreshPlayerList()

Players.PlayerAdded:Connect(function()
    task.wait(1)
    RefreshPlayerList()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(1)
    RefreshPlayerList()
end)

-- ─── MAIN TAB: BYPASS ────────────────────────────────────────────────────────

local BypassTab = Window:CreateTab("Bypass", 4483362458)
local BypassSection = BypassTab:CreateSection("Anti-Detection")

BypassTab:CreateToggle({
    Name = "Anti Kick",
    Section = BypassSection,
    CurrentValue = false,
    Callback = function(val)
        if val then StartAntiKick() else StopAntiKick() end
    end,
})

BypassTab:CreateButton({
    Name = "Rejoin (avoid ban)",
    Section = BypassSection,
    Callback = function()
        local ts = game:GetService("TeleportService")
        ts:Teleport(game.PlaceId, LocalPlayer)
    end,
})

-- ─── MAIN TAB: UTILITIES ─────────────────────────────────────────────────────

local UtilsTab = Window:CreateTab("Utilities", 4483362458)
local UtilsSection = UtilsTab:CreateSection("Chat")

UtilsTab:CreateToggle({
    Name = "Chat Spam",
    Section = UtilsSection,
    CurrentValue = false,
    Callback = function(val)
        if val then StartChatSpam() else StopChatSpam() end
    end,
})

UtilsTab:CreateSlider({
    Name = "Chat Spam Delay (s)",
    Section = UtilsSection,
    Min = 0.5,
    Max = 5,
    Default = 1.5,
    Increment = 0.1,
    Callback = function(val)
        ChatSpam.Delay = val
    end,
})

local FlingSection = UtilsTab:CreateSection("Fling")

UtilsTab:CreateToggle({
    Name = "Fling All Players",
    Section = FlingSection,
    CurrentValue = false,
    Callback = function(val)
        if val then StartFling() else StopFling() end
    end,
})

UtilsTab:CreateDropdown({
    Name = "Fling Mode",
    Section = FlingSection,
    Options = {"Classic", "Up"},
    Default = "Classic",
    Callback = function(val)
        Fling.Type = val
    end,
})

UtilsTab:CreateSlider({
    Name = "Fling Power",
    Section = FlingSection,
    Min = 1000,
    Max = 50000,
    Default = 5000,
    Increment = 500,
    Callback = function(val)
        Fling.Power = val
    end,
})

local SoundSection = UtilsTab:CreateSection("Sound")

UtilsTab:CreateToggle({
    Name = "Sound Spam (Earrape)",
    Section = SoundSection,
    CurrentValue = false,
    Callback = function(val)
        if val then StartSoundSpam() else StopSoundSpam() end
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- PRISON LIFE TAB (only visible if in Prison Life)
-- ═══════════════════════════════════════════════════════════════════════════════

if IS_PRISON_LIFE then
    
    PrisonLifeTab = Window:CreateTab("Prison Life", 4483362458)
    
    -- === ARREST SECTION ===
    local ArrestSection = PrisonLifeTab:CreateSection("Arrest")
    
    PrisonLifeTab:CreateToggle({
        Name = "Auto Arrest (range)",
        Section = ArrestSection,
        CurrentValue = false,
        Callback = function(val)
            PrisonLife.AutoArrest = val
            if val then
                task.spawn(PrisonAutoArrestLoop)
            end
        end,
    })
    
    PrisonLifeTab:CreateSlider({
        Name = "Auto Arrest Range",
        Section = ArrestSection,
        Min = 10,
        Max = 250,
        Default = 30,
        Increment = 5,
        Callback = function(val)
            PrisonLife.AutoArrestRange = val
        end,
    })
    
    PrisonLifeTab:CreateToggle({
        Name = "Auto Tase",
        Section = ArrestSection,
        CurrentValue = false,
        Callback = function(val)
            PrisonLife.AutoTase = val
            if val then
                task.spawn(PrisonAutoTaseLoop)
            end
        end,
    })
    
    PrisonLifeTab:CreateToggle({
        Name = "Auto Handcuff",
        Section = ArrestSection,
        CurrentValue = false,
        Callback = function(val)
            PrisonLife.AutoHandcuff = val
            if val then
                task.spawn(PrisonAutoHandcuffLoop)
            end
        end,
    })
    
    PrisonLifeTab:CreateButton({
        Name = "Silent Arrest (selected player)",
        Section = ArrestSection,
        Callback = function()
            if selectedPlayer then
                PrisonSilentArrest(selectedPlayer)
            else
                Notify("Arrest", "Select a player from the Players tab first", 3)
            end
        end,
    })
    
    PrisonLifeTab:CreateButton({
        Name = "Arrest All Criminals",
        Section = ArrestSection,
        Callback = PrisonArrestAllCriminals,
    })
    
    local VehicleSection = PrisonLifeTab:CreateSection("Vehicle Spawn")
    
    PrisonLifeTab:CreateButton({
        Name = "Spawn Police Car",
        Section = VehicleSection,
        Callback = function()
            PrisonSpawnVehicle("police")
        end,
    })
    
    PrisonLifeTab:CreateButton({
        Name = "Spawn Helicopter",
        Section = VehicleSection,
        Callback = function()
            PrisonSpawnVehicle("heli")
        end,
    })
    
    -- === TROLL SECTION ===
    local TrollSection = PrisonLifeTab:CreateSection("Troll")
    
    PrisonLifeTab:CreateButton({
        Name = "Fling All",
        Section = TrollSection,
        Callback = function()
            local oldActive = Fling.Active
            if not oldActive then StartFling() end
            task.wait(3)
            if not oldActive then StopFling() end
            Notify("Fling", "Fling burst completed!", 3)
        end,
    })
    
    PrisonLifeTab:CreateButton({
        Name = "Freeze All Players",
        Section = TrollSection,
        Callback = PrisonFreezeAll,
    })
    
    PrisonLifeTab:CreateButton({
        Name = "Crash Server",
        Section = TrollSection,
        Callback = PrisonCrashServer,
    })
    
    PrisonLifeTab:CreateButton({
        Name = "Remove Jail Doors",
        Section = TrollSection,
        Callback = PrisonRemoveJailDoors,
    })
    
    PrisonLifeTab:CreateButton({
        Name = "Remove Cuffs (all players)",
        Section = TrollSection,
        Callback = PrisonRemoveCuffs,
    })
    
    PrisonLifeTab:CreateButton({
        Name = "Infinite Arrest (crash player)",
        Section = TrollSection,
        Callback = function()
            if selectedPlayer then
                task.spawn(function()
                    PrisonInfiniteArrest(selectedPlayer)
                end)
                Notify("Arrest", "Infinite arrest on " .. selectedPlayer.Name, 4)
            else
                Notify("Error", "Select a player first!", 3)
            end
        end,
    })
    
    PrisonLifeTab:CreateButton({
        Name = "Force Respawn All",
        Section = TrollSection,
        Callback = PrisonForceRespawn,
    })
    
    PrisonLifeTab:CreateButton({
        Name = "Give All Players Guns",
        Section = TrollSection,
        Callback = PrisonGiveAllGuns,
    })
    
    PrisonLifeTab:CreateButton({
        Name = "Swap Teams",
        Section = TrollSection,
        Callback = PrisonSwapTeams,
    })
    
    PrisonLifeTab:CreateButton({
        Name = "Unanchor Map",
        Section = TrollSection,
        Callback = PrisonUnanchorMap,
    })
    
    PrisonLifeTab:CreateToggle({
        Name = "Sound Spam (Earrape)",
        Section = TrollSection,
        CurrentValue = false,
        Callback = function(val)
            PrisonLife.SoundSpamPL = val
            if val then StartSoundSpam() else StopSoundSpam() end
        end,
    })
    
    -- === AIMBOT SECTION ===
    local AimbotSection = PrisonLifeTab:CreateSection("Aimbot")
    
    PrisonLifeTab:CreateToggle({
        Name = "Silent Aim",
        Section = AimbotSection,
        CurrentValue = false,
        Callback = function(val)
            PrisonAimbot.SilentAim = val
            Notify("Aimbot", "Silent Aim " .. (val and "enabled" or "disabled"), 3)
        end,
    })
    
    PrisonLifeTab:CreateToggle({
        Name = "Aimlock",
        Section = AimbotSection,
        CurrentValue = false,
        Callback = function(val)
            PrisonAimbot.Aimlock = val
            if val then
                task.spawn(PrisonAimbotLoop)
            end
        end,
    })
    
    PrisonLifeTab:CreateToggle({
        Name = "Triggerbot (auto-shoot on enemy)",
        Section = AimbotSection,
        CurrentValue = false,
        Callback = function(val)
            PrisonAimbot.Triggerbot = val
            if val then
                task.spawn(PrisonAimbotLoop)
            end
        end,
    })
    
    PrisonLifeTab:CreateToggle({
        Name = "No Recoil",
        Section = AimbotSection,
        CurrentValue = false,
        Callback = function(val)
            PrisonAimbot.NoRecoil = val
            if val then
                task.spawn(PrisonAimbotLoop)
            end
        end,
    })
    
    PrisonLifeTab:CreateToggle({
        Name = "No Spread",
        Section = AimbotSection,
        CurrentValue = false,
        Callback = function(val)
            PrisonAimbot.NoSpread = val
            if val then
                task.spawn(PrisonAimbotLoop)
            end
        end,
    })
    
    PrisonLifeTab:CreateToggle({
        Name = "Wallbang",
        Section = AimbotSection,
        CurrentValue = false,
        Callback = function(val)
            PrisonAimbot.Wallbang = val
            PrisonWallbangOverride()
        end,
    })
    
    PrisonLifeTab:CreateSlider({
        Name = "Aimbot FOV",
        Section = AimbotSection,
        Min = 50,
        Max = 500,
        Default = 200,
        Increment = 10,
        Callback = function(val)
            PrisonAimbot.FOV = val
        end,
    })
    
    -- === ESP SECTION (Prison Life specific) ===
    local PrisonESPTabSection = PrisonLifeTab:CreateSection("ESP - Items & Vehicles")
    
    PrisonLifeTab:CreateToggle({
        Name = "Item ESP (Keys, Guns, Drugs, etc.)",
        Section = PrisonESPTabSection,
        CurrentValue = false,
        Callback = function(val)
            ESP.ItemESP = val
            PrisonCreateItemESP()
        end,
    })
    
    PrisonLifeTab:CreateColorPicker({
        Name = "Item ESP Color",
        Section = PrisonESPTabSection,
        Default = Color3.fromRGB(255, 255, 0),
        Callback = function(val)
            for _, itemName in ipairs({"Key", "Gun", "Drug", "Crowbar", "Bag", "Money", "Weapon", "Knife", "Lockpick"}) do
                PrisonLife.ESPItemColors[itemName] = val
            end
            if ESP.ItemESP then
                PrisonCreateItemESP()
            end
        end,
    })
    
    PrisonLifeTab:CreateToggle({
        Name = "Vehicle ESP",
        Section = PrisonESPTabSection,
        CurrentValue = false,
        Callback = function(val)
            ESP.VehicleESP = val
            PrisonCreateVehicleESP()
        end,
    })
    
    PrisonLifeTab:CreateColorPicker({
        Name = "Vehicle ESP Color",
        Section = PrisonESPTabSection,
        Default = Color3.fromRGB(0, 200, 255),
        Callback = function(val)
            PrisonLife.ESPVehicleColors["Vehicle"] = val
            if ESP.VehicleESP then
                PrisonCreateVehicleESP()
            end
        end,
    })
    
    PrisonLifeTab:CreateToggle({
        Name = "ESP Click Teleport",
        Section = PrisonESPTabSection,
        CurrentValue = false,
        Callback = function(val)
            ESP.ClickTeleport = val
            if val then
                task.spawn(PrisonHandleESPClick)
            end
        end,
    })
    
    -- === TELEPORT ESP SECTION ===
    local TeleportESPSection = PrisonLifeTab:CreateSection("Teleport ESP")
    
    PrisonLifeTab:CreateLabel({
        Name = "Enable 'ESP Click Teleport' above, then click a player's ESP to teleport",
        Section = TeleportESPSection,
    })
    
    -- === MANUAL ARREST BY NAME ===
    local ManualArrestSection = PrisonLifeTab:CreateSection("Manual Arrest")
    
    local arrestPlayerInput = PrisonLifeTab:CreateInput({
        Name = "Player Name to Arrest",
        Section = ManualArrestSection,
        Placeholder = "Enter player name...",
        Callback = function(val)
            -- stored in closure, used by button below
        end,
    })
    
    PrisonLifeTab:CreateButton({
        Name = "Arrest by Name",
        Section = ManualArrestSection,
        Callback = function()
            -- We'll grab from the input
            local playerName = arrestPlayerInput and arrestPlayerInput.Text or ""
            if playerName and playerName ~= "" then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Name:lower():find(playerName:lower()) then
                        PrisonSilentArrest(player)
                        Notify("Arrest", "Arrested " .. player.Name, 3)
                        break
                    end
                end
            else
                Notify("Error", "Enter a player name first", 3)
            end
        end,
    })
    
    Notify("Prison Life", "Prison Life loaded with all modules!", 5)
    
end -- end of IS_PRISON_LIFE

Notify("Loaded", "Tung Tung Sahur v2.0 loaded successfully!", 4)
