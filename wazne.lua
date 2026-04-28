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
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

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
    ES PTracers = false,
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

-- Anti AFK
local function SetupAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

if States.AntiAFK then
    SetupAntiAFK()
end

-- Anti Detection Bypasses
local function SetupBypasses()
    if States.AntiDetect then
        -- Remote spy detection bypass
        pcall(function()
            for _, v in pairs(getconnections(LocalPlayer.DescendantAdded)) do
                v:Disable()
            end
        end)
        
        -- Anti kick bypass
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
        
        -- Anti log bypass
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
end

-- ESP Functions
local ESPObjects = {}

local function CreateESP(character, player)
    if not character or character == LocalPlayer.Character then return end
    
    local esp = {}
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    local root = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not head then return end
    
    -- Box
    esp.Box = Drawing.new("Square")
    esp.Box.Visible = States.ESPBoxes
    esp.Box.Color = Color3.fromRGB(255, 50, 50)
    esp.Box.Thickness = 1.5
    esp.Box.Filled = false
    
    -- Name
    esp.Name = Drawing.new("Text")
    esp.Name.Visible = States.ESPNames
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    
    -- Tracer
    esp.Tracer = Drawing.new("Line")
    esp.Tracer.Visible = States.ESPTracers
    esp.Tracer.Color = Color3.fromRGB(255, 50, 50)
    esp.Tracer.Thickness = 1.5
    
    -- Health Bar
    esp.Health = Drawing.new("Text")
    esp.Health.Visible = States.ESPHealth
    esp.Health.Size = 12
    esp.Health.Center = true
    esp.Health.Outline = true
    
    -- Chams (Highlight)
    if States.ESPChams then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(255, 50, 50)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.Parent = character
        esp.Highlight = highlight
    end
    
    local function UpdateESP()
        if not character or not character.Parent or not humanoid or humanoid.Health <= 0 then
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Tracer.Visible = false
            esp.Health.Visible = false
            return
        end
        
        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        local rootPos, _ = Camera:WorldToViewportPoint(root.Position)
        
        if not onScreen then
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Tracer.Visible = false
            esp.Health.Visible = false
            return
        end
        
        local scale = head.Position.Y - root.Position.Y
        local boxSize = Vector2.new(scale * 1.5, scale * 2)
        
        esp.Box.Visible = States.ESPBoxes
        esp.Box.Position = Vector2.new(headPos.X - boxSize.X/2, headPos.Y - boxSize.Y)
        esp.Box.Size = boxSize
        
        esp.Name.Visible = States.ESPNames
        esp.Name.Position = Vector2.new(headPos.X, headPos.Y - boxSize.Y - 15)
        esp.Name.Text = player.Name
        
        esp.Tracer.Visible = States.ESPTracers
        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
        
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
    
    esp.Update = UpdateESP
    table.insert(ESPObjects, esp)
    return esp
end

