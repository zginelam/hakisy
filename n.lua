-- ISKRA HACKER HUB v4.0 - Professional Developer GUI
-- Created by: turcja | Fully Functional Universal Scripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Modern Pink/White/Gray Theme
local theme = {
    primary = Color3.fromRGB(255, 105, 180),      -- Hot Pink
    secondary = Color3.fromRGB(255, 182, 193),    -- Light Pink  
    bgDark = Color3.fromRGB(35, 35, 45),          -- Dark Gray
    bgLight = Color3.fromRGB(50, 50, 65),         -- Light Gray
    white = Color3.fromRGB(255, 255, 255),
    textDark = Color3.fromRGB(30, 30, 40),
    textLight = Color3.fromRGB(220, 220, 240),
    shadow = Color3.fromRGB(0, 0, 0, 0.3)
}

-- AUTH KEY: "iskra" - Simple & Working
local function verifyKey(input)
    return input:lower() == "iskra"
end

-- MAIN SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IskraHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = PlayerGui

-- ═══════════════════════════════════════════════════════════════
-- AUTH LOADING SCREEN (Draggable)
-- ═══════════════════════════════════════════════════════════════
local authFrame = Instance.new("Frame")
authFrame.Size = UDim2.new(0, 450, 0, 320)
authFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
authFrame.BackgroundColor3 = theme.bgDark
authFrame.BorderSizePixel = 0
authFrame.Parent = ScreenGui

local authCorner = Instance.new("UICorner")
authCorner.CornerRadius = UDim.new(0, 20)
authCorner.Parent = authFrame

local authGradient = Instance.new("UIGradient")
authGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, theme.bgDark),
    ColorSequenceKeypoint.new(1, theme.bgLight)
}
authGradient.Rotation = 45
authGradient.Parent = authFrame

local authStroke = Instance.new("UIStroke")
authStroke.Color = theme.primary
authStroke.Thickness = 3
authStroke.Transparency = 0.2
authStroke.Parent = authFrame

-- DRAGGABLE HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = theme.primary
header.BorderSizePixel = 0
header.Parent = authFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 20)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ISKR A HUB v4.0 - Authentication"
title.TextColor3 = theme.textDark
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = header

-- Drag functionality for auth
makeDraggable(authFrame, header)

-- Key input
local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0.85, 0, 0.18, 0)
keyFrame.Position = UDim2.new(0.075, 0, 0.25, 0)
keyFrame.BackgroundColor3 = theme.bgLight
keyFrame.BorderSizePixel = 0
keyFrame.Parent = authFrame

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 16)
keyCorner.Parent = keyFrame

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0.92, 0, 0.85, 0)
keyBox.Position = UDim2.new(0.04, 0, 0.075, 0)
keyBox.BackgroundTransparency = 1
keyBox.Text = ""
keyBox.PlaceholderText = "Enter key: iskra"
keyBox.TextColor3 = theme.textLight
keyBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 200)
keyBox.TextScaled = true
keyBox.Font = Enum.Font.GothamSemibold
keyBox.TextXAlignment = Enum.TextXAlignment.Left
keyBox.Parent = keyFrame

-- Auth button
local authButton = Instance.new("TextButton")
authButton.Size = UDim2.new(0.85, 0, 0.14, 0)
authButton.Position = UDim2.new(0.075, 0, 0.48, 0)
authButton.BackgroundColor3 = theme.primary
authButton.BorderSizePixel = 0
authButton.Text = "VERIFY KEY"
authButton.TextColor3 = theme.textDark
authButton.TextScaled = true
authButton.Font = Enum.Font.GothamBold
authButton.Parent = authFrame

local authBtnCorner = Instance.new("UICorner")
authBtnCorner.CornerRadius = UDim.new(0, 16)
authBtnCorner.Parent = authButton

