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

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- State Variables
local States = {
    Fly = false,
    Noclip = false,
    Speed = false,
    Jump = false,
    InfJump = false,
    Fling = false,
    Spin = false,
    Float = false,
    ESPBoxes = false,
    ESPNames = false,
    ESPTracers = false,
    ESPHealth = false,
    ESPChams = false,
    Fullbright = false,
    NightVision = false,
    XRay = false,
    FogRemoved = false,
    SoundSpam = false,
    ChatSpam = false,
    FlingAll = false,
    FlingUp = false,
    SilentAim = false,
    Aimlock = false,
    Triggerbot = false,
    NoSpread = false,
    Wallbang = false,
    AutoFarm = false,
    AutoCollect = false,
    AutoClick = false,
    AutoBuy = false,
    AutoQuest = false,
    AntiAFK = false,
    AntiDetect = false,
    SpeedAmount = 50,
    JumpAmount = 50,
}

-- Connection Storage (for cleanup)
local Connections = {}

-- Anti AFK
local function SetupAntiAFK()
    local connection
    connection = LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    table.insert(Connections, connection)
end

-- Anti Detection Bypasses
local function SetupBypasses()
    pcall(function()
        for _, v in pairs(getconnections(LocalPlayer.DescendantAdded)) do
            v:Disable()
        end
    end)
    
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            if method == "FireServer" or method == "InvokeServer" then
                if tostring(self):find("Kick") or tostring(self):find("Ban") then
                    return
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
    
    pcall(function()
        local mt = getrawmetatable(game)
        local oldIndex = mt.__index
        setreadonly(mt, false)
        mt.__index = newcclosure(function(self, key)
            if tostring(self):find("RemoteEvent") and key == "FireServer" then
                return function() end
            end
            return oldIndex(self, key)
        end)
        setreadonly(mt, true)
    end)
end

-- ESP Objects
local ESPObjects = {}

local function CreateESP(character, player)
    if not character or character == LocalPlayer.Character then return end
    
    local esp = {}
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    local root = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not head then return end
    
    esp.Character = character
    esp.Player = player
    
    -- Box
    local box = Drawing.new("Square")
    box.Visible = States.ESPBoxes
    box.Color = Color3.fromRGB(255, 50, 50)
    box.Thickness = 1.5
    box.Filled = false
    esp.Box = box
    
    -- Name
    local nameText = Drawing.new("Text")
    nameText.Visible = States.ESPNames
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.Text = player.Name
    esp.Name = nameText
    
    -- Tracer
    local tracer = Drawing.new("Line")
    tracer.Visible = States.ESPTracers
    tracer.Color = Color3.fromRGB(255, 50, 50)
    tracer.Thickness = 1.5
    esp.Tracer = tracer
    
    -- Health
    local healthText = Drawing.new("Text")
    healthText.Visible = States.ESPHealth
    healthText.Size = 12
    healthText.Center = true
    healthText.Outline = true
    esp.Health = healthText
    
    -- Chams
    if States.ESPChams then
        local success, highlight = pcall(function()
            local h = Instance.new("Highlight")
            h.Adornee = character
            h.FillColor = Color3.fromRGB(255, 50, 50)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.FillTransparency = 0.5
            h.Parent = character
            return h
        end)
        if success then
            esp.Highlight = highlight
        end
    end
    
    table.insert(ESPObjects, esp)
    return esp
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
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.P = 9e4
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.CFrame = root.CFrame
        bodyGyro.Parent = root
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Parent = root
        
        local conn = RunService.RenderStepped:Connect(function()
            if not States.Fly or not char or not char.Parent then
                pcall(function()
                    bodyGyro:Destroy()
                    bodyVelocity:Destroy()
                end)
                if humanoid then humanoid.PlatformStand = false end
                conn:Disconnect()
                return
            end
            
            local moveDirection = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            bodyGyro.CFrame = CFrame.new(root.Position, root.Position + Camera.CFrame.LookVector)
            bodyVelocity.Velocity = moveDirection * (States.SpeedAmount * 2)
        end)
        table.insert(Connections, conn)
    end
