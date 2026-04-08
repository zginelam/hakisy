-- [FPS] One Tap Script by HackerAI - Rayfield Interface
-- For "[FPS] One Tap" - Stringless Banjo
-- Universal & Visual Features with Advanced Options

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "TurcjaHub",
   LoadingTitle = "TurcjaHub Loading...",
   LoadingSubtitle = "Powered by turcja",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "OneTapHub",
      FileName = "OneTapConfig"
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
local Mouse = LocalPlayer:GetMouse()

-- Variables
local Connections = {}
local Toggles = {}
local Sliders = {}
local Colors = {}
local RainbowHue = 0

-- Rainbow Color Function
spawn(function()
   while true do
      RainbowHue = RainbowHue + 0.01
      if RainbowHue > 1 then RainbowHue = 0 end
      wait()
   end
end)

local function RainbowColor()
   return Color3.fromHSV(RainbowHue, 1, 1)
end

-- Universal Tab
local UniversalTab = Window:CreateTab("Universal", 4483362458)

-- Fly Section
local FlySection = UniversalTab:CreateSection("Fly Controls")

Toggles.Fly = UniversalTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      Toggles.Fly = Value
      if Value then
         local BodyVelocity = Instance.new("BodyVelocity")
         local BodyAngularVelocity = Instance.new("BodyAngularVelocity")
         BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
         BodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
         BodyVelocity.Velocity = Vector3.new(0, 0, 0)
         BodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
         BodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
         BodyAngularVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
         
         spawn(function()
            while Toggles.Fly do
               local moveVector = Vector3.new(0, 0, 0)
               if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Camera.CFrame.LookVector end
               if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - Camera.CFrame.LookVector end
               if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Camera.CFrame.RightVector end
               if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Camera.CFrame.RightVector end
               if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
               if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, 1, 0) end
               
               BodyVelocity.Velocity = moveVector * Sliders.FlySpeed.Value
               RunService.Heartbeat:Wait()
            end
            BodyVelocity:Destroy()
            BodyAngularVelocity:Destroy()
         end)
      end
   end,
})

Sliders.FlySpeed = UniversalTab:CreateSlider({
   Name = "Fly Speed",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(Value)
      Sliders.FlySpeed = Value
   end,
})

-- Movement Section
local MovementSection = UniversalTab:CreateSection("Movement")

Sliders.Speed = UniversalTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 50,
   Flag = "WalkSpeed",
   Callback = function(Value)
      Sliders.Speed = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

Toggles.Noclip = UniversalTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
      Toggles.Noclip = Value
      if Value then
         Connections.Noclip = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
               for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                  if part:IsA("BasePart") and part.CanCollide then
                     part.CanCollide = false
                  end
               end
            end
         end)
      else
         if Connections.Noclip then Connections.Noclip:Disconnect() end
      end
   end,
})

-- Combat Section
local CombatSection = UniversalTab:CreateSection("Combat")

Toggles.FlingAll = UniversalTab:CreateToggle({
   Name = "Fling All Players",
   CurrentValue = false,
   Flag = "FlingAll",
   Callback = function(Value)
      Toggles.FlingAll = Value
      if Value then
         for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               local velocity = Instance.new("BodyVelocity")
               velocity.MaxForce = Vector3.new(4000, 4000, 4000)
               velocity.Velocity = Vector3.new(math.random(-1000,1000), math.random(500,2000), math.random(-1000,1000))
               velocity.Parent = player.Character.HumanoidRootPart
               game:GetService("Debris"):AddItem(velocity, 0.1)
            end
         end
      end
   end,
})

Toggles.InfiniteJump = UniversalTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJump",
   Callback = function(Value)
      Toggles.InfiniteJump = Value
      if Value then
         Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
               LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
         end)
      else
         if Connections.InfiniteJump then Connections.InfiniteJump:Disconnect() end
      end
   end,
})

-- Visuals Tab
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

-- ESP Section
local ESPSection = VisualsTab:CreateSection("ESP & Tracers")

