-- Iskra Hub v6.0 - Created by turcja
-- Professional Roblox Exploit GUI (Dark Gray Theme - Exact Match to Reference)
-- Toggle: Left Shift | Key: "iskra" | Fully Draggable | Smooth Animations

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

-- Theme (Exact dark gray from reference image)
local Theme = {
    BgPrimary = Color3.fromRGB(32, 32, 42),
    BgSecondary = Color3.fromRGB(45, 45, 55),
    BgTertiary = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(100, 100, 120),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(200, 200, 210),
    Stroke = Color3.fromRGB(60, 60, 75),
    Success = Color3.fromRGB(100, 200, 100),
    Error = Color3.fromRGB(255, 100, 100)
}

-- State
local GuiVisible = false
local Authenticated = false
local Connections = {}
local Toggles = {
    Fly = false, Noclip = false, Speed = false, Jump = false
}

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IskraHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Frame (Draggable)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 400)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
MainFrame.BackgroundColor3 = Theme.BgPrimary
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Corner & Stroke
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Stroke
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = Theme.BgSecondary
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local HeaderStroke = Instance.new("UIStroke")
HeaderStroke.Color = Theme.Stroke
HeaderStroke.Thickness = 1
HeaderStroke.Parent = Header

-- Header Content
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Iskra Hub v6.0"
Title.TextColor3 = Theme.TextPrimary
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Header

local UserInfo = Instance.new("TextLabel")
UserInfo.Name = "UserInfo"
UserInfo.Size = UDim2.new(0.3, 0, 1, 0)
UserInfo.Position = UDim2.new(0.6, 0, 0, 0)
UserInfo.BackgroundTransparency = 1
UserInfo.Text = "Loading..."
UserInfo.TextColor3 = Theme.TextSecondary
UserInfo.TextScaled = true
UserInfo.Font = Enum.Font.Gotham
UserInfo.TextXAlignment = Enum.TextXAlignment.Right
UserInfo.Parent = Header

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "Minimize"
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -45, 0.5, -15)
MinimizeBtn.BackgroundColor3 = Theme.Accent
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Theme.TextPrimary
MinimizeBtn.TextScaled = true
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = Header

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeBtn

-- Tab System
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 0, 40)
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -20, 1, -110)
ContentContainer.Position = UDim2.new(0, 10, 0, 95)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Tabs Data
local Tabs = {
    {Name = "Player", Content = {}},
    {Name = "Combat", Content = {}},
    {Name = "Troll", Content = {}},
    {Name = "ToH", Content = {}},
    {Name = "GitHub", Content = {}},
    {Name = "Utility", Content = {}},
    {Name = "turcja", Content = {}}
}