-- Movement Functions
local function Fly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    
    humanoid.PlatformStand = true
    local bodyGyro = Instance.new("BodyGyro")
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = root
    
    local flyConn
    flyConn = RunService.RenderStepped:Connect(function()
        if not States.Fly or not char or not char.Parent then
            if bodyGyro then bodyGyro:Destroy() end
            if bodyVelocity then bodyVelocity:Destroy() end
            if humanoid then humanoid.PlatformStand = false end
            if flyConn then flyConn:Disconnect() end
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
end

local function Noclip()
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    local conn
    conn = RunService.Stepped:Connect(function()
        if not States.Noclip or not char or not char.Parent then
            if conn then conn:Disconnect() end
            return
        end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function SpeedBoost()
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

local function JumpBoost()
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

local function InfJump()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local infJumpConn
    infJumpConn = UserInputService.JumpRequest:Connect(function()
        if not States.InfJump or not char or not char.Parent then
            if infJumpConn then infJumpConn:Disconnect() end
            return
        end
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end

local function Fling()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local bodyAngVel = Instance.new("BodyAngularVelocity")
    bodyAngVel.AngularVelocity = Vector3.new(0, 500, 0)
    bodyAngVel.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyAngVel.P = 9e9
    bodyAngVel.Parent = root
    
    local flingConn
    flingConn = RunService.RenderStepped:Connect(function()
        if not States.Fling or not char or not char.Parent then
            if bodyAngVel then bodyAngVel:Destroy() end
            if flingConn then flingConn:Disconnect() end
            return
        end
        root.Velocity = Vector3.new(0, 50, 0)
    end)
end

local function Spin()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local spinConn
    spinConn = RunService.RenderStepped:Connect(function()
        if not States.Spin or not char or not char.Parent then
            if spinConn then spinConn:Disconnect() end
            return
        end
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(10), 0)
    end)
end

local function Float()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local floatConn
    floatConn = RunService.RenderStepped:Connect(function()
        if not States.Float or not char or not char.Parent then
            if floatConn then floatConn:Disconnect() end
            return
        end
        root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        root.CFrame = CFrame.new(root.Position.X, root.Position.Y, root.Position.Z)
    end)
end

-- Visual Functions
local function Fullbright()
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

local function NightVision()
    if States.NightVision then
        Lighting.Ambient = Color3.fromRGB(0, 255, 0)
        Lighting.Brightness = 0.5
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1000
    else
        Fullbright()
    end
end

local function XRay()
    if States.XRay then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character) then
                v.LocalTransparencyModifier = 0.5
            end
        end
    else
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 0
            end
        end
    end
end

local function RemoveFog()
    if States.FogRemoved then
        Lighting.FogEnd = 1e10
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = 500
        Lighting.FogStart = 0
    end
end

-- Troll Functions
local function SoundSpam()
    local sounds = {
        "rbxassetid://911136078",
        "rbxassetid://138750308",
        "rbxassetid://1846575042",
        "rbxassetid://1285875234",
        "rbxassetid://1603674808"
    }
    
    local soundSpamConn
    soundSpamConn = RunService.RenderStepped:Connect(function()
        if not States.SoundSpam then
            if soundSpamConn then soundSpamConn:Disconnect() end
            return
        end
        local sound = Instance.new("Sound")
        sound.SoundId = sounds[math.random(1, #sounds)]
        sound.Volume = 10
        sound.Parent = Workspace
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 5)
    end)
end

local function ChatSpam()
    local messages = {
        "RobluX najlepszy!",
        "s4d > all",
        "get rekt",
        "RobluX On Top",
        "twój stary to haker",
        "free robux 2026",
        "discord.gg/roblux"
    }
    
    local chatConn
    chatConn = RunService.RenderStepped:Connect(function()
        if not States.ChatSpam then
            if chatConn then chatConn:Disconnect() end
            return
        end
        local args = {
            [1] = messages[math.random(1, #messages)],
            [2] = "All"
        }
        pcall(function()
            game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                and game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
                and game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(args))
        end)
    end)
end

local function FlingAll()
    local flingAllConn
    flingAllConn = RunService.RenderStepped:Connect(function()
        if not States.FlingAll then
            if flingAllConn then flingAllConn:Disconnect() end
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
end

local function FlingUp()
    local flingUpConn
    flingUpConn = RunService.RenderStepped:Connect(function()
        if not States.FlingUp then
            if flingUpConn then flingUpConn:Disconnect() end
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
end

-- Arsenal Specific Functions
local ArsenalFunctions = {}

if IsArsenal then
    function ArsenalFunctions.SilentAim()
        local silentAimConn
        silentAimConn = RunService.RenderStepped:Connect(function()
            if not States.SilentAim then
                if silentAimConn then silentAimConn:Disconnect() end
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
                        -- Fire to closest target
                        pcall(function()
                            weaponScript:FindFirstChild("Fire"):InvokeServer(closestTarget)
                        end)
                    end
                end
            end
        end)
    end
    
    function ArsenalFunctions.Aimlock()
        local aimlockConn
        aimlockConn = RunService.RenderStepped:Connect(function()
            if not States.Aimlock then
                if aimlockConn then aimlockConn:Disconnect() end
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
    end
    
    function ArsenalFunctions.Triggerbot()
        local triggerConn
        triggerConn = RunService.RenderStepped:Connect(function()
            if not States.Triggerbot then
                if triggerConn then triggerConn:Disconnect() end
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
    end
    
    function ArsenalFunctions.NoSpread()
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", function(self, key)
            if tostring(self):find("WeaponScript") and (key == "Spread" or key == "Recoil") then
                return 0
            end
            return oldIndex(self, key)
        end)
    end
    
    function ArsenalFunctions.Wallbang()
        -- Wallbang by removing collision check
        local wallbangConn
        wallbangConn = RunService.RenderStepped:Connect(function()
            if not States.Wallbang then
                if wallbangConn then wallbangConn:Disconnect() end
                return
            end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            -- Make parts transparent for raycasting
            for _, part in pairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") and not part:IsDescendantOf(char) then
                    part.CanQuery = false
                end
            end
        end)
    end
end

-- Case Paradise Specific Functions
local CaseParadiseFunctions = {}

if IsCaseParadise then
    function CaseParadiseFunctions.AutoFarm()
        local autoFarmConn
        autoFarmConn = RunService.RenderStepped:Connect(function()
            if not States.AutoFarm then
                if autoFarmConn then autoFarmConn:Disconnect() end
                return
            end
            
            -- Find collectibles and farm them
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and v:FindFirstChild("ClickDetector") then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = CFrame.new(v.Position)
                        task.wait(0.1)
                        fireclickdetector(v.ClickDetector)
                    end
                end
            end
        end)
    end
    
    function CaseParadiseFunctions.AutoCollect()
        local autoCollectConn
        autoCollectConn = RunService.RenderStepped:Connect(function()
            if not States.AutoCollect then
                if autoCollectConn then autoCollectConn:Disconnect() end
                return
            end
            
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Part") and v.Name:find("Case") or v.Name:find("Drop") then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = CFrame.new(v.Position)
                    end
                end
            end
        end)
    end
    
    function CaseParadiseFunctions.AutoClick()
        local autoClickConn
        autoClickConn = RunService.RenderStepped:Connect(function()
            if not States.AutoClick then
                if autoClickConn then autoClickConn:Disconnect() end
                return
            end
            
            local mouse = LocalPlayer:GetMouse()
            mouse1click()
        end)
    end
    
    function CaseParadiseFunctions.AutoBuy()
        local autoBuyConn
        autoBuyConn = RunService.RenderStepped:Connect(function()
            if not States.AutoBuy then
                if autoBuyConn then autoBuyConn:Disconnect() end
                return
            end
            
            -- Auto buy cheapest case
            pcall(function()
                local buyRemote = game:GetService("ReplicatedStorage"):FindFirstChild("BuyItem", true)
                if buyRemote then
                    buyRemote:InvokeServer("CheapestCase")
                end
            end)
        end)
    end
    
    function CaseParadiseFunctions.AutoQuest()
        local autoQuestConn
        autoQuestConn = RunService.RenderStepped:Connect(function()
            if not States.AutoQuest then
                if autoQuestConn then autoQuestConn:Disconnect() end
                return
            end
            
            pcall(function()
                local questRemote = game:GetService("ReplicatedStorage"):FindFirstChild("ClaimQuest", true)
                if questRemote then
                    questRemote:FireServer()
                end
            end)
        end)
    end
end

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Check if ESP already exists for this player
            local espExists = false
            for _, esp in pairs(ESPObjects) do
                if esp.Character == player.Character then
                    espExists = true
                    esp.Update()
                    break
                end
            end
            
            if not espExists then
                CreateESP(player.Character, player)
            end
        end
    end
    
    -- Cleanup dead ESP
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        if not esp.Character or not esp.Character.Parent then
            if esp.Highlight then esp.Highlight:Destroy() end
            if esp.Box then esp.Box:Remove() end
            if esp.Name then esp.Name:Remove() end
            if esp.Tracer then esp.Tracer:Remove() end
            if esp.Health then esp.Health:Remove() end
            table.remove(ESPObjects, i)
        end
    end
end)

-- Character Added handler for ESP
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if player ~= LocalPlayer then
            CreateESP(character, player)
        end
    end)
end)

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        CreateESP(player.Character, player)
    end
end

-- UI Creation
local MainTab = Window:CreateTab("Informacje", "info")
local MovementTab = Window:CreateTab("Ruch", "move")
local ESPTab = Window:CreateTab("ESP", "eye")
local VisualsTab = Window:CreateTab("Visiale", "light")
local TrollTab = Window:CreateTab("Troll", "alert-circle")
local ArsenalTab = IsArsenal and Window:CreateTab("Arsenal", "crosshair")
local CaseParadiseTab = IsCaseParadise and Window:CreateTab("Case Paradise", "package")

-- Information Tab
local InfoSection = MainTab:CreateSection("Informacje")

MainTab:CreateParagraph({
    Title = "RobluX Premium",
    Content = "Wersja: 2.0.0\nAutor: s4d\nGra: " .. GameName .. "\nID: " .. PlaceID .. "\n\nDiscord: discord.gg/roblux"
})

MainTab:CreateButton({
    Name = "Skopiuj Discord",
    Callback = function()
        setclipboard("discord.gg/roblux")
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
        Rayfield:Destroy()
    end
})

-- Bypasses Section
local BypassSection = MainTab:CreateSection("Bypassy")

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
local MoveSection = MovementTab:CreateSection("Główne")

MovementTab:CreateToggle({
    Name = "Latanie (Fly)",
    CurrentValue = false,
    Callback = function(value)
        States.Fly = value
        if value then
            Fly()
        end
    end
})

MovementTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(value)
        States.Noclip = value
        if value then
            Noclip()
        end
    end
})

MovementTab:CreateToggle({
    Name = "Speed Boost",
    CurrentValue = false,
    Callback = function(value)
        States.Speed = value
        SpeedBoost()
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
            SpeedBoost()
        end
    end
})

MovementTab:CreateToggle({
    Name = "Jump Boost",
    CurrentValue = false,
    Callback = function(value)
        States.Jump = value
        JumpBoost()
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
            JumpBoost()
        end
    end
})

MovementTab:CreateToggle({
    Name = "Inf Jump",
    CurrentValue = false,
    Callback = function(value)
        States.InfJump = value
        if value then
            InfJump()
        end
    end
})

MovementTab:CreateToggle({
    Name = "Fling",
    CurrentValue = false,
    Callback = function(value)
        States.Fling = value
        if value then
            Fling()
        end
    end
})

MovementTab:CreateToggle({
    Name = "Spin",
    CurrentValue = false,
    Callback = function(value)
        States.Spin = value
        if value then
            Spin()
        end
    end
})

MovementTab:CreateToggle({
    Name = "Float",
    CurrentValue = false,
    Callback = function(value)
        States.Float = value
        if value then
            Float()
        end
    end
})

-- ESP Tab
local ESPMainSection = ESPTab:CreateSection("ESP Główne")

ESPTab:CreateToggle({
    Name = "ESP Box",
    CurrentValue = false,
    Callback = function(value)
        States.ESPBoxes = value
        for _, esp in pairs(ESPObjects) do
            if esp.Box then
                esp.Box.Visible = value
            end
        end
    end
})

ESPTab:CreateToggle({
    Name = "ESP Nazwy",
    CurrentValue = false,
    Callback = function(value)
        States.ESPNames = value
        for _, esp in pairs(ESPObjects) do
            if esp.Name then
                esp.Name.Visible = value
            end
        end
    end
})

ESPTab:CreateToggle({
    Name = "ESP Tracery",
    CurrentValue = false,
    Callback = function(value)
        States.ESPTracers = value
        for _, esp in pairs(ESPObjects) do
            if esp.Tracer then
                esp.Tracer.Visible = value
            end
        end
    end
})

ESPTab:CreateToggle({
    Name = "ESP Health",
    CurrentValue = false,
    Callback = function(value)
        States.ESPHealth = value
        for _, esp in pairs(ESPObjects) do
            if esp.Health then
                esp.Health.Visible = value
            end
        end
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
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = player.Character
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = player.Character
                    
                    -- Store in ESP objects
                    for _, esp in pairs(ESPObjects) do
                        if esp.Character == player.Character then
                            esp.Highlight = highlight
                            break
                        end
                    end
                end
            end
        else
            for _, esp in pairs(ESPObjects) do
                if esp.Highlight then
                    esp.Highlight:Destroy()
                    esp.Highlight = nil
                end
            end
            -- Remove any remaining highlights
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Highlight") then
                    v:Destroy()
                end
            end
        end
    end
})

-- Visuals Tab
local VisualsMainSection = VisualsTab:CreateSection("Visiale")

VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(value)
        States.Fullbright = value
        if value then
            States.NightVision = false
        end
        Fullbright()
    end
})

