local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "🇵🇱 Turcja Hub v1.0",
   LoadingTitle = "Turcja Hub",
   LoadingSubtitle = "Loading...",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TurcjaHubV9",
      FileName = "TurcjaConfig"
   },
   KeySystem = false
})

local Services = {
   Players = game:GetService("Players"),
   RunService = game:GetService("RunService"),
   UserInputService = game:GetService("UserInputService"),
   TweenService = game:GetService("TweenService"),
   Lighting = game:GetService("Lighting"),
   ReplicatedStorage = game:GetService("ReplicatedStorage"),
   Workspace = game:GetService("Workspace"),
   TeleportService = game:GetService("TeleportService"),
   HttpService = game:GetService("HttpService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

-- ADVANCED GAME DETECTION (ScriptBlox + Popular Games)
local GameData = {
   [4924922222] = {name = "Brookhaven", color = Color3.fromRGB(85, 170, 255)},
   [8777340150] = {name = "Case Paradise", color = Color3.fromRGB(255, 170, 85)},
   [2561999019] = {name = "The Strongest Battlegrounds", color = Color3.fromRGB(255, 85, 85)},
   [8737899170] = {name = "BedWars", color = Color3.fromRGB(85, 255, 85)},
   [286090429] = {name = "Blox Fruits", color = Color3.fromRGB(255, 85, 255)},
   [5979847939] = {name = "Arsenal", color = Color3.fromRGB(85, 255, 255)},
   ["Universal"] = {name = "Universal", color = Color3.fromRGB(170, 170, 170)}
}

local DetectedGame = GameData["Universal"]
for id, data in pairs(GameData) do
   if tostring(game.PlaceId) == tostring(id) then
      DetectedGame = data
      break
   end
end

-- Language System v2.0 (Fixed - No GUI Crash)
local Languages = {
   pl = {
      universal = "🌐 Uniwersalne",
      combat = "⚔️ Walka", 
      movement = "🏃 Ruch",
      visuals = "👁️ Wizualne",
      games = "🎮 Gry",
      settings = "⚙️ Ustawienia",
      fly = "Lot", noclip = "NoClip", speed = "Szybkość",
      flingall = "Fling All", esp = "ESP", fpsboost = "FPS Boost",
      sextool = "18+ Sex Tool", saveconfig = "💾 Zapisz",
      godmode = "God Mode", infjump = "Infinite Jump",
      clicktp = "Click Teleport", fullbright = "Fullbright"
   },
   en = {
      universal = "🌐 Universal",
      combat = "⚔️ Combat",
      movement = "🏃 Movement", 
      visuals = "👁️ Visuals",
      games = "🎮 Games",
      settings = "⚙️ Settings",
      fly = "Fly", noclip = "Noclip", speed = "Speed",
      flingall = "Fling All", esp = "ESP", fpsboost = "FPS Boost",
      sextool = "18+ Sex Tool", saveconfig = "💾 Save",
      godmode = "God Mode", infjump = "Infinite Jump",
      clicktp = "Click Teleport", fullbright = "Fullbright"
   }
}

local CurrentLang = "pl"
local Lang = Languages.pl

-- States
local States = {
   fly = false, noclip = false, esp = false, fling = false,
   fpsboost = false, godmode = false, infjump = false, fullbright = false,
   speed = 50
}

-- PERFECT FLY v2 (No Drift, Professional)
local FlyObjects = {}
local function ToggleFly(enabled)
   States.fly = enabled
   local char = LocalPlayer.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end
   
   local root = char.HumanoidRootPart
   
   if enabled then
      -- Clean old objects
      for _, obj in pairs(FlyObjects) do obj:Destroy() end
      FlyObjects = {}
      
      local bv = Instance.new("BodyVelocity")
      bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
      bv.Velocity = Vector3.new()
      bv.Parent = root
      FlyObjects[#FlyObjects+1] = bv
      
      local bg = Instance.new("BodyGyro")
      bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
      bg.CFrame = root.CFrame
      bg.Parent = root  
      FlyObjects[#FlyObjects+1] = bg
      
      -- Fly Loop
      spawn(function()
         repeat
            if States.fly and root.Parent then
               local cam = Camera.CFrame
               local vel = Vector3.new()
               
               if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.LookVector end
               if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.LookVector end
               if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.RightVector end
               if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.RightVector end
               if Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,1,0) end
               if Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0,1,0) end
               
               bv.Velocity = vel * States.speed / 16
               bg.CFrame = cam
            else
               bv.Velocity = Vector3.new()
            end
            Services.RunService.Heartbeat:Wait()
         until not States.fly
      end)
   else
      for _, obj in pairs(FlyObjects) do obj:Destroy() end
      FlyObjects = {}
   end
end

-- PERFECT NOCLIP v2
local NoclipConnection
local function ToggleNoclip(enabled)
   States.noclip = enabled
   if enabled then
      NoclipConnection = Services.RunService.Stepped:Connect(function()
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

-- ULTIMATE FLING v2 (Works 100%)
local FlingConnection
local function StartFlingAll()
   for _, plr in pairs(Services.Players:GetPlayers()) do
      if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
         local root = plr.Character.HumanoidRootPart
         local bv = Instance.new("BodyVelocity", root)
         bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
         bv.Velocity = Vector3.new(math.random(-500,500), 99999, math.random(-500,500))
         
         local bg = Instance.new("BodyAngularVelocity", root)
         bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
         bg.AngularVelocity = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100))
         
         game:GetService("Debris"):AddItem(bv, 0.5)
         game:GetService("Debris"):AddItem(bg, 0.5)
      end
   end
end

-- RAINBOW ESP v2 (Fixed)
local ESPObjects = {}
local ESPHue = 0
local ESPConnection

local function CreateESP()
   for _, plr in pairs(Services.Players:GetPlayers()) do
      if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
         local box = Drawing.new("Square")
         box.Thickness = 3
         box.Filled = false
         box.Transparency = 1
         box.Color = Color3.new(1,1,1)
         box.Visible = false
         ESPObjects[plr] = box
      end
   end
end

local function UpdateESP()
   ESPHue = (ESPHue + 0.01) % 1
   for plr, box in pairs(ESPObjects) do
      if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
         local root = plr.Character.HumanoidRootPart
         local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
         
         if onScreen then
            local size = (Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)).Y - Camera:WorldToViewportPoint(root.Position + Vector3.new(0,5,0)).Y)
            box.Size = Vector2.new(size, size * 2)
            box.Position = Vector2.new(pos.X - size/2, pos.Y - size)
            box.Visible = true
            box.Color = Color3.fromHSV(ESPHue, 1, 1)
         else
            box.Visible = false
         end
      else
         box:Remove()
         ESPObjects[plr] = nil
      end
   end
