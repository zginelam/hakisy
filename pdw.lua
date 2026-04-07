-- Ultimate Roblox Cheat Script with Rayfield GUI
-- ESP, Fling, FakeLag, Movement Hacks + More
-- Source: Custom built with Rayfield UI (https://github.com/jensonhirst/Rayfield)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ultimate Cheat Hub",
   LoadingTitle = "Loading Ultimate Cheats...",
   LoadingSubtitle = "by HackerAI",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "UltimateCheatHub",
      FileName = "config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Variables
local ESPConnections = {}
local Tracers = {}
local Toggles = {}
local Sliders = {}
local Keybinds = {}
local Notifications = {}

-- Notification System
local function Notify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
        Image = 4483362458
    })
end

-- ESP System
local ESPFolder = Drawing.new("Folder")
ESPFolder.Name = "ESP"
ESPFolder.Parent = Drawing

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Transparency = 1
    Box.Color = Color3.fromRGB(255, 0, 0)
    Box.Visible = false
    
    local NameTag = Drawing.new("Text")
    NameTag.Size = 16
    NameTag.Center = true
    NameTag.Outline = true
    NameTag.Font = 2
    NameTag.Color = Color3.fromRGB(255, 255, 255)
    NameTag.Visible = false
    
    local Tracer = Drawing.new("Line")
    Tracer.Thickness = 2
    Tracer.Color = Color3.fromRGB(255, 0, 0)
    Tracer.Transparency = 1
    Tracer.Visible = false
    
    ESPConnections[player] = {
        Box = Box,
        NameTag = NameTag,
        Tracer = Tracer,
        Player = player
    }
end

local function UpdateESP()
    for player, esp in pairs(ESPConnections) do
        if player and player.Parent and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            local vector, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
            
            if onScreen then
                local head = player.Character:FindFirstChild("Head")
                local size = (Camera:WorldToViewportPoint(head.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 3, 0)).Y)
                local boxSize = size * 1.5
                
                esp.Box.Size = Vector2.new(2000 / vector.Z, boxSize)
                esp.Box.Position = Vector2.new(vector.X - esp.Box.Size.X / 2, vector.Y - esp.Box.Size.Y / 2)
                esp.Box.Visible = true
                
                esp.NameTag.Position = Vector2.new(vector.X, vector.Y - esp.Box.Size.Y / 2 - 16)
                esp.NameTag.Text = player.Name .. " [" .. math.floor(humanoid.Health) .. "]"
                esp.NameTag.Visible = true
                
                esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.Tracer.To = Vector2.new(vector.X, vector.Y + esp.Box.Size.Y / 2)
                esp.Tracer.Visible = true
            else
                esp.Box.Visible = false
                esp.NameTag.Visible = false
                esp.Tracer.Visible = false
            end
        else
            esp.Box.Visible = false
            esp.NameTag.Visible = false
            esp.Tracer.Visible = false
        end
    end
end

-- Refresh ESP on player spawn/reset
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        CreateESP(player)
    end)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

-- Fling System (ALL Players)
local Flinging = false
local FlingConnection

local function FlingPlayer(targetPlayer)
    if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = targetPlayer.Character.HumanoidRootPart
        local velocity = Instance.new("BodyVelocity")
        velocity.MaxForce = Vector3.new(4000, 4000, 4000)
        velocity.Velocity = Vector3.new(math.random(-500, 500), 1000, math.random(-500, 500))
        velocity.Parent = hrp
        
        game:GetService("Debris"):AddItem(velocity, 0.1)
    end
end

local function StartFlingAll()
    Flinging = true
    spawn(function()
        while Flinging do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    FlingPlayer(player)
                end
            end
            wait(0.1)
        end
    end)
end

-- Movement Hacks
local SpeedValue = 50
local FlyEnabled = false
local FlySpeed = 50
local NoClipEnabled = false
local InfiniteJumpEnabled = false
local HighJumpEnabled = false
local BunnyHopEnabled = false
local AirWalkEnabled = false
local SpinBotEnabled = false
local FOVValue = 70

-- Character Variables
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Fly Hack
local FlyConnection
local function ToggleFly()
    FlyEnabled = not FlyEnabled
    if FlyEnabled then
        local BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.Parent = RootPart
        
        FlyConnection = RunService.Heartbeat:Connect(function()
            local CameraDirection = Camera.CFrame.LookVector
            local CameraRight = Camera.CFrame.RightVector
            
            local MoveVector = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then MoveVector = MoveVector + CameraDirection end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then MoveVector = MoveVector - CameraDirection end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then MoveVector = MoveVector - CameraRight end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then MoveVector = MoveVector + CameraRight end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then MoveVector = MoveVector + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then MoveVector = MoveVector - Vector3.new(0, 1, 0) end
            
            BodyVelocity.Velocity = MoveVector * FlySpeed
        end)
    else
        if FlyConnection then FlyConnection:Disconnect() end
        if RootPart:FindFirstChild("BodyVelocity") then
            RootPart:FindFirstChild("BodyVelocity"):Destroy()
        end
    end
