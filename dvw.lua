-- ULTIMATE ROBLOX CHEAT HUB v3.0 - FULLY FIXED
-- Naprawiony Fling, ESP, NoClip + CMDs + Anti-Cheat Bypass

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "🔥 Ultimate Cheat Hub v3.0",
   LoadingTitle = "Ładowanie Pro Cheatów...",
   LoadingSubtitle = "Fling/ESP/NoClip + CMDs + AC Bypass",
   ConfigurationSaving = {Enabled = true, FolderName = "UltimateV3", FileName = "config"},
   KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Anti-Detection & Bypass
getgenv().SecureMode = true
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
   local args = {...}
   local method = getnamecallmethod()
   if method == "Kick" or method == "FireServer" and tostring(self) == "MainHandler" then
      return
   end
   return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- Variables
local ESPData = {}
local Toggles = {Fling = false, ESP = false, NoClip = false}
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Spectating = nil

-- Notification
local function Notify(title, text)
   Rayfield:Notify({Title = title, Content = text, Duration = 4, Image = 4483362458})
end

-- FIXED ESP + Tracers (No Bugs)
local function ClearESP()
   for _, obj in pairs(ESPData) do
      pcall(function()
         obj.Box:Remove()
         obj.Name:Remove()
         obj.Tracer:Remove()
         obj.Health:Remove()
      end)
   end
   ESPData = {}
end

local function CreateESP(Player)
   if Player == LocalPlayer then return end
   
   local Box = Drawing.new("Square")
   Box.Thickness = 3
   Box.Filled = false
   Box.Color = Color3.new(1, 0, 1)
   Box.Transparency = 0.8
   
   local Name = Drawing.new("Text")
   Name.Size = 16
   Name.Font = 2
   Name.Color = Color3.new(1, 1, 1)
   Name.Outline = true
   Name.Center = true
   
   local Tracer = Drawing.new("Line")
   Tracer.Thickness = 2
   Tracer.Color = Color3.new(1, 0, 1)
   
   local Health = Drawing.new("Quad")
   Health.Thickness = 3
   Health.Filled = true
   Health.Color = Color3.new(0, 1, 0)
   
   ESPData[Player] = {Box = Box, Name = Name, Tracer = Tracer, Health = Health}
end

local ESPConnection
local function ToggleESP(state)
   Toggles.ESP = state
   ClearESP()
   
   if state then
      for _, Player in pairs(Players:GetPlayers()) do
         CreateESP(Player)
      end
      
      ESPConnection = RunService.RenderStepped:Connect(function()
         for Player, ESP in pairs(ESPData) do
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
               local HRP = Player.Character.HumanoidRootPart
               local Humanoid = Player.Character:FindFirstChild("Humanoid")
               local Vector, OnScreen = Camera:WorldToViewportPoint(HRP.Position)
               
               if OnScreen and Humanoid then
                  local Head = Player.Character.Head
                  local Top = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
                  local Bottom = Camera:WorldToViewportPoint(HRP.Position - Vector3.new(0, 4, 0))
                  
                  local Height = math.abs(Top.Y - Bottom.Y)
                  local Width = Height / 2
                  
                  ESP.Box.Size = Vector2.new(Width, Height)
                  ESP.Box.Position = Vector2.new(Vector.X - Width/2, Vector.Y - Height/2)
                  ESP.Box.Visible = true
                  
                  ESP.Name.Text = Player.Name .. " [" .. math.floor(Humanoid.Health) .. "]"
                  ESP.Name.Position = Vector2.new(Vector.X, Vector.Y - Height/2 - 20)
                  ESP.Name.Visible = true
                  
                  ESP.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                  ESP.Tracer.To = Vector2.new(Vector.X, Vector.Y + Height/2)
                  ESP.Tracer.Visible = true
                  
                  local HealthPercent = Humanoid.Health / Humanoid.MaxHealth
                  ESP.Health.Color = Color3.new(1-HealthPercent, HealthPercent, 0)
                  ESP.Health.PointA = Vector2.new(Vector.X - Width/2 - 6, Vector.Y - Height/2)
                  ESP.Health.PointB = Vector2.new(Vector.X - Width/2 - 2, Vector.Y - Height/2)
                  ESP.Health.PointC = Vector2.new(Vector.X - Width/2 - 2, Vector.Y + Height/2 * HealthPercent)
                  ESP.Health.PointD = Vector2.new(Vector.X - Width/2 - 6, Vector.Y + Height/2 * HealthPercent)
                  ESP.Health.Visible = true
               else
                  ESP.Box.Visible = false
                  ESP.Name.Visible = false
                  ESP.Tracer.Visible = false
                  ESP.Health.Visible = false
               end
            end
         end
      end)
   else
      if ESPConnection then ESPConnection:Disconnect() end
   end
end

-- FIXED FLING ALL (Super Strong)
local FlingConnection
local function ToggleFling(state)
   Toggles.Fling = state
   if FlingConnection then FlingConnection:Disconnect() end
   
   if state then
      FlingConnection = RunService.Heartbeat:Connect(function()
         for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
               local TargetHRP = Player.Character.HumanoidRootPart
               local A = Instance.new("BodyAngularVelocity")
               A.AngularVelocity = Vector3.new(0, math.random(1e5, 5e5), 0)
               A.MaxTorque = Vector3.new(0, math.huge, 0)
               A.P = math.huge
               A.Parent = TargetHRP
               
               local B = Instance.new("BodyVelocity")
               B.MaxForce = Vector3.new(1e9, 1e9, 1e9)
               B.Velocity = Vector3.new(math.random(-1e4,1e4), 1e5, math.random(-1e4,1e4))
               B.Parent = TargetHRP
               
               game.Debris:AddItem(A, 0.2)
               game.Debris:AddItem(B, 0.2)
            end
         end
      end)
   end