VisualsTab:CreateToggle({
    Name = "Night Vision",
    CurrentValue = false,
    Callback = function(value)
        States.NightVision = value
        if value then
            States.Fullbright = false
        end
        NightVision()
    end
})

VisualsTab:CreateToggle({
    Name = "X-Ray",
    CurrentValue = false,
    Callback = function(value)
        States.XRay = value
        XRay()
    end
})

VisualsTab:CreateToggle({
    Name = "Usuń Mgłę",
    CurrentValue = false,
    Callback = function(value)
        States.FogRemoved = value
        RemoveFog()
    end
})

-- Troll Tab
local TrollMainSection = TrollTab:CreateSection("Troll")

TrollTab:CreateToggle({
    Name = "Spam Dźwiękiem",
    CurrentValue = false,
    Callback = function(value)
        States.SoundSpam = value
        if value then
            SoundSpam()
        end
    end
})

TrollTab:CreateToggle({
    Name = "Spam Czatem",
    CurrentValue = false,
    Callback = function(value)
        States.ChatSpam = value
        if value then
            ChatSpam()
        end
    end
})

TrollTab:CreateToggle({
    Name = "Fling All",
    CurrentValue = false,
    Callback = function(value)
        States.FlingAll = value
        if value then
            FlingAll()
        end
    end
})

