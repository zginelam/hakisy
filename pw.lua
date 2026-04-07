-- Turcja Hub - FIXED GUI DISPLAY
-- All options now visible in Rayfield interface

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Turcja Hub v5.0",
   LoadingTitle = "Initializing...",
   LoadingSubtitle = "Loading all features",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TurcjaHub",
      FileName = "config"
   },
   KeySystem = false -- Set this to false to disable key system
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Anti-detection
local mt = getrawmetatable(game)
local backup = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(Self, ...)
   local args = {...}
   local method = getnamecallmethod()
   if method == "FireServer" and tostring(Self):lower():find("anti") then
      return
   end
   if method == "Kick" then
      return
   end
   return backup(Self, ...)
end)
setreadonly(mt, true)

-- Variables
local Character = LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local ESPData = {}
local espEnabled = false
local flingEnabled = false
local toggles = {}
local sliders = {}

-- Notification function
local function notify(title, content)
   Rayfield:Notify({
      Title = title,
      Content = content,
      Duration = 3,
      Image = 4483362458
   })
end

-- ESP System (Fixed)
local function createESP(player)
   if player == LocalPlayer then return end
   
   local box = Drawing.new("Square")
   box.Filled = false
   box.Thickness = 2
   box.Color = Color3.fromRGB(255, 0, 255)
   
   local nameTag = Drawing.new("Text")
   nameTag.Size = 16
   nameTag.Font = 2
   nameTag.Outline = true
   nameTag.Color = Color3.fromRGB(255, 255, 255)
   
   local tracer = Drawing.new("Line")
   tracer.Thickness = 1.5
   tracer.Color = Color3.fromRGB(255, 0, 255)
   
   ESPData[player] = {box = box, nameTag = nameTag, tracer = tracer}
end

local espConnection
local function toggleESP(enabled)
   espEnabled = enabled
   
   if enabled then
      for _, player in pairs(Players:GetPlayers()) do
         createESP(player)
      end
      
      espConnection = RunService.RenderStepped:Connect(function()
         for player, drawings in pairs(ESPData) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               local rootPart = player.Character.HumanoidRootPart
               local humanoid = player.Character:FindFirstChild("Humanoid")
               
               local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
               
               if onScreen and humanoid then
                  local head = player.Character:FindFirstChild("Head")
                  if head then
                     local headPos = Camera:WorldToViewportPoint(head.Position)
                     local size = (headPos.Y - screenPos.Y) / 2
                     
                     drawings.box.Size = Vector2.new(2000/rootPart.Position.Magnitude, size * 2)
                     drawings.box.Position = Vector2.new(screenPos.X - drawings.box.Size.X / 2, screenPos.Y - drawings.box.Size.Y / 2)
                     drawings.box.Visible = true
                     
                     drawings.nameTag.Text = player.Name .. " [" .. math.floor(humanoid.Health) .. "]"
                     drawings.nameTag.Position = Vector2.new(screenPos.X, screenPos.Y - size * 2 - 16)
                     drawings.nameTag.Visible = true
                     
                     drawings.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                     drawings.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                     drawings.tracer.Visible = true
                  end
               else
                  drawings.box.Visible = false
                  drawings.nameTag.Visible = false
                  drawings.tracer.Visible = false
               end
            end
         end
      end)
   else
      if espConnection then
         espConnection:Disconnect()
      end
      for _, drawings in pairs(ESPData) do
         drawings.box:Remove()
         drawings.nameTag:Remove()
         drawings.tracer:Remove()
      end
      ESPData = {}
   end
end

-- Fling All (Fixed - sends everyone to space)
local flingConnection
local function toggleFling(enabled)
   flingEnabled = enabled
   if flingConnection then flingConnection:Disconnect() end
   
   if enabled then
      flingConnection = RunService.Heartbeat:Connect(function()
         for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               local hrp = player.Character.HumanoidRootPart
               
               local bv = Instance.new("BodyVelocity")
               bv.MaxForce = Vector3.new(4e5, 4e5, 4e5)
               bv.Velocity = Vector3.new(math.random(-2e4,2e4), 5e4, math.random(-2e4,2e4))
               bv.Parent = hrp
               
               local ba = Instance.new("BodyAngularVelocity")
               ba.AngularVelocity = Vector3.new(0, math.huge, 0)
               ba.MaxTorque = Vector3.new(0, math.huge, 0)
               ba.Parent = hrp
               
               game:GetService("Debris"):AddItem(bv, 0.2)
               game:GetService("Debris"):AddItem(ba, 0.2)
            end
         end
      end)
   end
end

-- NoClip (Fixed)
local noclipConnection
local function toggleNoClip(enabled)
   toggles.noclip = enabled
   if noclipConnection then noclipConnection:Disconnect() end
   
   noclipConnection = RunService.Stepped:Connect(function()
      if toggles.noclip and Character then
         for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
               part.CanCollide = false
            end
         end
      end
   end)
end

-- Fly System
local flyConnection, flyVelocity
local function toggleFly(enabled)
   toggles.fly = enabled
   if flyConnection then flyConnection:Disconnect() end
   if flyVelocity then flyVelocity:Destroy() end
   
   if enabled then
      flyVelocity = Instance.new("BodyVelocity")
      flyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
      flyVelocity.Parent = RootPart
      
      flyConnection = RunService.Heartbeat:Connect(function()
         local cam = Workspace.CurrentCamera
         local move = Vector3.new()
         
         if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
         if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
         if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
         if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
         if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
         if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move + Vector3.new(0, -1, 0) end
         
         flyVelocity.Velocity = move.Unit * (sliders.flySpeed or 50)
      end)
   end
