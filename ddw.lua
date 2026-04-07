-- Ultimate Roblox Cheat Script - FIXED Rayfield GUI
-- Wszystko działa + Pełne GUI z wszystkimi opcjami

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Turcja Hub",
   LoadingTitle = "Ładowanie",
   LoadingSubtitle = "TurcjaHub • ESP/Fling/Movement",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "UltimateHub",
      FileName = "UltimateConfig"
   },
   KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Variables
local ESPObjects = {}
local Toggles = {}
local Sliders = {}
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Notification Helper
local function Notify(title, text, duration)
   Rayfield:Notify({
      Title = title,
      Content = text,
      Duration = duration or 4,
      Image = 4483362458
   })
end

-- ESP System (Box + Name + Tracer + Health)
local ESPEnabled = false
local ESPFolder = {}

local function CreateESP(Player)
   if Player == LocalPlayer then return end
   
   local Box = Drawing.new("Square")
   Box.Size = Vector2.new(0, 0)
   Box.Color = Color3.fromRGB(255, 0, 255)
   Box.Thickness = 3
   Box.Filled = false
   Box.Transparency = 1
   
   local Name = Drawing.new("Text")
   Name.Size = 18
   Name.Font = 2
   Name.Color = Color3.fromRGB(255, 255, 255)
   Name.Outline = true
   Name.OutlineColor = Color3.fromRGB(0, 0, 0)
   Name.Center = true
   
   local Tracer = Drawing.new("Line")
   Tracer.Color = Color3.fromRGB(255, 0, 255)
   Tracer.Thickness = 2
   Tracer.Transparency = 1
   
   local HealthBar = Drawing.new("Line")
   HealthBar.Color = Color3.fromRGB(0, 255, 0)
   HealthBar.Thickness = 3
   
   ESPFolder[Player] = {Box = Box, Name = Name, Tracer = Tracer, HealthBar = HealthBar}
end

local function UpdateESP()
   for Player, ESP in pairs(ESPFolder) do
      if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Humanoid") then
         local RootPart = Player.Character.HumanoidRootPart
         local Humanoid = Player.Character.Humanoid
         local Head = Player.Character:FindFirstChild("Head")
         
         local Vector, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
         local HeadPos = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
         local LegPos = Camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0))
         
         if OnScreen then
            local Size = (HeadPos.Y - LegPos.Y) / 2
            local BoxPos = Vector2.new(Vector.X, HeadPos.Y - Size * 1.5)
            
            ESP.Box.Size = Vector2.new(Size / 2, Size * 3)
            ESP.Box.Position = BoxPos - ESP.Box.Size / 2
            ESP.Box.Visible = true
            
            ESP.Name.Text = Player.Name .. "\n[" .. math.floor(Humanoid.Health) .. "]"
            ESP.Name.Position = Vector2.new(Vector.X, HeadPos.Y - Size * 2)
            ESP.Name.Visible = true
            
            ESP.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2 + 40)
            ESP.Tracer.To = Vector2.new(Vector.X, Vector.Y + ESP.Box.Size.Y / 2)
            ESP.Tracer.Visible = true
            
            local HealthPercent = Humanoid.Health / Humanoid.MaxHealth
            ESP.HealthBar.From = Vector2.new(Vector.X - Size / 2 - 4, HeadPos.Y)
            ESP.HealthBar.To = Vector2.new(Vector.X - Size / 2 - 4, HeadPos.Y + (Size * 3 * HealthPercent))
            ESP.HealthBar.Color = Color3.fromRGB(255 * (1 - HealthPercent), 255 * HealthPercent, 0)
            ESP.HealthBar.Visible = true
         else
            ESP.Box.Visible = ESPEnabled
            ESP.Name.Visible = ESPEnabled
            ESP.Tracer.Visible = ESPEnabled
            ESP.HealthBar.Visible = ESPEnabled
         end
      end
   end
end

-- Fling System
local Flinging = false
local function FlingAll()
   for _, Player in pairs(Players:GetPlayers()) do
      if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
         local HRP = Player.Character.HumanoidRootPart
         local BV = Instance.new("BodyVelocity")
         BV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
         BV.Velocity = Vector3.new(math.random(-5e3, 5e3), 5e3, math.random(-5e3, 5e3))
         BV.Parent = HRP
         game:GetService("Debris"):AddItem(BV, 0.2)
      end
   end
end

-- Character Reset Handler
LocalPlayer.CharacterAdded:Connect(function(Char)
   Character = Char
   Humanoid = Character:WaitForChild("Humanoid")
   RootPart = Character:WaitForChild("HumanoidRootPart")
   Notify("🔄 Refresh", "Cheaty odświeżone po respawnie!", 3)
end)

-- TABS
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
local MovementTab = Window:CreateTab("🏃 Movement", 4483362458)
local VisualTab = Window:CreateTab("👁️ Visuals", 4483362458)
local PlayerTab = Window:CreateTab("👤 Player", 4483362458)

-- COMBAT TAB
CombatTab:CreateToggle({
   Name = "🌈 ESP + Tracers + Health",
   CurrentValue = false,
   Flag = "ESP",
   Callback = function(Value)
      ESPEnabled = Value
      if Value then
         for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer then
               CreateESP(Player)
            end
         end
      end
   end,
})

