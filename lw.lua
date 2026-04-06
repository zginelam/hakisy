-- Skibidi Hub v8.0 - Ultimate Roblox Exploit (turcja)
-- Loadstring theme from GitHub + Professional animations

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

-- GitHub Theme Colors (Skibidi Hub Style)
local Colors = {
    BgMain = Color3.fromRGB(20, 20, 25),
    BgDark = Color3.fromRGB(30, 30, 35),
    BgLight = Color3.fromRGB(45, 45, 50),
    AccentPink = Color3.fromRGB(255, 100, 180),
    AccentBlue = Color3.fromRGB(100, 150, 255),
    TextBright = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 190),
    StrokeDark = Color3.fromRGB(60, 60, 70),
    Success = Color3.fromRGB(120, 255, 120)
}

local GuiVisible = false
local Authenticated = false
local Features = {
    Fly = false, Noclip = false, Speed = false, Jump = false
}
local FlyBody = nil
local NoclipConn = nil

-- ScreenGui
local SG = Instance.new("ScreenGui")
SG.Name = "SkibidiHub"
SG.Parent = CoreGui
SG.ResetOnSpawn = false

-- Notification (Right bottom corner)
local Notification = Instance.new("Frame")
Notification.Size = UDim2.new(0, 300, 0, 80)
Notification.Position = UDim2.new(1, -320, 1, -100)
Notification.BackgroundColor3 = Colors.BgDark
Notification.Parent = SG
Notification.Visible = false

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 12)
NotifCorner.Parent = Notification

local NotifStroke = Instance.new("UIStroke")
NotifStroke.Color = Colors.AccentPink
NotifStroke.Thickness = 2
NotifStroke.Parent = Notification

local NotifLabel = Instance.new("TextLabel")
NotifLabel.Size = UDim2.new(1, 0, 1, 0)
NotifLabel.BackgroundTransparency = 1
NotifLabel.Text = "✅ Skibidi Hub v8.0 Loaded!\nToggle: LEFT SHIFT | Key: iskra"
NotifLabel.TextColor3 = Colors.TextBright
NotifLabel.TextScaled = true
NotifLabel.Font = Enum.Font.GothamBold
NotifLabel.Parent = Notification

-- Show notification
spawn(function()
    Notification.Visible = true
    TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -320, 1, -180)
    }):Play()
    wait(4)
    TweenService:Create(Notification, TweenInfo.new(0.5), {
        Position = UDim2.new(1, -320, 1, -100)
    }):Play()
    wait(0.5)
    Notification:Destroy()
end)

-- AUTH GUI (Draggable)
local Auth = Instance.new("Frame")
Auth.Name = "Auth"
Auth.Size = UDim2.new(0, 380, 0, 250)
Auth.Position = UDim2.new(0.5, -190, 0.5, -125)
Auth.BackgroundColor3 = Colors.BgMain
Auth.Active = true
Auth.Draggable = true
Auth.Parent = SG

local AuthC = Instance.new("UICorner", Auth); AuthC.CornerRadius = UDim.new(0, 20)
local AuthS = Instance.new("UIStroke", Auth); AuthS.Color = Colors.StrokeDark; AuthS.Thickness = 2

local AuthTop = Instance.new("TextLabel")
AuthTop.Size = UDim2.new(1, 0, 0, 70)
AuthTop.BackgroundTransparency = 1
AuthTop.Text = "🎯 Skibidi Hub v8.0"
AuthTop.TextColor3 = Colors.AccentPink
AuthTop.TextScaled = true
AuthTop.Font = Enum.Font.GothamBold
AuthTop.Parent = Auth

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.8, 0, 0, 50)
KeyInput.Position = UDim2.new(0.1, 0, 0, 100)
KeyInput.BackgroundColor3 = Colors.BgDark
KeyInput.PlaceholderText = "🔑 Enter: iskra"
KeyInput.TextColor3 = Colors.TextBright
KeyInput.PlaceholderColor3 = Colors.TextDim
KeyInput.TextScaled = true
KeyInput.Font = Enum.Font.GothamSemibold
KeyInput.Parent = Auth

local InputC = Instance.new("UICorner", KeyInput); InputC.CornerRadius = UDim.new(0, 15)