-- Create Tabs
local CurrentTab = nil
for i, tabData in ipairs(Tabs) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = tabData.Name
    TabBtn.Size = UDim2.new(1/7, -5, 1, 0)
    TabBtn.Position = UDim2.new((i-1)/7, 0, 0, 0)
    TabBtn.BackgroundColor3 = Theme.BgTertiary
    TabBtn.Text = tabData.Name
    TabBtn.TextColor3 = Theme.TextSecondary
    TabBtn.TextScaled = true
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = TabContainer
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabBtn
    
    local TabStroke = Instance.new("UIStroke")
    TabStroke.Color = Theme.Stroke
    TabStroke.Thickness = 1
    TabStroke.Parent = TabBtn
    
    -- Tab Content Frame
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = tabData.Name .. "Content"
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.Position = UDim2.new(0, 0, 0, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 6
    TabContent.ScrollBarImageColor3 = Theme.Accent
    TabContent.Visible = false
    TabContent.Parent = ContentContainer
    
    local TabContentLayout = Instance.new("UIListLayout")
    TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabContentLayout.Padding = UDim.new(0, 8)
    TabContentLayout.Parent = TabContent
    
    TabBtn.MouseButton1Click:Connect(function()
        if CurrentTab then
            CurrentTab.Visible = false
        end
        CurrentTab = TabContent
        TabContent.Visible = true
        for _, btn in ipairs(TabContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Theme.BgTertiary
                btn.TextColor3 = Theme.TextSecondary
            end
        end
        TabBtn.BackgroundColor3 = Theme.Accent
        TabBtn.TextColor3 = Theme.TextPrimary
    end)
end

-- Populate Tabs with Controls
local function CreateToggle(parent, name, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -16, 0, 35)
    ToggleFrame.BackgroundColor3 = Theme.BgSecondary
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = Theme.Stroke
    ToggleStroke.Thickness = 1
    ToggleStroke.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Theme.TextPrimary
    ToggleLabel.TextScaled = true
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 25, 0, 25)
    ToggleBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
    ToggleBtn.BackgroundColor3 = Theme.BgTertiary
    ToggleBtn.Text = ""
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ToggleFrame
    
    local ToggleBtnCorner = Instance.new("UICorner")
    ToggleBtnCorner.CornerRadius = UDim.new(0, 12)
    ToggleBtnCorner.Parent = ToggleBtn
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
    ToggleCircle.Position = UDim2.new(0, 3.5, 0.5, -9)
    ToggleCircle.BackgroundColor3 = Theme.Error
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Parent = ToggleBtn
    
    local ToggleCircleCorner = Instance.new("UICorner")
    ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCircleCorner.Parent = ToggleCircle
    
    local toggled = false
    ToggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        local tween = TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
            BackgroundColor3 = toggled and Theme.Success or Theme.Error,
            Position = toggled and UDim2.new(1, -21.5, 0.5, -9) or UDim2.new(0, 3.5, 0.5, -9)
        })
        tween:Play()
        callback(toggled)
    end)
    
    return function(state) 
        toggled = state
        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Theme.Success or Theme.Error,
            Position = state and UDim2.new(1, -21.5, 0.5, -9) or UDim2.new(0, 3.5, 0.5, -9)
        }):Play()
    end
end

local function CreateButton(parent, name, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -16, 0, 40)
    Button.BackgroundColor3 = Theme.Accent
    Button.Text = name
    Button.TextColor3 = Theme.TextPrimary
    Button.TextScaled = true
    Button.Font = Enum.Font.GothamSemibold
    Button.BorderSizePixel = 0
    Button.Parent = parent
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        local tween1 = TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, -18, 0, 38)})
        local tween2 = TweenService:Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -16, 0, 40)})
        tween1:Play()
        tween1.Completed:Connect(function() callback() tween2:Play() end)
    end)
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.BgSecondary}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
    end)
end

-- Fill Player Tab
local PlayerContent = ContentContainer:FindFirstChild("PlayerContent")
CreateToggle(PlayerContent, "Fly (X)", function(state) Toggles.Fly = state end)
CreateToggle(PlayerContent, "Noclip (C)", function(state) Toggles.Noclip = state end)
CreateToggle(PlayerContent, "Speed (V)", function(state) Toggles.Speed = state end)
CreateToggle(PlayerContent, "High Jump (B)", function(state) Toggles.Jump = state end)
CreateButton(PlayerContent, "Reset Character", function() LocalPlayer.Character:BreakJoints() end)
CreateButton(PlayerContent, "Rejoin Server", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)

-- Combat Tab
local CombatContent = ContentContainer:FindFirstChild("CombatContent")
CreateButton(CombatContent, "Ultimate Fling All", function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            hrp.Velocity = Vector3.new(0, 50000, 0)
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 5000, 0)
        end
    end
end)
CreateButton(CombatContent, "Kill All Players", function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            player.Character:BreakJoints()
        end
    end
end)

-- Troll Tab
local TrollContent = ContentContent:FindFirstChild("TrollContent")
CreateButton(TrollContent, "Fling Server", function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj ~= workspace.CurrentCamera then
            obj.Velocity = Vector3.new(math.random(-5000,5000), 50000, math.random(-5000,5000))
        end
    end
end)
CreateButton(TrollContent, "Delete Map", function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent ~= LocalPlayer.Character then
            obj:Destroy()
        end
    end
end)

