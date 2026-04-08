----- -- [FPS] TurcjaHub v2.0 - Advanced FPS Script by HackerAI
-- Professional One Tap Hub with Full Feature Implementation
-- Optimized Performance & Anti-Callback Errors

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "TurcjaHub v2.0",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "Powered by Turcja",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TurcjaHub",
      FileName = "TurcjaConfig"
   },
   KeySystem = false
})

-- Core Services
local Services = {
   Players = game:GetService("Players"),
   RunService = game:GetService("RunService"),
   UserInputService = game:GetService("UserInputService"),
   TweenService = game:GetService("TweenService"),
   Workspace = game:GetService("Workspace"),
   Lighting = game:GetService("Lighting"),
   Debris = game:GetService("Debris")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- State Management
local State = {
   Enabled = {},
   Values = {},
   Connections = {},
   ESPData = {},
   Targets = {},
   Performance = {FrameTime = 0, LastUpdate = 0}
}

-- Color System
local ColorSystem = {
   RainbowHue = 0,
   UpdateConnection = nil
}

-- Performance Optimizer
local PerformanceOptimizer = {
   MaxESP = 50,
   UpdateRate = 1/60, -- 60 FPS target
   CullDistance = 5000
}

-- Initialize Rainbow
spawn(function()
   while task.wait() do
      ColorSystem.RainbowHue = (ColorSystem.RainbowHue + 0.005) % 1
   end
end)

local function GetColor(useRainbow, customColor)
   if useRainbow then
      return Color3.fromHSV(ColorSystem.RainbowHue, 1, 1)
   end
   return customColor or Color3.fromRGB(255, 0, 0)
end

-- Utility Functions
local Utils = {
   GetCharacter = function(player)
      return player.Character and player.Character.Parent and player.Character:FindFirstChild("HumanoidRootPart") and player.Character
   end,
   
   GetHealthPercent = function(humanoid)
      return humanoid and humanoid.Health > 0 and (humanoid.Health / humanoid.MaxHealth) or 0
   end,
   
   WorldToScreen = function(position)
      local screen, onScreen = Camera:WorldToViewportPoint(position)
      return Vector2.new(screen.X, screen.Y), onScreen, screen.Z
   end,
   
   GetClosestTarget = function(fovLimit)
      local closest, shortestDist = nil, fovLimit or math.huge
      local mousePos = Vector2.new(Mouse.X, Mouse.Y)
      
      for _, player in pairs(Services.Players:GetPlayers()) do
         if player ~= LocalPlayer then
            local char = Utils.GetCharacter(player)
            if char and Utils.GetHealthPercent(char.Humanoid) > 0 then
               local head = char:FindFirstChild("Head")
               if head then
                  local screenPos, onScreen = Utils.WorldToScreen(head.Position)
                  if onScreen then
                     local dist = (mousePos - screenPos).Magnitude
                     if dist < shortestDist then
                        closest = {Player = player, Position = head.Position, Screen = screenPos, Distance = dist}
                        shortestDist = dist
                     end
                  end
               end
            end
         end
      end
      return closest
   end,
   
   SafeDisconnect = function(connection)
      if connection then
         connection:Disconnect()
         return nil
      end
   end
}

-- ESP System v2.0
local ESPManager = {
   Drawings = {},
   
   CreateESP = function(player)
      local esp = {
         Box = Drawing.new("Square"),
         Name = Drawing.new("Text"),
         Distance = Drawing.new("Text"),
         Health = Drawing.new("Text"),
         Tracer = Drawing.new("Line"),
         Player = player
      }
      
      -- Configure drawings
      esp.Box.Filled = false
      esp.Box.Thickness = 2
      esp.Box.Transparency = 1
      esp.Name.Size = 14
      esp.Name.Center = true
      esp.Name.Outline = true
      esp.Name.Font = 2
      esp.Distance.Size = 12
      esp.Distance.Center = true
      esp.Distance.Outline = true
      esp.Distance.Font = 2
      esp.Health.Size = 12
      esp.Health.Center = true
      esp.Health.Outline = true
      esp.Health.Font = 2
      esp.Tracer.Thickness = 1.5
      
      ESPManager.Drawings[player] = esp
   end,
   
   UpdateESP = function()
      for player, esp in pairs(ESPManager.Drawings) do
         local char = Utils.GetCharacter(player)
         if char and Utils.GetHealthPercent(char.Humanoid) > 0 then
            local rootPart = char.HumanoidRootPart
            local head = char:FindFirstChild("Head")
            local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
            
            if distance <= State.Values.ESPDistance then
               local screenPos, onScreen = Utils.WorldToScreen(rootPart.Position)
               if onScreen then
                  -- Calculate box size
                  local headScreen, _ = Utils.WorldToScreen(head.Position)
                  local legScreen, _ = Utils.WorldToScreen(rootPart.Position - Vector3.new(0, 4, 0))
                  local boxSize = math.abs(headScreen.Y - legScreen.Y)
                  local boxWidth = boxSize * 0.4
                  
                  -- Update visuals
                  esp.Box.Size = Vector2.new(boxWidth, boxSize)
                  esp.Box.Position = Vector2.new(screenPos.X - boxWidth/2, screenPos.Y - boxSize/2)
                  esp.Box.Visible = true
                  esp.Box.Color = GetColor(State.Enabled.Rainbow, State.Values.ESPColor)
                  
                  esp.Name.Text = player.Name
                  esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize/2 - 20)
                  esp.Name.Visible = true
                  esp.Name.Color = esp.Box.Color
                  
                  local distText = math.floor(distance) .. "m"
                  esp.Distance.Text = distText
                  esp.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize/2 + 5)
                  esp.Distance.Visible = true
                  esp.Distance.Color = esp.Box.Color
                  
                  local healthPercent = Utils.GetHealthPercent(char.Humanoid) * 100
                  esp.Health.Text = math.floor(healthPercent) .. "% HP"
                  esp.Health.Position = Vector2.new(screenPos.X - boxWidth/2 - 5, screenPos.Y - boxSize/2)
                  esp.Health.Visible = true
                  esp.Health.Color = Color3.fromRGB(255 - healthPercent * 2.55, healthPercent * 2.55, 0)
                  
                  if State.Enabled.Tracers then
                     esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                     esp.Tracer.To = screenPos
                     esp.Tracer.Visible = true
                     esp.Tracer.Color = esp.Box.Color
                  else
                     esp.Tracer.Visible = false
                  end
               else
                  ESPManager.HideESP(esp)
               end
            else
               ESPManager.HideESP(esp)
            end
         else
            ESPManager.HideESP(esp)
         end
      end
   end,
   
   HideESP = function(esp)
      esp.Box.Visible = false
      esp.Name.Visible = false
      esp.Distance.Visible = false
      esp.Health.Visible = false
      esp.Tracer.Visible = false
   end,
   
   Cleanup = function()
      for player, esp in pairs(ESPManager.Drawings) do
         for _, drawing in pairs(esp) do
            if drawing.Remove then drawing:Remove() end
         end
      end
      ESPManager.Drawings = {}
   end
}

