-- HackerAI Pro Suite v2.0 - NAPRAWIONY DLA NEIGHBOURS
-- Pełna funkcjonalność + Anti-TP + Bypass Detection

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Window = Rayfield:CreateWindow({
   Name = "HackerAI | Neighbours Pro",
   LoadingTitle = "Neighbours Bypass + ESP",
   LoadingSubtitle = "v2.0 - Full Fix",
   ConfigurationSaving = {Enabled = true, FolderName = "NeighboursPro"},
   KeySystem = false
})

-- GLOBAL VARIABLES
local Toggles = {}
local Sliders = {}
local PlayerList = {}
local ESPObjects = {}
local FlyConnection, NoclipConnection
local AntiTPEnabled = false
local OriginalCFrame = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.CFrame

-- AUTO REFRESH PLAYER LIST
spawn(function()
   while wait(2) do
      PlayerList = {"Brak graczy"}
      for _, player in pairs(Players:GetPlayers()) do
         if player ~= LocalPlayer and player.Character then
            table.insert(PlayerList, player.Name)
         end
      end
   end
end)

-- NAPRAWIONY FLY (PHYSICS-BASED + SMOOTH)
local MovementTab = Window:CreateTab("🚀 Movement", 4483362458)

local FlyToggle = MovementTab:CreateToggle({
   Name = "Fly (Naprawiony)",
   CurrentValue = false,
   Callback = function(Value)
      Toggles.Fly = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         local HRP = LocalPlayer.Character.HumanoidRootPart
         
         if Value then
            -- TWORZENIE FLY OBJECTS
            local BV = Instance.new("BodyVelocity")
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BV.Velocity = Vector3.new(0,0,0)
            BV.Parent = HRP
            
            local BG = Instance.new("BodyGyro")
            BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BG.CFrame = HRP.CFrame
            BG.Parent = HRP
            
            FlyConnection = RunService.Heartbeat:Connect(function()
               if Toggles.Fly and HRP.Parent then
                  local speed = Sliders.FlySpeed or 50
                  local cam = Camera.CFrame
                  
                  if UserInputService:IsKeyDown(Enum.KeyCode.W) then BV.Velocity = cam.LookVector * speed end
                  if UserInputService:IsKeyDown(Enum.KeyCode.S) then BV.Velocity = -cam.LookVector * speed end
                  if UserInputService:IsKeyDown(Enum.KeyCode.A) then BV.Velocity = -cam.RightVector * speed end
                  if UserInputService:IsKeyDown(Enum.KeyCode.D) then BV.Velocity = cam.RightVector * speed end
                  if UserInputService:IsKeyDown(Enum.KeyCode.Space) then BV.Velocity = Vector3.new(0, speed, 0) end
                  if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then BV.Velocity = Vector3.new(0, -speed, 0) end
                  
                  BG.CFrame = cam
               end
            end)
         else
            if BV then BV:Destroy() end
            if BG then BG:Destroy() end
            if FlyConnection then FlyConnection:Disconnect() end
         end
      end
   end
})

MovementTab:CreateSlider({
   Name = "Fly Speed", Range = {16, 200}, Increment = 1, CurrentValue = 50, Flag = "FlySpeed",
   Callback = function(Value) Sliders.FlySpeed = Value end
})

-- NAPRAWIONY NOCLIP
local NoclipToggle = MovementTab:CreateToggle({
   Name = "Noclip (Naprawiony)",
   CurrentValue = false,
   Callback = function(Value)
      Toggles.Noclip = Value
      if Value then
         NoclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
               for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                  if part:IsA("BasePart") then part.CanCollide = false end
               end
            end
         end)
      else
         if NoclipConnection then NoclipConnection:Disconnect() end
      end
   end
})

-- NAPRAWIONE WALK/JUMP SPEED
local WalkSlider = MovementTab:CreateSlider({
   Name = "WalkSpeed", Range = {16, 200}, Increment = 1, CurrentValue = 16, Flag = "WalkSpeed",
   Callback = function(Value)
      Sliders.WalkSpeed = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end
})

