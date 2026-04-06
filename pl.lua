-- Iskra Hub v4.0 - ULTIMATE Dark Professional Edition
-- Created by: turcja | Enhanced by: HackerAI
-- Toggle: LEFT SHIFT

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- Enhanced Dark Theme Colors
local Colors = {
    Primary = Color3.fromRGB(20, 20, 30),
    Secondary = Color3.fromRGB(30, 30, 40),
    Tertiary = Color3.fromRGB(40, 40, 50),
    Accent = Color3.fromRGB(255, 85, 170),
    AccentLight = Color3.fromRGB(255, 150, 190),
    AccentDark = Color3.fromRGB(200, 50, 140),
    TextPrimary = Color3.fromRGB(245, 245, 255),
    TextSecondary = Color3.fromRGB(180, 180, 200),
    Success = Color3.fromRGB(100, 255, 150),
    Warning = Color3.fromRGB(255, 200, 100),
    Error = Color3.fromRGB(255, 100, 100),
    Shadow = Color3.fromRGB(0, 0, 0)
}

-- State Management
local GuiOpen = false
local Toggles = {}
local Connections = {}
local Sliders = {}

-- Main GUI
local MainGui = Instance.new("ScreenGui")
MainGui.Name = HttpService:GenerateGUID(false)
MainGui.Parent = PlayerGui
MainGui.ResetOnSpawn = false
MainGui.Enabled = false
MainGui.DisplayOrder = 999