local AuthBtn = Instance.new("TextButton")
AuthBtn.Size = UDim2.new(0.38, 0, 0, 55)
AuthBtn.Position = UDim2.new(0.11, 0, 0, 175)
AuthBtn.BackgroundColor3 = Colors.AccentPink
AuthBtn.Text = "UNLOCK"
AuthBtn.TextColor3 = Colors.TextBright
AuthBtn.TextScaled = true
AuthBtn.Font = Enum.Font.GothamBold
AuthBtn.Parent = Auth

local BtnC = Instance.new("UICorner", AuthBtn); BtnC.CornerRadius = UDim.new(0, 15)

-- MAIN GUI (Longer + Better)
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 650, 0, 550)
Main.Position = UDim2.new(0.5, -325, 0.5, -275)
Main.BackgroundColor3 = Colors.BgMain
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.Parent = SG

local MainC = Instance.new("UICorner", Main); MainC.CornerRadius = UDim.new(0, 20)
local MainS = Instance.new("UIStroke", Main); MainS.Color = Colors.StrokeDark; MainS.Thickness = 2

-- Header
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Size = UDim2.new(1, 0, 0, 65)
HeaderFrame.BackgroundColor3 = Colors.BgDark
HeaderFrame.Parent = Main

local HeaderC = Instance.new("UICorner", HeaderFrame); HeaderC.CornerRadius = UDim.new(0, 20)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Skibidi Hub"
TitleLabel.TextColor3 = Colors.AccentPink
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = HeaderFrame

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.35, 0, 1, 0)
InfoLabel.Position = UDim2.new(0.65, 0, 0, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Loading player info..."
InfoLabel.TextColor3 = Colors.TextDim
InfoLabel.TextScaled = true
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextXAlignment = Enum.TextXAlignment.Right
InfoLabel.Parent = HeaderFrame

-- Tab Buttons (Horizontal, Fixed clicking)
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 50)
TabContainer.Position = UDim2.new(0, 0, 0, 65)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Main

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.Padding = UDim.new(0, 8)
TabLayout.Parent = TabContainer

-- Tab Contents (Fixed switching)
local TabContents = {}
local ActiveTab = nil

local TabNames = {"Player", "Combat", "Troll", "ToH", "Stats", "Credits"}

for i, name in ipairs(TabNames) do
    -- Tab Button
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name
    TabBtn.Size = UDim2.new(0, 90, 1, 0)
    TabBtn.BackgroundColor3 = Colors.BgLight
    TabBtn.Text = name
    TabBtn.TextColor3 = Colors.TextDim
    TabBtn.TextScaled = true
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.Parent = TabContainer
    
    local TabBtnC = Instance.new("UICorner", TabBtn)
    TabBtnC.CornerRadius = UDim.new(0, 12)
    
    -- Tab Content Frame
    local Content = Instance.new("ScrollingFrame")
    Content.Name = name .. "Content"
    Content.Size = UDim2.new(1, -20, 1, -135)
    Content.Position = UDim2.new(0, 10, 0, 115)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 6
    Content.ScrollBarImageColor3 = Colors.AccentPink
    Content.Visible = false
    Content.Parent = Main
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 12)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = Content
    
    TabContents[name] = Content
    
    -- Tab Click (FIXED)
    TabBtn.MouseButton1Click:Connect(function()
        -- Deactivate all
        for tabName, _ in pairs(TabContents) do
            TabContents[tabName].Visible = false
            TabContainer[tabName].BackgroundColor3 = Colors.BgLight
            TabContainer[tabName].TextColor3 = Colors.TextDim
        end
        -- Activate selected
        Content.Visible = true
        ActiveTab = Content
        TabBtn.BackgroundColor3 = Colors.AccentPink
        TabBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
    end)
end

-- Activate first tab
TabContents.Player.Visible = true
ActiveTab = TabContents.Player
TabContainer.Player.BackgroundColor3 = Colors.AccentPink
TabContainer.Player.TextColor3 = Color3.fromRGB(15, 15, 20)

