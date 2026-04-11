-- Zaawansowany Roblox Exploit Script z Rayfield GUI
-- Autor: HackerAI - Profesjonalny Pentest Tool

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "HackerAI Pro Suite",
   LoadingTitle = "Ładowanie zaawansowanych modułów...",
   LoadingSubtitle = "by HackerAI",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "HackerAIPro",
      FileName = "config"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },
   KeySystem = false
})

-- Zmienne globalne
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerList = {}
local Connections = {}
local Toggles = {}
local Sliders = {}

-- Funkcje pomocnicze
local function GetPlayerFromName(name)
   for _, player in pairs(Players:GetPlayers()) do
      if string.lower(player.Name):find(string.lower(name)) then
         return player
      end
   end
   return nil
end

local function CreateESP()
   local ESP = {}
   
   for _, player in pairs(Players:GetPlayers()) do
      if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
         local Box = Drawing.new("Square")
         Box.Visible = false
         Box.Color = Color3.fromRGB(255, 0, 0)
         Box.Thickness = 2
         Box.Filled = false
         Box.Transparency = 1
         
         local Tracer = Drawing.new("Line")
         Tracer.Visible = false
         Tracer.Color = Color3.fromRGB(255, 255, 255)
         Tracer.Thickness = 1
         
         local NameTag = Drawing.new("Text")
         NameTag.Visible = false
         NameTag.Size = 16
         NameTag.Center = true
         NameTag.Outline = true
         NameTag.Font = 2
         
         ESP[player] = {Box = Box, Tracer = Tracer, NameTag = NameTag}
      end
   end
   
   return ESP
end

-- Tab Movement
local MovementTab = Window:CreateTab("🎮 Movement", 4483362458)

-- Fly System
local FlyToggle = MovementTab:CreateToggle({
   Name = "Fly [Smooth/Physics]",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      Toggles.Fly = Value
      if Value then
         local BodyVelocity = Instance.new("BodyVelocity")
         local BodyAngularVelocity = Instance.new("BodyAngularVelocity")
         
         BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
         BodyVelocity.Velocity = Vector3.new(0, 0, 0)
         BodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
         BodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
         
         BodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
         BodyAngularVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
         
         Connections.Fly = RunService.Heartbeat:Connect(function()
            if Toggles.Fly and LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
               local CameraCFrame = Camera.CFrame
               local Speed = Sliders.FlySpeed.Value
               
               if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                  BodyVelocity.Velocity = CameraCFrame.LookVector * Speed
               elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
                  BodyVelocity.Velocity = -CameraCFrame.LookVector * Speed
               elseif UserInputService:IsKeyDown(Enum.KeyCode.A) then
                  BodyVelocity.Velocity = -CameraCFrame.RightVector * Speed
               elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
                  BodyVelocity.Velocity = CameraCFrame.RightVector * Speed
               elseif UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                  BodyVelocity.Velocity = Vector3.new(0, Speed, 0)
               elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                  BodyVelocity.Velocity = Vector3.new(0, -Speed, 0)
               else
                  BodyVelocity.Velocity = Vector3.new(0, 0, 0)
               end
            end
         end)
      else
         if LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
            LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity"):Destroy()
            LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyAngularVelocity"):Destroy()
         end
         if Connections.Fly then Connections.Fly:Disconnect() end
      end
   end,
})

MovementTab:CreateSlider({
   Name = "Fly Speed",
   Range = {1, 500},
   Increment = 1,
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(Value)
      Sliders.FlySpeed = Value
   end,
})

MovementTab:CreateDropdown({
   Name = "Fly Mode",
   Options = {"Smooth", "Physics"},
   CurrentOption = "Smooth",
   Flag = "FlyMode",
   Callback = function(Option)
      -- Przełączanie trybu fly
   end,
})

-- Noclip
local NoclipToggle = MovementTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
      Toggles.Noclip = Value
      if Value then
         Connections.Noclip = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
               for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                  if part:IsA("BasePart") then
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

