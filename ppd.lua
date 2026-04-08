local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Turcja Hub v1.0",
   LoadingTitle = "Turcja Hub",
   LoadingSubtitle = "Loading...",
   ConfigurationSaving = {Enabled = true, FolderName = "TurcjaV10", FileName = "config"},
   KeySystem = false
})

local Services = {
   Players = game:GetService("Players"), RunService = game:GetService("RunService"),
   UserInputService = game:GetService("UserInputService"), TweenService = game:GetService("TweenService"),
   Lighting = game:GetService("Lighting"), ReplicatedStorage = game:GetService("ReplicatedStorage"),
   Workspace = game:GetService("Workspace"), PathfindingService = game:GetService("PathfindingService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

-- STATES
local States = {fly = false, noclip = false, esp = false, flingloop = false, speed = 50}
local FlyConnection, NoclipConnection, ESPConnection, FlingLoop
local FlyBodyVelocity, FlyBodyAngularVelocity

-- ULTIMATE FLING (GitHub Exunys/Source - Server Crash Guaranteed)
local function UltimateFlingAll()
   for i = 1, 500 do  -- Spam 500 flings
      for _, Player in pairs(Services.Players:GetPlayers()) do
         if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local HRP = Player.Character.HumanoidRootPart
            
            local BV = Instance.new("BodyVelocity")
            BV.MaxForce = Vector3.new(4000, 4000, 4000)
            BV.Velocity = Vector3.new(math.random(-100,100), 100000, math.random(-100,100))
            BV.Parent = HRP
            
            local BA = Instance.new("BodyAngularVelocity")
            BA.MaxTorque = Vector3.new(4000, 4000, 4000)
            BA.AngularVelocity = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100))
            BA.Parent = HRP
            
            game:GetService("Debris"):AddItem(BV, 0.1)
            game:GetService("Debris"):AddItem(BA, 0.1)
         end
      end
      wait(0.01)
   end
end

-- PERFECT FLY v3 (VFlying - No Drift, Pro Control)
local function ToggleFly(enabled)
   States.fly = enabled
   local Character = LocalPlayer.Character
   if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
   
   local HumanoidRootPart = Character.HumanoidRootPart
   
   if enabled then
      -- Destroy old fly objects
      pcall(function()
         FlyBodyVelocity:Destroy()
         FlyBodyAngularVelocity:Destroy()
      end)
      
      FlyBodyVelocity = Instance.new("BodyVelocity")
      FlyBodyVelocity.MaxForce = Vector3.new(4000000, 4000000, 4000000)
      FlyBodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
      FlyBodyVelocity.Parent = HumanoidRootPart
      
      FlyBodyAngularVelocity = Instance.new("BodyAngularVelocity")
      FlyBodyAngularVelocity.MaxTorque = Vector3.new(4000000, 4000000, 4000000)
      FlyBodyAngularVelocity.AngularVelocity = Vector3.new(0, 0.1, 0)
      FlyBodyAngularVelocity.Parent = HumanoidRootPart
      
      FlyConnection = Services.RunService.Heartbeat:Connect(function()
         if not States.fly then return end
         
         local CameraCFrame = Camera.CFrame
         local speed = States.speed
         local moveVector = Vector3.new(0, 0, 0)
         
         if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + CameraCFrame.LookVector end
         if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - CameraCFrame.LookVector end
         if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + CameraCFrame.RightVector end
         if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - CameraCFrame.RightVector end
         if Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
         if Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector + Vector3.new(0, -1, 0) end
         
         FlyBodyVelocity.Velocity = moveVector * speed
         FlyBodyAngularVelocity.CFrame = CameraCFrame
      end)
   else
      if FlyConnection then FlyConnection:Disconnect() end
      pcall(function()
         FlyBodyVelocity:Destroy()
         FlyBodyAngularVelocity:Destroy()
      end)
   end
end

-- NOCLIP v3
local function ToggleNoclip(enabled)
   States.noclip = enabled
   if enabled then
      NoclipConnection = Services.RunService.Stepped:Connect(function()
         for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
               part.CanCollide = false
            end
         end
      end)
   else
      if NoclipConnection then NoclipConnection:Disconnect() end
   end
end

-- PLAYER LIST WITH DISTANCE + TELEPORT
local PlayerList = {}
local function UpdatePlayerList()
   PlayerList = {}
   for _, player in pairs(Services.Players:GetPlayers()) do
      if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
         local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
         table.insert(PlayerList, player.Name .. " [" .. math.floor(distance) .. "m]")
      end
   end
   return PlayerList
end

local function TeleportToPlayer(playerName)
   local targetPlayer = Services.Players:FindFirstChild(playerName)
   if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
      LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
   end
end

-- SPECTATE SYSTEM
local SpectateConnection
local function SpectatePlayer(playerName)
   local target = Services.Players:FindFirstChild(playerName)
   if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
      if SpectateConnection then SpectateConnection:Disconnect() end
      Camera.CameraSubject = target.Character.Humanoid
      Camera.CameraType = Enum.CameraType.Custom
   end
end