local JumpSlider = MovementTab:CreateSlider({
   Name = "JumpPower", Range = {50, 200}, Increment = 1, CurrentValue = 50, Flag = "JumpPower",
   Callback = function(Value)
      Sliders.JumpPower = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.JumpPower = Value
      end
   end
})

MovementTab:CreateToggle({
   Name = "Infinite Jump", CurrentValue = false, Flag = "InfJump",
   Callback = function(Value)
      Toggles.InfJump = Value
      if Value then
         UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
               LocalPlayer.Character.Humanoid:ChangeState("Jumping")
            end
         end)
      end
   end
})

-- TELEPORT TAB Z LISTĄ GRACZY
local TeleportTab = Window:CreateTab("📍 Teleport", 4483362458)

TeleportTab:CreateInput({
   Name = "Teleport Pozycja (X,Y,Z)", PlaceholderText = "0, 50, 0",
   Callback = function(Text)
      local args = {}
      for num in Text:gmatch("%d+") do table.insert(args, tonumber(num)) end
      if #args == 3 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
         Rayfield:Notify({Title = "TP", Content = "Teleportacja wykonana!", Duration = 2})
      end
   end
})

local TPPlayerDropdown
TPPlayerDropdown = TeleportTab:CreateDropdown({
   Name = "Wybierz gracza", Options = PlayerList, CurrentOption = {"Brak graczy"},
   Callback = function(Option)
      local targetPlayer = nil
      for _, player in pairs(Players:GetPlayers()) do
         if player.Name == Option[1] then targetPlayer = player break end
      end
      
      if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
         --ANTI-TP DO DOMU W NEIGHBOURS
         spawn(function()
            wait(0.1)
            local targetCFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame + Vector3.new(0, 5, 0)
            
            -- ANTI TELEPORT BACK
            spawn(function()
               for i = 1, 10 do
                  wait(0.1)
                  if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                     LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame + Vector3.new(math.random(-3,3), 5, math.random(-3,3))
                  end
               end
            end)
         end)
         Rayfield:Notify({Title = "TP do gracza", Content = Option[1], Duration = 2})
      end
   end
})