-- ToH Tab (Tower of Hell specific)
local ToHContent = ContentContainer:FindFirstChild("ToHContent")
CreateButton(ToHContent, "Auto Win ToH", function()
    -- Tower of Hell win exploit
    local args = {game:GetService("ReplicatedStorage").DefaultStore.Event:InvokeServer("win")}
end)
CreateButton(ToHContent, "TP to End", function()
    if workspace:FindFirstChild("End") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.End.CFrame
    end
end)

-- GitHub Tab
local GitHubContent = ContentContainer:FindFirstChild("GitHubContent")
CreateButton(GitHubContent, "Load Infinite Yield", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)
CreateButton(GitHubContent, "Load CMD-X", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/bloxcmds/cmdx/main/cmdx.lua"))()
end)
CreateButton(GitHubContent, "Load Dark Dex", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua", true))()
end)

-- Utility Tab
local UtilityContent = ContentContainer:FindFirstChild("UtilityContent")
CreateButton(UtilityContent, "ReplicatedStorage ESP", function()
    -- Simple ESP example
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Theme.Success
            highlight.OutlineColor = Theme.Accent
            highlight.Parent = player.Character
        end
    end
end)
CreateButton(UtilityContent, "Server Crash", function()
    while wait() do
        game:GetService("ReplicatedStorage").DefaultStore.Event:FireServer("win")
    end
end)

-- turcja Tab (Credits & Settings)
local TurcjaContent = ContentContainer:FindFirstChild("turcjaContent")
local CreditLabel = Instance.new("TextLabel")
CreditLabel.Size = UDim2.new(1, -20, 0, 60)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "Created by turcja \nIskra Hub v1.0"
CreditLabel.TextColor3 = Theme.Accent
CreditLabel.TextScaled = true
CreditLabel.Font = Enum.Font.GothamBold
CreditLabel.Parent = TurcjaContent

-- Auth GUI
local AuthFrame = Instance.new("Frame")
AuthFrame.Name = "AuthFrame"
AuthFrame.Size = UDim2.new(0, 300, 0, 200)
AuthFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
AuthFrame.BackgroundColor3 = Theme.BgPrimary
AuthFrame.Active = true
AuthFrame.Draggable = true
AuthFrame.Parent = ScreenGui

local AuthCorner = Instance.new("UICorner")
AuthCorner.CornerRadius = UDim.new(0, 16)
AuthCorner.Parent = AuthFrame

local AuthStroke = Instance.new("UIStroke")
AuthStroke.Color = Theme.Stroke
AuthStroke.Thickness = 2
AuthStroke.Parent = AuthFrame

local AuthTitle = Instance.new("TextLabel")
AuthTitle.Size = UDim2.new(1, 0, 0, 60)
AuthTitle.BackgroundTransparency = 1
AuthTitle.Text = "Iskra Hub Authentication"
AuthTitle.TextColor3 = Theme.TextPrimary
AuthTitle.TextScaled = true
AuthTitle.Font = Enum.Font.GothamBold
AuthTitle.Parent = AuthFrame

local AuthInput = Instance.new("TextBox")
AuthInput.Size = UDim2.new(0.85, 0, 0, 40)
AuthInput.Position = UDim2.new(0.075, 0, 0, 80)
AuthInput.BackgroundColor3 = Theme.BgSecondary
AuthInput.Text = ""
AuthInput.PlaceholderText = "Enter key: iskra"
AuthInput.TextColor3 = Theme.TextPrimary
AuthInput.PlaceholderColor3 = Theme.TextSecondary
AuthInput.TextScaled = true
AuthInput.Font = Enum.Font.Gotham
AuthInput.ClearTextOnFocus = false
AuthInput.Parent = AuthFrame

local AuthInputCorner = Instance.new("UICorner")
AuthInputCorner.CornerRadius = UDim.new(0, 10)
AuthInputCorner.Parent = AuthInput