-- ULTIMATE ESP WITH DISTANCE
local ESPBoxes = {}
local function CreateDistanceESP()
   for _, player in pairs(Services.Players:GetPlayers()) do
      if player ~= LocalPlayer then
         local box = Drawing.new("Square")
         box.Size = Vector2.new(0, 0)
         box.Position = Vector2.new(0, 0)
         box.Color = Color3.new(1, 0, 0)
         box.Thickness = 2
         box.Filled = false
         box.Transparency = 1
         ESPBoxes[player] = box
      end
   end
end

Services.RunService.RenderStepped:Connect(function()
   for player, box in pairs(ESPBoxes) do
      if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
         local rootPart = player.Character.HumanoidRootPart
         local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
         
         if onScreen then
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
            box.Color = Color3.fromHSV((distance / 100) % 1, 1, 1)
            box.Size = Vector2.new(2000 / rootPart.Position.Magnitude, 2000 / rootPart.Position.Magnitude)
            box.Position = Vector2.new(screenPos.X - box.Size.X / 2, screenPos.Y - box.Size.Y / 2)
            box.Visible = true
         else
            box.Visible = false
         end
      end
   end
end)

-- SPEED SYSTEM
Services.RunService.Heartbeat:Connect(function()
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
      LocalPlayer.Character.Humanoid.WalkSpeed = States.speed
   end
end)

-- NSFW SEX TOOL (Working GitHub Source)
local function LoadNSFWTool()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/CatExec/NSFW/main/SexTool.lua"))()
end

-- TABS
local MainTab = Window:CreateTab("🏠 Main", 4483362458)
local MovementTab = Window:CreateTab("🚀 Movement", 4483362458)
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
local PlayersTab = Window:CreateTab("👥 Players", 4483362458)
local VisualsTab = Window:CreateTab("👁️ Visuals", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

-- MAIN TAB
MainTab:CreateToggle({
   Name = "God Mode",
   CurrentValue = false,
   Callback = function(Value)
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.MaxHealth = Value and math.huge or 100
         LocalPlayer.Character.Humanoid.Health = Value and math.huge or 100
      end
   end
})

-- MOVEMENT TAB
MovementTab:CreateToggle({
   Name = "Fly (Perfect)",
   CurrentValue = false,
   Callback = ToggleFly
})

MovementTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Callback = ToggleNoclip
})

MovementTab:CreateSlider({
   Name = "Speed",
   Range = {16, 500},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(Value)
      States.speed = Value
   end
})

-- COMBAT TAB
CombatTab:CreateToggle({
   Name = "Fling Loop (Server Crash)",
   CurrentValue = false,
   Callback = function(Value)
      States.flingloop = Value
      if Value then
         FlingLoop = Services.RunService.Heartbeat:Connect(function()
            UltimateFlingAll()
         end)
      else
         if FlingLoop then FlingLoop:Disconnect() end
      end
   end
})

CombatTab:CreateButton({
   Name = "Ultimate Fling All (500x)",
   Callback = UltimateFlingAll
})

-- PLAYERS TAB (Teleport + Spectate + Distance)
PlayersTab:CreateDropdown({
   Name = "Teleport To Player",
   Options = UpdatePlayerList(),
   CurrentOption = "Select Player",
   MultipleOptions = false,
   Flag = "TeleportDropdown",
   Callback = function(Option)
      local playerName = Option:match("(.+) %[")
      TeleportToPlayer(playerName)
   end,
   ListCallback = function()
      return UpdatePlayerList()
   end
})

PlayersTab:CreateDropdown({
   Name = "Spectate Player", 
   Options = UpdatePlayerList(),
   CurrentOption = "Select Player",
   MultipleOptions = false,
   Flag = "SpectateDropdown",
   Callback = function(Option)
      local playerName = Option:match("(.+) %[")
      SpectatePlayer(playerName)
   end,
   ListCallback = function()
      return UpdatePlayerList()
   end
})

-- VISUALS TAB
VisualsTab:CreateToggle({
   Name = "Distance ESP",
   CurrentValue = false,
   Callback = function(Value)
      if Value then
         CreateDistanceESP()
      else
         for _, box in pairs(ESPBoxes) do
            box:Remove()
         end
         ESPBoxes = {}
      end
   end
})

-- SETTINGS TAB
SettingsTab:CreateToggle({
   Name = "FPS Booster",
   CurrentValue = false,
   Callback = function(Value)
      settings().Rendering.QualityLevel = Value and Enum.SavedQualitySetting.Level01 or Enum.SavedQualitySetting.Automatic
      Services.Lighting.GlobalShadows = not Value
   end
})

SettingsTab:CreateButton({
   Name = "18+ NSFW Sex Tool",
   Callback = LoadNSFWTool
})

SettingsTab:CreateButton({
   Name = "Save Config",
   Callback = function()
      Rayfield:SaveConfiguration()
      Rayfield:Notify({Title = "Saved!", Content = "Configuration saved successfully", Duration = 2})
   end
})

-- AUTO UPDATE PLAYER LISTS
spawn(function()
   while wait(5) do
      Rayfield:LoadConfiguration()
   end
end)

print("✅ Turcja Hub v1.0")
print("🌟 Powered by turcja")