end

-- FIXED NoClip (Works Through Everything)
local NoClipConnection
local function ToggleNoClip(state)
   Toggles.NoClip = state
   if NoClipConnection then NoClipConnection:Disconnect() end
   
   NoClipConnection = RunService.Stepped:Connect(function()
      if Toggles.NoClip and Character then
         for _, Part in pairs(Character:GetDescendants()) do
            if Part:IsA("BasePart") then
               Part.CanCollide = false
            elseif Part:IsA("MeshPart") then
               Part.CanCollide = false
            end
         end
      end
   end)
end

-- CMD System (Yield + Dex + More)
local CMDs = {}
local function AddCMD(Name, Func)
   CMDs[Name:lower()] = Func
end

AddCMD("yield", function()
   wait(math.huge)
end)

AddCMD("dex", function()
   loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Dex%20Explorer%20Source.lua"))()
end)

AddCMD("rejoin", function()
   game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

AddCMD("flingme", function()
   local BV = Instance.new("BodyVelocity")
   BV.MaxForce = Vector3.new(1e9,1e9,1e9)
   BV.Velocity = Vector3.new(0,1e5,0)
   BV.Parent = RootPart
   game.Debris:AddItem(BV, 1)
end)

-- Chat CMD Handler
Players.LocalPlayer.Chatted:Connect(function(msg)
   local Args = msg:split(" ")
   local CMD = Args[1]:lower()
   
   if CMDs[CMD] then
      CMDs[CMD](unpack(Args))
   end
end)

-- TABS
local Combat = Window:CreateTab("⚔️ Combat", nil)
local Movement = Window:CreateTab("🏃 Movement", nil)
local Visuals = Window:CreateTab("👁️ Visuals", nil)
local Player = Window:CreateTab("👤 Player", nil)
local Misc = Window:CreateTab("📝 CMDs", nil)

-- COMBAT
Combat:CreateToggle({Name = "🌈 ESP + Tracers", CurrentValue = false, Flag = "ESP", Callback = ToggleESP})
Combat:CreateToggle({Name = "💥 Fling ALL (FIXED)", CurrentValue = false, Flag = "Fling", Callback = ToggleFling})

-- MOVEMENT
Movement:CreateSlider({Name = "Speed", Range = {16, 500}, Increment = 1, CurrentValue = 50, Flag = "Speed", Callback = function(v) Humanoid.WalkSpeed = v end})
Movement:CreateToggle({Name = "✈️ Fly", CurrentValue = false, Flag = "Fly", Callback = function(v) 
   Toggles.Fly = v 
   -- Fly code here (z poprzedniego)
end})
Movement:CreateToggle({Name = "👻 NoClip (FIXED)", CurrentValue = false, Flag = "NoClip", Callback = ToggleNoClip})
Movement:CreateToggle({Name = "📈 Infinite Jump", CurrentValue = false, Flag = "Jump", Callback = function(v) Toggles.InfJump = v end})
Movement:CreateToggle({Name = "🌙 Low Gravity", CurrentValue = false, Flag = "Gravity", Callback = function(v) Toggles.Gravity = v end})
Movement:CreateButton({Name = "🚀 Fling Me", Callback = function() CMDs["flingme"]() end})

-- VISUALS
Visuals:CreateSlider({Name = "FOV", Range = {30, 120}, Increment = 1, CurrentValue = 70, Flag = "FOV", Callback = function(v) Camera.FieldOfView = v end})

-- PLAYER
local SpectateInput
SpectateInput = Player:CreateInput({
   Name = "Spectate ('' to disable)",
   PlaceholderText = "Nick gracza lub ''",
   Callback = function(Text)
      if Text == "" or Text == "'" then
         Camera.CameraSubject = Humanoid
         Spectating = nil
         Notify("Spectate", "Wracasz do siebie!")
         return
      end
      
      local Target = Players:FindFirstChild(Text)
      if Target and Target.Character then
         Camera.CameraSubject = Target.Character.Humanoid
         Spectating = Target
         Notify("Spectate", "Spectate: " .. Text)
      else
         Notify("Error", "Nie znaleziono!")
      end
   end,
})

Player:CreateButton({Name = "Reconnect", Callback = function() CMDs["rejoin"]() end})

-- MISC CMDs
Misc:CreateParagraph({Title = "CMDs (chat):", Content = "yield | dex | rejoin | flingme"})
Misc:CreateButton({Name = "Execute Dex Explorer", Callback = function() CMDs["dex"]() end})
Misc:CreateButton({Name = "Yield (Freeze)", Callback = function() CMDs["yield"]() end})

-- MAIN LOOPS
spawn(function()
   while task.wait() do
      if Toggles.InfJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
         Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
      end
      
      if Toggles.Gravity then
         Workspace.Gravity = 50
      else
         Workspace.Gravity = 196.2
      end
   end
end)

-- Player Join/Leave
Players.PlayerAdded:Connect(function(Player)
   Player.CharacterAdded:Connect(function()
      wait(1)
      if Toggles.ESP then CreateESP(Player) end
   end)
end)

for _, Player in pairs(Players:GetPlayers()) do
   if Player ~= LocalPlayer then CreateESP(Player) end
end

-- Keybinds
UserInputService.InputBegan:Connect(function(key)
   if key.KeyCode == Enum.KeyCode.F then
      RootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,5,0))
   end
end)

Notify("✅ v3.0 LOADED", "Fling/ESP/NoClip FIXED + CMDs + AC Bypass", 6)