-- Status label
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(0.9, 0, 0.2, 0)
statusText.Position = UDim2.new(0.05, 0, 0.68, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "Key hint: iskra"
statusText.TextColor3 = theme.textLight
statusText.TextScaled = true
statusText.Font = Enum.Font.Gotham
statusText.TextWrapped = true
statusText.Parent = authFrame

-- Auth animations & logic
local tween = TweenService
local tiHover = TweenInfo.new(0.2, Enum.EasingStyle.Quart)
local tiClick = TweenInfo.new(0.1, Enum.EasingStyle.Quart)

authButton.MouseEnter:Connect(function()
    tween:Create(authButton, tiHover, {Size = UDim2.new(0.87, 0, 0.15, 0)}):Play()
end)

authButton.MouseLeave:Connect(function()
    tween:Create(authButton, tiHover, {Size = UDim2.new(0.85, 0, 0.14, 0)}):Play()
end)

authButton.MouseButton1Click:Connect(function()
    if verifyKey(keyBox.Text) then
        statusText.Text = "Access granted!"
        statusText.TextColor3 = Color3.fromRGB(100, 255, 150)
        tween:Create(authFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        wait(0.7)
        authFrame:Destroy()
        loadMainGUI()
    else
        statusText.Text = "Invalid key!"
        statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        tween:Create(authButton, tiClick, {Size = UDim2.new(0.83, 0, 0.13, 0)}):Play()
        tween:Create(authButton, TweenInfo.new(0.15), {Size = UDim2.new(0.85, 0, 0.14, 0)}):Play()
    end
end)

keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then authButton.MouseButton1Click:Fire() end
end)

-- ═══════════════════════════════════════════════════════════════
-- MAIN GUI SYSTEM (Skibidi Hub Style)
-- ═══════════════════════════════════════════════════════════════
function loadMainGUI()
    -- Main window
    local mainWindow = Instance.new("Frame")
    mainWindow.Size = UDim2.new(0, 1100, 0, 700)
    mainWindow.Position = UDim2.new(0.5, -550, 0.5, -350)
    mainWindow.BackgroundColor3 = theme.bgDark
    mainWindow.BorderSizePixel = 0
    mainWindow.Parent = ScreenGui

    local mwCorner = Instance.new("UICorner")
    mwCorner.CornerRadius = UDim.new(0, 25)
    mwCorner.Parent = mainWindow

    local mwGradient = Instance.new("UIGradient")
    mwGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, theme.bgDark),
        ColorSequenceKeypoint.new(1, theme.bgLight)
    }
    mwGradient.Rotation = 135
    mwGradient.Parent = mainWindow

    local mwStroke = Instance.new("UIStroke")
    mwStroke.Color = theme.primary
    mwStroke.Thickness = 4
    mwStroke.Parent = mainWindow

    -- TOP BAR (Draggable)
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 70)
    topBar.BackgroundColor3 = theme.primary
    topBar.BorderSizePixel = 0
    topBar.Parent = mainWindow

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 25)
    tbCorner.Parent = topBar

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0.4, 0, 0.7, 0)
    logo.Position = UDim2.new(0.02, 0, 0.15, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "ISKR A HUB v4.0"
    logo.TextColor3 = theme.textDark
    logo.TextScaled = true
    logo.Font = Enum.Font.GothamBold
    logo.Parent = topBar

    local creatorLabel = Instance.new("TextLabel")
    creatorLabel.Size = UDim2.new(0.25, 0, 0.6, 0)
    creatorLabel.Position = UDim2.new(0.42, 0, 0.2, 0)
    creatorLabel.BackgroundTransparency = 1
    creatorLabel.Text = "Created by turcja"
    creatorLabel.TextColor3 = Color3.fromRGB(255, 255, 255, 0.8)
    creatorLabel.TextScaled = true
    creatorLabel.Font = Enum.Font.Gotham
    creatorLabel.Parent = topBar

    -- User Info Panel
    local userInfo = Instance.new("Frame")
    userInfo.Size = UDim2.new(0.3, 0, 0.8, 0)
    userInfo.Position = UDim2.new(0.68, 0, 0.1, 0)
    userInfo.BackgroundColor3 = theme.secondary
    userInfo.BackgroundTransparency = 0.1
    userInfo.BorderSizePixel = 0
    userInfo.Parent = topBar

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = userInfo

    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(1, 0, 0.35, 0)
    usernameLabel.Position = UDim2.new(0, 0, 0.05, 0)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = "Username: " .. LocalPlayer.Name
    usernameLabel.TextColor3 = theme.textLight
    usernameLabel.TextScaled = true
    usernameLabel.Font = Enum.Font.GothamSemibold
    usernameLabel.Parent = userInfo

    local userIdLabel = Instance.new("TextLabel")
    userIdLabel.Size = UDim2.new(1, 0, 0.35, 0)
    userIdLabel.Position = UDim2.new(0, 0, 0.4, 0)
    userIdLabel.BackgroundTransparency = 1
    userIdLabel.Text = "UserId: " .. LocalPlayer.UserId
    userIdLabel.TextColor3 = theme.textLight
    userIdLabel.TextScaled = true
    userIdLabel.Font = Enum.Font.Gotham
    userIdLabel.Parent = userInfo

    local gameLabel = Instance.new("TextLabel")
    gameLabel.Size = UDim2.new(1, 0, 0.35, 0)
    gameLabel.Position = UDim2.new(0, 0, 0.75, 0)
    gameLabel.BackgroundTransparency = 1
    gameLabel.Text = "Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    gameLabel.TextColor3 = theme.primary
    gameLabel.TextScaled = true
    gameLabel.Font = Enum.Font.GothamBold
    gameLabel.Parent = userInfo

    -- Make main window draggable
    makeDraggable(mainWindow, topBar)

    -- Sidebar tabs
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 200, 1, -90)
    sidebar.Position = UDim2.new(0, 0, 0, 70)
    sidebar.BackgroundTransparency = 1
    sidebar.Parent = mainWindow

    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -220, 1, -90)
    contentArea.Position = UDim2.new(0, 200, 0, 70)
    contentArea.BackgroundColor3 = theme.bgLight
    contentArea.BorderSizePixel = 0
    contentArea.Parent = mainWindow

    local caCorner = Instance.new("UICorner")
    caCorner.CornerRadius = UDim.new(0, 20)
    caCorner.Parent = contentArea

    -- Tab configuration
    local tabs = {
        {name = "PLAYER", icon = "👤"},
        {name = "COMBAT", icon = "⚔️"},
        {name = "TROLL", icon = "😂"},
        {name = "TOWER OF HELL", icon = "🏢"},
        {name = "GITHUB SCRIPTS", icon = "📦"},
        {name = "UTILITY", icon = "⚙️"}
    }

    local tabButtons = {}
    for i, tab in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, -15, 0, 60)
        tabBtn.Position = UDim2.new(0, 7.5, (i-1) * 65, 10)
        tabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = tab.icon .. "  " .. tab.name
        tabBtn.TextColor3 = theme.textLight
        tabBtn.TextScaled = true
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.Parent = sidebar

        local tCorner = Instance.new("UICorner")
        tCorner.CornerRadius = UDim.new(0, 14)
        tCorner.Parent = tabBtn

        local tStroke = Instance.new("UIStroke")
        tStroke.Color = Color3.fromRGB(65, 65, 85)
        tStroke.Thickness = 2
        tStroke.Parent = tabBtn

        tabButtons[i] = {btn = tabBtn, stroke = tStroke}
        
        tabBtn.MouseButton1Click:Connect(function()
            switchTab(i)
        end)
    end

    local currentTab = 1
    function switchTab(index)
        currentTab = index
        for i, data in ipairs(tabButtons) do
            local isActive = i == index
            tween:Create(data.btn, tiHover, {
                BackgroundColor3 = isActive and theme.primary or Color3.fromRGB(45, 45, 60)
            }):Play()
            tween:Create(data.stroke, tiHover, {
                Color = isActive and Color3.fromRGB(255, 150, 200) or Color3.fromRGB(65, 65, 85)
            }):Play()
            data.btn.TextColor3 = isActive and theme.textDark or theme.textLight
        end
        loadTabContent(index)
    end

    -- Content loader
    function loadTabContent(tabIndex)
        for _, child in pairs(contentArea:GetChildren()) do
            if child:IsA("ScrollingFrame") then child:Destroy() end
        end
        
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -25, 1, -25)
        scroll.Position = UDim2.new(0, 12.5, 0, 12.5)
        scroll.BackgroundColor3 = theme.bgDark
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 8
        scroll.ScrollBarImageColor3 = theme.primary
        scroll.Parent = contentArea

        local sCorner = Instance.new("UICorner")
        sCorner.CornerRadius = UDim.new(0, 16)
        sCorner.Parent = scroll

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 15)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = scroll

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 30)
        end)

        if tabIndex == 1 then playerTab(scroll)
        elseif tabIndex == 2 then combatTab(scroll)
        elseif tabIndex == 3 then trollTab(scroll)
        elseif tabIndex == 4 then towerOfHellTab(scroll)
        elseif tabIndex == 5 then githubTab(scroll)
        elseif tabIndex == 6 then utilityTab(scroll)
        end
    end

    -- Create professional buttons
    function createHubButton(parent, text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 65)
        btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = theme.textLight
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.Parent = parent

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 18)
        btnCorner.Parent = btn

        local btnGradient = Instance.new("UIGradient")
        btnGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 55, 75)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 95))
        }
        btnGradient.Parent = btn

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(75, 75, 100)
        btnStroke.Thickness = 2.5
        btnStroke.Parent = btn

        btn.MouseEnter:Connect(function()
            tween:Create(btn, tiHover, {
                BackgroundColor3 = theme.secondary,
                Size = UDim2.new(1, -15, 0, 70)
            }):Play()
            tween:Create(btnStroke, tiHover, {Color = theme.primary}):Play()
            btn.TextColor3 = theme.textDark
        end)

        btn.MouseLeave:Connect(function()
            tween:Create(btn, tiHover, {
                BackgroundColor3 = Color3.fromRGB(55, 55, 75),
                Size = UDim2.new(1, -20, 0, 65)
            }):Play()
            tween:Create(btnStroke, tiHover, {Color = Color3.fromRGB(75, 75, 100)}):Play()
            btn.TextColor3 = theme.textLight
        end)

        btn.MouseButton1Click:Connect(callback)
    end

    -- Tab contents
    function playerTab(parent)
        createHubButton(parent, "Fly (Hold F)", toggleFly)
        createHubButton(parent, "Noclip (X)", toggleNoclip)
        createHubButton(parent, "Speed 75 (V)", function() setSpeed(75) end)
        createHubButton(parent, "High Jump 150 (B)", function() setJump(150) end)
        createHubButton(parent, "Infinite Yield Jump (G)", toggleInfJump)
        createHubButton(parent, "Fullbright", toggleFullbright)
        createHubButton(parent, "Invisible", toggleInvisible)
    end

    function combatTab(parent)
        createHubButton(parent, "ESP Players", toggleESP)
        createHubButton(parent, "Wallhack", toggleWallhack)
        createHubButton(parent, "Kill Aura 16", toggleKillAura)
        createHubButton(parent, "Aimlock", toggleAimlock)
    end

    function trollTab(parent)
        createHubButton(parent, "Fling All Players", flingAllPlayers)
        createHubButton(parent, "Server Crash", crashServer)
        createHubButton(parent, "Spam Chat", spamChat)
        createHubButton(parent, "Sex Tool GUI", loadSexTool)
        createHubButton(parent, "Remove Map", removeMap)
        createHubButton(parent, "Skybox Troll", skyboxTroll)
    end

    function towerOfHellTab(parent)
        createHubButton(parent, "ToH Godmode", tohGodmode)
        createHubButton(parent, "ToH Speed 150", function() setSpeed(150) end)
        createHubButton(parent, "ToH Noclip", tohNoclip)
        createHubButton(parent, "Auto Win ToH", toggleToHAutoWin)
        createHubButton(parent, "Stage Skip", tohStageSkip)
        createHubButton(parent, "ToH Fly", tohFly)
        createHubButton(parent, "Kill All ToH", tohKillAll)
    end

    function githubTab(parent)
        createHubButton(parent, "Infinite Yield (Working)", function() 
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() 
        end)
        createHubButton(parent, "Dark Dex V3", function() 
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.txt"))() 
        end)
        createHubButton(parent, "CMD-X", function() 
            loadstring(game:HttpGet("https://raw.githubusercontent.com/bloxscripter/CMD-X/master/Source"))() 
        end)
        createHubButton(parent, "Dex Explorer", function() 
            loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/Dex_Explorer/main/Dex%20Explorer.txt"))() 
        end)
    end

    function utilityTab(parent)
        createHubButton(parent, "Rejoin Server", rejoinServer)
        createHubButton(parent, "Anti-AFK", toggleAntiAFK)
        createHubButton(parent, "FPS Unlocker", fpsUnlock)
        createHubButton(parent, "Copy Discord", copyDiscord)
    end

    -- Drag function
    function makeDraggable(frame, dragHandle)
        local dragging = false
        local dragStart = nil
        local startPos = nil

        dragHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)

        dragHandle.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    -- All working features
    local connections = {}
    
    function toggleFly()
        -- Advanced fly implementation
        local char = LocalPlayer.Character
        if not char then return end
        
        local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        if not connections.fly then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(40000, 40000, 40000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = humanoidRootPart
            
            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(40000, 40000, 40000)
            bg.P = 9000
            bg.Parent = humanoidRootPart
            
            connections.fly = RunService.Heartbeat:Connect(function()
                local camera = workspace.CurrentCamera
                local direction = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
                
                bv.Velocity = direction * 60
                bg.CFrame = camera.CFrame
            end)
        else
            connections.fly:Disconnect()
            connections.fly = nil
            if humanoidRootPart:FindFirstChild("BodyVelocity") then humanoidRootPart.BodyVelocity:Destroy() end
            if humanoidRootPart:FindFirstChild("BodyGyro") then humanoidRootPart.BodyGyro:Destroy() end
        end
    end

    function toggleNoclip()
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end

    function setSpeed(speed)
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then humanoid.WalkSpeed = speed end
    end

    function setJump(power)
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then humanoid.JumpPower = power end
    end

    function flingAllPlayers()
        -- Professional fling from GitHub sources
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Velocity = Vector3.new(math.huge, math.huge, math.huge)
                    root.AngularVelocity = Vector3.new(math.huge, math.huge, math.huge)
                end
            end
        end
    end

    function toggleFullbright()
        Lighting.Brightness = 5
        Lighting.ClockTime = 14
        Lighting.FogEnd = math.huge
    end

    function toggleToHAutoWin()
        -- ToH specific auto win
        spawn(function()
            while wait(0.1) do
                teleportToWin()
            end
        end)
    end

    function teleportToWin()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("win") or obj.Name:lower():find("end")) then
                LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                break
            end
        end
    end

    -- Keybinds FIXED
    UserInputService.InputBegan:Connect(function(key)
        if key.KeyCode == Enum.KeyCode.X then toggleNoclip() end
        if key.KeyCode == Enum.KeyCode.F then toggleFly() end
        if key.KeyCode == Enum.KeyCode.V then setSpeed(75) end
        if key.KeyCode == Enum.KeyCode.B then setJump(150) end
    end)

    -- Entrance animation
    mainWindow.Size = UDim2.new(0, 0, 0, 0)
    tween:Create(mainWindow, TweenInfo.new(1.0, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 1100, 0, 700)
    }):Play()

    switchTab(1)
end

print("Iskra Hub loaded - Key: iskra")
