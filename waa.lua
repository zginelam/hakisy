--[[
    RobluX Premium Exploit GUI
    Framework: Rayfield UI
    Author: Professional Security Researcher
--]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "RobluX Premium",
    LoadingTitle = "RobluX",
    LoadingSubtitle = "by s4d",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RobluXConfig",
        FileName = "Settings"
    },
    Discord = {
        Enabled = true,
        Invite = "discord.gg/roblux",
        RememberJoins = true
    },
    KeySystem = false
})

-- Game Detection
local PlaceID = game.PlaceId
local IsArsenal = PlaceID == 286090429
local IsCaseParadise = PlaceID == 118637423917462
local GameName = "Unknown Game"

if IsArsenal then
    GameName = "Arsenal"
elseif IsCaseParadise then
    GameName = "Case Paradise"
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Check Drawing support
local DrawingSupported = pcall(Drawing.new, "Square")

-- State Variables
local States = {
    Fly = false, Noclip = false, Speed = false, Jump = false,
    InfJump = false, Fling = false, Spin = false, Float = false,
    ESPBoxes = false, ESPNames = false, ESPTracers = false,
    ESPHealth = false, ESPChams = false,
    Fullbright = false, NightVision = false, XRay = false, FogRemoved = false,
    SoundSpam = false, ChatSpam = false, FlingAll = false, FlingUp = false,
    SilentAim = false, Aimlock = false, Triggerbot = false,
    NoSpread = false, Wallbang = false,
    AutoFarm = false, AutoCollect = false, AutoClick = false,
    AutoBuy = false, AutoQuest = false,
    AntiAFK = false, AntiDetect = false,
    SpeedAmount = 50, JumpAmount = 50,
}

-- Connection cleanup table
local Connections = {}
local function AddConn(c)
    if c then table.insert(Connections, c) end
end

-- Anti AFK
local function SetupAntiAFK()
    local c = LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    AddConn(c)
end

-- Anti Detection Bypasses
local function SetupBypasses()
    pcall(function()
        for _, v in pairs(getconnections(LocalPlayer.DescendantAdded)) do
            v:Disable()
        end
    end)
    pcall(function()
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if (method == "FireServer" or method == "InvokeServer") and
               (tostring(self):find("Kick") or tostring(self):find("Ban")) then
                return
            end
            return old(self, ...)
        end)
    end)
end

-- ESP System (only if Drawing is supported)
local ESPObjects = {}

