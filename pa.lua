local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Turcja Hub",
   LoadingTitle = "Loading Interface",
   LoadingSubtitle = "Professional Cheat Suite",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TurcjaHub",
      FileName = "TurcjaConfig"
   },
   KeySystem = false
})

-- Core Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Anti-Detection
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
   local method = getnamecallmethod()
   local args = {...}
   if method == "Kick" or (method == "FireServer" and (tostring(self):lower():find("anti") or tostring(self):lower():find("report"))) then
      return wait(math.huge)
   end
   return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- State Variables
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local ESPObjects = {}
local ESPEnabled = false
local FlingEnabled = false
local Toggles = {}
local Sliders = {}

-- Notification System
local function Notify(Title, Content)
   Rayfield:Notify({
      Title = Title,
      Content = Content,
      Duration = 3.5,
      Image = 4483362458
   })
end

-- Professional ESP System
local function CleanupESP()
   for player, objects in pairs(ESPObjects) do
      pcall(function()
         objects.box:Remove()
         objects.name:Remove()
         objects.tracer:Remove()
         objects.health:Remove()
      end)
   end
   ESPObjects = {}
end

local function CreateESP(player)
   if player == LocalPlayer or ESPObjects[player] then return end
   
   local box = Drawing.new("Square")
   box.Thickness = 2
   box.Filled = false
   box.Color = Color3.fromRGB(255, 50, 255)
   box.Transparency = 0.9
   
   local name = Drawing.new("Text")
   name.Size = 16
   name.Font = 2
   name.Color = Color3.fromRGB(255, 255, 255)
   name.Outline = true
   name.OutlineColor = Color3.fromRGB(0, 0, 0)
   name.Center = true
   
   local tracer = Drawing.new("Line")
   tracer.Thickness = 2
   tracer.Color = Color3.fromRGB(255, 50, 255)
   tracer.Transparency = 0.8
   
   local health = Drawing.new("Line")
   health.Thickness = 3
   health.Color = Color3.fromRGB(0, 255, 0)
   
   ESPObjects[player] = {box = box, name = name, tracer = tracer, health = health}
end

local ESPUpdateConnection
local function ToggleESP(enabled)
   ESPEnabled = enabled
   CleanupESP()
   
   if enabled then
      for _, player in pairs(Players:GetPlayers()) do
         CreateESP(player)
      end
      
      ESPUpdateConnection = RunService.RenderStepped:Connect(function()
         for player, objects in pairs(ESPObjects) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               local root = player.Character.HumanoidRootPart
               local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
               local head = player.Character:FindFirstChild("Head")
               
               if humanoid and head then
                  local vector, onScreen = Camera:WorldToViewportPoint(root.Position)
                  local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.3, 0))
                  local footPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 4, 0))
                  
                  if onScreen then
                     local boxHeight = math.abs(headPos.Y - footPos.Y)
                     local boxWidth = boxHeight / 2
                     
                     objects.box.Size = Vector2.new(boxWidth, boxHeight)
                     objects.box.Position = Vector2.new(vector.X - boxWidth / 2, vector.Y - boxHeight / 2)
                     objects.box.Visible = true
                     
                     objects.name.Text = string.format("%s\n[%.0fHP]", player.Name, humanoid.Health)
                     objects.name.Position = Vector2.new(vector.X, headPos.Y - 25)
                     objects.name.Visible = true
                     
                     objects.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                     objects.tracer.To = Vector2.new(vector.X, vector.Y + boxHeight / 2)
                     objects.tracer.Visible = true
                     
                     local healthPercent = humanoid.Health / humanoid.MaxHealth
                     objects.health.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                     objects.health.From = Vector2.new(vector.X - boxWidth / 2 - 4, headPos.Y)
                     objects.health.To = Vector2.new(vector.X - boxWidth / 2 - 4, headPos.Y + boxHeight * healthPercent)
                     objects.health.Visible = true
                  else
                     objects.box.Visible = false
                     objects.name.Visible = false
                     objects.tracer.Visible = false
                     objects.health.Visible = false
                  end
               end
            end
         end
      end)
   else
      if ESPUpdateConnection then
         ESPUpdateConnection:Disconnect()
      end
   end