end

-- TABS - ALL VISIBLE NOW
local Tab1 = Window:CreateTab("Combat", 4483362458)
local Tab2 = Window:CreateTab("Movement", 4483362458)
local Tab3 = Window:CreateTab("Visuals", 4483362458)
local Tab4 = Window:CreateTab("Player", 4483362458)

-- COMBAT TAB
Tab1:CreateToggle({
   Name = "ESP + Tracers",
   CurrentValue = false,
   Flag = "ESP_Toggle",
   Callback = function(Value)
      toggleESP(Value)
   end,
})

Tab1:CreateToggle({
   Name = "Fling All Players",
   CurrentValue = false,
   Flag = "Fling_Toggle",
   Callback = function(Value)
      toggleFling(Value)
   end,
})

-- MOVEMENT TAB
Tab2:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 500},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "WalkSpeed_Slider",
   Callback = function(Value)
      sliders.walkspeed = Value
      if Humanoid then
         Humanoid.WalkSpeed = Value
      end
   end,
})

Tab2:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Flag = "Fly_Toggle",
   Callback = function(Value)
      toggleFly(Value)
   end,
})

Tab2:CreateSlider({
   Name = "Fly Speed",
   Range = {1, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 50,
   Flag = "FlySpeed_Slider",
   Callback = function(Value)
      sliders.flySpeed = Value
   end,
})

Tab2:CreateToggle({
   Name = "NoClip",
   CurrentValue = false,
   Flag = "NoClip_Toggle",
   Callback = function(Value)
      toggleNoClip(Value)
   end,
})

Tab2:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJump_Toggle",
   Callback = function(Value)
      toggles.infjump = Value
   end,
})

Tab2:CreateToggle({
   Name = "Low Gravity",
   CurrentValue = false,
   Flag = "LowGravity_Toggle",
   Callback = function(Value)
      toggles.lowgravity = Value
   end,
})

Tab2:CreateToggle({
   Name = "Bunny Hop",
   CurrentValue = false,
   Flag = "BunnyHop_Toggle",
   Callback = function(Value)
      toggles.bunnyhop = Value
   end,
})

Tab2:CreateToggle({
   Name = "Fake Lag",
   CurrentValue = false,
   Flag = "FakeLag_Toggle",
   Callback = function(Value)
      toggles.fakelag = Value
   end,
})

Tab2:CreateToggle({
   Name = "Spin Bot",
   CurrentValue = false,
   Flag = "SpinBot_Toggle",
   Callback = function(Value)
      toggles.spinbot = Value
   end,
})

Tab2:CreateButton({
   Name = "Teleport to Mouse (F key)",
   Callback = function()
      if RootPart then
         RootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
      end
   end,
})

-- VISUALS TAB
Tab3:CreateSlider({
   Name = "FOV Changer",
   Range = {30, 120},
   Increment = 1,
   Suffix = "FOV",
   CurrentValue = 70,
   Flag = "FOV_Slider",
   Callback = function(Value)
      Camera.FieldOfView = Value
   end,
})

-- PLAYER TAB
Tab4:CreateInput({
   Name = "Spectate (empty = self)",
   PlaceholderText = "Player name",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      if Text == "" then
         Camera.CameraSubject = Humanoid
         return
      end
      local targetPlayer = Players:FindFirstChild(Text)
      if targetPlayer and targetPlayer.Character then
         Camera.CameraSubject = targetPlayer.Character.Humanoid
      end
   end,
})

Tab4:CreateButton({
   Name = "Dex Explorer",
   Callback = function()
      loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Dex Explorer.txt"))()
   end,
})

Tab4:CreateButton({
   Name = "Infinite Yield",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
   end,
})

Tab4:CreateButton({
   Name = "Reconnect",
   Callback = function()
      TeleportService:Teleport(game.PlaceId)
   end,
})

-- Main Loop
spawn(function()
   while wait() do
      -- Update walkspeed
      if sliders.walkspeed and Humanoid then
         Humanoid.WalkSpeed = sliders.walkspeed
      end
      
      -- Infinite jump
      if toggles.infjump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
         Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
      end
      
      -- Low gravity
      if toggles.lowgravity then
         Workspace.Gravity = 50
      else
         Workspace.Gravity = 196.2
      end
      
      -- Bunny hop
      if toggles.bunnyhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
         Humanoid.Jump = true
      end
      
      -- Fake lag
      if toggles.fakelag and RootPart then
         RootPart.CFrame = RootPart.CFrame + Vector3.new(math.random(-2,2)*0.1, 0, math.random(-2,2)*0.1)
      end
      
      -- Spin bot
      if toggles.spinbot and RootPart then
         RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(20), 0)
      end
   end
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(key)
   if key.KeyCode == Enum.KeyCode.F and RootPart then
      RootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
   end
end)

-- Character respawn
LocalPlayer.CharacterAdded:Connect(function(char)
   Character = char
   Humanoid = char:WaitForChild("Humanoid")
   RootPart = char:WaitForChild("HumanoidRootPart")
end)

-- ESP player tracking
for _, player in pairs(Players:GetPlayers()) do
   player.CharacterAdded:Connect(function()
      wait(0.5)
      if espEnabled then
         createESP(player)
      end
   end)
end

notify("Turcja Hub", "All features loaded successfully")