TrollTab:CreateToggle({
    Name = "Fling Up",
    CurrentValue = false,
    Callback = function(value)
        States.FlingUp = value
        if value then
            FlingUp()
        end
    end
})

-- Arsenal Tab (conditional)
if IsArsenal and ArsenalTab then
    local ArsenalMainSection = ArsenalTab:CreateSection("Aimbot")
    
    ArsenalTab:CreateToggle({
        Name = "Silent Aim",
        CurrentValue = false,
        Callback = function(value)
            States.SilentAim = value
            if value then
                ArsenalFunctions.SilentAim()
            end
        end
    })
    
    ArsenalTab:CreateToggle({
        Name = "Aimlock",
        CurrentValue = false,
        Callback = function(value)
            States.Aimlock = value
            if value then
                ArsenalFunctions.Aimlock()
            end
        end
    })
    
    ArsenalTab:CreateToggle({
        Name = "Triggerbot",
        CurrentValue = false,
        Callback = function(value)
            States.Triggerbot = value
            if value then
                ArsenalFunctions.Triggerbot()
            end
        end
    })
    
    ArsenalTab:CreateToggle({
        Name = "No Spread",
        CurrentValue = false,
        Callback = function(value)
            States.NoSpread = value
            if value then
                ArsenalFunctions.NoSpread()
            end
        end
    })
    
    ArsenalTab:CreateToggle({
        Name = "Wallbang",
        CurrentValue = false,
        Callback = function(value)
            States.Wallbang = value
            if value then
                ArsenalFunctions.Wallbang()
            end
        end
    })
    
    ArsenalTab:CreateButton({
        Name = "Refresh Weapons",
        Callback = function()
            pcall(function()
                LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                and LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
            end)
            Rayfield:Notify({
                Title = "Odświeżono",
                Content = "Bronie odświeżone",
                Duration = 3
            })
        end
    })