Toggles.ESP = VisualsTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "ESP",
   Callback = function(Value)
      Toggles.ESP = Value
      if Value then
         for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
               createESP(player)
            end
         end
         Connections.ESPNewPlayer = Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
               if Toggles.ESP then createESP(player) end
            end)
         end)
      else
         if Connections.ESPNewPlayer then Connections.ESPNewPlayer:Disconnect() end
         for _, esp in pairs(ESPBoxes) do
            if esp then esp:Remove() end
         end
         ESPBoxes = {}
      end
   end,
})

Toggles.Tracers = VisualsTab:CreateToggle({
   Name = "Tracers",
   CurrentValue = false,
   Flag = "Tracers",
   Callback = function(Value)
      Toggles.Tracers = Value
   end,
})

Sliders.Distance = VisualsTab:CreateSlider({
   Name = "ESP Distance Limit (meters)",
   Range = {50, 5000},
   Increment = 50,
   CurrentValue = 1000,
   Flag = "ESPDistance",
   Callback = function(Value)
      Sliders.Distance = Value
   end,
})

-- Aimbot Section
local AimbotSection = VisualsTab:CreateSection("Aimbot")

Toggles.Aimbot = VisualsTab:CreateToggle({
   Name = "Silent Aim (Lock on Closest)",
   CurrentValue = false,
   Flag = "SilentAim",
   Callback = function(Value)
      Toggles.Aimbot = Value
   end,
})

Toggles.AutoShoot = VisualsTab:CreateToggle({
   Name = "Auto Shoot",
   CurrentValue = false,
   Flag = "AutoShoot",
   Callback = function(Value)
      Toggles.AutoShoot = Value
   end,
})

Sliders.AimbotFOV = VisualsTab:CreateSlider({
   Name = "Aimbot FOV",
   Range = {0, 500},
   Increment = 10,
   CurrentValue = 150,
   Flag = "AimbotFOV",
   Callback = function(Value)
      -- FOV Circle update
   end,
})

-- Crosshair Section
local CrosshairSection = VisualsTab:CreateSection("Crosshair")

Toggles.Crosshair = VisualsTab:CreateToggle({
   Name = "Custom Crosshair",
   CurrentValue = false,
   Flag = "CustomCrosshair",
   Callback = function(Value)
      Toggles.Crosshair = Value
      updateCrosshair()
   end,
})

-- Color Settings Tab
local ColorsTab = Window:CreateTab("Colors", 4483362458)

local ColorSection = ColorsTab:CreateSection("Global Colors")

Colors.MainColor = ColorsTab:CreateColorPicker({
   Name = "Main Color",
   Color = RainbowColor(),
   Flag = "MainColor",
   Callback = function(Value)
      Colors.MainColor = Value
   end,
})

Colors.ESPColor = ColorsTab:CreateColorPicker({
   Name = "ESP/Tracers Color",
   Color = Color3.fromRGB(255, 0, 0),
   Flag = "ESPColor",
   Callback = function(Value)
      Colors.ESPColor = Value
   end,
})

Toggles.Rainbow = ColorsTab:CreateToggle({
   Name = "Rainbow Mode",
   CurrentValue = true,
   Flag = "RainbowMode",
   Callback = function(Value)
      Toggles.Rainbow = Value
   end,
})

-- Advanced Tab
local AdvancedTab = Window:CreateTab("Advanced", 4483362458)

local ExploitSection = AdvancedTab:CreateSection("Exploits")

Toggles.Fullbright = AdvancedTab:CreateToggle({
   Name = "Fullbright",
   CurrentValue = false,
   Flag = "Fullbright",
   Callback = function(Value)
      if Value then
         game.Lighting.Brightness = 3
         game.Lighting.ClockTime = 14
         game.Lighting.FogEnd = 9e9
         game.Lighting.GlobalShadows = false
         game.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
      else
         game.Lighting.Brightness = 2
         game.Lighting.ClockTime = 14
         game.Lighting.FogEnd = 100000
         game.Lighting.GlobalShadows = true
         game.Lighting.OutdoorAmbient = Color3.fromRGB(51, 51, 51)
      end
   end,
})