end

local function ToggleNoclip(state)
    if state then
        local char = LocalPlayer.Character
        if not char then return end
        
        local conn = RunService.Stepped:Connect(function()
            if not States.Noclip or not char or not char.Parent then
                conn:Disconnect()
                return
            end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        table.insert(Connections, conn)
    end
end

local function ApplySpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if States.Speed then
        humanoid.WalkSpeed = States.SpeedAmount
    else
        humanoid.WalkSpeed = 16
    end
end

local function ApplyJump()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if States.Jump then
        humanoid.JumpPower = States.JumpAmount
    else
        humanoid.JumpPower = 50
    end
end

local function ToggleInfJump(state)
    if state then
        local conn = UserInputService.JumpRequest:Connect(function()
            if not States.InfJump then
                conn:Disconnect()
                return
            end
            local char = LocalPlayer.Character
            if not char then return end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        table.insert(Connections, conn)
    end
end

local function ToggleFling(state)
    if state then
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local bodyAngVel = Instance.new("BodyAngularVelocity")
        bodyAngVel.AngularVelocity = Vector3.new(0, 500, 0)
        bodyAngVel.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyAngVel.P = 9e9
        bodyAngVel.Parent = root
        
        local conn = RunService.RenderStepped:Connect(function()
            if not States.Fling or not char or not char.Parent then
                pcall(function() bodyAngVel:Destroy() end)
                conn:Disconnect()
                return
            end
            root.Velocity = Vector3.new(0, 50, 0)
        end)
        table.insert(Connections, conn)
    end
end

local function ToggleSpin(state)
    if state then
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local conn = RunService.RenderStepped:Connect(function()
            if not States.Spin or not char or not char.Parent then
                conn:Disconnect()
                return
            end
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(10), 0)
        end)
        table.insert(Connections, conn)
    end
end

local function ToggleFloat(state)
    if state then
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local conn = RunService.RenderStepped:Connect(function()
            if not States.Float or not char or not char.Parent then
                conn:Disconnect()
                return
            end
            root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        end)
        table.insert(Connections, conn)
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
                if States.XRay and not v:IsDescendantOf(LocalPlayer.Character) then
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
            "rbxassetid://911136078",
            "rbxassetid://138750308",
            "rbxassetid://1846575042",
            "rbxassetid://1285875234",
            "rbxassetid://1603674808"
        }
        
        local conn = RunService.RenderStepped:Connect(function()
            if not States.SoundSpam then
                conn:Disconnect()
                return
            end
            local sound = Instance.new("Sound")
            sound.SoundId = sounds[math.random(1, #sounds)]
            sound.Volume = 10
            sound.Parent = Workspace
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 5)
        end)
        table.insert(Connections, conn)
    end
end

local function ToggleChatSpam(state)
    if state then
        local messages = {
            "RobluX najlepszy!",
            "s4d > all",
            "get rekt",
            "RobluX On Top",
            "free robux 2026"
        }
        
        local conn = RunService.RenderStepped:Connect(function()
            if not States.ChatSpam then
                conn:Disconnect()
                return
            end
            
            local chatRemote = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if chatRemote then
                local sayMsg = chatRemote:FindFirstChild("SayMessageRequest")
                if sayMsg then
                    pcall(function()
                        sayMsg:FireServer(messages[math.random(1, #messages)], "All")
                    end)
                end
            end
        end)
        table.insert(Connections, conn)
    end
end

local function ToggleFlingAll(state)
    if state then
        local conn = RunService.RenderStepped:Connect(function()
            if not States.FlingAll then
                conn:Disconnect()
                return
            end
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local distance = (root.Position - targetRoot.Position).Magnitude
                        if distance < 20 then
                            targetRoot.CFrame = CFrame.new(targetRoot.Position, root.Position)
                            targetRoot.Velocity = Vector3.new(0, 100, 0)
                        end
                    end
                end
            end
        end)
        table.insert(Connections, conn)
    end
end

local function ToggleFlingUp(state)
    if state then
        local conn = RunService.RenderStepped:Connect(function()
            if not States.FlingUp then
                conn:Disconnect()
                return
            end
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local distance = (root.Position - targetRoot.Position).Magnitude
                        if distance < 30 then
                            targetRoot.Velocity = Vector3.new(targetRoot.Velocity.X, 200, targetRoot.Velocity.Z)
                        end
                    end
                end
            end
        end)
        table.insert(Connections, conn)
    end
end

-- Arsenal Functions
if IsArsenal then
    local function ToggleSilentAim(state)
        if state then
            local conn = RunService.RenderStepped:Connect(function()
                if not States.SilentAim then
                    conn:Disconnect()
                    return
                end
                
                local mouse = LocalPlayer:GetMouse()
                local closestTarget = nil
                local closestDistance = math.huge
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local targetPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                        if onScreen then
                            local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(targetPos.X, targetPos.Y)).Magnitude
                            if distance < closestDistance and distance < 200 then
                                closestDistance = distance
                                closestTarget = player.Character.HumanoidRootPart
                            end
                        end
                    end
                end
                
                if closestTarget then
                    local weapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if weapon then
                        local weaponScript = weapon:FindFirstChild("WeaponScript")
                        if weaponScript then
                            local fireFunc = weaponScript:FindFirstChild("Fire")
                            if fireFunc then
                                pcall(function()
                                    fireFunc:InvokeServer(closestTarget)
                                end)
                            end
                        end
                    end
                end
            end)
            table.insert(Connections, conn)
        end
    end
    
    local function ToggleAimlock(state)
        if state then
            local conn = RunService.RenderStepped:Connect(function()
                if not States.Aimlock then
                    conn:Disconnect()
                    return
                end
                
                local closestTarget = nil
                local closestDistance = math.huge
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                        local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
                        if onScreen then
                            local mousePos = LocalPlayer:GetMouse()
                            local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(headPos.X, headPos.Y)).Magnitude
                            if distance < closestDistance and distance < 300 then
                                closestDistance = distance
                                closestTarget = player.Character.Head
                            end
                        end
                    end
                end
                
                if closestTarget then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
                end
            end)
            table.insert(Connections, conn)
        end
    end
    
    local function ToggleTriggerbot(state)
        if state then
            local conn = RunService.RenderStepped:Connect(function()
                if not States.Triggerbot then
                    conn:Disconnect()
                    return
                end
                
                local mouse = LocalPlayer:GetMouse()
                local target = mouse.Target
                
                if target and target.Parent then
                    local player = Players:GetPlayerFromCharacter(target.Parent)
                    if player and player ~= LocalPlayer then
                        local weapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if weapon then
                            pcall(function()
                                weapon:Activate()
                            end)
                        end
                    end
                end
            end)
            table.insert(Connections, conn)
        end
    end
    
    local function ToggleNoSpread()
        if States.NoSpread then
            pcall(function()
                local oldIndex
                oldIndex = hookmetamethod(game, "__index", function(self, key)
                    if tostring(self):find("WeaponScript") and (key == "Spread" or key == "Recoil") then
                        return 0
                    end
                    return oldIndex(self, key)
                end)
            end)
        end
    end
    
    local function ToggleWallbang(state)
        if state then
            local conn = RunService.RenderStepped:Connect(function()
                if not States.Wallbang then
                    conn:Disconnect()
                    return
                end
                
                for _, part in pairs(Workspace:GetDescendants()) do
                    pcall(function()
                        if part:IsA("BasePart") then
                            local char = LocalPlayer.Character
                            if char and not part:IsDescendantOf(char) then
                                part.CanQuery = false
                            end
                        end
                    end)
                end
            end)
            table.insert(Connections, conn)
        end
    end
end

-- Case Paradise Functions
if IsCaseParadise then
    local function ToggleAutoFarm(state)
        if state then
            local conn = RunService.RenderStepped:Connect(function()
                if not States.AutoFarm then
                    conn:Disconnect()
                    return
                end
                
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
            table.insert(Connections, conn)
        end
    end
    
    local function ToggleAutoCollect(state)
        if state then
            local conn = RunService.RenderStepped:Connect(function()
                if not States.AutoCollect then
                    conn:Disconnect()
                    return
                end
                
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
            table.insert(Connections, conn)
        end
    end
    
    local function ToggleAutoClick(state)
        if state then
            local conn = RunService.RenderStepped:Connect(function()
                if not States.AutoClick then
                    conn:Disconnect()
                    return
                end
                
                local mouse = LocalPlayer:GetMouse()
                pcall(function()
                    mouse1press()
                    task.wait(0.05)
                    mouse1release()
                end)
            end)
            table.insert(Connections, conn)
        end
    end
    
    local function ToggleAutoBuy(state)
        if state then
            local conn = RunService.RenderStepped:Connect(function()
                if not States.AutoBuy then
                    conn:Disconnect()
                    return
                end
                
                pcall(function()
                    local buyRemote = game:GetService("ReplicatedStorage"):FindFirstChild("BuyItem", true)
                    if buyRemote then
                        buyRemote:InvokeServer("CheapestCase")
                    end
                end)
            end)
            table.insert(Connections, conn)
        end
    end
    
    local function ToggleAutoQuest(state)
        if state then
            local conn = RunService.RenderStepped:Connect(function()
                if not States.AutoQuest then
                    conn:Disconnect()
                    return
                end
                
                pcall(function()
                    local questRemote = game:GetService("ReplicatedStorage"):FindFirstChild("ClaimQuest", true)
                    if questRemote then
                        questRemote:FireServer()
                    end
                end)
            end)
            table.insert(Connections, conn)
        end
    end
end

-- ESP Update Loop
local espUpdateConn = RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local exists = false
            for _, esp in pairs(ESPObjects) do
                if esp.Player == player then
                    exists = true
                    break
                end
            end
            if not exists then
                CreateESP(player.Character, player)
            end
        end
    end
    
    -- Update visible ESPs
    for _, esp in pairs(ESPObjects) do
        local char = esp.Character
        local player = esp.Player
        if not char or not char.Parent then
            if esp.Box then esp.Box:Remove() end
            if esp.Name then esp.Name:Remove() end
            if esp.Tracer then esp.Tracer:Remove() end
            if esp.Health then esp.Health:Remove() end
            if esp.Highlight then pcall(function() esp.Highlight:Destroy() end) end
        else
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head")
            local root = char:FindFirstChild("HumanoidRootPart")
            
            if humanoid and head and root and humanoid.Health > 0 then
                local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local rootPos = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local scale = (head.Position - root.Position).Magnitude
                    local boxSize = Vector2.new(scale * 1.5, scale * 2)
                    
                    if esp.Box then
                        esp.Box.Visible = States.ESPBoxes
                        esp.Box.Position = Vector2.new(headPos.X - boxSize.X/2, headPos.Y - boxSize.Y)
                        esp.Box.Size = boxSize
                    end
                    
                    if esp.Name then
                        esp.Name.Visible = States.ESPNames
                        esp.Name.Position = Vector2.new(headPos.X, headPos.Y - boxSize.Y - 15)
                    end
                    
                    if esp.Tracer then
                        esp.Tracer.Visible = States.ESPTracers
                        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                    end
                    
                    if esp.Health then
                        esp.Health.Visible = States.ESPHealth
                        esp.Health.Position = Vector2.new(headPos.X, headPos.Y - boxSize.Y - 2)
                        local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                        esp.Health.Text = tostring(healthPercent) .. "%"
                        if healthPercent > 50 then
                            esp.Health.Color = Color3.fromRGB(0, 255, 0)
                        elseif healthPercent > 25 then
                            esp.Health.Color = Color3.fromRGB(255, 255, 0)
                        else
                            esp.Health.Color = Color3.fromRGB(255, 0, 0)
                        end
                    end
                else
                    if esp.Box then esp.Box.Visible = false end
                    if esp.Name then esp.Name.Visible = false end
                    if esp.Tracer then esp.Tracer.Visible = false end
                    if esp.Health then esp.Health.Visible = false end
                end
            else
                if esp.Box then esp.Box.Visible = false end
                if esp.Name then esp.Name.Visible = false end
                if esp.Tracer then esp.Tracer.Visible = false end
                if esp.Health then esp.Health.Visible = false end
            end
        end
    end
    
    -- Cleanup dead ESPs
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        if not esp.Character or not esp.Character.Parent then
            if esp.Box then esp.Box:Remove() end
            if esp.Name then esp.Name:Remove() end
            if esp.Tracer then esp.Tracer:Remove() end
            if esp.Health then esp.Health:Remove() end
            if esp.Highlight then pcall(function() esp.Highlight:Destroy() end) end
            table.remove(ESPObjects, i)
        end
    end
end)
table.insert(Connections, espUpdateConn)

-- Player connection for ESP
local function OnPlayerAdded(player)
    if player ~= LocalPlayer then
        local conn
        conn = player.CharacterAdded:Connect(function(char)
            CreateESP(char, player)
        end)
        table.insert(Connections, conn)
        
        if player.Character then
            CreateESP(player.Character, player)
        end
    end
end

for _, player in pairs(Players:GetPlayers()) do
    OnPlayerAdded(player)
end

Players.PlayerAdded:Connect(OnPlayerAdded)

-- Character added handler for movement re-apply
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if States.Speed then ApplySpeed() end
    if States.Jump then ApplyJump() end
    if States.Fly then ToggleFly(true) end
    if States.Noclip then ToggleNoclip(true) end
    if States.Fling then ToggleFling(true) end
    if States.Spin then ToggleSpin(true) end
    if States.Float then ToggleFloat(true) end
end)

-- UI Creation
local MainTab = Window:CreateTab("Informacje", "info")
local MovementTab = Window:CreateTab("Ruch", "move")
local ESPTab = Window:CreateTab("ESP", "eye")
local VisualsTab = Window:CreateTab("Visiale", "light")
local TrollTab = Window:CreateTab("Troll", "alert-circle")
local ArsenalTab = IsArsenal and Window:CreateTab("Arsenal", "crosshair")
local CaseParadiseTab = IsCaseParadise and Window:CreateTab("Case Paradise", "package")

-- Information Tab
MainTab:CreateParagraph({
    Title = "RobluX Premium",
    Content = "Wersja: 2.0.0\nAutor: s4d\nGra: " .. GameName .. "\nID: " .. PlaceID .. "\n\nDiscord: discord.gg/roblux"
})

MainTab:CreateButton({
    Name = "Skopiuj Discord",
    Callback = function()
        pcall(function()
            setclipboard("discord.gg/roblux")
        end)
        Rayfield:Notify({
            Title = "Skopiowano!",
            Content = "Link Discorda skopiowany do schowka",
            Duration = 3
        })
    end
})

MainTab:CreateButton({
    Name = "Zniszcz UI",
    Callback = function()
        for _, conn in pairs(Connections) do
            pcall(function() conn:Disconnect() end)
        end
        for _, esp in pairs(ESPObjects) do
            if esp.Box then esp.Box:Remove() end
            if esp.Name then esp.Name:Remove() end
            if esp.Tracer then esp.Tracer:Remove() end
            if esp.Health then esp.Health:Remove() end
            if esp.Highlight then pcall(function() esp.Highlight:Destroy() end) end
        end
        ESPObjects = {}
        Rayfield:Destroy()
    end
})

-- Bypasses Section
MainTab:CreateSection("Bypassy")

MainTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Callback = function(value)
        States.AntiAFK = value
        if value then
            SetupAntiAFK()
        end
    end
})