if DrawingSupported then
    local function CreateESP(character, player)
        if not character or character == LocalPlayer.Character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local head = character:FindFirstChild("Head")
        if not humanoid or not head then return end

        local esp = {
            Character = character,
            Player = player,
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Tracer = Drawing.new("Line"),
            Health = Drawing.new("Text")
        }

        esp.Box.Color = Color3.fromRGB(255, 50, 50)
        esp.Box.Thickness = 1.5
        esp.Box.Filled = false
        esp.Box.Visible = false

        esp.Name.Color = Color3.fromRGB(255, 255, 255)
        esp.Name.Size = 14
        esp.Name.Center = true
        esp.Name.Outline = true
        esp.Name.Text = player.Name
        esp.Name.Visible = false

        esp.Tracer.Color = Color3.fromRGB(255, 50, 50)
        esp.Tracer.Thickness = 1.5
        esp.Tracer.Visible = false

        esp.Health.Size = 12
        esp.Health.Center = true
        esp.Health.Outline = true
        esp.Health.Visible = false

        table.insert(ESPObjects, esp)
        return esp
    end

    -- ESP cleanup function
    local function RemoveESP(esp)
        if esp then
            pcall(function() esp.Box:Remove() end)
            pcall(function() esp.Name:Remove() end)
            pcall(function() esp.Tracer:Remove() end)
            pcall(function() esp.Health:Remove() end)
            if esp.Highlight then
                pcall(function() esp.Highlight:Destroy() end)
            end
        end
    end

    -- ESP Update Loop
    local espConn = RunService.RenderStepped:Connect(function()
        -- Auto-create ESP for new players
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local found = false
                for _, esp in pairs(ESPObjects) do
                    if esp.Player == player then
                        found = true
                        break
                    end
                end
                if not found then
                    CreateESP(player.Character, player)
                end
            end
        end

        -- Update all ESPs
        for i = #ESPObjects, 1, -1 do
            local esp = ESPObjects[i]
            local char = esp.Character
            local player = esp.Player

            if not char or not char.Parent then
                RemoveESP(esp)
                table.remove(ESPObjects, i)
            else
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local head = char:FindFirstChild("Head")
                local root = char:FindFirstChild("HumanoidRootPart")

                if humanoid and head and root and humanoid.Health > 0 then
                    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    local rootPos = Camera:WorldToViewportPoint(root.Position)

                    if onScreen then
                        local scale = (head.Position - root.Position).Magnitude
                        local boxSize = Vector2.new(math.max(scale * 1.5, 10), math.max(scale * 2, 20))

                        -- Box
                        esp.Box.Visible = States.ESPBoxes
                        esp.Box.Position = Vector2.new(headPos.X - boxSize.X/2, headPos.Y - boxSize.Y)
                        esp.Box.Size = boxSize

                        -- Name
                        esp.Name.Visible = States.ESPNames
                        esp.Name.Position = Vector2.new(headPos.X, headPos.Y - boxSize.Y - 15)

                        -- Tracer
                        esp.Tracer.Visible = States.ESPTracers
                        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)

                        -- Health
                        esp.Health.Visible = States.ESPHealth
                        esp.Health.Position = Vector2.new(headPos.X, headPos.Y - boxSize.Y - 2)
                        local hp = math.floor((humanoid.Health / math.max(humanoid.MaxHealth, 1)) * 100)
                        esp.Health.Text = tostring(hp) .. "%"
                        if hp > 50 then
                            esp.Health.Color = Color3.fromRGB(0, 255, 0)
                        elseif hp > 25 then
                            esp.Health.Color = Color3.fromRGB(255, 255, 0)
                        else
                            esp.Health.Color = Color3.fromRGB(255, 0, 0)
                        end
                    else
                        esp.Box.Visible = false
                        esp.Name.Visible = false
                        esp.Tracer.Visible = false
                        esp.Health.Visible = false
                    end
                else
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.Tracer.Visible = false
                    esp.Health.Visible = false
                end
            end
        end
    end)
    AddConn(espConn)
end

-- Chams toggle handler (works without Drawing)
local function ToggleChams(state)
    if state then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                pcall(function()
                    local h = Instance.new("Highlight")
                    h.Adornee = player.Character
                    h.FillColor = Color3.fromRGB(255, 50, 50)
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                    h.FillTransparency = 0.5
                    h.Parent = player.Character
                    -- Store reference
                    if DrawingSupported then
                        for _, esp in pairs(ESPObjects) do
                            if esp.Player == player then
                                esp.Highlight = h
                                break
                            end
                        end
                    end
                end)
            end
        end
    else
        -- Remove all highlights
        for _, v in pairs(Workspace:GetDescendants()) do
            pcall(function()
                if v:IsA("Highlight") then
                    v:Destroy()
                end
            end)
        end
        if DrawingSupported then
            for _, esp in pairs(ESPObjects) do
                esp.Highlight = nil
            end
        end
    end
end

-- Player connection for ESP
if DrawingSupported then
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                CreateESP(player.Character, player)
            end
            local c = player.CharacterAdded:Connect(function(char)
                CreateESP(char, player)
            end)
            AddConn(c)
        end
    end
    local c = Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            local c2 = player.CharacterAdded:Connect(function(char)
                CreateESP(char, player)
            end)
            AddConn(c2)
        end
    end)
    AddConn(c)
end