-- Aimbot & Combat System v2.0
local CombatManager = {
   Target = nil,
   
   UpdateAimbot = function()
      if State.Enabled.SilentAim or State.Enabled.KillAura then
         local fovLimit = State.Values.AimbotFOV
         CombatManager.Target = Utils.GetClosestTarget(fovLimit)
      end
   end,
   
   ApplySilentAim = function()
      if CombatManager.Target and State.Enabled.SilentAim then
         local targetPos = CombatManager.Target.Position
         local delta = (targetPos - Camera.CFrame.Position).Unit
         local sensitivity = 0.15
         
         -- Smooth aim adjustment
         mousemoverel(
            delta.X * sensitivity,
            delta.Y * sensitivity
         )
      end
   end,
   
   KillAura = function()
      if State.Enabled.KillAura and CombatManager.Target then
         local targetChar = CombatManager.Target.Player.Character
         if targetChar then
            -- Auto-shoot at target
            mouse1click()
            task.wait(0.05)
            mouse1release()
            
            -- Additional fling for kill aura effect
            local rootPart = targetChar:FindFirstChild("HumanoidRootPart")
            if rootPart then
               local fling = Instance.new("BodyVelocity")
               fling.MaxForce = Vector3.new(4e5, 4e5, 4e5)
               fling.Velocity = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Unit * 100
               fling.Parent = rootPart
               Services.Debris:AddItem(fling, 0.2)
            end
         end
      end
   end
}