MainTab:CreateToggle({
    Name = "Anti Detection",
    CurrentValue = false,
    Callback = function(value)
        States.AntiDetect = value
        if value then
            SetupBypasses()
        end
    end
})

-- Movement Tab
MovementTab:CreateSection("Główne")

MovementTab:CreateToggle({
    Name = "Latanie (Fly)",
    CurrentValue = false,
    Callback = function(value)
        States.Fly = value
        ToggleFly(value)
    end
})

MovementTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(value)
        States.Noclip = value
        ToggleNoclip(value)
    end
})

MovementTab:CreateToggle({
    Name = "Speed Boost",
    CurrentValue = false,
    Callback = function(value)
        States.Speed = value
        ApplySpeed()
    end
})

MovementTab:CreateSlider({
    Name = "Speed Amount",
    Range = {16, 250},
    Increment = 1,
    Suffix = "WS",
    CurrentValue = 50,
    Callback = function(value)
        States.SpeedAmount = value
        if States.Speed then
            ApplySpeed()
        end
    end
})

MovementTab:CreateToggle({
    Name = "Jump Boost",
    CurrentValue = false,
    Callback = function(value)
        States.Jump = value
        ApplyJump()
    end
})

MovementTab:CreateSlider({
    Name = "Jump Amount",
    Range = {50, 500},
    Increment = 1,
    Suffix = "JP",
    CurrentValue = 50,
    Callback = function(value)
        States.JumpAmount = value
        if States.Jump then
            ApplyJump()
        end
    end
})