-- Movement Functions
local function ToggleFly(state)
    if state then
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then return end

        humanoid.PlatformStand = true
        local bg = Instance.new("BodyGyro")
        local bv = Instance.new("BodyVelocity")
        bg.P = 9e4
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = root.CFrame
        bg.Parent = root
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = root

        local c = RunService.RenderStepped:Connect(function()
            if not States.Fly or not char or not char.Parent then
                pcall(function() bg:Destroy() end)
                pcall(function() bv:Destroy() end)
                if humanoid then humanoid.PlatformStand = false end
                c:Disconnect()
                return
            end
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
            bg.CFrame = CFrame.new(root.Position, root.Position + Camera.CFrame.LookVector)
            bv.Velocity = dir * (States.SpeedAmount * 2)
        end)
        AddConn(c)
    end
end

local function ToggleNoclip(state)
    if state then
        local char = LocalPlayer.Character
        if not char then return end
        local c = RunService.Stepped:Connect(function()
            if not States.Noclip or not char or not char.Parent then
                c:Disconnect()
                return
            end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        AddConn(c)
    end
end

local function ApplySpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = States.Speed and States.SpeedAmount or 16
    end
end

local function ApplyJump()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = States.Jump and States.JumpAmount or 50
    end
end

local function ToggleInfJump(state)
    if state then
        local c = UserInputService.JumpRequest:Connect(function()
            if not States.InfJump then c:Disconnect(); return end
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
        AddConn(c)
    end
end

local function ToggleFling(state)
    if state then
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local bav = Instance.new("BodyAngularVelocity")
        bav.AngularVelocity = Vector3.new(0, 500, 0)
        bav.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bav.P = 9e9
        bav.Parent = root
        local c = RunService.RenderStepped:Connect(function()
            if not States.Fling or not char or not char.Parent then
                pcall(function() bav:Destroy() end)
                c:Disconnect()
                return
            end
            root.Velocity = Vector3.new(0, 50, 0)
        end)
        AddConn(c)
    end
end

local function ToggleSpin(state)
    if state then
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local c = RunService.RenderStepped:Connect(function()
            if not States.Spin or not char or not char.Parent then
                c:Disconnect()
                return
            end
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(10), 0)
        end)
        AddConn(c)
    end
end

local function ToggleFloat(state)
    if state then
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local c = RunService.RenderStepped:Connect(function()
            if not States.Float or not char or not char.Parent then
                c:Disconnect()
                return
            end
            root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        end)
        AddConn(c)
    end
end

-- Visual Functions
local function ApplyFullbright()
    if States.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
        Lighting.GlobalShadows = false
        Lighting.ClockTime = 12
    else
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.Brightness = 1
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
        Lighting.GlobalShadows = true
    end
end

local function ApplyNightVision()
    if States.NightVision then
        Lighting.Ambient = Color3.fromRGB(0, 255, 0)
        Lighting.Brightness = 0.5
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1000
    else
        ApplyFullbright()
    end
end

local function ApplyXRay()
    for _, v in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") then
                if States.XRay and LocalPlayer.Character and not v:IsDescendantOf(LocalPlayer.Character) then
                    v.LocalTransparencyModifier = 0.5
                else
                    v.LocalTransparencyModifier = 0
                end
            end
        end)
    end
end

local function ApplyFog()
    if States.FogRemoved then
        Lighting.FogEnd = 1e10
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = 500
        Lighting.FogStart = 0
    end
end