-- ESP System
local ESPBoxes = {}
local function createESP(player)
   local esp = {}
   local box = Drawing.new("Square")
   local nameTag = Drawing.new("Text")
   local distanceTag = Drawing.new("Text")
   local tracer = Drawing.new("Line")
   
   esp.Box = box
   esp.Name = nameTag
   esp.Distance = distanceTag
   esp.Tracer = tracer
   esp.Player = player
   
   ESPBoxes[player] = esp
end

-- Main Loop
Connections.MainLoop = RunService.Heartbeat:Connect(function()
   -- Aimbot Logic
   if Toggles.Aimbot then
      local closestPlayer, shortestDistance = nil, Sliders.AimbotFOV.Value
      for _, player in pairs(Players:GetPlayers()) do
         if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local screenPoint, onScreen = Camera:WorldToScreenPoint(player.Character.Head.Position)
            if onScreen then
               local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
               if distance < shortestDistance then
                  closestPlayer = player
                  shortestDistance = distance
               end
            end
         end
      end
      if closestPlayer then
         -- Silent aim implementation (modify mouse hit)
         mousemoverel((closestPlayer.Character.Head.Position - Camera.CFrame.Position).Unit.X * 0.1, (closestPlayer.Character.Head.Position - Camera.CFrame.Position).Unit.Y * 0.1)
      end
   end
   
   -- Auto Shoot
   if Toggles.AutoShoot and Toggles.Aimbot then
      -- Trigger weapon fire (game specific)
      mouse1click()
      wait(0.1)
      mouse1release()
   end
   
   -- ESP Update
   if Toggles.ESP then
      for player, esp in pairs(ESPBoxes) do
         if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local rootPart = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid
            
            local screenPos, onScreen = Camera:WorldToScreenPoint(rootPart.Position)
            if onScreen and (Camera.CFrame.Position - rootPart.Position).Magnitude <= Sliders.Distance.Value then
               local size = (Camera:WorldToScreenPoint(rootPart.Position - Vector3.new(0, 3, 0)) - Camera:WorldToScreenPoint(rootPart.Position + Vector3.new(0, 5, 0))).Magnitude
               
               esp.Box.Size = Vector2.new(size, size)
               esp.Box.Position = Vector2.new(screenPos.X - size/2, screenPos.Y - size/2)
               esp.Box.Visible = true
               esp.Box.Color = Toggles.Rainbow and RainbowColor() or Colors.ESPColor
               esp.Box.Thickness = 2
               esp.Box.Filled = false
               esp.Box.Transparency = 1
               
               esp.Name.Text = player.Name .. " [" .. math.floor((Camera.CFrame.Position - rootPart.Position).Magnitude) .. "m]"
               esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - size/2 - 20)
               esp.Name.Visible = true
               esp.Name.Color = Toggles.Rainbow and RainbowColor() or Colors.ESPColor
               esp.Name.Size = 16
               esp.Name.Center = true
               esp.Name.Outline = true
               
               if Toggles.Tracers then
                  esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                  esp.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                  esp.Tracer.Visible = true
                  esp.Tracer.Color = Toggles.Rainbow and RainbowColor() or Colors.ESPColor
                  esp.Tracer.Thickness = 2
               end
            else
               esp.Box.Visible = false
               esp.Name.Visible = false
               esp.Tracer.Visible = false
            end
         else
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Tracer.Visible = false
         end
      end
   end
end)

-- Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function()
   wait(1)
   if Sliders.Speed then
      LocalPlayer.Character.Humanoid.WalkSpeed = Sliders.Speed
   end
end)

Rayfield:Notify({
   Title = "Script Loaded!",
   Content = "TurcjaHub One Tap Hub is ready!",
   Duration = 5,
   Image = 4483362458,
})

print("Loaded successfully!")