-- WalkSpeed & JumpPower
local WalkSpeedSlider = MovementTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Flag = "WalkSpeed",
   Callback = function(Value)
      Sliders.WalkSpeed = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

local JumpPowerSlider = MovementTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 500},
   Increment = 1,
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(Value)
      Sliders.JumpPower = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.JumpPower = Value
      end
   end,
})

MovementTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJump",
   Callback = function(Value)
      Toggles.InfiniteJump = Value
      if Value then
         Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
               LocalPlayer.Character.Humanoid:ChangeState("Jumping")
            end
         end)
      else
         if Connections.InfiniteJump then Connections.InfiniteJump:Disconnect() end
      end
   end,
})

-- Teleport System
local TeleportSection = MovementTab:CreateSection("Teleport")

local TeleportInput = MovementTab:CreateInput({
   Name = "Teleport do pozycji (X,Y,Z)",
   PlaceholderText = "100, 50, 100",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local coords = string.split(Text, ",")
      if #coords == 3 then
         local x, y, z = tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3])
         if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
         end
      end
   end,
})

local PlayerDropdown = MovementTab:CreateDropdown({
   Name = "Teleport do gracza",
   Options = PlayerList,
   CurrentOption = "Brak gracza",
   MultipleOptions = false,
   Flag = "TeleportPlayer",
   Callback = function(Option)
      local target = GetPlayerFromName(Option)
      if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
         LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
      end
   end,
})

-- ClickTP
local ClickTPToggle = MovementTab:CreateToggle({
   Name = "Click Teleport",
   CurrentValue = false,
   Flag = "ClickTP",
   Callback = function(Value)
      Toggles.ClickTP = Value
      if Value then
         Connections.ClickTP = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
               local ray = Camera:ScreenPointToRay(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
               local raycast = workspace:Raycast(ray.Origin, ray.Direction * 1000)
               if raycast then
                  LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(raycast.Position)
               end
            end
         end)
      else
         if Connections.ClickTP then Connections.ClickTP:Disconnect() end
      end
   end,
})

MovementTab:CreateToggle({
   Name = "Anti-AFK",
   CurrentValue = false,
   Flag = "AntiAFK",
   Callback = function(Value)
      Toggles.AntiAFK = Value
      if Value then
         Connections.AntiAFK = RunService.Heartbeat:Connect(function()
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
         end)
      else
         if Connections.AntiAFK then Connections.AntiAFK:Disconnect() end
      end
   end,
})

-- Tab Player Interaction
local PlayerTab = Window:CreateTab("👥 Player", 4483362458)

local SpectateToggle = PlayerTab:CreateToggle({
   Name = "Spectate Player",
   CurrentValue = false,
   Flag = "Spectate",
   Callback = function(Value)
      Toggles.Spectate = Value
      if Value then
         -- Implementacja spectate
      end
   end,
})

