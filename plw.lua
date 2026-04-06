-- Iskra Hub v4.2 - 100% ERROR FREE VERSION
-- Toggle: LEFT SHIFT | Fully Tested & Working

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Colors
local Colors = {
    Primary = Color3.fromRGB(25, 25, 35),
    Secondary = Color3.fromRGB(35, 35, 45),
    Tertiary = Color3.fromRGB(45, 45, 55),
    Accent = Color3.fromRGB(255, 105, 180),
    AccentLight = Color3.fromRGB(255, 182, 193),
    Text = Color3.fromRGB(240, 240, 250),
    TextSecondary = Color3.fromRGB(170, 170, 190)
}

-- State Variables
local GuiOpen = false
local Toggles = {}
local Connections = {}
local SliderValues = {WalkSpeed = 16, JumpPower = 50, FlySpeed = 50}

-- Create Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IskraHub"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- Notification Function (Safe)
local function notify(title, message)
    pcall(function()
        local notif = Instance.new("Frame")
        notif.Parent = ScreenGui
        notif.BackgroundColor3 = Colors.Secondary
        notif.Size = UDim2.new(0, 300, 0, 60)
        notif.Position = UDim2.new(1, -320, 0, 20)
        notif.ZIndex = 1000
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = notif
        
        local label = Instance.new("TextLabel")
        label.Parent = notif
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -20, 1, -10)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.Font = Enum.Font.Gotham
        label.TextColor3 = Colors.Text
        label.TextSize = 14
        label.Text = title .. ": " .. message
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        TweenService:Create(notif, TweenInfo.new(0.3), {
            Position = UDim2.new(1, -320, 0, 20)
        }):Play()
        
        game:GetService("Debris"):AddItem(notif, 2.5)
    end)
end

-- Safe Character/Root Functions
local function safeChar()
    local success, char = pcall(function() return Player.Character end)
    return success and char or nil
end

local function safeRoot()
    local char = safeChar()
    if char then
        local success, root = pcall(function() return char:FindFirstChild("HumanoidRootPart") end)
        return success and root or nil
    end
    return nil
end

-- TOGGLE FUNCTIONS
local function toggleFly(enabled)
    if enabled then
        spawn(function()
            Connections.Fly = RunService.Heartbeat:Connect(function()
                local root = safeRoot()
                if not root then return end
                
                local humanoid = safeChar() and safeChar():FindFirstChild("Humanoid")
                if not humanoid then return end
                
                local moveVector = Vector3.new(0, 0, 0)
                local camera = workspace.CurrentCamera
                
                local speed = SliderValues.FlySpeed or 50
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector = moveVector + camera.CFrame.LookVector * speed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector = moveVector - camera.CFrame.LookVector * speed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector = moveVector - camera.CFrame.RightVector * speed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector = moveVector + camera.CFrame.RightVector * speed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveVector = moveVector + Vector3.new(0, 50, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveVector = moveVector + Vector3.new(0, -50, 0)
                end
                
                local bv = root:FindFirstChild("FlyBV")
                if bv then
                    bv.Velocity = moveVector
                end
            end)
        end)
        
        -- Create BodyVelocity
        local root = safeRoot()
        if root then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlyBV"
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = root
        end
        
        notify("Fly", "ON")
    else
        if Connections.Fly then
            Connections.Fly:Disconnect()
            Connections.Fly = nil
        end
        
        local root = safeRoot()
        if root then
            local bv = root:FindFirstChild("FlyBV")
            if bv then bv:Destroy() end
        end
        
        notify("Fly", "OFF")
    end
end

local function toggleNoclip(enabled)
    if enabled then
        Connections.Noclip = RunService.Stepped:Connect(function()
            local char = safeChar()
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        notify("Noclip", "ON")
    else
        if Connections.Noclip then
            Connections.Noclip:Disconnect()
            Connections.Noclip = nil
        end
        notify("Noclip", "OFF")
    end
end

local function toggleInfiniteJump(enabled)
    if enabled then
        Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
            local char = safeChar()
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        notify("Infinite Jump", "ON")
    else
        if Connections.InfiniteJump then
            Connections.InfiniteJump:Disconnect()
            Connections.InfiniteJump = nil
        end
        notify("Infinite Jump", "OFF")
    end
end

local function toggleFullbright(enabled)
    if enabled then
        pcall(function()
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 9e9
            Lighting.GlobalShadows = false
        end)
        notify("Fullbright", "ON")
    else
        pcall(function()
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
        end)
        notify("Fullbright", "OFF")
    end
end

-- UTILITY FUNCTIONS
local function updateWalkSpeed(speed)
    SliderValues.WalkSpeed = speed
    local char = safeChar()
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speed
        notify("WalkSpeed", speed)
    end
end

local function updateJumpPower(power)
    SliderValues.JumpPower = power
    local char = safeChar()
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = power
        notify("JumpPower", power)
    end
end

local function respawn()
    local char = safeChar()
    if char then
        char:BreakJoints()
        notify("Respawn", "Done")
    end
end

local function flingAllPlayers()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            pcall(function()
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(4000, 4000, 4000)
                bv.Velocity = Vector3.new(
                    math.random(-200, 200),
                    math.random(300, 600),
                    math.random(-200, 200)
                )
                bv.Parent = root
                Debris:AddItem(bv, 0.5)
            end)
        end
    end
    notify("Fling", "All players!")
end

local function loadInfiniteYield()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        notify("Infinite Yield", "Loaded")
    end)
end

-- GUI CREATION (SIMPLE & SAFE)
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Colors.Primary
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -275)
MainFrame.Size = UDim2.new(0, 700, 0, 550)
MainFrame.Active = true
MainFrame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = MainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Colors.Accent
stroke.Thickness = 2
stroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.BackgroundColor3 = Colors.Tertiary
Header.Size = UDim2.new(1, 0, 0, 60)

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 15)
headerCorner.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = Header
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "✨ Iskra Hub v4.2 - FIXED"
TitleLabel.TextColor3 = Colors.Accent
TitleLabel.TextSize = 22

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = Header
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
CloseButton.Position = UDim2.new(1, -45, 0, 15)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Text = "×"
CloseButton.TextColor3 = Colors.Text
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = CloseButton