MovementTab:CreateToggle({
    Name = "Inf Jump",
    CurrentValue = false,
    Callback = function(value)
        States.InfJump = value
        ToggleInfJump(value)
    end
})

MovementTab:CreateToggle({
    Name = "Fling",
    CurrentValue = false,
    Callback = function(value)
        States.Fling = value
        ToggleFling(value)
    end
})

MovementTab:CreateToggle({
    Name = "Spin",
    CurrentValue = false,
    Callback = function(value)
        States.Spin = value
        ToggleSpin(value)
    end
})

MovementTab:CreateToggle({
    Name = "Float",
    CurrentValue = false,
    Callback = function(value)
        States.Float = value
        ToggleFloat(value)
    end
})

-- ESP Tab
ESPTab:CreateSection("ESP Główne")

ESPTab:CreateToggle({
    Name = "ESP Box",
    CurrentValue = false,
    Callback = function(value)
        States.ESPBoxes = value
    end
})

ESPTab:CreateToggle({
    Name = "ESP Nazwy",
    CurrentValue = false,
    Callback = function(value)
        States.ESPNames = value
    end
})

ESPTab:CreateToggle({
    Name = "ESP Tracery",
    CurrentValue = false,
    Callback = function(value)
        States.ESPTracers = value
    end
})