-- Notification System
local Notifications = {}
local function createNotification(title, message, duration)
    local notif = Instance.new("Frame")
    notif.Parent = MainGui
    notif.BackgroundColor3 = Colors.Secondary
    notif.Size = UDim2.new(0, 300, 0, 80)
    notif.Position = UDim2.new(0, 20, 0, 20 + (#Notifications * 90))
    notif.ClipsDescendants = true
    
    local corner = Instance.new("UICorner", notif)
    corner.CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = Colors.Accent
    stroke.Thickness = 1.5
    
    local titleLabel = Instance.new("TextLabel", notif)
    titleLabel.Size = UDim2.new(1, -20, 0.5, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = Colors.TextPrimary
    titleLabel.TextSize = 16
    titleLabel.Text = title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local msgLabel = Instance.new("TextLabel", notif)
    msgLabel.Size = UDim2.new(1, -20, 0.4, 0)
    msgLabel.Position = UDim2.new(0, 15, 0.5, 0)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextColor3 = Colors.TextSecondary
    msgLabel.TextSize = 13
    msgLabel.Text = message
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    table.insert(Notifications, notif)
    
    TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(0, 20, 0, 20 + ((#Notifications-1) * 90))}):Play()
    
    game:GetService("Debris"):AddItem(notif, duration or 3)
    notif:Destroying:Connect(function()
        for i, v in pairs(Notifications) do
            if v == notif then
                table.remove(Notifications, i)
                for j = i, #Notifications do
                    TweenService:Create(Notifications[j], TweenInfo.new(0.3), {
                        Position = UDim2.new(0, 20, 0, 20 + ((j-1) * 90))
                    }):Play()
                end
                break
            end
        end
    end)
end

-- Main Frame Creation
local MainFrame = nil
local function createMainFrame()
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = MainGui
    MainFrame.BackgroundColor3 = Colors.Primary
    MainFrame.Position = UDim2.new(0.5, -375, 0.5, -300)
    MainFrame.Size = UDim2.new(0, 750, 0, 600)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    
    -- Enhanced Visual Effects
    local corner = Instance.new("UICorner", MainFrame)
    corner.CornerRadius = UDim.new(0, 20)
    
    local stroke = Instance.new("UIStroke", MainFrame)
    stroke.Color = Colors.Accent
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    
    local gradient = Instance.new("UIGradient", MainFrame)
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Primary),
        ColorSequenceKeypoint.new(0.5, Colors.Secondary),
        ColorSequenceKeypoint.new(1, Colors.Tertiary)
    }
    gradient.Rotation = 45
    
    -- Shadow Effect
    local shadow = Instance.new("Frame", MainFrame)
    shadow.Name = "Shadow"
    shadow.BackgroundColor3 = Colors.Shadow
    shadow.BackgroundTransparency = 0.8
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.ZIndex = -1
    local shadowCorner = Instance.new("UICorner", shadow)
    shadowCorner.CornerRadius = UDim.new(0, 20)
    
    return MainFrame
end

-- Header Creation
local function createHeader(parent)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = parent
    Header.BackgroundColor3 = Colors.Tertiary
    Header.Size = UDim2.new(1, 0, 0, 70)
    
    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 20)
    HeaderCorner.TopLeftRadius = 20
    HeaderCorner.TopRightRadius = 20
    
    local gradient = Instance.new("UIGradient", Header)
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Tertiary),
        ColorSequenceKeypoint.new(1, Colors.Secondary)
    }
    
    -- Logo
    local Logo = Instance.new("TextLabel")
    Logo.Parent = Header
    Logo.BackgroundTransparency = 1
    Logo.Position = UDim2.new(0, 25, 0, 10)
    Logo.Size = UDim2.new(0, 200, 0, 50)
    Logo.Font = Enum.Font.GothamBold
    Logo.Text = "✨ ISKRA HUB v4.0"
    Logo.TextColor3 = Colors.Accent
    Logo.TextSize = 28
    Logo.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Version
    local Version = Instance.new("TextLabel")
    Version.Parent = Header
    Version.BackgroundTransparency = 1
    Version.Position = UDim2.new(0, 25, 0, 45)
    Version.Size = UDim2.new(0, 200, 0, 20)
    Version.Font = Enum.Font.Gotham
    Version.Text = "ULTIMATE EDITION"
    Version.TextColor3 = Colors.TextSecondary
    Version.TextSize = 12
    Version.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Player Info
    local PlayerFrame = Instance.new("Frame")
    PlayerFrame.Parent = Header
    PlayerFrame.BackgroundColor3 = Colors.Secondary
    PlayerFrame.Position = UDim2.new(0.65, -10, 0.15, 0)
    PlayerFrame.Size = UDim2.new(0.2, 0, 0.7, 0)
    
    local PlayerCorner = Instance.new("UICorner", PlayerFrame)
    PlayerCorner.CornerRadius = UDim.new(0, 12)
    
    local PlayerLabel = Instance.new("TextLabel", PlayerFrame)
    PlayerLabel.BackgroundTransparency = 1
    PlayerLabel.Size = UDim2.new(1, -12, 1, 0)
    PlayerLabel.Position = UDim2.new(0, 8, 0, 0)
    PlayerLabel.Font = Enum.Font.GothamSemibold
    PlayerLabel.Text = Player.Name .. "\n" .. Player.UserId
    PlayerLabel.TextColor3 = Colors.TextPrimary
    PlayerLabel.TextSize = 14
    PlayerLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = Header
    CloseBtn.BackgroundColor3 = Colors.Error
    CloseBtn.Position = UDim2.new(1, -50, 0, 20)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Colors.TextPrimary
    CloseBtn.TextSize = 18
    
    local CloseCorner = Instance.new("UICorner", CloseBtn)
    CloseCorner.CornerRadius = UDim.new(0, 8)
    
    return CloseBtn
end

-- Enhanced Toggle
local function createToggle(parent, name, defaultState, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name .. "Toggle"
    ToggleFrame.Parent = parent
    ToggleFrame.BackgroundColor3 = Colors.Secondary
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    
    local corner = Instance.new("UICorner", ToggleFrame)
    corner.CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", ToggleFrame)
    stroke.Color = Colors.AccentDark
    stroke.Thickness = 1
    
    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 20, 0, 0)
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = name
    Label.TextColor3 = Colors.TextPrimary
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleBtn = Instance.new("Frame")
    ToggleBtn.Parent = ToggleFrame
    ToggleBtn.BackgroundColor3 = Colors.Error
    ToggleBtn.Position = UDim2.new(0.75, 0, 0.2, 0)
    ToggleBtn.Size = UDim2.new(0, 30, 0, 20)
    
    local BtnCorner = Instance.new("UICorner", ToggleBtn)
    BtnCorner.CornerRadius = UDim.new(0, 10)
    
    local Knob = Instance.new("Frame")
    Knob.Parent = ToggleBtn
    Knob.BackgroundColor3 = Colors.TextPrimary
    Knob.Size = UDim2.new(0.45, 0, 0.85, 0)
    Knob.Position = UDim2.new(0, 2, 0.075, 0)
    
    local KnobCorner = Instance.new("UICorner", Knob)
    KnobCorner.CornerRadius = UDim.new(0, 10)
    
    local state = defaultState or false
    Toggles[name] = state
    
    local function updateToggle(newState)
        state = newState
        Toggles[name] = state
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Colors.Success or Colors.Error
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(0.55, -2, 0.075, 0) or UDim2.new(0, 2, 0.075, 0)
        }):Play()
        callback(state)
    end
    
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateToggle(not state)
        end
    end)
    
    return ToggleFrame