-- Troll Functions
local function ToggleSoundSpam(state)
    if state then
        local sounds = {
            "rbxassetid://911136078", "rbxassetid://138750308",
            "rbxassetid://1846575042", "rbxassetid://1285875234",
            "rbxassetid://1603674808"
        }
        local c = RunService.RenderStepped:Connect(function()
            if not States.SoundSpam then c:Disconnect(); return end
            local s = Instance.new("Sound")
            s.SoundId = sounds[math.random(1, #sounds)]
            s.Volume = 10
            s.Parent = Workspace
            s:Play()
            game:GetService("Debris"):AddItem(s, 5)
        end)
        AddConn(c)
    end
end

local function ToggleChatSpam(state)
    if state then
        local msgs = {"RobluX najlepszy!", "s4d > all", "get rekt", "RobluX On Top", "free robux 2026"}
        local c = RunService.RenderStepped:Connect(function()
            if not States.ChatSpam then c:Disconnect(); return end
            local chat = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if chat then
                local say = chat:FindFirstChild("SayMessageRequest")
                if say then
                    pcall(function() say:FireServer(msgs[math.random(1, #msgs)], "All") end)
                end
            end
        end)
        AddConn(c)
    end
end

local function ToggleFlingAll(state)
    if state then
        local c = RunService.RenderStepped:Connect(function()
            if not States.FlingAll then c:Disconnect(); return end
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local tr = p.Character:FindFirstChild("HumanoidRootPart")
                    if tr and (root.Position - tr.Position).Magnitude < 20 then
                        tr.CFrame = CFrame.new(tr.Position, root.Position)
                        tr.Velocity = Vector3.new(0, 100, 0)
                    end
                end
            end
        end)
        AddConn(c)
    end
end

local function ToggleFlingUp(state)
    if state then
        local c = RunService.RenderStepped:Connect(function()
            if not States.FlingUp then c:Disconnect(); return end
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local tr = p.Character:FindFirstChild("HumanoidRootPart")
                    if tr and (root.Position - tr.Position).Magnitude < 30 then
                        tr.Velocity = Vector3.new(tr.Velocity.X, 200, tr.Velocity.Z)
                    end
                end
            end
        end)
        AddConn(c)
    end
end

-- Arsenal Functions
if IsArsenal then
    local function ToggleSilentAim(state)
        if state then
            local c = RunService.RenderStepped:Connect(function()
                if not States.SilentAim then c:Disconnect(); return end
                local mouse = LocalPlayer:GetMouse()
                local closest, closestDist = nil, math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local pos, on = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                        if on then
                            local d = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                            if d < closestDist and d < 200 then closest, closestDist = p.Character.HumanoidRootPart, d end
                        end
                    end
                end
                if closest then
                    local weapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if weapon then
                        local ws = weapon:FindFirstChild("WeaponScript")
                        if ws then
                            local fire = ws:FindFirstChild("Fire")
                            if fire then pcall(function() fire:InvokeServer(closest) end) end
                        end
                    end
                end
            end)
            AddConn(c)
        end
    end

    local function ToggleAimlock(state)
        if state then
            local c = RunService.RenderStepped:Connect(function()
                if not States.Aimlock then c:Disconnect(); return end
                local closest, closestDist = nil, math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                        local pos, on = Camera:WorldToViewportPoint(p.Character.Head.Position)
                        if on then
                            local d = (Vector2.new(LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                            if d < closestDist and d < 300 then closest, closestDist = p.Character.Head, d end
                        end
                    end
                end
                if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position) end
            end)
            AddConn(c)
        end
    end

    local function ToggleTriggerbot(state)
        if state then
            local c = RunService.RenderStepped:Connect(function()
                if not States.Triggerbot then c:Disconnect(); return end
                local target = LocalPlayer:GetMouse().Target
                if target and target.Parent then
                    local p = Players:GetPlayerFromCharacter(target.Parent)
                    if p and p ~= LocalPlayer then
                        local weapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if weapon then pcall(function() weapon:Activate() end) end
                    end
                end
            end)
            AddConn(c)
        end
    end

    local function ToggleNoSpread()
        if States.NoSpread then
            pcall(function()
                local old
                old = hookmetamethod(game, "__index", function(self, k)
                    if tostring(self):find("WeaponScript") and (k == "Spread" or k == "Recoil") then return 0 end
                    return old(self, k)
                end)
            end)
        end
    end

    local function ToggleWallbang(state)
        if state then
            local c = RunService.RenderStepped:Connect(function()
                if not States.Wallbang then c:Disconnect(); return end
                for _, v in pairs(Workspace:GetDescendants()) do
                    pcall(function()
                        if v:IsA("BasePart") and LocalPlayer.Character and not v:IsDescendantOf(LocalPlayer.Character) then
                            v.CanQuery = false
                        end
                    end)
                end
            end)
            AddConn(c)
        end
    end
end

-- Case Paradise Functions
if IsCaseParadise then
    local function ToggleAutoFarm(state)
        if state then
            local c = RunService.RenderStepped:Connect(function()
                if not States.AutoFarm then c:Disconnect(); return end
                for _, v in pairs(Workspace:GetDescendants()) do
                    pcall(function()
                        if v:IsA("BasePart") and v:FindFirstChild("ClickDetector") then
                            local char = LocalPlayer.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char.HumanoidRootPart.CFrame = CFrame.new(v.Position)
                                task.wait(0.1)
                                fireclickdetector(v.ClickDetector)
                            end
                        end
                    end)
                end
            end)
            AddConn(c)
        end
    end

    local function ToggleAutoCollect(state)
        if state then
            local c = RunService.RenderStepped:Connect(function()
                if not States.AutoCollect then c:Disconnect(); return end
                for _, v in pairs(Workspace:GetDescendants()) do
                    pcall(function()
                        if v:IsA("Part") and (v.Name:find("Case") or v.Name:find("Drop")) then
                            local char = LocalPlayer.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char.HumanoidRootPart.CFrame = CFrame.new(v.Position)
                            end
                        end
                    end)
                end
            end)
            AddConn(c)
        end
    end

    local function ToggleAutoClick(state)
        if state then
            local c = RunService.RenderStepped:Connect(function()
                if not States.AutoClick then c:Disconnect(); return end
                pcall(function()
                    mouse1press()
                    task.wait(0.05)
                    mouse1release()
                end)
            end)
            AddConn(c)
        end
    end

    local function ToggleAutoBuy(state)
        if state then
            local c = RunService.RenderStepped:Connect(function()
                if not States.AutoBuy then c:Disconnect(); return end
                pcall(function()
                    local br = game:GetService("ReplicatedStorage"):FindFirstChild("BuyItem", true)
                    if br then br:InvokeServer("CheapestCase") end
                end)
            end)
            AddConn(c)
        end
    end

    local function ToggleAutoQuest(state)
        if state then
            local c = RunService.RenderStepped:Connect(function()
                if not States.AutoQuest then c:Disconnect(); return end
                pcall(function()
                    local qr = game:GetService("ReplicatedStorage"):FindFirstChild("ClaimQuest", true)
                    if qr then qr:FireServer() end
                end)
            end)
            AddConn(c)
        end
    end
end

-- Character respawn handler
local charConn = LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if States.Speed then ApplySpeed() end
    if States.Jump then ApplyJump() end
    if States.Fly then ToggleFly(true) end
    if States.Noclip then ToggleNoclip(true) end
    if States.Fling then ToggleFling(true) end
    if States.Spin then ToggleSpin(true) end
    if States.Float then ToggleFloat(true) end
end)
AddConn(charConn)

-- =============================================
-- UI CREATION
-- =============================================

local MainTab = Window:CreateTab("Informacje", "info")
local MovementTab = Window:CreateTab("Ruch", "move")
local ESPTab = Window:CreateTab("ESP", "eye")
local VisualsTab = Window:CreateTab("Visiale", "light")
local TrollTab = Window:CreateTab("Troll", "alert-circle")
local ArsenalTab = IsArsenal and Window:CreateTab("Arsenal", "crosshair") or nil
local CaseParadiseTab = IsCaseParadise and Window:CreateTab("Case Paradise", "package") or nil

-- ========== INFORMATION TAB ==========
MainTab:CreateParagraph({
    Title = "RobluX Premium",
    Content = "Wersja: 2.0.0\nAutor: s4d\nGra: " .. GameName .. "\nID gry: " .. PlaceID .. "\n\nDiscord: discord.gg/roblux"
})

MainTab:CreateButton({
    Name = "Skopiuj Discord",
    Callback = function()
        pcall(function() setclipboard("discord.gg/roblux") end)
        Rayfield:Notify({ Title = "Skopiowano!", Content = "Link Discorda skopiowany", Duration = 3 })
    end
})

MainTab:CreateButton({
    Name = "Zniszcz UI",
    Callback = function()
        for _, c in pairs(Connections) do pcall(function() c:Disconnect() end) end
        if DrawingSupported then
            for _, esp in pairs(ESPObjects) do
                pcall(function() esp.Box:Remove() end)
                pcall(function() esp.Name:Remove() end)
                pcall(function() esp.Tracer:Remove() end)
                pcall(function() esp.Health:Remove() end)
                if esp.Highlight then pcall(function() esp.Highlight:Destroy() end) end
            end
            ESPObjects = {}
        end
        Rayfield:Destroy()
    end
})

MainTab:CreateSection("Bypassy")

MainTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Callback = function(v)
        States.AntiAFK = v
        if v then SetupAntiAFK() end
    end
})

MainTab:CreateToggle({
    Name = "Anti Detection",
    CurrentValue = false,
    Callback = function(v)
        States.AntiDetect = v
        if v then SetupBypasses() end
    end
})

-- ========== MOVEMENT TAB ==========
MovementTab:CreateSection("Główne")

MovementTab:CreateToggle({
    Name = "Latanie (Fly)",
    CurrentValue = false,
    Callback = function(v) States.Fly = v; ToggleFly(v) end
})

MovementTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v) States.Noclip = v; ToggleNoclip(v) end
})

MovementTab:CreateToggle({
    Name = "Speed Boost",
    CurrentValue = false,
    Callback = function(v) States.Speed = v; ApplySpeed() end
})

MovementTab:CreateSlider({
    Name = "Speed Amount",
    Range = {16, 250},
    Increment = 1,
    Suffix = "WS",
    CurrentValue = 50,
    Callback = function(v)
        States.SpeedAmount = v
        if States.Speed then ApplySpeed() end
    end
})

MovementTab:CreateToggle({
    Name = "Jump Boost",
    CurrentValue = false,
    Callback = function(v) States.Jump = v; ApplyJump() end
})

MovementTab:CreateSlider({
    Name = "Jump Amount",
    Range = {50, 500},
    Increment = 1,
    Suffix = "JP",
    CurrentValue = 50,
    Callback = function(v)
        States.JumpAmount = v
        if States.Jump then ApplyJump() end
    end
})

MovementTab:CreateToggle({
    Name = "Inf Jump",
    CurrentValue = false,
    Callback = function(v) States.InfJump = v; ToggleInfJump(v) end
})

MovementTab:CreateToggle({
    Name = "Fling",
    CurrentValue = false,
    Callback = function(v) States.Fling = v; ToggleFling(v) end
})

MovementTab:CreateToggle({
    Name = "Spin",
    CurrentValue = false,
    Callback = function(v) States.Spin = v; ToggleSpin(v) end
})

MovementTab:CreateToggle({
    Name = "Float",
    CurrentValue = false,
    Callback = function(v) States.Float = v; ToggleFloat(v) end
})

-- ========== ESP TAB ==========
ESPTab:CreateSection("ESP Główne")

ESPTab:CreateToggle({
    Name = "ESP Box",
    CurrentValue = false,
    Callback = function(v) States.ESPBoxes = v end
})

ESPTab:CreateToggle({
    Name = "ESP Nazwy",
    CurrentValue = false,
    Callback = function(v) States.ESPNames = v end
})

ESPTab:CreateToggle({
    Name = "ESP Tracery",
    CurrentValue = false,
    Callback = function(v) States.ESPTracers = v end
})

ESPTab:CreateToggle({
    Name = "ESP Health",
    CurrentValue = false,
    Callback = function(v) States.ESPHealth = v end
})

ESPTab:CreateToggle({
    Name = "ESP Chams (Highlight)",
    CurrentValue = false,
    Callback = function(v)
        States.ESPChams = v
        ToggleChams(v)
    end
})

if not DrawingSupported then
    ESPTab:CreateParagraph({
        Title = "Uwaga",
        Content = "Twój executor nie wspiera Drawing API. ESP Box/Nazwy/Tracery/Health nie będą działać, ale Chams (Highlight) działa."
    })
end

-- ========== VISUALS TAB ==========
VisualsTab:CreateSection("Visiale")

VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(v)
        States.Fullbright = v
        if v then States.NightVision = false end
        ApplyFullbright()
    end
})