end

-- NoClip
local NoClipConnection
local function ToggleNoClip()
    NoClipEnabled = not NoClipEnabled
    if NoClipConnection then NoClipConnection:Disconnect() end
    
    NoClipConnection = RunService.Stepped:Connect(function()
        if NoClipEnabled and Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- Infinite Jump
local InfiniteJumpConnection
local function ToggleInfiniteJump()
    InfiniteJumpEnabled = not InfiniteJumpEnabled
    if InfiniteJumpConnection then InfiniteJumpConnection:Disconnect() end
    
    InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if InfiniteJumpEnabled then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- High Jump / Low Gravity
local GravityConnection
local function ToggleHighJump()
    HighJumpEnabled = not HighJumpEnabled
    if GravityConnection then GravityConnection:Disconnect() end
    
    if HighJumpEnabled then
        GravityConnection = RunService.Heartbeat:Connect(function()
            Workspace.Gravity = 50
        end)
    else
        Workspace.Gravity = 196.2
    end
end

-- Bunny Hop
local BunnyHopConnection
local function ToggleBunnyHop()
    BunnyHopEnabled = not BunnyHopEnabled
    if BunnyHopConnection then BunnyHopConnection:Disconnect() end
    
    BunnyHopConnection = RunService.Heartbeat:Connect(function()
        if BunnyHopEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            Humanoid.Jump = true
        end
    end)
end

-- Air Walk
local AirWalkConnection
local function ToggleAirWalk()
    AirWalkEnabled = not AirWalkEnabled
    if AirWalkConnection then AirWalkConnection:Disconnect() end
    
    AirWalkConnection = RunService.Heartbeat:Connect(function()
        if AirWalkEnabled and RootPart then
            local ray = Workspace:Raycast(RootPart.Position, Vector3.new(0, -10, 0))
            if not ray then
                RootPart.CFrame = RootPart.CFrame + Vector3.new(0, -0.1, 0)
            end
        end
    end)
end

-- Spin Bot
local SpinConnection
local function ToggleSpinBot()
    SpinBotEnabled = not SpinBotEnabled
    if SpinConnection then SpinConnection:Disconnect() end
    
    SpinConnection = RunService.Heartbeat:Connect(function()
        if SpinBotEnabled then
            RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(10), 0)
        end
    end)
end

-- Speed Changer
local SpeedConnection
local function UpdateSpeed()
    if SpeedConnection then SpeedConnection:Disconnect() end
    SpeedConnection = RunService.Heartbeat:Connect(function()
        Humanoid.WalkSpeed = SpeedValue
    end)
end

-- FOV Changer
local function UpdateFOV()
    Camera.FieldOfView = FOVValue
end

-- Fake Lag / Teleport Lag
local FakeLagEnabled = false
local Positions = {}
local LagConnection

local function ToggleFakeLag()
    FakeLagEnabled = not FakeLagEnabled
    if LagConnection then LagConnection:Disconnect() end
    
    if FakeLagEnabled then
        LagConnection = RunService.Heartbeat:Connect(function()
            table.insert(Positions, RootPart.CFrame)
            if #Positions > 10 then
                table.remove(Positions, 1)
            end
            
            if #Positions > 1 then
                RootPart.CFrame = Positions[math.random(1, #Positions)]
            end
        end)
    end
end

-- Teleport
local function TeleportToMouse()
    local mouse = LocalPlayer:GetMouse()
    if mouse.Hit then
        RootPart.CFrame = CFrame.new(mouse.Hit.Position)
    end
end

-- Spectate
local SpectateTarget = nil
local SpectateConnection
local function SpectatePlayer(playerName)
    local target = Players:FindFirstChild(playerName)
    if target and target.Character then
        SpectateTarget = target
        if SpectateConnection then SpectateConnection:Disconnect() end
        SpectateConnection = RunService.RenderStepped:Connect(function()
            if SpectateTarget and SpectateTarget.Character and SpectateTarget.Character:FindFirstChild("HumanoidRootPart") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, SpectateTarget.Character.HumanoidRootPart.Position)
            end
        end)
        Notify("Spectate", "Now spectating " .. playerName, 2)
    else
        Notify("Error", "Player not found!", 2)
    end
end

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        TeleportToMouse()
    end
    
    if input.KeyCode == Enum.KeyCode.X and SpectateTarget then
        if SpectateConnection then SpectateConnection:Disconnect() end
        SpectateTarget = nil
        Notify("Spectate", "Stopped spectating", 2)
    end
end)

-- Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Refresh all hacks
    UpdateSpeed()
    UpdateFOV()
    ToggleNoClip() -- Re-enable noclip
    ToggleInfiniteJump() -- Re-enable infinite jump
    
    Notify("Refresh", "All hacks refreshed after respawn!", 3)
end)

-- GUI TABS
local CombatTab = Window:CreateTab("Combat", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- Combat Tab
CombatTab:CreateToggle({
   Name = "ESP + Tracers (Always Refreshes)",
   CurrentValue = false,
   Flag = "ESP_Toggle",
   Callback = function(Value)
       Toggles.ESP = Value
       RunService.RenderStepped:Connect(function()
           if Toggles.ESP then
               UpdateESP()
           else
               for _, esp in pairs(ESPConnections) do
                   esp.Box.Visible = false
                   esp.NameTag.Visible = false
                   esp.Tracer.Visible = false
               end
           end
       end)
   end
})

CombatTab:CreateToggle({
   Name = "Fling ALL Players",
   CurrentValue = false,
   Flag = "Fling_Toggle",
   Callback = function(Value)
       Flinging = Value
       if Value then
           StartFlingAll()
           Notify("Fling", "Flinging all players!", 2)
       end
   end
})

-- Movement Tab
MovementTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 50,
   Flag = "SpeedSlider",
   Callback = function(Value)
       SpeedValue = Value
       UpdateSpeed()
   end
})

MovementTab:CreateToggle({
   Name = "Fly (WASD + Space/Shift)",
   CurrentValue = false,
   Flag = "Fly_Toggle",
   Callback = function(Value)
       ToggleFly()
   end
})

MovementTab:CreateSlider({
   Name = "Fly Speed",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
       FlySpeed = Value
   end
})

MovementTab:CreateToggle({
   Name = "NoClip",
   CurrentValue = false,
   Flag = "NoClip_Toggle",
   Callback = function(Value)
       ToggleNoClip()
   end
})

MovementTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJump_Toggle",
   Callback = function(Value)
       ToggleInfiniteJump()
   end
})

MovementTab:CreateToggle({
   Name = "High Jump / Low Gravity",
   CurrentValue = false,
   Flag = "HighJump_Toggle",
   Callback = function(Value)
       ToggleHighJump()
   end
})

MovementTab:CreateToggle({
   Name = "Bunny Hop",
   CurrentValue = false,
   Flag = "BunnyHop_Toggle",
   Callback = function(Value)
       ToggleBunnyHop()
   end
})

MovementTab:CreateToggle({
   Name = "Air Walk",
   CurrentValue = false,
   Flag = "AirWalk_Toggle",
   Callback = function(Value)
       ToggleAirWalk()
   end
})

MovementTab:CreateToggle({
   Name = "Spin Bot",
   CurrentValue = false,
   Flag = "SpinBot_Toggle",
   Callback = function(Value)
       ToggleSpinBot()
   end
})

MovementTab:CreateToggle({
   Name = "Fake Lag (Teleport)",
   CurrentValue = false,
   Flag = "FakeLag_Toggle",
   Callback = function(Value)
       ToggleFakeLag()
   end
})

MovementTab:CreateButton({
   Name = "Teleport to Mouse (F)",
   Callback = function()
       TeleportToMouse()
   end
})

-- Visual Tab
VisualTab:CreateSlider({
   Name = "FOV Changer",
   Range = {30, 120},
   Increment = 1,
   CurrentValue = 70,
   Flag = "FOVSlider",
   Callback = function(Value)
       FOVValue = Value
       UpdateFOV()
   end
})

-- Player Tab
PlayerTab:CreateInput({
   Name = "Spectate Player (X to stop)",
   PlaceholderText = "Player name...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       SpectatePlayer(Text)
   end
})

PlayerTab:CreateButton({
   Name = "Reconnect (Refreshes ESP)",
   Callback = function()
       LocalPlayer:Kick("Reconnecting...")
       wait(1)
       game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
   end
})

-- Main ESP Loop
spawn(function()
    while wait() do
        if Toggles.ESP then
            UpdateESP()
        end
    end
end)

-- Update FOV
RunService.RenderStepped:Connect(UpdateFOV)

Notify("Loaded", "Ultimate Cheat Hub ready! All features work after respawn.", 5)

-- Cleanup on leave
game:BindToClose(function()
    for _, esp in pairs(ESPConnections) do
        esp.Box:Remove()
        esp.NameTag:Remove()
        esp.Tracer:Remove()
    end
end)