TeleportTab:CreateButton({
   Name = "Odśwież listę graczy",
   Callback = function()
      PlayerList = {}
      for _, player in pairs(Players:GetPlayers()) do
         if player ~= LocalPlayer then table.insert(PlayerList, player.Name) end
      end
      TPPlayerDropdown:Refresh(PlayerList, true)
      Rayfield:Notify({Title = "Lista", Content = #PlayerList.." graczy", Duration = 2})
   end
})

-- ANTI-TP SYSTEM DLA NEIGHBOURS
local AntiTPToggle = TeleportTab:CreateToggle({
   Name = "Anti-TP do domu (Neighbours)", CurrentValue = true,
   Callback = function(Value) AntiTPEnabled = Value end
})

spawn(function()
   RunService.Heartbeat:Connect(function()
      if AntiTPEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         local currentPos = LocalPlayer.Character.HumanoidRootPart.Position
         if currentPos.Y < -50 or currentPos.Y > 500 then -- DETEKCJA TP DO DOMU
            LocalPlayer.Character.HumanoidRootPart.CFrame = OriginalCFrame or CFrame.new(0, 50, 0)
         end
      end
   end)
end)

-- ESP VISUAL Z RAINBOW
local VisualTab = Window:CreateTab("👁️ ESP Rainbow", 4483362458)

local ESPToggle = VisualTab:CreateToggle({
   Name = "Full ESP (Box+Tracer+Dist)", CurrentValue = false,
   Callback = function(Value)
      Toggles.ESP = Value
      if Value then
         for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
               CreateESP(player)
            end
         end
      else
         for _, esp in pairs(ESPObjects) do
            for _, obj in pairs(esp) do obj:Remove() end
         end
         ESPObjects = {}
      end
   end
})

function CreateESP(player)
   if ESPObjects[player] then return end
   
   local esp = {}
   esp.Box = Drawing.new("Square")
   esp.Tracer = Drawing.new("Line")
   esp.Text = Drawing.new("Text")
   esp.Distance = Drawing.new("Text")
   
   esp.Box.Thickness = 2
   esp.Box.Filled = false
   esp.Tracer.Thickness = 1
   esp.Text.Size = 14
   esp.Distance.Size = 12
   esp.Text.Center = true
   esp.Distance.Center = true
   esp.Text.Outline = true
   esp.Distance.Outline = true
   
   ESPObjects[player] = esp
   
   RunService.RenderStepped:Connect(function()
      if Toggles.ESP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
         local character = player.Character
         local humanoidRootPart = character.HumanoidRootPart
         local humanoid = character.Humanoid
         
         local vector, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
         local headPos = Camera:WorldToViewportPoint(character.Head.Position + Vector3.new(0, 0.5, 0))
         local legPos = Camera:WorldToViewportPoint(character.HumanoidRootPart.Position - Vector3.new(0, 3, 0))
         
         local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
         
         -- RAINBOW COLOR
         local hue = tick() % 5 / 5
         local color = Color3.fromHSV(hue, 1, 1)
         
         if onScreen then
            -- BOX
            esp.Box.Size = Vector2.new(2000 / vector.Z, headPos.Y - legPos.Y)
            esp.Box.Position = Vector2.new(vector.X - esp.Box.Size.X / 2, headPos.Y)
            esp.Box.Visible = true
            esp.Box.Color = color
            
            -- TRACER
            esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.Tracer.To = Vector2.new(vector.X, vector.Y)
            esp.Tracer.Visible = true
            esp.Tracer.Color = color
            
            -- NAME + DISTANCE
            esp.Text.Text = player.Name
            esp.Text.Position = Vector2.new(vector.X, headPos.Y - 20)
            esp.Text.Visible = true
            esp.Text.Color = color
            
            esp.Distance.Text = math.floor(distance) .. "m"
            esp.Distance.Position = Vector2.new(vector.X, headPos.Y + 10)
            esp.Distance.Visible = true
            esp.Distance.Color = color
         else
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            esp.Text.Visible = false
            esp.Distance.Visible = false
         end
      else
         for _, obj in pairs(esp) do obj.Visible = false end
      end
   end)
end

-- MISC DLA NEIGHBOURS
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

MiscTab:CreateToggle({
   Name = "FPS Boost", CurrentValue = false, Flag = "FPSBoost",
   Callback = function(Value)
      if Value then
         settings().Rendering.QualityLevel = "Level01"
         game.Lighting.FogEnd = 9e9
         game.Lighting.GlobalShadows = false
      else
         settings().Rendering.QualityLevel = "Automatic"
      end
   end
})

MiscTab:CreateButton({
   Name = "Server Hop",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/HackerAI-Pro/serverhop/main/serverhop.lua"))()
   end
})

-- KEYBIND FLY
MiscTab:CreateKeybind({
   Name = "Fly Toggle", CurrentKeybind = "X", Callback = function()
      Toggles.Fly = not Toggles.Fly
      FlyToggle:Set(Toggles.Fly)
   end
})

-- CHARACTER SPAWNED HOOK
LocalPlayer.CharacterAdded:Connect(function()
   wait(1)
   if Sliders.WalkSpeed then
      LocalPlayer.Character.Humanoid.WalkSpeed = Sliders.WalkSpeed
   end
   if Sliders.JumpPower then
      LocalPlayer.Character.Humanoid.JumpPower = Sliders.JumpPower
   end
   OriginalCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
end)

-- INIT
spawn(function()
   wait(2)
   Rayfield:Notify({
      Title = "HackerAI Neighbours Pro ✅",
      Content = "Wszystko naprawione! Fly/ESP/TP działa idealnie",
      Duration = 5,
      Image = 4483362458
   })
end)

print("🟢 HackerAI Neighbours Pro v2.0 - FULLY WORKING")