end

-- Fling All System (GitHub Quality)
local FlingConnection
local function ToggleFling(enabled)
   FlingEnabled = enabled
   if FlingConnection then FlingConnection:Disconnect() end
   
   if enabled then
      FlingConnection = RunService.Heartbeat:Connect(function()
         for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               local targetRoot = player.Character.HumanoidRootPart
               
               local bodyVelocity = Instance.new("BodyVelocity")
               bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
               bodyVelocity.Velocity = Vector3.new(
                  math.random(-5000, 5000),
                  25000,
                  math.random(-5000, 5000)
               )
               bodyVelocity.Parent = targetRoot
               
               local bodyAngular = Instance.new("BodyAngularVelocity")
               bodyAngular.AngularVelocity = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
               bodyAngular.MaxTorque = Vector3.new(4000, 4000, 4000)
               bodyAngular.P = 12500
               bodyAngular.Parent = targetRoot
               
               game:GetService("Debris"):AddItem(bodyVelocity, 0.25)
               game:GetService("Debris"):AddItem(bodyAngular, 0.25)
            end
         end
      end)
   end
end

-- NoClip System
local NoClipConnection
local function ToggleNoClip(enabled)
   Toggles.NoClip = enabled
   if NoClipConnection then NoClipConnection:Disconnect() end
   
   NoClipConnection = RunService.Stepped:Connect(function()
      if Toggles.NoClip and Character then
         for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
               part.CanCollide = false
            end
         end
      end
   end)
end

-- Fly System
local FlyConnection, FlyBodyVelocity
local function ToggleFly(enabled)
   Toggles.Fly = enabled
   if FlyConnection then FlyConnection:Disconnect() end
   if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
   
   if enabled then
      FlyBodyVelocity = Instance.new("BodyVelocity")
      FlyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
      FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
      FlyBodyVelocity.Parent = RootPart
      
      FlyConnection = RunService.Heartbeat:Connect(function()
         local moveVector = Vector3.new(0, 0, 0)
         local speed = Sliders.FlySpeed or 50
         
         if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + Camera.CFrame.LookVector
         end
         if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - Camera.CFrame.LookVector
         end
         if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - Camera.CFrame.RightVector
         end
         if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + Camera.CFrame.RightVector
         end
         if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, 1, 0)
         end
         if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveVector = moveVector - Vector3.new(0, 1, 0)
         end
         
         FlyBodyVelocity.Velocity = moveVector * speed
      end)
   end
end

-- Tabs Creation
local CombatTab = Window:CreateTab("Combat", nil)
local MovementTab = Window:CreateTab("Movement", nil)
local VisualTab = Window:CreateTab("Visuals", nil)
local PlayerTab = Window:CreateTab("Player", nil)

-- Combat Tab
CombatTab:CreateToggle({
   Name = "ESP + Tracers",
   CurrentValue = false,
   Flag = "ESPEnabled",
   Callback = ToggleESP
})

CombatTab:CreateToggle({
   Name = "Fling All Players",
   CurrentValue = false,
   Flag = "FlingEnabled",
   Callback = ToggleFling
})

-- Movement Tab
MovementTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Flag = "WalkSpeed",
   Callback = function(value)
      Sliders.WalkSpeed = value
      if Humanoid then Humanoid.WalkSpeed = value end
   end
})

MovementTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Flag = "FlyEnabled",
   Callback = ToggleFly
})

MovementTab:CreateSlider({
   Name = "Fly Speed",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(value)
      Sliders.FlySpeed = value
   end
})

MovementTab:CreateToggle({
   Name = "NoClip",
   CurrentValue = false,
   Flag = "NoClipEnabled",
   Callback = ToggleNoClip
})

MovementTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJump",
   Callback = function(value)
      Toggles.InfiniteJump = value
   end
})

MovementTab:CreateToggle({
   Name = "Low Gravity",
   CurrentValue = false,
   Flag = "LowGravity",
   Callback = function(value)
      Toggles.LowGravity = value
   end
})