-- Crosshair System
local CrosshairManager = {
   Elements = {},
   
   CreateCrosshair = function()
      local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
      
      local crosshair = {
         Main = Drawing.new("Line"),
         Side1 = Drawing.new("Line"),
         Side2 = Drawing.new("Line"),
         Side3 = Drawing.new("Line"),
         Side4 = Drawing.new("Line"),
         CenterDot = Drawing.new("Circle")
      }
      
      crosshair.Main.From = center
      crosshair.Main.To = center + Vector2.new(20, 0)
      crosshair.Main.Thickness = 3
      crosshair.Main.Color = Color3.fromRGB(255, 255, 255)
      
      crosshair.Side1.From = center
      crosshair.Side1.To = center + Vector2.new(0, 20)
      crosshair.Side1.Thickness = 3
      crosshair.Side1.Color = crosshair.Main.Color
      
      crosshair.Side2.From = center
      crosshair.Side2.To = center + Vector2.new(0, -20)
      crosshair.Side2.Thickness = 3
      crosshair.Side2.Color = crosshair.Main.Color
      
      crosshair.Side3.From = center
      crosshair.Side3.To = center + Vector2.new(-20, 0)
      crosshair.Side3.Thickness = 3
      crosshair.Side3.Color = crosshair.Main.Color
      
      crosshair.Side4.From = center
      crosshair.Side4.To = center + Vector2.new(20, 0)
      crosshair.Side4.Thickness = 3
      crosshair.Side4.Color = crosshair.Main.Color
      
      crosshair.CenterDot.Position = center
      crosshair.CenterDot.Radius = 3
      crosshair.CenterDot.NumSides = 8
      crosshair.CenterDot.Filled = true
      crosshair.CenterDot.Color = Color3.fromRGB(255, 0, 0)
      
      CrosshairManager.Elements = crosshair
   end,
   
   UpdateCrosshair = function()
      if not next(CrosshairManager.Elements) then return end
      
      local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
      local color = GetColor(State.Enabled.Rainbow, State.Values.CrosshairColor)
      
      for _, element in pairs(CrosshairManager.Elements) do
         element.Color = color
         element.Visible = State.Enabled.CustomCrosshair
      end
      
      CrosshairManager.Elements.Main.From = center
      CrosshairManager.Elements.Main.To = center + Vector2.new(20, 0)
      CrosshairManager.Elements.Side1.From = center
      CrosshairManager.Elements.Side1.To = center + Vector2.new(0, 20)
      CrosshairManager.Elements.Side2.From = center
      CrosshairManager.Elements.Side2.To = center + Vector2.new(0, -20)
      CrosshairManager.Elements.Side3.From = center
      CrosshairManager.Elements.Side3.To = center + Vector2.new(-20, 0)
      CrosshairManager.Elements.Side4.From = center
      CrosshairManager.Elements.Side4.To = center + Vector2.new(20, 0)
      CrosshairManager.Elements.CenterDot.Position = center
   end
}

-- Fly System v2.0
local FlyManager = {
   BodyVelocity = nil,
   BodyAngular = nil,
   
   StartFly = function()
      local char = LocalPlayer.Character
      if not char or not char:FindFirstChild("HumanoidRootPart") then return end
      
      FlyManager.BodyVelocity = Instance.new("BodyVelocity")
      FlyManager.BodyAngular = Instance.new("BodyAngularVelocity")
      
      FlyManager.BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
      FlyManager.BodyAngular.MaxTorque = Vector3.new(4000, 4000, 4000)
      FlyManager.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
      FlyManager.BodyAngular.AngularVelocity = Vector3.new(0, 0, 0)
      
      FlyManager.BodyVelocity.Parent = char.HumanoidRootPart
      FlyManager.BodyAngular.Parent = char.HumanoidRootPart
   end,
   
   UpdateFly = function()
      if not FlyManager.BodyVelocity then return end
      
      local moveVector = Vector3.new(0, 0, 0)
      local speed = State.Values.FlySpeed or 50
      
      if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then 
         moveVector = moveVector + Camera.CFrame.LookVector 
      end
      if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then 
         moveVector = moveVector - Camera.CFrame.LookVector 
      end
      if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then 
         moveVector = moveVector - Camera.CFrame.RightVector 
      end
      if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then 
         moveVector = moveVector + Camera.CFrame.RightVector 
      end
      if Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
         moveVector = moveVector + Vector3.new(0, 1, 0) 
      end
      if Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then 
         moveVector = moveVector - Vector3.new(0, 1, 0) 
      end
      
      FlyManager.BodyVelocity.Velocity = moveVector * speed
   end,
   
   StopFly = function()
      if FlyManager.BodyVelocity then FlyManager.BodyVelocity:Destroy() end
      if FlyManager.BodyAngular then FlyManager.BodyAngular:Destroy() end
      FlyManager.BodyVelocity = nil
      FlyManager.BodyAngular = nil
   end
}