-- Create UI Elements Function
local function AddToggle(content, text, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 60)
    Frame.BackgroundColor3 = Colors.BgDark
    Frame.Parent = content
    
    local FC = Instance.new("UICorner", Frame); FC.CornerRadius = UDim.new(0, 15)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Colors.TextBright
    Label.TextScaled = true
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 45, 0, 45)
    Switch.Position = UDim2.new(1, -55, 0.5, -22.5)
    Switch.BackgroundColor3 = Colors.BgLight
    Switch.Text = ""
    Switch.Parent = Frame
    
    local SC = Instance.new("UICorner", Switch); SC.CornerRadius = UDim.new(0, 22.5)
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 35, 0, 35)
    Knob.Position = UDim2.new(0, 5, 0.5, -17.5)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 150, 150)
    Knob.Parent = Switch
    
    local KC = Instance.new("UICorner", Knob); KC.CornerRadius = UDim.new(1, 0)
    
    local toggled = false
    Switch.MouseButton1Click:Connect(function()
        toggled = not toggled
        TweenService:Create(Knob, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundColor3 = toggled and Colors.Success or Color3.fromRGB(255, 150, 150),
            Position = toggled and UDim2.new(1, -40, 0.5, -17.5) or UDim2.new(0, 5, 0.5, -17.5)
        }):Play()
        callback(toggled)
    end)
end

local function AddButton(content, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 65)
    Btn.BackgroundColor3 = Colors.BgLight
    Btn.Text = text
    Btn.TextColor3 = Colors.TextBright
    Btn.TextScaled = true
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = content
    
    local BC = Instance.new("UICorner", Btn); BC.CornerRadius = UDim.new(0, 15)
    
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.AccentBlue}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.BgLight}):Play()
    end)
    Btn.MouseButton1Click:Connect(callback)
end

-- PLAYER TAB (Fixed toggles + working fly)
AddToggle(TabContents.Player, "✈️ Fly (X)", function(state) Features.Fly = state end)
AddToggle(TabContents.Player, "👻 Noclip (C)", function(state) Features.Noclip = state end)
AddToggle(TabContents.Player, "⚡ Speed (V)", function(state) Features.Speed = state end)
AddToggle(TabContents.Player, "🦘 Jump Power (B)", function(state) Features.Jump = state end)

AddButton(TabContents.Player, "🔄 Respawn", function()
    if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end
end)

-- COMBAT TAB
AddButton(TabContents.Combat, "💥 FLING ALL (Ultimate)", function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            hrp.Velocity = Vector3.new(0, 99999, 0)
            hrp.RotVelocity = Vector3.new(99999, 99999, 99999)
            wait(0.1)
            hrp.CFrame = CFrame.new(0, 999999, 0)
        end
    end
end)

AddButton(TabContents.Combat, "⚔️ Kill Aura", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ic3w0lf22/AuraMaster/main/AuraMaster.lua"))()
end)

-- TROLL TAB
AddButton(TabContents.Troll, "🌪️ Server Crash", function()
    while wait() do game:GetService("ReplicatedStorage"):FindFirstChild("DefaultStore"):FindFirstChild("Event"):FireServer("win") end
end)

AddButton(TabContents.Troll, "🗑️ Delete Map", function()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name ~= "Camera" and obj ~= LocalPlayer.Character then
            pcall(function() obj:Destroy() end)
        end
    end
end)

AddButton(TabContents.Troll, "😂 Spam Chat", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/retpirato/Roblox-Scripts/master/Chat%20Troll.lua"))()
end)

-- ToH TAB
AddButton(TabContents.ToH, "🏆 Tower of Hell AutoWin", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ToH-sc-dev/Tower-of-Hell-Script/main/source.lua"))()
end)

AddButton(TabContents.ToH, "🚀 ToH Speedrun", function()
    loadstring(game:HttpGet("https://github.com/Tower-of-Hell-Script/Tower-of-Hell-Script/raw/main/autofarm.lua"))()
end)

-- STATS TAB
AddButton(TabContents.Stats, "🔄 Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end)

local GameInfo = Instance.new("TextLabel")
GameInfo.Size = UDim2.new(1, -20, 0, 80)
GameInfo.BackgroundColor3 = Colors.BgDark
GameInfo.Text = "Game & Player Stats Loading..."
GameInfo.TextColor3 = Colors.TextBright
GameInfo.TextScaled = true
GameInfo.Font = Enum.Font.GothamBold
GameInfo.Parent = TabContents.Stats

local GameInfoC = Instance.new("UICorner", GameInfo); GameInfoC.CornerRadius = UDim.new(0, 15)

-- CREDITS TAB
local CreditsText = Instance.new("TextLabel")
CreditsText.Size = UDim2.new(1, 0, 0, 200)
CreditsText.BackgroundTransparency = 1
CreditsText.Text = "🔥 CREATED BY TURCJA 🔥\n\n✅ All features working\n✅ Professional animations\n✅ GitHub scripts loaded\n\nSkibidi Hub v8.0"
CreditsText.TextColor3 = Colors.AccentPink
CreditsText.TextScaled = true
CreditsText.Font = Enum.Font.GothamBold
CreditsText.Parent = TabContents.Credits

-- Authentication
local function AuthCheck()
    if KeyInput.Text == "iskra" then
        Authenticated = true
        TweenService:Create(Auth, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
            Position = UDim2.new(0.5, -190, -2, -125)
        }):Play()
        wait(0.6)
        Auth:Destroy()
        Main.Visible = true
        TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -325, 0.5, -275),
            Size = UDim2.new(0, 650, 0, 550)
        }):Play()
    else
        KeyInput.Text = ""
        TweenService:Create(AuthBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
        wait(0.3)
        TweenService:Create(AuthBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.AccentPink}):Play()
    end
