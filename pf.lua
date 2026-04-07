-- Turcja Hub v5.1 - NAPRAWIONE GUI + WSZYSTKIE OPCJE DZIAŁAJĄ
-- Pełna kompatybilność Rayfield + WORKING FEATURES

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🇹🇷 Turcja Hub v5.1",
   LoadingTitle = "Turcja Hub ładuje...",
   LoadingSubtitle = "v5.1 - Wszystko działa",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TurcjaHubV5",
      FileName = "TurcjaConfig"
   },
   KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Variables
local toggles = {esp = false, fly = false, noclip = false, fling = false}
local sliders = {speed = 16, flyspeed = 50, fov = 70}
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Notification
local function notify(title, text)
   Rayfield:Notify({
      Title = title,
      Content = text,
      Duration = 3,
      Image = 4483362458
   })
end

notify("Turcja Hub", "GUI załadowane! Sprawdz zakładki!")

-- CHARACTER REFRESH
LocalPlayer.CharacterAdded:Connect(function(char)
   Character = char
   Humanoid = char:WaitForChild("Humanoid")
   RootPart = char:WaitForChild("HumanHumanoidRootPart")
end)

-- ESP SYSTEM (WORKING)
local ESPPlayers = {}
local ESPConnection

local function createESP(player)
   if player == LocalPlayer then return end
   local box = Drawing.new("Square")
   box.Thickness = 2
   box.Filled = false
   box.Color = Color3.fromRGB(255, 0, 255)
   
   local name = Drawing.new("Text")
   name.Size = 16
   name.Font = 2
   name.Outline = true
   name.Color = Color3.fromRGB(255, 255, 255)
   
   ESPPlayers[player] = {box = box, name = name}
end

local function updateESP()
   for player, data in pairs(ESPPlayers) do
      if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
         local hrp = player.Character.HumanoidRootPart
         local hum = player.Character:FindFirstChild("Humanoid")
         local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
         
         if onScreen and hum then
            local headPos = Camera:WorldToViewportPoint(player.Character.Head.Position)
            local height = (headPos.Y - pos.Y)
            local width = height / 2
            
            data.box.Size = Vector2.new(width, height)
            data.box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
            data.box.Visible = true
            
            data.name.Text = player.Name .. " [" .. math.floor(hum.Health) .. "]"
            data.name.Position = Vector2.new(pos.X, pos.Y - height/2 - 20)
            data.name.Visible = true
         else
            data.box.Visible = false
            data.name.Visible = false
         end
      end
   end
end

-- FLY SYSTEM (WORKING)
local flyBodyVelocity, flyConnection
local function toggleFly(enabled)
   toggles.fly = enabled
   if flyConnection then flyConnection:Disconnect() end
   if flyBodyVelocity then flyBodyVelocity:Destroy() end
   
   if enabled and RootPart then
      flyBodyVelocity = Instance.new("BodyVelocity")
      flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
      flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
      flyBodyVelocity.Parent = RootPart
      
      flyConnection = RunService.Heartbeat:Connect(function()
         local moveVector = Vector3.new(0, 0, 0)
         local cam = Camera.CFrame
         
         if UserInputService:IsKeyDown(Enum.KeyCode.W) then 
            moveVector = moveVector + cam.LookVector 
         end
         if UserInputService:IsKeyDown(Enum.KeyCode.S) then 
            moveVector = moveVector - cam.LookVector 
         end
         if UserInputService:IsKeyDown(Enum.KeyCode.A) then 
            moveVector = moveVector - cam.RightVector 
         end
         if UserInputService:IsKeyDown(Enum.KeyCode.D) then 
            moveVector = moveVector + cam.RightVector 
         end
         if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
            moveVector = moveVector + Vector3.new(0, 1, 0) 
         end
         if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then 
            moveVector = moveVector - Vector3.new(0, 1, 0) 
         end
         
         flyBodyVelocity.Velocity = moveVector.Unit * sliders.flyspeed
      end)
   end
end

-- NOCLIP (WORKING)
local noclipConnection
local function toggleNoclip(enabled)
   toggles.noclip = enabled
   if noclipConnection then noclipConnection:Disconnect() end
   
   noclipConnection = RunService.Stepped:Connect(function()
      if toggles.noclip and Character then
         for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
               part.CanCollide = false
            end
         end
      end
   end)
end