CombatTab:CreateToggle({
   Name = "💥 Fling ALL Players",
   CurrentValue = false,
   Flag = "Fling",
   Callback = function(Value)
      Flinging = Value
      spawn(function()
         while Flinging do
            FlingAll()
            wait(0.1)
         end
      end)
   end,
})

-- MOVEMENT TAB
MovementTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 500},
   Increment = 5,
   CurrentValue = 50,
   Flag = "WalkSpeed",
   Callback = function(Value)
      if Humanoid then Humanoid.WalkSpeed = Value end
   end,
})

MovementTab:CreateToggle({
   Name = "✈️ Fly (WASD + Space)",
   CurrentValue = false,
   Flag = "Fly",
   Callback = function(Value)
      Toggles.Fly = Value
      if Value then
         local BV = Instance.new("BodyVelocity")
         BV.MaxForce = Vector3.new(4000, 4000, 4000)
         BV.Parent = RootPart
         Toggles.FlyBV = BV
         
         Toggles.FlyConn = RunService.Heartbeat:Connect(function()
            if Toggles.Fly then
               local Move = Vector3.new(0,0,0)
               if UserInputService:IsKeyDown(Enum.KeyCode.W) then Move = Move + Camera.CFrame.LookVector end
               if UserInputService:IsKeyDown(Enum.KeyCode.S) then Move = Move - Camera.CFrame.LookVector end
               if UserInputService:IsKeyDown(Enum.KeyCode.A) then Move = Move - Camera.CFrame.RightVector end
               if UserInputService:IsKeyDown(Enum.KeyCode.D) then Move = Move + Camera.CFrame.RightVector end
               if UserInputService:IsKeyDown(Enum.KeyCode.Space) then Move = Move + Vector3.new(0,1,0) end
               if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then Move = Move - Vector3.new(0,1,0) end
               BV.Velocity = Move * 50
            end
         end)
      else
         if Toggles.FlyConn then Toggles.FlyConn:Disconnect() end
         if Toggles.FlyBV then Toggles.FlyBV:Destroy() end
      end
   end,
})

MovementTab:CreateToggle({
   Name = "👻 NoClip",
   CurrentValue = false,
   Flag = "NoClip",
   Callback = function(Value)
      Toggles.NoClip = Value
   end,
})

MovementTab:CreateToggle({
   Name = "📈 Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJump",
   Callback = function(Value)
      Toggles.InfiniteJump = Value
   end,
})

MovementTab:CreateToggle({
   Name = "🌙 Low Gravity",
   CurrentValue = false,
   Flag = "LowGravity",
   Callback = function(Value)
      Toggles.LowGravity = Value
   end,
})

MovementTab:CreateToggle({
   Name = "🐰 Bunny Hop",
   CurrentValue = false,
   Flag = "BunnyHop",
   Callback = function(Value)
      Toggles.BunnyHop = Value
   end,
})

MovementTab:CreateToggle({
   Name = "💨 Fake Lag",
   CurrentValue = false,
   Flag = "FakeLag",
   Callback = function(Value)
      Toggles.FakeLag = Value
   end,
})

MovementTab:CreateButton({
   Name = "🚀 Teleport to Mouse (F)",
   Callback = function()
      RootPart.CFrame = CFrame.new(Mouse.Hit.Position)
      Notify("Teleport", "Teleported to mouse!", 2)
   end,
})

-- VISUALS TAB
VisualTab:CreateSlider({
   Name = "FOV",
   Range = {30, 120},
   Increment = 1,
   CurrentValue = 70,
   Flag = "FOV",
   Callback = function(Value)
      Camera.FieldOfView = Value
   end,
})

-- PLAYER TAB
PlayerTab:CreateInput({
   Name = "Spectate Player",
   PlaceholderText = "Wpisz nick gracza...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local Target = Players:FindFirstChild(Text)
      if Target then
         Camera.CameraSubject = Target.Character.Humanoid
         Notify("Spectate", "Spectating " .. Text, 3)
      else
         Notify("Error", "Gracz nie znaleziony!", 3)
      end
   end,
})

PlayerTab:CreateButton({
   Name = "Reconnect (Refresh)",
   Callback = function()
      TeleportService:Teleport(game.PlaceId, LocalPlayer)
   end,
})

-- Main Loops
spawn(function()
   while wait() do
      UpdateESP()
      
      -- NoClip
      if Toggles.NoClip and Character then
         for _, Part in pairs(Character:GetChildren()) do
            if Part:IsA("BasePart") then Part.CanCollide = false end
         end
      end
      
      -- Infinite Jump
      if Toggles.InfiniteJump then
         Humanoid:ChangeState("Jumping")
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
      if Toggles.FakeLag then
         RootPart.CFrame = RootPart.CFrame + Vector3.new(math.random(-10,10)/10, 0, math.random(-10,10)/10)
      end
   end
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(Input)
   if Input.KeyCode == Enum.KeyCode.F then
      RootPart.CFrame = CFrame.new(Mouse.Hit.Position)
   end
end)

-- Init Players
for _, Player in pairs(Players:GetPlayers()) do
   Player.CharacterAdded:Connect(function()
      wait(1)
      if ESPEnabled then CreateESP(Player) end
   end)
end

Notify("✅ LOADED", "Wszystkie cheaty działają! (F=Teleport)", 5)