ESPTab:CreateToggle({
    Name = "ESP Health",
    CurrentValue = false,
    Callback = function(value)
        States.ESPHealth = value
    end
})

ESPTab:CreateToggle({
    Name = "ESP Chams (Highlight)",
    CurrentValue = false,
    Callback = function(value)
        States.ESPChams = value
        if value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local success, highlight = pcall(function()
                        local h = Instance.new("Highlight")
                        h.Adornee = player.Character
                        h.FillColor = Color3.fromRGB(255, 50, 50)
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.FillTransparency = 0.5
                        h.Parent = player.Character
                        return h
                    end)
                    if success then
                        for _, esp in pairs(ESPObjects) do
                            if esp.Player == player then
                                esp.Highlight = highlight
                                break
                            end
                        end
                    end
                end
            end
        else
            for _, esp in pairs(ESPObjects) do
                if esp.Highlight then
                    pcall(function() esp.Highlight:Destroy() end)
                    esp.Highlight = nil
                end
            end
            for _, v in pairs(Workspace:GetDescendants()) do
                pcall(function()
                    if v:IsA("Highlight") then
                        v:Destroy()
                    end
                end)
            end
        end
    end
})

-- Visuals Tab
VisualsTab:CreateSection("Visiale")

VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(value)
        States.Fullbright = value
        if value then States.NightVision = false end
        ApplyFullbright()
    end
})