end

-- Enhanced Button
local function createButton(parent, name, callback, color)
    local Button = Instance.new("TextButton")
    Button.Name = name .. "Btn"
    Button.Parent = parent
    Button.BackgroundColor3 = color or Colors.Accent
    Button.Size = UDim2.new(1, 0, 0, 50)
    Button.Font = Enum.Font.GothamSemibold
    Button.Text = name
    Button.TextColor3 = Colors.TextPrimary
    Button.TextSize = 15
    
    local corner = Instance.new("UICorner", Button)
    corner.CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", Button)
    stroke.Color = Colors.AccentDark
    stroke.Thickness = 1.5
    
    Button.MouseButton1Click:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
            Size = UDim2.new(1, -10, 0, 45),
            Rotation = 2
        }):Play()
        wait(0.1)
        TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
            Size = UDim2.new(1, 0, 0, 50),
            Rotation = 0
        }):Play()
        callback()
    end)
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = (color or Colors.AccentLight) or Colors.AccentLight
        }):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = color or Colors.Accent
        }):Play()
    end)
    
    return Button
end

-- Slider
local function createSlider(parent, name, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = name .. "Slider"
    SliderFrame.Parent = parent
    SliderFrame.BackgroundColor3 = Colors.Secondary
    SliderFrame.Size = UDim2.new(1, 0, 0, 60)
    
    local corner = Instance.new("UICorner", SliderFrame)
    corner.CornerRadius = UDim.new(0, 12)
    
    local Label = Instance.new("TextLabel")
    Label.Parent = SliderFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 20, 0, 5)
    Label.Size = UDim2.new(0.5, 0, 0.5, 0)
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = name .. ": " .. default
    Label.TextColor3 = Colors.TextPrimary
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Parent = SliderFrame
    SliderBar.BackgroundColor3 = Colors.Tertiary
    SliderBar.Position = UDim2.new(0, 20, 0.6, 0)
    SliderBar.Size = UDim2.new(0.8, 0, 0, 8)
    
    local SliderCorner = Instance.new("UICorner", SliderBar)
    SliderCorner.CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Parent = SliderBar
    Fill.BackgroundColor3 = Colors.Accent
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.ZIndex = 2
    
    local FillCorner = Instance.new("UICorner", Fill)
    FillCorner.CornerRadius = UDim.new(1, 0)
    
    local Knob = Instance.new("Frame")
    Knob.Parent = SliderBar
    Knob.BackgroundColor3 = Colors.TextPrimary
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new((default - min) / (max - min), -8, -0.5, 0)
    
    local KnobCorner = Instance.new("UICorner", Knob)
    KnobCorner.CornerRadius = UDim.new(0.5, 0)
    
    local dragging = false
    local value = default
    
    local function updateSlider(newValue)
        value = math.clamp(newValue, min, max)
        local percent = (value - min) / (max - min)
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Knob.Position = UDim2.new(percent, -8, -0.5, 0)
        Label.Text = name .. ": " .. math.floor(value)
        Sliders[name] = value
        callback(value)
    end
    
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    SliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mouse = UserInputService:GetMouseLocation()
            local relativeX = math.clamp((mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            updateSlider(min + (max - min) * relativeX)
        end
    end)
    
    updateSlider(default)
    return SliderFrame
end

-- Initialize GUI
createMainFrame()
local CloseBtn = createHeader(MainFrame)

-- Content Area
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "Content"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 20, 0, 85)
ContentFrame.Size = UDim2.new(1, -40, 1, -105)
ContentFrame.ScrollBarThickness = 6
ContentFrame.ScrollBarImageColor3 = Colors.Accent
ContentFrame.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
ContentFrame.ScrollBarImageTransparency = 0.3

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = ContentFrame
ContentLayout.Padding = UDim.new(0, 15)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Categories
local function createCategory(name, items)
    local CatFrame = Instance.new("Frame")
    CatFrame.Name = name
    CatFrame.Parent = ContentFrame
    CatFrame.BackgroundColor3 = Colors.Secondary
    CatFrame.Size = UDim2.new(1, 0, 0, 0)
    CatFrame.LayoutOrder = #ContentFrame:GetChildren()
    
    local CatCorner = Instance.new("UICorner", CatFrame)
    CatCorner.CornerRadius = UDim.new(0, 16)
    
    local stroke = Instance.new("UIStroke", CatFrame)
    stroke.Color = Colors.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    
    local Title = Instance.new("TextLabel")
    Title.Parent = CatFrame
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "  " .. name
    Title.TextColor3 = Colors.Accent
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local ItemLayout = Instance.new("UIListLayout")
    ItemLayout.Parent = CatFrame
    ItemLayout.Padding = UDim.new(0, 10)
    ItemLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    for i, item in pairs(items) do
        item.Parent = CatFrame
        item.LayoutOrder = i
    end
    
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 30)
    end)
    
    return CatFrame