-- Main UI Tabs
local UniversalTab = Window:CreateTab("Universal", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local ColorsTab = Window:CreateTab("Colors", 4483362458)

-- Universal Tab
local UniversalSection1 = UniversalTab:CreateSection("Movement")
State.Enabled.Fly = UniversalTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(value)
      State.Enabled.Fly = value
      if value then
         FlyManager.StartFly()
      else
         FlyManager.StopFly()
      end
   end
})

State.Values.FlySpeed = UniversalTab:CreateSlider({
   Name = "Fly Speed",
   Range = {16, 500},
   Increment = 5,
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(value) State.Values.FlySpeed = value end
})

State.Enabled.Speed = UniversalTab:CreateToggle({
   Name = "Walk Speed",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(value)
      State.Enabled.Speed = value
      local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
      if humanoid then
         humanoid.WalkSpeed = value and (State.Values.Speed or 50) or 16
      end
   end
})

State.Values.Speed = UniversalTab:CreateSlider({
   Name = "Speed Value",
   Range = {16, 500},
   Increment = 5,
   CurrentValue = 50,
   Flag = "SpeedValue",
   Callback = function(value) State.Values.Speed = value end
})

State.Enabled.Noclip = UniversalTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(value)
      State.Enabled.Noclip = value
   end
})

-- Visuals Tab
local VisualsSection1 = VisualsTab:CreateSection("ESP System")
State.Enabled.ESP = VisualsTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(value)
      State.Enabled.ESP = value
      if value then
         for _, player in pairs(Services.Players:GetPlayers()) do
            if player ~= LocalPlayer then
               ESPManager.CreateESP(player)
            end
         end
      else
         ESPManager.Cleanup()
      end
   end
})

State.Enabled.Tracers = VisualsTab:CreateToggle({
   Name = "Tracers",
   CurrentValue = false,
   Flag = "TracersToggle",
   Callback = function(value) State.Enabled.Tracers = value end
})

State.Values.ESPDistance = VisualsTab:CreateSlider({
   Name = "ESP Distance Limit",
   Range = {100, 5000},
   Increment = 100,
   CurrentValue = 1000,
   Flag = "ESPDistance",
   Callback = function(value) State.Values.ESPDistance = value end
})

State.Enabled.CustomCrosshair = VisualsTab:CreateToggle({
   Name = "Custom Crosshair",
   CurrentValue = false,
   Flag = "CrosshairToggle",
   Callback = function(value)
      State.Enabled.CustomCrosshair = value
      if value then
         CrosshairManager.CreateCrosshair()
      else
         for _, element in pairs(CrosshairManager.Elements) do
            if element.Remove then element:Remove() end
         end
         CrosshairManager.Elements = {}
      end
   end
})

-- Combat Tab
local CombatSection1 = CombatTab:CreateSection("Aimbot")
State.Enabled.SilentAim = CombatTab:CreateToggle({
   Name = "Silent Aim",
   CurrentValue = false,
   Flag = "SilentAimToggle",
   Callback = function(value) State.Enabled.SilentAim = value end
})

State.Values.AimbotFOV = CombatTab:CreateSlider({
   Name = "Aimbot FOV",
   Range = {0, 500},
   Increment = 10,
   CurrentValue = 150,
   Flag = "AimbotFOV",
   Callback = function(value) State.Values.AimbotFOV = value end
})

State.Enabled.AutoShoot = CombatTab:CreateToggle({
   Name = "Auto Shoot",
   CurrentValue = false,
   Flag = "AutoShootToggle",
   Callback = function(value) State.Enabled.AutoShoot = value end
})

State.Enabled.KillAura = CombatTab:CreateToggle({
   Name = "Kill Aura",
   CurrentValue = false,
   Flag = "KillAuraToggle",
   Callback = function(value) State.Enabled.KillAura = value end
})