VisualsTab:CreateToggle({
    Name = "Night Vision",
    CurrentValue = false,
    Callback = function(value)
        States.NightVision = value
        if value then States.Fullbright = false end
        ApplyNightVision()
    end
})

VisualsTab:CreateToggle({
    Name = "X-Ray",
    CurrentValue = false,
    Callback = function(value)
        States.XRay = value
        ApplyXRay()
    end
})

VisualsTab:CreateToggle({
    Name = "Usuń Mgłę",
    CurrentValue = false,
    Callback = function(value)
        States.FogRemoved = value
        ApplyFog()
    end
})

-- Troll Tab
TrollTab:CreateSection("Troll")

TrollTab:CreateToggle({
    Name = "Spam Dźwiękiem",
    CurrentValue = false,
    Callback = function(value)
        States.SoundSpam = value
        ToggleSoundSpam(value)
    end
})

TrollTab:CreateToggle({
    Name = "Spam Czatem",
    CurrentValue = false,
    Callback = function(value)
        States.ChatSpam = value
        ToggleChatSpam(value)
    end
})

TrollTab:CreateToggle({
    Name = "Fling All",
    CurrentValue = false,
    Callback = function(value)
        States.FlingAll = value
        ToggleFlingAll(value)
    end
})

TrollTab:CreateToggle({
    Name = "Fling Up",
    CurrentValue = false,
    Callback = function(value)
        States.FlingUp = value
        ToggleFlingUp(value)
    end
})