VisualsTab:CreateToggle({
    Name = "Night Vision",
    CurrentValue = false,
    Callback = function(v)
        States.NightVision = v
        if v then States.Fullbright = false end
        ApplyNightVision()
    end
})

VisualsTab:CreateToggle({
    Name = "X-Ray",
    CurrentValue = false,
    Callback = function(v) States.XRay = v; ApplyXRay() end
})

VisualsTab:CreateToggle({
    Name = "Usuń Mgłę",
    CurrentValue = false,
    Callback = function(v) States.FogRemoved = v; ApplyFog() end
})

-- ========== TROLL TAB ==========
TrollTab:CreateSection("Troll")

TrollTab:CreateToggle({
    Name = "Spam Dźwiękiem",
    CurrentValue = false,
    Callback = function(v) States.SoundSpam = v; ToggleSoundSpam(v) end
})

TrollTab:CreateToggle({
    Name = "Spam Czatem",
    CurrentValue = false,
    Callback = function(v) States.ChatSpam = v; ToggleChatSpam(v) end
})

TrollTab:CreateToggle({
    Name = "Fling All",
    CurrentValue = false,
    Callback = function(v) States.FlingAll = v; ToggleFlingAll(v) end
})

TrollTab:CreateToggle({
    Name = "Fling Up",
    CurrentValue = false,
    Callback = function(v) States.FlingUp = v; ToggleFlingUp(v) end
})