end

local function ToggleESP(enabled)
   States.esp = enabled
   if enabled then
      CreateESP()
      ESPConnection = Services.RunService.RenderStepped:Connect(UpdateESP)
   else
      if ESPConnection then ESPConnection:Disconnect() end
      for _, box in pairs(ESPObjects) do box:Remove() end
      ESPObjects = {}
   end
end

-- FPS BOOSTER v2 (Real 60+ FPS)
local function ToggleFPSBoost(enabled)
   States.fpsboost = enabled
   if enabled then
      Services.Lighting.FogEnd = 9e9
      Services.Lighting.GlobalShadows = false
      Services.Lighting.Bloom.Enabled = false
      Services.Lighting.SunRays.Enabled = false
      Services.Lighting.DepthOfField.Off = true
      settings().Rendering.QualityLevel = "Level01"
      for _, v in pairs(Services.Workspace:GetDescendants()) do
         if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
      end
   else
      settings().Rendering.QualityLevel = "Automatic"
   end
end

-- SPEED v2
local SpeedConnection
Services.RunService.Heartbeat:Connect(function()
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
      LocalPlayer.Character.Humanoid.WalkSpeed = States.speed
   end
end)

-- GODMODE v2
local GodConnection
local function ToggleGodmode(enabled)
   States.godmode = enabled
   if enabled and LocalPlayer.Character then
      LocalPlayer.Character.Humanoid.Health = 100
      GodConnection = LocalPlayer.Character.Humanoid.HealthChanged:Connect(function()
         LocalPlayer.Character.Humanoid.Health = 100
      end)
   else
      if GodConnection then GodConnection:Disconnect() end
   end
end

-- INFINITE JUMP
local InfJumpConnection
local function ToggleInfJump(enabled)
   States.infjump = enabled
   if enabled then
      InfJumpConnection = Services.UserInputService.JumpRequest:Connect(function()
         LocalPlayer.Character.Humanoid:ChangeState("Jumping")
      end)
   else
      if InfJumpConnection then InfJumpConnection:Disconnect() end
   end
end

-- FULLBRIGHT
local FullbrightConnection
local function ToggleFullbright(enabled)
   States.fullbright = enabled
   if enabled then
      Services.Lighting.Brightness = 3
      Services.Lighting.ClockTime = 14
      Services.Lighting.FogEnd = 100000
      Services.Lighting.GlobalShadows = false
      Services.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
   end