end

-- WORKING FEATURES
local function getCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function getRoot()
    local char = getCharacter()
    return char:WaitForChild("HumanoidRootPart")
end

function toggleFly(state)
    if state then
        local char = getCharacter()
        local root = getRoot()
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(4000, 4000, 4000)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = root
        
        Connections.Fly = RunService.Heartbeat:Connect(function()
            if char.Parent and root.Parent then
                local moveVector = Vector3.new()
                local cam = workspace.CurrentCamera
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector = moveVector + cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector = moveVector - cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector = moveVector - cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector = moveVector + cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveVector = moveVector + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveVector = moveVector - Vector3.new(0, 1, 0)
                end
                
                bv.Velocity = moveVector * (Sliders["FlySpeed"] or 50)
            end
        end)
        createNotification("Fly", "Enabled", 2)
    else
        if Connections.Fly then
            Connections.Fly:Disconnect()
            Connections.Fly = nil
        end
        local bv = getRoot():FindFirstChild("BodyVelocity")
        if bv then bv:Destroy() end
        createNotification("Fly", "Disabled", 2)
    end
end

function toggleNoclip(state)
    if state then
        Connections.Noclip = RunService.Stepped:Connect(function()
            local char = getCharacter()
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        createNotification("Noclip", "Enabled", 2)
    else
        if Connections.Noclip then
            Connections.Noclip:Disconnect()
            Connections.Noclip = nil
        end
        createNotification("Noclip", "Disabled", 2)
    end
end

function toggleInfiniteJump(state)
    if state then
        Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
            local char = getCharacter()
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        createNotification("Infinite Jump", "Enabled", 2)
    else
        if Connections.InfiniteJump then
            Connections.InfiniteJump:Disconnect()
            Connections.InfiniteJump = nil
        end
        createNotification("Infinite Jump", "Disabled", 2)
    end
end

function toggleFullbright(state)
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 9e9
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(123, 123, 123)
        createNotification("Fullbright", "Enabled", 2)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 50)
        createNotification("Fullbright", "Disabled", 2)
    end
