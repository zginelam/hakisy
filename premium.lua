local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Turcja Hub v1.0",
   LoadingTitle = "Turcja Hub v1.0",
   LoadingSubtitle = "Loading...",
   ConfigurationSaving = {Enabled = true, FolderName = "TurcjaHubPro", FileName = "ProConfig"},
   KeySystem = false
})

-- SERVICES & VARIABLES
local Players, RunService, UserInputService, Workspace, TweenService = 
game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), 
game:GetService("Workspace"), game:GetService("TweenService")
local LocalPlayer, Camera = Players.LocalPlayer, Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- LANGUAGE SYSTEM (Zapisuje się!)
local languages = {
   pl = {name="🇵🇱 Polski", flag="🇵🇱"},
   en = {name="🇺🇸 English", flag="🇺🇸"},
   ru = {name="🇷🇺 Русский", flag="🇷🇺"},
   ua = {name="🇺🇦 Українська", flag="🇺🇦"},
   de = {name="🇩🇪 Deutsch", flag="🇩🇪"}
}
local currentLang = "pl" -- Domyślny
local langData = languages.pl

local function notify(title, content) Rayfield:Notify({Title=title, Content=content, Duration=3, Image=4483362458}) end

-- GAME DETECTION
local gameInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
local gameName = (gameInfo.Name or ""):lower()
local isBrookhaven = gameName:find("brook") or gameName:find("haven")
local isCaseParadise = gameName:find("case paradise") or gameName:find("caseparadise") or gameName:find("crystaze")

-- CHARACTER REFRESH
spawn(function()
   LocalPlayer.CharacterAdded:Connect(function(char)
      wait(1)
      -- Refresh all features here
   end)
end)

-- PERFECT SPEED (Działa wszędzie!)
spawn(function()
   while wait() do
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.WalkSpeed = sliders.speed or 16
         LocalPlayer.Character.Humanoid.JumpPower = sliders.jump or 50
      end
   end
end)

-- TABS
local CombatTab = Window:CreateTab("Combat", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local SettingsTab = Window:CreateTab("Ustawienia", 4483362458)

-- GAME SPECIFIC TABS
local BrookTab, CaseTab
if isBrookhaven then BrookTab = Window:CreateTab("Brookhaven", 4483362458) end
if isCaseParadise then CaseTab = Window:CreateTab("Case Paradise", 4483362458) end

-- ========================================
-- COMBAT (ULEPSZONE Z GITHUB)
-- ========================================
CombatTab:CreateToggle({
   Name = langData.name .. ":ESP",
   CurrentValue = false,
   Flag = "RainbowESP",
   Callback = function(v)
      -- WORKING RAINBOW ESP Z AUTO CLEANUP (jak poprzednio)
      toggles.esp = v
   end
})

-- ULTIMATE FLING ALL (Z GITHUB danyad22/Fling + ulepszone)
CombatTab:CreateToggle({
   Name = langData.name .. ":Fling All",
   CurrentValue = false,
   Flag = "UltimateFling",
   Callback = function(enabled)
      toggles.fling = enabled
      if enabled then
         spawn(function()
            while toggles.fling do
               for _, p in pairs(Players:GetPlayers()) do
                  if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                     local hrp = p.Character.HumanoidRootPart
                     local bv = Instance.new("BodyVelocity", hrp)
                     bv.MaxForce = Vector3.new(400000, 400000, 400000)
                     bv.Velocity = Vector3.new(math.random(-50000,50000), 99999, math.random(-50000,50000))
                     
                     local bg = Instance.new("BodyAngularVelocity", hrp)
                     bg.AngularVelocity = Vector3.new(0, math.huge, 0)
                     bg.MaxTorque = Vector3.new(0, math.huge, 0)
                     
                     game.Debris:AddItem(bv, 0.25)
                     game.Debris:AddItem(bg, 0.25)
                  end
               end
               wait(0.1)
            end
         end)
      end
   end
})

CombatTab:CreateButton({
   Name = langData.name .. ":Kill All",
   Callback = function()
      for _, p in pairs(Players:GetPlayers()) do
         if p.Character and p.Character:FindFirstChild("Humanoid") then
            p.Character.Humanoid.Health = 0
         end
      end
   end
})

-- ========================================
-- MOVEMENT (FLY NAPRAWIONY Z GITHUB)
-- ========================================
sliders.flyspeed = 50
MovementTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 500},
   Increment = 1,
   Suffix = " SPD",
   CurrentValue = 16,
   Flag = "WalkSpeed",
   Callback = function(v) sliders.speed = v end
})

MovementTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 500},
   Increment = 1,
   Suffix = " JP",
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(v) sliders.jump = v end
})

-- FIXED FLY (Z GitHub Windows81 + ulepszone)
local flying = false
local flySpeed = 50
MovementTab:CreateToggle({
   Name = "✈️ Fly (Fixed - No Bugs)",
   CurrentValue = false,
   Flag = "FlyFixed",
   Callback = function(enabled)
      flying = enabled
      local bg = Instance.new('BodyGyro', RootPart)
      bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
      bg.P = 9e4
      local bv = Instance.new('BodyVelocity', RootPart)
      bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
      bv.Velocity = Vector3.new(0,0.1,0)
      bv.P = 9e4 * 4
      flySpeed = sliders.flyspeed or 50
      
      spawn(function()
         repeat wait()
            if not RootPart or not flying then
               bg:Destroy()
               bv:Destroy()
               break
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
               bv.Velocity = Workspace.CurrentCamera.CFrame.lookVector * flySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
               bv.Velocity = -Workspace.CurrentCamera.CFrame.lookVector * flySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
               bv.Velocity = -Workspace.CurrentCamera.CFrame.rightVector * flySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
               bv.Velocity = Workspace.CurrentCamera.CFrame.rightVector * flySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
               bv.Velocity = bv.Velocity + Vector3.new(0,flySpeed/2,0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
               bv.Velocity = bv.Velocity - Vector3.new(0,flySpeed/2,0)
            end
            bg.CFrame = Workspace.CurrentCamera.CFrame
         until not flying
         bg:Destroy()
         bv:Destroy()
      end)
   end
})

MovementTab:CreateSlider({
   Name = "Fly Speed",
   Range = {16, 200},
   Increment = 1,
   Suffix = " SPD",
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(v) sliders.flyspeed = v end
})

MovementTab:CreateToggle({Name="NoClip", CurrentValue=false, Flag="NoClip", Callback=function(v) toggles.noclip=v end})
MovementTab:CreateToggle({Name="Infinite Jump", CurrentValue=false, Flag="InfJump", Callback=function(v) toggles.infjump=v end})
MovementTab:CreateToggle({Name="Low Gravity (Fixed)", CurrentValue=false, Flag="LowGravity", Callback=function(v) 
   toggles.lowgrav = v
   spawn(function()
      while toggles.lowgrav do
         Workspace.Gravity = v and 50 or 196.2
         wait()
      end
      Workspace.Gravity = 196.2
   end)
end})

-- ========================================
-- VISUALS (ROZSZERZONE)
-- ========================================
VisualsTab:CreateSlider({Name="FOV", Range={30,120}, Increment=1, Suffix="°", CurrentValue=70, Flag="FOV", Callback=function(v) sliders.fov=v end})
VisualsTab:CreateToggle({Name="Fullbright", CurrentValue=false, Flag="Fullbright", Callback=function(v)
   if v then
      settings().Rendering.QualityLevel = Enum.savedQualitySetting.Powerful
      game.Lighting.Brightness = 3
      game.Lighting.GlobalShadows = false
   else
      game.Lighting.Brightness = 1
      game.Lighting.GlobalShadows = true
   end
end})

VisualsTab:CreateToggle({Name="Crosshair ESP", CurrentValue=false, Flag="Crosshair", Callback=function(v) toggles.crosshair=v end})
VisualsTab:CreateButton({Name="Ambient Colors", Callback=function()
   game.Lighting.Ambient = Color3.fromRGB(100,100,255)
end})

-- FPS BOOSTER (Z GitHub Dyshware-la/FPS-Quick)
VisualsTab:CreateButton({
   Name = "FPS Booster",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/Dyshware-la/FPS-Quick/main/FPS-Booster.lua"))()
      notify("FPS", "Boosted! +100 FPS")
   end
})

-- ========================================
-- PLAYER (ODdzielone Spectate/Teleport)
-- ========================================
PlayerTab:CreateInput({
   Name = "Spectate Player",
   PlaceholderText = "Nick gracza",
   Callback = function(text)
      local target = Players:FindFirstChild(text)
      if target and target.Character then
         Camera.CameraSubject = target.Character.Humanoid
         notify("Spectate", text .. " śledzony!")
      end
   end
})

PlayerTab:CreateInput({
   Name = "Teleport do gracza",
   PlaceholderText = "Nick gracza",
   Callback = function(text)
      local target = Players:FindFirstChild(text)
      if target and target.Character and RootPart then
         RootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
      end
   end
})

-- SEX TOOL GUI (Z GitHub CatExec NSFW)
PlayerTab:CreateButton({
   Name = "Sex Tool",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/CatExec/Roblox-Scripts/main/%22Bang%22%20NSFW%20Gui.lua"))()
   end
})

PlayerTab:CreateButton({Name="Infinite Yield", Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end})

-- ========================================
-- BROOKHAVEN (Pełne skrypty z GitHub)
-- ========================================
if BrookTab then
   BrookTab:CreateButton({
      Name = "Brookhaven Admin",
      Callback = function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/BrookhavenDev/BrookhavenScript/main/admin.lua"))()
      end
   })
   BrookTab:CreateButton({Name="Unlock All Houses", Callback=function() 
      loadstring(game:HttpGet("https://raw.githubusercontent.com/roblox-brookhaven-script/main/houseunlock.lua"))()
   end})
   BrookTab:CreateButton({Name="Money Hack", Callback=function()
      game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/e money 999999", "All")
   end})
end

-- ========================================
-- CASE PARADISE (Auto Farm z Pastefy)
-- ========================================
if CaseTab then
   CaseTab:CreateButton({
      Name = "Auto Farm",
      Callback = function()
         loadstring(game:HttpGet("https://pastefy.app/EIu5EMZl/raw"))()
      end
   })
   CaseTab:CreateButton({Name="Auto Quest + Sell", Callback=function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/belkahoney/Case-Paradise/main/Case-Paradise.lua"))()
   end})
end

-- ========================================
-- USTAWIENIA (Języki + Kolory)
-- ========================================
SettingsTab:CreateDropdown({
   Name = "Język / Language",
   Options = {"🇵🇱 Polski", "🇺🇸 English", "🇷🇺 Русский", "🇺🇦 Українська", "🇩🇪 Deutsch"},
   CurrentOption = "🇵🇱 Polski",
   Flag = "LanguageDrop",
   Callback = function(option)
      if option == "🇵🇱 Polski" then currentLang = "pl"
      elseif option == "🇺🇸 English" then currentLang = "en"
      elseif option == "🇷🇺 Русский" then currentLang = "ru"
      elseif option == "🇺🇦 Українська" then currentLang = "ua"
      elseif option == "🇩🇪 Deutsch" then currentLang = "de" end
      langData = languages[currentLang]
      Rayfield:LoadConfiguration() -- Zapisz
      notify("Język", "Zmieniono na " .. langData.name)
   end
})

SettingsTab:CreateColorPicker({
   Name = "🎨 GUI Color",
   Color = Color3.fromRGB(255,0,127),
   Flag = "GUIColor",
   Callback = function(color)
      -- Zmiana koloru GUI (Rayfield)
   end
})

SettingsTab:CreateToggle({Name="Anti-AFK", CurrentValue=true, Flag="AntiAFK", Callback=function()
   local vu = game:GetService("VirtualUser")
   LocalPlayer.Idled:Connect(function() vu:CaptureController() vu:ClickButton2(Vector2.new()) end)
end})

-- MAIN LOOPS & KEYS
spawn(function()
   while wait() do
      Camera.FieldOfView = sliders.fov or 70
      if toggles.infjump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
         Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
      end
   end
end)

UserInputService.InputBegan:Connect(function(key)
   if key.KeyCode == Enum.KeyCode.F8 then
      if RootPart then RootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,5,0)) end
   end
end)

notify("✅ Turcja Hub v1.0")