-- Arsenal Tab (conditional)
if IsArsenal and ArsenalTab then
    ArsenalTab:CreateSection("Aimbot")
    
    ArsenalTab:CreateToggle({
        Name = "Silent Aim",
        CurrentValue = false,
        Callback = function(value)
            States.SilentAim = value
            ToggleSilentAim(value)
        end
    })
    
    ArsenalTab:CreateToggle({
        Name = "Aimlock",
        CurrentValue = false,
        Callback = function(value)
            States.Aimlock = value
            ToggleAimlock(value)
        end
    })
    
    ArsenalTab:CreateToggle({
        Name = "Triggerbot",
        CurrentValue = false,
        Callback = function(value)
            States.Triggerbot = value
            ToggleTriggerbot(value)
        end
    })
    
    ArsenalTab:CreateToggle({
        Name = "No Spread",
        CurrentValue = false,
        Callback = function(value)
            States.NoSpread = value
            ToggleNoSpread()
        end
    })
    
    ArsenalTab:CreateToggle({
        Name = "Wallbang",
        CurrentValue = false,
        Callback = function(value)
            States.Wallbang = value
            ToggleWallbang(value)
        end
    })
    
    ArsenalTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            Rayfield:Notify({
                Title = "Odświeżono",
                Content = "Status broni odświeżony",
                Duration = 3
            })
        end
    })
end

-- Case Paradise Tab (conditional)
if IsCaseParadise and CaseParadiseTab then
    CaseParadiseTab:CreateSection("Auto Farm")
    
    CaseParadiseTab:CreateToggle({
        Name = "Auto Farm",
        CurrentValue = false,
        Callback = function(value)
            States.AutoFarm = value
            ToggleAutoFarm(value)
        end
    })
    
    CaseParadiseTab:CreateToggle({
        Name = "Auto Collect",
        CurrentValue = false,
        Callback = function(value)
            States.AutoCollect = value
            ToggleAutoCollect(value)
        end
    })
    
    CaseParadiseTab:CreateToggle({
        Name = "Auto Click",
        CurrentValue = false,
        Callback = function(value)
            States.AutoClick = value
            ToggleAutoClick(value)
        end
    })
    
    CaseParadiseTab:CreateToggle({
        Name = "Auto Buy",
        CurrentValue = false,
        Callback = function(value)
            States.AutoBuy = value
            ToggleAutoBuy(value)
        end
    })
    
    CaseParadiseTab:CreateToggle({
        Name = "Auto Quest",
        CurrentValue = false,
        Callback = function(value)
            States.AutoQuest = value
            ToggleAutoQuest(value)
        end
    })
end

-- Load Configuration
Rayfield:LoadConfiguration()