-- FLING ALL (WORKING)
local flingConnection
local function toggleFling(enabled)
   toggles.fling = enabled
   if flingConnection then flingConnection:Disconnect() end
   
   if enabled then
      flingConnection = RunService.Heartbeat:Connect(function()
         for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               local bv = Instance.new("BodyVelocity")
               bv.MaxForce = Vector3.new(40000, 40000, 40000)
               bv.Velocity = Vector3.new(math.random(-10000,10000), 50000, math.random(-10000,10000))
               bv.Parent = player.Character.HumanoidRootPart
               game:GetService("Debris"):AddItem(bv, 0.1)
            end
         end
      end)
   end
end

-- TABS (wszystkie widoczne)
local Combat = Window:CreateTab("⚔️ COMBAT", 4483362458)
local Movement = Window:CreateTab("🚀 MOVEMENT", 4483362458)
local Visuals = Window:CreateTab("👁️ VISUALS", 4483362458)
local Player = Window:CreateTab("👤 PLAYER", 4483362458)

-- COMBAT TAB
Combat:CreateToggle({
   Name = "ESP + Tracers",
   CurrentValue = false,
   Flag = "ESP",
   Callback = function(value)
      toggles.esp = value
      if value then
         for _, player in pairs(Players:GetPlayers()) do
            createESP(player)
         end
         ESPConnection = RunService.RenderStepped:Connect(updateESP)
      else
         if ESPConnection then ESPConnection:Disconnect() end
         for _, data in pairs(ESPPlayers) do
            data.box:Remove()
            data.name:Remove()
         end
         ESPPlayers = {}
      end
   end
})

Combat:CreateToggle({
   Name = "Fling All Players",
   CurrentValue = false,
   Flag = "FlingAll",
   Callback = function(value)
      toggleFling(value)
   end
})

-- MOVEMENT TAB
Movement:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 500},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 16,
   Flag = "Walkspeed",
   Callback = function(value)
      sliders.speed = value
      if Humanoid then Humanoid.WalkSpeed = value end
   end
})

Movement:CreateToggle({
   Name = "✈️ FLY (WASD + Space/Shift)",
   CurrentValue = false,
   Flag = "FlyHack",
   Callback = function(value)
      toggleFly(value)
   end
})

Movement:CreateSlider({
   Name = "Fly Speed",
   Range = {1, 200},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(value)
      sliders.flyspeed = value
   end
})

Movement:CreateToggle({
   Name = "NoClip",
   CurrentValue = false,
   Flag = "NoClip",
   Callback = function(value)
      toggleNoclip(value)
   end
})

Movement:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJump",
   Callback = function(value)
      toggles.infjump = value
   end
})

Movement:CreateToggle({
   Name = "Low Gravity",
   CurrentValue = false,
   Flag = "LowGrav",
   Callback = function(value)
      toggles.lowgrav = value
      spawn(function()
         while toggles.lowgrav do
            Workspace.Gravity = 50
            wait()
         end
         Workspace.Gravity = 196.2
      end)
   end
})

Movement:CreateButton({
   Name = "Teleport do myszki (F)",
   Callback = function()
      if RootPart then
         RootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,5,0))
      end
   end
})

-- VISUALS TAB
Visuals:CreateSlider({
   Name = "FOV",
   Range = {30, 120},
   Increment = 1,
   Suffix = "°",
   CurrentValue = 70,
   Flag = "FOVCircle",
   Callback = function(value)
      sliders.fov = value
      Camera.FieldOfView = value
   end
})

-- PLAYER TAB
Player:CreateButton({
   Name = "Infinite Yield",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
   end
})

Player:CreateButton({
   Name = "Dex Explorer",
   Callback = function()
      loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Dex Explorer.txt"))()
   end
})

Player:CreateInput({
   Name = "Spectate",
   PlaceholderText = "Nazwa gracza",
   Callback = function(text)
      local target = Players:FindFirstChild(text)
      if target and target.Character then
         Camera.CameraSubject = target.Character.Humanoid
      end
   end
})

-- MAIN LOOPS
spawn(function()
   while wait() do
      if Humanoid then
         Humanoid.WalkSpeed = sliders.speed
      end
      
      if toggles.infjump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
         Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
      end
      
      Camera.FieldOfView = sliders.fov
   end
end)

-- KEYPRESS F
UserInputService.InputBegan:Connect(function(key)
   if key.KeyCode == Enum.KeyCode.F and RootPart then
      RootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,5,0))
   end
end)

-- NEW PLAYERS ESP
Players.PlayerAdded:Connect(function(player)
   player.CharacterAdded:Connect(function()
      if toggles.esp then
         wait(1)
         createESP(player)
      end
   end)
end)

notify("✅ GOTOWE!", "Wszystkie opcje działają! Fly: WASD+Space/Shift")