MovementTab:CreateToggle({
   Name = "Bunny Hop",
   CurrentValue = false,
   Flag = "BunnyHop",
   Callback = function(value)
      Toggles.BunnyHop = value
   end
})

MovementTab:CreateToggle({
   Name = "Fake Lag",
   CurrentValue = false,
   Flag = "FakeLag",
   Callback = function(value)
      Toggles.FakeLag = value
   end
})

MovementTab:CreateToggle({
   Name = "Spin Bot",
   CurrentValue = false,
   Flag = "SpinBot",
   Callback = function(value)
      Toggles.SpinBot = value
   end
})

MovementTab:CreateButton({
   Name = "Teleport to Mouse",
   Callback = function()
      if RootPart then
         RootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 5, 0))
      end
   end
})

-- Visuals Tab
VisualTab:CreateSlider({
   Name = "FOV",
   Range = {30, 120},
   Increment = 1,
   CurrentValue = 70,
   Flag = "FOVChanger",
   Callback = function(value)
      Camera.FieldOfView = value
   end
})

-- Player Tab
PlayerTab:CreateInput({
   Name = "Spectate Player",
   PlaceholderText = "Enter player name (empty to disable)",
   RemoveTextAfterFocusLost = false,
   Callback = function(text)
      if text == "" then
         Camera.CameraSubject = Humanoid
         Notify("Spectate", "Returned to self view")
         return
      end
      
      local target = Players:FindFirstChild(text)
      if target and target.Character then
         Camera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
         Notify("Spectate", "Now spectating: " .. text)
      else
         Notify("Error", "Player not found")
      end
   end
})

PlayerTab:CreateButton({
   Name = "Reconnect",
   Callback = function()
      TeleportService:Teleport(game.PlaceId, LocalPlayer)
   end
})

-- CMD System (GitHub Sourced)
PlayerTab:CreateButton({
   Name = "Dex Explorer",
   Callback = function()
      loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Dex Explorer.txt"))()
   end
})

PlayerTab:CreateButton({
   Name = "Infinite Yield",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
   end
})

-- Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
   Character = newCharacter
   Humanoid = Character:WaitForChild("Humanoid")
   RootPart = Character:WaitForChild("HumanoidRootPart")
   
   -- Refresh movement values
   if Sliders.WalkSpeed then
      Humanoid.WalkSpeed = Sliders.WalkSpeed
   end
   
   Notify("Refresh", "Character refreshed - all features active")
end)

-- Player Join Handler (ESP Refresh)
Players.PlayerAdded:Connect(function(player)
   player.CharacterAdded:Connect(function()
      wait(1)
      if ESPEnabled then
         CreateESP(player)
      end
   end)
end)

-- Main Game Loop
local MainLoopConnection = RunService.Heartbeat:Connect(function()
   -- Apply WalkSpeed
   if Sliders.WalkSpeed and Humanoid then
      Humanoid.WalkSpeed = Sliders.WalkSpeed
   end
   
   -- Infinite Jump
   if Toggles.InfiniteJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
      Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
   end
   
   -- Low Gravity
   if Toggles.LowGravity then
      Workspace.Gravity = 50
   else
      Workspace.Gravity = 196.2
   end
   
   -- Bunny Hop
   if Toggles.BunnyHop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
      Humanoid.Jump = true
   end
   
   -- Fake Lag
   if Toggles.FakeLag and RootPart then
      RootPart.CFrame = RootPart.CFrame + Vector3.new(
         math.random(-5, 5) * 0.1,
         0,
         math.random(-5, 5) * 0.1
      )
   end
   
   -- Spin Bot
   if Toggles.SpinBot and RootPart then
      RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(15), 0)
   end
end)

-- Keyboard Input Handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
   if gameProcessed then return end
   
   if input.KeyCode == Enum.KeyCode.F then
      if RootPart then
         RootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 5, 0))
      end
   end
end)

-- Initialize existing players for ESP
for _, player in pairs(Players:GetPlayers()) do
   if player ~= LocalPlayer then
      player.CharacterAdded:Connect(function()
         wait(1)
         if ESPEnabled then
            CreateESP(player)
         end
      end)
   end
end

Notify("Turcja Hub", "Loaded successfully")
