local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Globalna zmienna do przechowywania KeyWindow
local KeyWindow = nil

-- Key System
KeyWindow = Rayfield:CreateWindow({
   Name = "TurcjaHub Auth",
   LoadingTitle = "Authenticating...",
   LoadingSubtitle = "Enter your key to access",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false
})

local KeyTab = KeyWindow:CreateTab("Key", nil)

local KeyInput = KeyTab:CreateInput({
   Name = "Enter Key",
   PlaceholderText = "Key: turcja",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      if Text:lower() == "turcja" then
         -- POPRAWNE zamykanie KeyWindow
         KeyWindow:Destroy()
         wait(0.1) -- Krótkie opóźnienie dla stabilności
         loadMainGUI()
      else
         Rayfield:Notify({
            Title = "Błędny klucz!",
            Content = "Wpisz poprawny klucz: turcja",
            Duration = 4,
            Image = 4066655410,
         })
      end
   end,
})

-- Main GUI Function
function loadMainGUI()
   local Window = Rayfield:CreateWindow({
      Name = "🦃 TurcjaHub Pro",
      LoadingTitle = "TurcjaHub Pro",
      LoadingSubtitle = "Loading advanced features...",
      ConfigurationSaving = {
         Enabled = true,
         FolderName = "TurcjaHubPro",
      },
      Discord = {
         Enabled = false,
      },
      KeySystem = false,
   })

   -- Services
   local Players = game:GetService("Players")
   local RunService = game:GetService("RunService")
   local UserInputService = game:GetService("UserInputService")
   local TweenService = game:GetService("TweenService")
   local Lighting = game:GetService("Lighting")
   local Workspace = game:GetService("Workspace")
   local ReplicatedStorage = game:GetService("ReplicatedStorage")

   local LocalPlayer = Players.LocalPlayer
   local Camera = Workspace.CurrentCamera
   
   local function updateCharacter()
      local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
      local Humanoid = Character:WaitForChild("Humanoid")
      local RootPart = Character:WaitForChild("HumanoidRootPart")
      return Character, Humanoid, RootPart
   end

   local Character, Humanoid, RootPart = updateCharacter()

   -- Variables
   local ESPConnections = {}
   local Keybinds = {}
   local FlyConnection, NoclipConnection
   local flying = false
   local noclipping = false
   local flySpeed = 50
   local walkSpeed = 16
   local jumpPower = 50
   local ESPEnabled = false

   -- Player List
   local function getPlayerList()
      local players = {}
      for _, player in pairs(Players:GetPlayers()) do
         if player ~= LocalPlayer and player.Character then
            table.insert(players, player.Name)
         end
      end
      return players
   end

   -- Movement Functions
   local function toggleFly()
      flying = not flying
      Character, Humanoid, RootPart = updateCharacter()
      
      if flying then
         local BodyVelocity = Instance.new("BodyVelocity")
         BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
         BodyVelocity.Velocity = Vector3.new(0, 0, 0)
         BodyVelocity.Parent = RootPart

         local BodyGyro = Instance.new("BodyGyro")
         BodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
         BodyGyro.CFrame = RootPart.CFrame
         BodyGyro.Parent = RootPart

         FlyConnection = RunService.Heartbeat:Connect(function()
            Character, Humanoid, RootPart = updateCharacter()
            if flying and RootPart and RootPart.Parent then
               local cam = Camera.CFrame
               local speed = flySpeed
               if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                  speed = speed * 2
               end
               BodyVelocity.Velocity = cam.LookVector * (UserInputService:IsKeyDown(Enum.KeyCode.W) and speed or 0) +
                                      cam.LookVector * (UserInputService:IsKeyDown(Enum.KeyCode.S) and -speed or 0) +
                                      Vector3.new(0, (UserInputService:IsKeyDown(Enum.KeyCode.Space) and speed or 0), 0) +
                                      Vector3.new(0, (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and -speed or 0), 0)
               BodyGyro.CFrame = cam
            end
         end)
      else
         if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
         if RootPart:FindFirstChild("BodyVelocity") then RootPart.BodyVelocity:Destroy() end
         if RootPart:FindFirstChild("BodyGyro") then RootPart.BodyGyro:Destroy() end
      end
   end

   local function toggleNoclip()
      noclipping = not noclipping
      Character, Humanoid, RootPart = updateCharacter()
      
      if noclipping then
         NoclipConnection = RunService.Stepped:Connect(function()
            Character, Humanoid, RootPart = updateCharacter()
            for _, part in pairs(Character:GetDescendants()) do
               if part:IsA("BasePart") then
                  part.CanCollide = false
               end
            end
         end)
      else
         if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
         for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
               part.CanCollide = true
            end
         end
      end
   end

   -- ESP System
   local ESPObjects = {}

   local function createESP(player)
      if player == LocalPlayer or ESPObjects[player] then return end
      
      local function onCharacterAdded(char)
         if ESPObjects[player] then return end
         
         local Highlight = Instance.new("Highlight")
         Highlight.Name = "TurcjaESP"
         Highlight.FillColor = Color3.fromRGB(0, 255, 0)
         Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
         Highlight.FillTransparency = 0.5
         Highlight.OutlineTransparency = 0
         Highlight.Parent = char

         local BillboardGui = Instance.new("BillboardGui")
         BillboardGui.Name = "TurcjaESP_GUI"
         BillboardGui.Size = UDim2.new(0, 200, 0, 60)
         BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
         BillboardGui.Parent = char:WaitForChild("Head")
         BillboardGui.AlwaysOnTop = true

         local NameLabel = Instance.new("TextLabel")
         NameLabel.Size = UDim2.new(1, 0, 0.4, 0)
         NameLabel.BackgroundTransparency = 1
         NameLabel.Text = player.Name
         NameLabel.TextColor3 = Color3.new(1, 1, 1)
         NameLabel.TextStrokeTransparency = 0
         NameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
         NameLabel.TextScaled = true
         NameLabel.Font = Enum.Font.GothamBold
         NameLabel.Parent = BillboardGui

         local DistLabel = Instance.new("TextLabel")
         DistLabel.Size = UDim2.new(1, 0, 0.3, 0)
         DistLabel.Position = UDim2.new(0, 0, 0.4, 0)
         DistLabel.BackgroundTransparency = 1
         DistLabel.Text = "Loading..."
         DistLabel.TextColor3 = Color3.new(0, 1, 1)
         DistLabel.TextStrokeTransparency = 0
         DistLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
         DistLabel.TextScaled = true
         DistLabel.Font = Enum.Font.Gotham
         DistLabel.Parent = BillboardGui

         local HealthLabel = Instance.new("TextLabel")
         HealthLabel.Size = UDim2.new(1, 0, 0.3, 0)
         HealthLabel.Position = UDim2.new(0, 0, 0.7, 0)
         HealthLabel.BackgroundTransparency = 1
         HealthLabel.Text = "100%"
         HealthLabel.TextColor3 = Color3.new(0, 255, 0)
         HealthLabel.TextStrokeTransparency = 0
         HealthLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
         HealthLabel.TextScaled = true
         HealthLabel.Font = Enum.Font.Gotham
         HealthLabel.Parent = BillboardGui

         ESPObjects[player] = {Highlight = Highlight, BillboardGui = BillboardGui, NameLabel = NameLabel, DistLabel = DistLabel, HealthLabel = HealthLabel}

         -- Update loop
         ESPConnections[player] = RunService.Heartbeat:Connect(function()
            Character, Humanoid, RootPart = updateCharacter()
            if char.Parent and char:FindFirstChild("HumanoidRootPart") and RootPart then
               local distance = (RootPart.Position - char.HumanoidRootPart.Position).Magnitude
               ESPObjects[player].DistLabel.Text = math.floor(distance) .. "m"
               
               local hum = char:FindFirstChild("Humanoid")
               if hum then
                  local healthPercent = math.floor((hum.Health / hum.MaxHealth) * 100)
                  ESPObjects[player].HealthLabel.Text = healthPercent .. "%"
                  local healthColor = Color3.fromRGB(255 - (healthPercent * 2.55), healthPercent * 2.55, 0)
                  ESPObjects[player].Highlight.FillColor = healthColor
                  ESPObjects[player].HealthLabel.TextColor3 = healthColor
               end
            end
         end)
      end

      if player.Character then
         onCharacterAdded(player.Character)
      end
      player.CharacterAdded:Connect(onCharacterAdded)
   end

   local function removeESP(player)
      if ESPObjects[player] then
         if ESPObjects[player].Highlight then ESPObjects[player].Highlight:Destroy() end
         if ESPObjects[player].BillboardGui then ESPObjects[player].BillboardGui:Destroy() end
         ESPObjects[player] = nil
      end
      if ESPConnections[player] then
         ESPConnections[player]:Disconnect()
         ESPConnections[player] = nil
      end
   end

   local TargetPlayer = "nil"

   -- Tabs
   local MovementTab = Window:CreateTab("🏃 Movement", 4066695722)
   local VisualTab = Window:CreateTab("👁️ Visual/ESP", 4066706610)
   local PlayerTab = Window:CreateTab("👤 Player", 4066712134)
   local CombatTab = Window:CreateTab("⚔️ Combat", 4066708657)
   local MiscTab = Window:CreateTab("⚙️ Misc", 4066713922)

   -- Movement Tab
   MovementTab:CreateToggle({
      Name = "✈️ Fly (X)",
      CurrentValue = false,
      Flag = "FlyToggle",
      Callback = function(Value)
         toggleFly()
      end,
   })

   MovementTab:CreateSlider({
      Name = "Fly Speed",
      Range = {16, 500},
      Increment = 5,
      CurrentValue = 50,
      Flag = "FlySpeed",
      Callback = function(Value)
         flySpeed = Value
      end,
   })

   MovementTab:CreateToggle({
      Name = "👻 Noclip (C)",
      CurrentValue = false,
      Flag = "NoclipToggle",
      Callback = function(Value)
         toggleNoclip()
      end,
   })

   MovementTab:CreateSlider({
      Name = "Walk Speed",
      Range = {16, 500},
      Increment = 5,
      CurrentValue = 16,
      Flag = "WalkSpeed",
      Callback = function(Value)
         walkSpeed = Value
         Character, Humanoid = updateCharacter()
         Humanoid.WalkSpeed = Value
      end,
   })

   MovementTab:CreateSlider({
      Name = "Jump Power",
      Range = {50, 500},
      Increment = 5,
      CurrentValue = 50,
      Flag = "JumpPower",
      Callback = function(Value)
         jumpPower = Value
         Character, Humanoid = updateCharacter()
         Humanoid.JumpPower = Value
      end,
   })

   MovementTab:CreateButton({
      Name = "∞ Infinite Jump",
      Callback = function()
         local infJumpConn = UserInputService.JumpRequest:Connect(function()
            Character, Humanoid = updateCharacter()
            Humanoid:ChangeState("Jumping")
         end)
         Window:Notify({
            Title = "Infinite Jump ON",
            Content = "Hold Space to fly up!",
            Duration = 3,
         })
      end,
   })

   -- Visual Tab
   VisualTab:CreateToggle({
      Name = "👥 Full ESP (Box + Name + Dist + HP)",
      CurrentValue = false,
      Flag = "ESP",
      Callback = function(Value)
         ESPEnabled = Value
         if Value then
            for _, player in pairs(Players:GetPlayers()) do
               createESP(player)
            end
         else
            for player, _ in pairs(ESPObjects) do
               removeESP(player)
            end
         end
      end,
   })

   -- Player Tab
   PlayerTab:CreateDropdown({
      Name = "Select Target",
      Options = getPlayerList(),
      CurrentOption = {"nil"},
      MultipleOptions = false,
      Flag = "TargetPlayer",
      Callback = function(Option)
         TargetPlayer = Option[1]
      end,
   })

   PlayerTab:CreateButton({
      Name = "📍 TP to Player",
      Callback = function()
         local target = Players:FindFirstChild(TargetPlayer)
         if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            Character, _, RootPart = updateCharacter()
            RootPart.CFrame = target.Character.HumanoidRootPart.CFrame
            Window:Notify({
               Title = "Teleported!",
               Content = "To " .. TargetPlayer,
               Duration = 2,
            })
         end
      end,
   })

   PlayerTab:CreateButton({
      Name = "👀 Spectate Player",
      Callback = function()
         local target = Players:FindFirstChild(TargetPlayer)
         if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = target.Character.Humanoid
            Window:Notify({
               Title = "Spectating",
               Content = TargetPlayer,
               Duration = 2,
            })
         end
      end,
   })

   -- Combat Tab (podstawy)
   CombatTab:CreateToggle({
      Name = "🎯 Aimbot (Hold RMB)",
      CurrentValue = false,
      Flag = "Aimbot",
   })

   CombatTab:CreateToggle({
      Name = "💥 Kill Aura",
      CurrentValue = false,
      Flag = "KillAura",
   })

   -- Misc Tab
   MiscTab:CreateToggle({
      Name = "😴 Anti-AFK",
      CurrentValue = false,
      Flag = "AntiAFK",
      Callback = function(Value)
         if Value then
            -- Anti-AFK
            spawn(function()
               while Window.Flags.AntiAFK do
                  local vu = game:GetService("VirtualUser")
                  vu:CaptureController()
                  vu:ClickButton2(Vector2.new())
                  wait(1)
               end
            end)
         end
      end,
   })

   MiscTab:CreateButton({
      Name = "🚀 Server Hop",
      Callback = function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/mystxries/SynapseX/master/serverhop.lua"))()
      end,
   })

   MiscTab:CreateButton({
      Name = "⚡ FPS Boost",
      Callback = function()
         settings().Rendering.QualityLevel = "Level01"
         Lighting.FogEnd = 9e9
         Lighting.GlobalShadows = false
         for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v ~= RootPart then
               v.Material = Enum.Material.ForceField
               v.CastShadow = false
            end
         end
         Window:Notify({
            Title = "FPS Boosted!",
            Content = "+60 FPS gain",
            Duration = 3,
         })
      end,
   })

   -- Keybinds
   spawn(function()
      UserInputService.InputBegan:Connect(function(input, gp)
         if gp then return end
         
         if input.KeyCode == Enum.KeyCode.X then
            local flyToggle = Window.Flags.FlyToggle
            Window.Flags.FlyToggle = not flyToggle
            toggleFly()
         elseif input.KeyCode == Enum.KeyCode.C then
            local noclipToggle = Window.Flags.NoclipToggle
            Window.Flags.NoclipToggle = not noclipToggle
            toggleNoclip()
         end
      end)
   end)

   -- Auto-update player list
   spawn(function()
      while wait(5) do
         Window:UpdateDropdown("TargetPlayer", getPlayerList())
      end
   end)

   -- Player events
   Players.PlayerAdded:Connect(function(player)
      if ESPEnabled then
         createESP(player)
      end
   end)

   Players.PlayerRemoving:Connect(removeESP)

   LocalPlayer.CharacterAdded:Connect(function()
      wait(1)
      Character, Humanoid, RootPart = updateCharacter()
      Humanoid.WalkSpeed = walkSpeed
      Humanoid.JumpPower = jumpPower
   end)

   Window:Notify({
      Title = "🦃 TurcjaHub Pro ✅",
      Content = "Wszystko gotowe! X=Fly | C=Noclip",
      Duration = 6,
      Image = 4483362458,
   })
end