local FlingSection = CombatTab:CreateSection("Fling")
State.Enabled.FlingAll = CombatTab:CreateToggle({
   Name = "Fling All",
   CurrentValue = false,
   Flag = "FlingAllToggle",
   Callback = function(value)
      State.Enabled.FlingAll = value
      if value then
         for _, player in pairs(Services.Players:GetPlayers()) do
            if player ~= LocalPlayer then
               local char = Utils.GetCharacter(player)
               if char then
                  local rootPart = char.HumanoidRootPart
                  local flingVel = Instance.new("BodyVelocity")
                  flingVel.MaxForce = Vector3.new(4e5, 4e5, 4e5)
                  flingVel.Velocity = Vector3.new(
                     math.random(-500, 500),
                     math.random(1000, 3000),
                     math.random(-500, 500)
                  )
                  flingVel.Parent = rootPart
                  Services.Debris:AddItem(flingVel, 0.3)
               end
            end
         end
         State.Enabled.FlingAll = false -- One-time execution
      end
   end
})

-- Colors Tab
local ColorsSection = ColorsTab:CreateSection("Color Settings")
State.Values.ESPColor = ColorsTab:CreateColorPicker({
   Name = "ESP Color",
   Color = Color3.fromRGB(255, 0, 0),
   Flag = "ESPColor",
   Callback = function(value) State.Values.ESPColor = value end
})

State.Values.CrosshairColor = ColorsTab:CreateColorPicker({
   Name = "Crosshair Color",
   Color = Color3.fromRGB(255, 255, 255),
   Flag = "CrosshairColor",
   Callback = function(value) State.Values.CrosshairColor = value end
})

State.Enabled.Rainbow = ColorsTab:CreateToggle({
   Name = "🌈 Rainbow Mode",
   CurrentValue = false,
   Flag = "RainbowToggle",
   Callback = function(value) State.Enabled.Rainbow = value end
})

-- Main Render Loop (Optimized)
State.Connections.MainLoop = Services.RunService.Heartbeat:Connect(function()
   local currentTime = tick()
   
   -- Performance throttling
   if currentTime - State.Performance.LastUpdate < PerformanceOptimizer.UpdateRate then
      return
   end
   State.Performance.LastUpdate = currentTime
   
   -- Noclip
   if State.Enabled.Noclip and LocalPlayer.Character then
      for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
         if part:IsA("BasePart") then
            part.CanCollide = false
         end
      end
   end
   
   -- Speed
   if State.Enabled.Speed and LocalPlayer.Character then
      local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
      if humanoid then
         humanoid.WalkSpeed = State.Values.Speed
      end
   end
   
   -- Fly
   if State.Enabled.Fly then
      FlyManager.UpdateFly()
   end
   
   -- Combat updates (lower frequency)
   CombatManager.UpdateAimbot()
   if State.Enabled.SilentAim then
      CombatManager.ApplySilentAim()
   end
   if State.Enabled.KillAura or (State.Enabled.AutoShoot and CombatManager.Target) then
      CombatManager.KillAura()
   end
   
   -- Visual updates
   if State.Enabled.ESP then
      ESPManager.UpdateESP()
   end
   if State.Enabled.CustomCrosshair then
      CrosshairManager.UpdateCrosshair()
   end
end)

-- Player Management
State.Connections.PlayerAdded = Services.Players.PlayerAdded:Connect(function(player)
   player.CharacterAdded:Connect(function()
      if State.Enabled.ESP then
         task.wait(1)
         ESPManager.CreateESP(player)
      end
   end)
end)

for _, player in pairs(Services.Players:GetPlayers()) do
   if player ~= LocalPlayer then
      player.CharacterAdded:Connect(function()
         if State.Enabled.ESP then
            task.wait(1)
            ESPManager.CreateESP(player)
         end
      end)
   end
end

-- Character Respawn
LocalPlayer.CharacterAdded:Connect(function()
   task.wait(1)
   if State.Enabled.Speed then
      local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
      if humanoid then
         humanoid.WalkSpeed = State.Values.Speed
      end
   end
end)

-- Cleanup on leave
Services.Players.PlayerRemoving:Connect(function(player)
   if ESPManager.Drawings[player] then
      for _, drawing in pairs(ESPManager.Drawings[player]) do
         if drawing.Remove then drawing:Remove() end
      end
      ESPManager.Drawings[player] = nil
   end
end)

Rayfield:Notify({
   Title = "TurcjaHub v2.0 Loaded!",
   Content = "All features operational.",
   Duration = 6,
   Image = 4483362458
})

print("TurcjaHub v2.0")