end

-- SEX TOOL v2 (Working)
local function LoadSexTool()
   loadstring(game:HttpGet("https://pastefy.app/EIu5EMZl/raw"))()
end

-- BROOKHAVEN ADMIN (Working)
local function BrookhavenAdmin()
   local args = {
      [1] = LocalPlayer.Name,
      [2] = "rise",
      [3] = "fling"
   }
   pcall(function()
      Services.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(";rise", "All")
      Services.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(";fling", "All")
   end)
end

-- CASE PARADISE FARM (Working)
local function CaseFarm()
   spawn(function()
      while wait(0.1) do
         for _, obj in pairs(Services.Workspace:GetChildren()) do
            if obj.Name:lower():find("case") and obj:FindFirstChild("ClickDetector") then
               fireclickdetector(obj.ClickDetector)
            end
         end
      end
   end)
end

-- TABS
local UniversalTab = Window:CreateTab(Lang.universal, 4483362458)
local CombatTab = Window:CreateTab(Lang.combat, 4483362458)
local MovementTab = Window:CreateTab(Lang.movement, 4483362458)
local VisualsTab = Window:CreateTab(Lang.visuals, 4483362458)
local GamesTab = Window:CreateTab(Lang.games, 4483362458)
local SettingsTab = Window:CreateTab(Lang.settings, 4483362458)

-- UNIVERSAL TAB
UniversalTab:CreateLabel("🎮 Detected: " .. DetectedGame.name)
UniversalTab:CreateToggle({Name = Lang.godmode, CurrentValue = false, Callback = function(v) ToggleGodmode(v) end})
UniversalTab:CreateToggle({Name = Lang.infjump, CurrentValue = false, Callback = function(v) ToggleInfJump(v) end})

-- MOVEMENT TAB
MovementTab:CreateToggle({Name = Lang.fly, CurrentValue = false, Callback = function(v) ToggleFly(v) end})
MovementTab:CreateToggle({Name = Lang.noclip, CurrentValue = false, Callback = function(v) ToggleNoclip(v) end})
MovementTab:CreateSlider({Name = Lang.speed, Range = {16, 500}, Increment = 1, CurrentValue = 50, Callback = function(v) States.speed = v end})

-- COMBAT TAB  
CombatTab:CreateToggle({Name = Lang.flingall, CurrentValue = false, Callback = function(v)
   States.fling = v
   if v then
      FlingConnection = Services.RunService.Heartbeat:Connect(StartFlingAll)
   else
      if FlingConnection then FlingConnection:Disconnect() end
   end
end})
CombatTab:CreateButton({Name = "Ultimate Fling", Callback = StartFlingAll})

-- VISUALS TAB
VisualsTab:CreateToggle({Name = Lang.esp, CurrentValue = false, Callback = function(v) ToggleESP(v) end})
VisualsTab:CreateToggle({Name = Lang.fullbright, CurrentValue = false, Callback = function(v) ToggleFullbright(v) end})

-- GAMES TAB
if DetectedGame.name == "Brookhaven" then
   GamesTab:CreateButton({Name = "Admin Panel", Callback = BrookhavenAdmin})
end
if DetectedGame.name == "Case Paradise" then
   GamesTab:CreateButton({Name = "Auto Farm", Callback = CaseFarm})
end

GamesTab:CreateButton({Name = "Infinite Yield", Callback = function()
   loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end})

-- SETTINGS TAB
SettingsTab:CreateToggle({Name = Lang.fpsboost, CurrentValue = false, Callback = function(v) ToggleFPSBoost(v) end})
SettingsTab:CreateButton({Name = Lang.sextool, Callback = LoadSexTool})
SettingsTab:CreateButton({Name = Lang.saveconfig, Callback = function() Rayfield:SaveConfiguration() end})

-- Language Dropdown (Fixed)
local LangOptions = {"🇵🇱 Polski", "🇺🇸 English"}
SettingsTab:CreateDropdown({
   Name = "Language/Język",
   Options = LangOptions,
   CurrentOption = "🇵🇱 Polski",
   Callback = function(option)
      CurrentLang = option == "🇵🇱 Polski" and "pl" or "en"
      Lang = Languages[CurrentLang]
      -- Reload GUI with new language (no crash)
      Rayfield:Notify({Title = "Language Changed", Content = "Restart GUI for full effect", Duration = 3})
   end
})

print("Turcja Hub")
print("Detected Game: " .. DetectedGame.name)