-- ========== ARSENAL TAB ==========
if ArsenalTab then
    ArsenalTab:CreateSection("Aimbot")

    ArsenalTab:CreateToggle({
        Name = "Silent Aim",
        CurrentValue = false,
        Callback = function(v) States.SilentAim = v; ToggleSilentAim(v) end
    })

    ArsenalTab:CreateToggle({
        Name = "Aimlock",
        CurrentValue = false,
        Callback = function(v) States.Aimlock = v; ToggleAimlock(v) end
    })

    ArsenalTab:CreateToggle({
        Name = "Triggerbot",
        CurrentValue = false,
        Callback = function(v) States.Triggerbot = v; ToggleTriggerbot(v) end
    })

    ArsenalTab:CreateToggle({
        Name = "No Spread",
        CurrentValue = false,
        Callback = function(v) States.NoSpread = v; ToggleNoSpread() end
    })

    ArsenalTab:CreateToggle({
        Name = "Wallbang",
        CurrentValue = false,
        Callback = function(v) States.Wallbang = v; ToggleWallbang(v) end
    })

    ArsenalTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            Rayfield:Notify({ Title = "Odświeżono", Content = "Status odświeżony", Duration = 3 })
        end
    })
end

-- ========== CASE PARADISE TAB ==========
if CaseParadiseTab then
    CaseParadiseTab:CreateSection("Auto Farm")

    CaseParadiseTab:CreateToggle({
        Name = "Auto Farm",
        CurrentValue = false,
        Callback = function(v) States.AutoFarm = v; ToggleAutoFarm(v) end
    })

    CaseParadiseTab:CreateToggle({
        Name = "Auto Collect",
        CurrentValue = false,
        Callback = function(v) States.AutoCollect = v; ToggleAutoCollect(v) end
    })

    CaseParadiseTab:CreateToggle({
        Name = "Auto Click",
        CurrentValue = false,
        Callback = function(v) States.AutoClick = v; ToggleAutoClick(v) end
    })

    CaseParadiseTab:CreateToggle({
        Name = "Auto Buy",
        CurrentValue = false,
        Callback = function(v) States.AutoBuy = v; ToggleAutoBuy(v) end
    })

    CaseParadiseTab:CreateToggle({
        Name = "Auto Quest",
        CurrentValue = false,
        Callback = function(v) States.AutoQuest = v; ToggleAutoQuest(v) end
    })
end

-- Load saved config
Rayfield:LoadConfiguration()