end

function setWalkSpeed(speed)
    local char = getCharacter()
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speed
        createNotification("WalkSpeed", "Set to " .. speed, 2)
    end
end

function setJumpPower(power)
    local char = getCharacter()
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = power
        createNotification("JumpPower", "Set to " .. power, 2)
    end
end

function respawnPlayer()
    local char = getCharacter()
    char:BreakJoints()
    createNotification("Respawn", "Player respawned", 2)
end

-- ENHANCED FLING (Better than basic fling)
function flingAll()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local fling = Instance.new("BodyVelocity")
            fling.MaxForce = Vector3.new(4000, 4000, 4000)
            fling.Velocity = Vector3.new(
                math.random(-500, 500),
                math.random(800, 1500),
                math.random(-500, 500)
            )
            fling.Parent = root
            
            local angular = Instance.new("BodyAngularVelocity")
            angular.MaxTorque = Vector3.new(4000, 4000, 4000)
            angular.AngularVelocity = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100))
            angular.Parent = root
            
            Debris:AddItem(fling, 0.3)
            Debris:AddItem(angular, 0.3)
        end
    end
    createNotification("Fling", "All players flung!", 3)
end

function pushAllPlayers()
    local myRoot = getRoot()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = plr.Character.HumanoidRootPart
            local direction = (targetRoot.Position - myRoot.Position).Unit
            local push = Instance.new("BodyVelocity")
            push.MaxForce = Vector3.new(4000, 0, 4000)
            push.Velocity = direction * 150 + Vector3.new(0, 50, 0)
            push.Parent = targetRoot
            Debris:AddItem(push, 0.4)
        end
    end
    createNotification("Push", "All players pushed!", 3)
end

function loadInfiniteYield()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    createNotification("Infinite Yield", "Loaded successfully!", 3)
end

-- Create Categories
createCategory("🌐 Universal", {
    createToggle(ContentFrame, "Fly", false, toggleFly),
    createSlider(ContentFrame, "FlySpeed", 16, 200, 50, function(v) end),
    createToggle(ContentFrame, "Noclip", false, toggleNoclip),
    createToggle(ContentFrame, "InfiniteJump", false, toggleInfiniteJump),
    createToggle(ContentFrame, "Fullbright", false, toggleFullbright),
    createSlider(ContentFrame, "WalkSpeed", 16, 200, 16, setWalkSpeed),
    createSlider(ContentFrame, "JumpPower", 0, 200, 50, setJumpPower),
    createButton(ContentFrame, "🔄 Respawn", respawnPlayer)
})

createCategory("😂 Troll", {
    createButton(ContentFrame, "💥 FLING ALL", flingAll, Colors.Error),
    createButton(ContentFrame, "🚀 PUSH ALL", pushAllPlayers, Colors.Warning),
    createButton(ContentFrame, "⚡ Infinite Yield", loadInfiniteYield, Colors.Success),
    createButton(ContentFrame, "🌪️ Server Crash", function()
        while wait() do
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("💥", "All")
        end
    end, Colors.Error)
})

createCategory("⭐ Extras", {
    createButton(ContentFrame, "🎨 Rejoin Server", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end),
    createButton(ContentFrame, "🗑️ Clear Debris", function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and obj.Name == "FlingPart" then
                obj:Destroy()
            end
        end
    end)
})

-- Toggle GUI with LEFT SHIFT
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        GuiOpen = not GuiOpen
        MainGui.Enabled = GuiOpen
        if GuiOpen then
            createNotification("Iskra Hub", "Opened (v4.0)", 1)
        end
    end
end)

-- Close Button
CloseBtn.MouseButton1Click:Connect(function()
    GuiOpen = false
    MainGui.Enabled = false
    createNotification("Iskra Hub", "Closed", 1)
end)

print("✅ Iskra Hub v4.0 ULTIMATE LOADED! Press LEFT SHIFT to toggle")
createNotification("Iskra Hub v4.0", "Loaded successfully! Press LEFT SHIFT", 4)