local AuthBtn = Instance.new("TextButton")
AuthBtn.Size = UDim2.new(0.4, 0, 0, 45)
AuthBtn.Position = UDim2.new(0.1, 0, 0, 140)
AuthBtn.BackgroundColor3 = Theme.Success
AuthBtn.Text = "Authenticate"
AuthBtn.TextColor3 = Theme.TextPrimary
AuthBtn.TextScaled = true
AuthBtn.Font = Enum.Font.GothamBold
AuthBtn.Parent = AuthFrame

local AuthBtnCorner = Instance.new("UICorner")
AuthBtnCorner.CornerRadius = UDim.new(0, 12)
AuthBtnCorner.Parent = AuthBtn

-- Show first tab by default
ContentContainer.PlayerContent.Visible = true
TabContainer.Player.TextButton.BackgroundColor3 = Theme.Accent
TabContainer.Player.TextButton.TextColor3 = Theme.TextPrimary

-- Update User Info
spawn(function()
    while wait(1) do
        if LocalPlayer then
            UserInfo.Text = LocalPlayer.Name .. "\nID: " .. LocalPlayer.UserId .. "\n" .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end
    end
end)

-- Auth Logic
local function Authenticate()
    if AuthInput.Text == "iskra" then
        Authenticated = true
        local tween = TweenService:Create(AuthFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -150, -1, -100)
        })
        tween:Play()
        tween.Completed:Connect(function()
            AuthFrame:Destroy()
        end)
        wait(0.5)
        ShowMainFrame()
    else
        AuthInput.Text = ""
        AuthInput.PlaceholderText = "Wrong key! Try: iskra"
        TweenService:Create(AuthBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Error}):Play()
        wait(0.5)
        TweenService:Create(AuthBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Success}):Play()
    end
end

AuthBtn.MouseButton1Click:Connect(Authenticate)
AuthInput.FocusLost:Connect(Authenticate)

-- Main Frame Functions
function ShowMainFrame()
    MainFrame.Visible = true
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -275, 0.5, -200)
    })
    tween:Play()
end

function HideMainFrame()
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0.5, -275, -1, -200)
    })
    tween:Play()
    tween.Completed:Connect(function()
        MainFrame.Visible = false
    end)
end

MinimizeBtn.MouseButton1Click:Connect(function()
    if MainFrame.Size.Y.Offset > 50 then
        -- Minimize
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 550, 0, 50)
        }):Play()
        MinimizeBtn.Text = "+"
    else
        -- Maximize
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 550, 0, 400)
        }):Play()
        MinimizeBtn.Text = "-"
    end
end)

-- Toggle Visibility
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        GuiVisible = not GuiVisible
        if GuiVisible then
            ShowMainFrame()
        else
            HideMainFrame()
        end
    elseif Authenticated then
        -- Binds
        if input.KeyCode == Enum.KeyCode.X then Toggles.Fly = not Toggles.Fly end
        if input.KeyCode == Enum.KeyCode.C then Toggles.Noclip = not Toggles.Noclip end
        if input.KeyCode == Enum.KeyCode.V then Toggles.Speed = not Toggles.Speed end
        if input.KeyCode == Enum.KeyCode.B then Toggles.Jump = not Toggles.Jump end
    end
end)

-- Exploit Functions
local FlyConnection, NoclipConnection

-- Fly
spawn(function()
    while true do
        wait()
        if Toggles.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            if not FlyConnection then
                local bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                bg.CFrame = hrp.CFrame
                bg.Parent = hrp
                
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Velocity = Vector3.new(0, 0.1, 0)
                bv.Parent = hrp
                
                FlyConnection = {bg, bv}
            end
            FlyConnection[1].CFrame = workspace.CurrentCamera.CFrame
            FlyConnection[2].Velocity = Vector3.new(0, 0.1, 0)
        elseif FlyConnection then
            for _, obj in ipairs(FlyConnection) do obj:Destroy() end
            FlyConnection = nil
        end
    end
end)

-- Noclip
NoclipConnection = RunService.Stepped:Connect(function()
    if Toggles.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Speed & Jump
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        if Toggles.Speed then hum.WalkSpeed = 100 end
        if Toggles.Jump then hum.JumpPower = 100 end
    end
end)

print("Iskra Hub v1.0 loaded!")
print("Created by turcja.")