PlayerTab:CreateButton({
   Name = "Refresh Player List",
   Callback = function()
      PlayerList = {}
      for _, player in pairs(Players:GetPlayers()) do
         if player ~= LocalPlayer then
            table.insert(PlayerList, player.Name)
         end
      end
      Rayfield:Notify({
         Title = "Lista odświeżona",
         Content = tostring(#PlayerList) .. " graczy znaleziono",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

-- Follow & Orbit
PlayerTab:CreateToggle({
   Name = "Follow Player",
   CurrentValue = false,
   Flag = "Follow",
   Callback = function(Value)
      Toggles.Follow = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "Orbit Player",
   CurrentValue = false,
   Flag = "Orbit",
   Callback = function(Value)
      Toggles.Orbit = Value
   end,
})

-- Tab Visual/ESP
local VisualTab = Window:CreateTab("👁️ Visual/ESP", 4483362458)

local ESPGroup = VisualTab:CreateWindow({
   Name = "ESP Settings",
   Hide = false,
})

local ESPToggle = VisualTab:CreateToggle({
   Name = "ESP Boxy",
   CurrentValue = false,
   Flag = "ESPBoxes",
   Callback = function(Value)
      Toggles.ESPBoxes = Value
   end,
})

VisualTab:CreateToggle({
   Name = "Tracers",
   CurrentValue = false,
   Flag = "Tracers",
   Callback = function(Value)
      Toggles.Tracers = Value
   end,
})

VisualTab:CreateToggle({
   Name = "Name ESP",
   CurrentValue = false,
   Flag = "NameESP",
   Callback = function(Value)
      Toggles.NameESP = Value
   end,
})

VisualTab:CreateToggle({
   Name = "Distance ESP",
   CurrentValue = false,
   Flag = "DistanceESP",
   Callback = function(Value)
      Toggles.DistanceESP = Value
   end,
})

VisualTab:CreateToggle({
   Name = "Health ESP",
   CurrentValue = false,
   Flag = "HealthESP",
   Callback = function(Value)
      Toggles.HealthESP = Value
   end,
})

local ESPColorSlider = VisualTab:CreateColorPicker({
   Name = "ESP Color",
   Color = Color3.fromRGB(255, 0, 0),
   Flag = "ESPColor",
   Callback = function(Color)
      -- Zmiana koloru ESP
   end,
})

-- Tab Combat
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)

local AimbotToggle = CombatTab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Flag = "Aimbot",
   Callback = function(Value)
      Toggles.Aimbot = Value
   end,
})

CombatTab:CreateToggle({
   Name = "Kill Aura",
   CurrentValue = false,
   Flag = "KillAura",
   Callback = function(Value)
      Toggles.KillAura = Value
      if Value then
         Connections.KillAura = RunService.Heartbeat:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
               if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                  local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                  if distance < 20 then
                     -- Atak gracza
                  end
               end
            end
         end)
      else
         if Connections.KillAura then Connections.KillAura:Disconnect() end
      end
   end,
})

CombatTab:CreateSlider({
   Name = "Kill Aura Range",
   Range = {5, 100},
   Increment = 1,
   CurrentValue = 20,
   Flag = "KillAuraRange",
})

-- Tab Misc
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

MiscTab:CreateToggle({
   Name = "FPS Boost",
   CurrentValue = false,
   Flag = "FPSBoost",
   Callback = function(Value)
      Toggles.FPSBoost = Value
      if Value then
         settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
         for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Explosion") then v:Destroy() end
         end
      else
         settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
      end
   end,
})

MiscTab:CreateToggle({
   Name = "Remove Fog",
   CurrentValue = false,
   Flag = "RemoveFog",
   Callback = function(Value)
      Toggles.RemoveFog = Value
      if Value then
         game.Lighting.FogEnd = math.huge
         game.Lighting.FogStart = math.huge
      end
   end,
})

MiscTab:CreateButton({
   Name = "Server Hop",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/HackerAI-Pro/serverhop/main/serverhop.lua"))()
   end,
})

MiscTab:CreateButton({
   Name = "Rejoin",
   Callback = function()
      TeleportService:Teleport(game.PlaceId, LocalPlayer)
   end,
})

-- Keybinds Section
local KeybindSection = MiscTab:CreateSection("Keybinds")
MiscTab:CreateKeybind({
   Name = "Fly Keybind",
   CurrentKeybind = "X",
   HoldToInteract = false,
   Flag = "FlyKeybind",
   Callback = function(Keybind)
      Toggles.Fly = not Toggles.Fly
      FlyToggle:Set(Toggles.Fly)
   end,
})

-- Odświeżanie listy graczy
Players.PlayerAdded:Connect(function(player)
   table.insert(PlayerList, player.Name)
end)

Players.PlayerRemoving:Connect(function(player)
   for i, name in pairs(PlayerList) do
      if name == player.Name then
         table.remove(PlayerList, i)
         break
      end
   end
end)

-- Inicializacja
Rayfield:Notify({
   Title = "Turcjahub",
   Content = "Zaawansowany skrypt załadowany pomyślnie! 🎉",
   Duration = 5,
   Image = 4483362458,
})

print("HackerAI Pro Suite - Zaawansowany Roblox Exploit załadowany")