end

-- Case Paradise Tab (conditional)
if IsCaseParadise and CaseParadiseTab then
    local CaseMainSection = CaseParadiseTab:CreateSection("Auto Farm")
    
    CaseParadiseTab:CreateToggle({
        Name = "Auto Farm",
        CurrentValue = false,
        Callback = function(value)
            States.AutoFarm = value
            if value then
                CaseParadiseFunctions.AutoFarm()
            end
        end
    })
    
    CaseParadiseTab:CreateToggle({
        Name = "Auto Collect",
        CurrentValue = false,
        Callback = function(value)
            States.AutoCollect = value
            if value then
                CaseParadiseFunctions.AutoCollect()
            end
        end
    })
    
    CaseParadiseTab:CreateToggle({
        Name = "Auto Click",
        CurrentValue = false,
        Callback = function(value)
            States.AutoClick = value
            if value then
                CaseParadiseFunctions.AutoClick()
            end
        end
    })
    
    CaseParadiseTab:CreateToggle({
        Name = "Auto Buy",
        CurrentValue = false,
        Callback = function(value)
            States.AutoBuy = value
            if value then
                CaseParadiseFunctions.AutoBuy()
            end
        end
    })
    
    CaseParadiseTab:CreateToggle({
        Name = "Auto Quest",
        CurrentValue = false,
        Callback = function(value)
            States.AutoQuest = value
            if value then
                CaseParadiseFunctions.AutoQuest()
            end
        end
    })
end

-- Load Settings
Rayfield:LoadConfiguration()