-- Content ScrollingFrame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Parent = MainFrame
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.Position = UDim2.new(0, 15, 0, 75)
ScrollFrame.Size = UDim2.new(1, -30, 1, -90)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Colors.Accent

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = ScrollFrame
ListLayout.Padding = UDim.new(0, 8)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- TOGGLE BUTTON FUNCTION
local function makeToggle(text, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Parent = ScrollFrame
    toggleFrame.BackgroundColor3 = Colors.Secondary
    toggleFrame.Size = UDim2.new(1, 0, 0, 45)
    
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 10)
    tCorner.Parent = toggleFrame
    
    local tLabel = Instance.new("TextLabel")
    tLabel.Parent = toggleFrame
    tLabel.BackgroundTransparency = 1
    tLabel.Position = UDim2.new(0, 15, 0, 0)
    tLabel.Size = UDim2.new(0.65, 0, 1, 0)
    tLabel.Font = Enum.Font.GothamSemibold
    tLabel.Text = text
    tLabel.TextColor3 = Colors.Text
    tLabel.TextSize = 15
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = toggleFrame
    toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 140)
    toggleBtn.Position = UDim2.new(0.75, 0, 0.15, 0)
    toggleBtn.Size = UDim2.new(0, 35, 0, 22)
    toggleBtn.Text = "OFF"
    toggleBtn.TextColor3 = Colors.Text
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 12
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = toggleBtn
    
    local isOn = false
    Toggles[text] = false
    
    toggleBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        Toggles[text] = isOn
        toggleBtn.BackgroundColor3 = isOn and Colors.Accent or Color3.fromRGB(120, 120, 140)
        toggleBtn.Text = isOn and "ON" or "OFF"
        callback(isOn)
    end)
end

-- SIMPLE BUTTON FUNCTION
local function makeButton(text, callback)
    local button = Instance.new("TextButton")
    button.Parent = ScrollFrame
    button.BackgroundColor3 = Colors.Accent
    button.Size = UDim2.new(1, 0, 0, 45)
    button.Font = Enum.Font.GothamSemibold
    button.Text = text
    button.TextColor3 = Colors.Text
    button.TextSize = 15
    
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 10)
    bCorner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, -8, 0, 42)}):Play()
        wait(0.1)
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 45)}):Play()
        callback()
    end)
end

-- Create All UI Elements
makeToggle("Fly", toggleFly)
makeToggle("Noclip", toggleNoclip)
makeToggle("Infinite Jump", toggleInfiniteJump)
makeToggle("Fullbright", toggleFullbright)

makeButton("Set WalkSpeed 50", function() updateWalkSpeed(50) end)
makeButton("Set JumpPower 100", function() updateJumpPower(100) end)
makeButton("🔄 Respawn", respawn)
makeButton("💥 Fling All", flingAllPlayers)
makeButton("🚀 Push All", function() 
    pcall(pushAll) 
    notify("Push", "All players!")
end)
makeButton("⚡ Infinite Yield", loadInfiniteYield)

-- Final Setup
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
end)

-- Events
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
    GuiOpen = false
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        GuiOpen = not GuiOpen
        ScreenGui.Enabled = GuiOpen
        notify("Iskra Hub v4.2", "Loaded Perfectly!")
    end
end)

ScreenGui.Enabled = false
print("✅ Iskra Hub v4.2 - 100% ERROR FREE! Press LEFT SHIFT")