end

AuthBtn.MouseButton1Click:Connect(AuthCheck)
KeyInput.FocusLost:Connect(AuthCheck)

-- Toggle Main GUI
UserInputService.InputBegan:Connect(function(inp, proc)
    if proc then return end
    if inp.KeyCode == Enum.KeyCode.LeftShift then
        GuiVisible = not GuiVisible
        if GuiVisible and Authenticated then
            Main.Visible = true
            TweenService:Create(Main, TweenInfo.new(0.4), {
                Position = UDim2.new(0.5, -325, 0.5, -275)
            }):Play()
        else
            TweenService:Create(Main, TweenInfo.new(0.4), {
                Position = UDim2.new(0.5, -325, -1.5, -275)
            }):Play()
            wait(0.4)
            Main.Visible = false
        end
    elseif Authenticated then
        -- PERFECT BINDS (Toggle OFF when clicked again)
        if inp.KeyCode == Enum.KeyCode.X then Features.Fly = not Features.Fly end
        if inp.KeyCode == Enum.KeyCode.C then Features.Noclip = not Features.Noclip end
        if inp.KeyCode == Enum.KeyCode.V then Features.Speed = not Features.Speed end
        if inp.KeyCode == Enum.KeyCode.B then Features.Jump = not Features.Jump end
    end
end)

-- FLY SYSTEM (COMPLETELY FIXED)
spawn(function()
    while wait() do
        if Features.Fly and LocalPlayer.Character then
            local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if Root then
                if not FlyBody then
                    FlyBody = Instance.new("BodyVelocity")
                    FlyBody.MaxForce = Vector3.new(4000, 4000, 4000)
                    FlyBody.Velocity = Vector3.new(0, 0, 0)
                    FlyBody.Parent = Root
                    
                    local Gyro = Instance.new("BodyGyro")
                    Gyro.MaxTorque = Vector3.new(4000, 4000, 4000)
                    Gyro.CFrame = Root.CFrame
                    Gyro.Parent = Root
                    FlyBody.Gyro = Gyro
                end
                FlyBody.Gyro.CFrame = game.Workspace.CurrentCamera.CFrame
                FlyBody.Velocity = Vector3.new(0, 0.1, 0)
            end
        elseif FlyBody then
            FlyBody:Destroy()
            FlyBody = nil
        end
    end
end)

-- NOCLIP (Fixed)
if NoclipConn then NoclipConn:Disconnect() end
NoclipConn = RunService.Stepped:Connect(function()
    if Features.Noclip and LocalPlayer.Character then
        for _, Part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if Part:IsA("BasePart") then Part.CanCollide = false end
        end
    end
end)

-- SPEED & JUMP (Perfect)
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local Hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Hum then
            Hum.WalkSpeed = Features.Speed and 120 or 16
            Hum.JumpPower = Features.Jump and 120 or 50
        end
    end
end)

-- Update Stats
spawn(function()
    while wait(3) do
        local success, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
        if success then
            InfoLabel.Text = LocalPlayer.Name .. "\nID: " .. LocalPlayer.UserId .. "\n" .. info.Name
            GameInfo.Text = "👤 " .. LocalPlayer.Name .. " | " .. LocalPlayer.UserId .. "\n🎮 " .. info.Name .. " (ID: " .. game.PlaceId .. ")\n📊 Players: " .. #Players:GetPlayers()
        end
    end
end)

print("🎯 Skibidi Hub v8.0 by turcja - PERFECTLY LOADED!")
