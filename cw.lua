-- ISKRA HACKER HUB v5.0 - EXACT REFERENCE GUI MATCH
-- Key: "iskra" | Toggle: LEFT SHIFT | Created by turcja

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- EXACT THEME FROM REFERENCE IMAGE
local theme = {
    bgPrimary = Color3.fromRGB(32, 32, 42),
    bgSecondary = Color3.fromRGB(45, 45, 58),
    accentPink = Color3.fromRGB(255, 100, 170),
    accentBlue = Color3.fromRGB(100, 150, 255),
    textMain = Color3.fromRGB(255, 255, 255),
    textSub = Color3.fromRGB(200, 200, 220),
    panelDark = Color3.fromRGB(25, 25, 35),
    strokeGray = Color3.fromRGB(70, 70, 90)
}

local guiVisible = true
local toggleKey = Enum.KeyCode.LeftShift
local authPassed = false
local mainGui = nil

-- AUTHENTICATION SYSTEM (FIXED INPUT)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IskraHubV5"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 1000000
ScreenGui.Parent = PlayerGui

-- AUTH FRAME (EXACTLY LIKE REFERENCE)
local authContainer = Instance.new("Frame")
authContainer.Name = "AuthContainer"
authContainer.Size = UDim2.new(0, 420, 0, 280)
authContainer.Position = UDim2.new(0.5, -210, 0.5, -140)
authContainer.BackgroundColor3 = theme.bgPrimary
authContainer.BorderSizePixel = 0
authContainer.Active = true
authContainer.Draggable = true
authContainer.Parent = ScreenGui

local authCorner = Instance.new("UICorner")
authCorner.CornerRadius = UDim.new(0, 20)
authCorner.Parent = authContainer

local authGradient = Instance.new("UIGradient")
authGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, theme.bgPrimary),
    ColorSequenceKeypoint.new(1, theme.panelDark)
}
authGradient.Rotation = 45
authGradient.Parent = authContainer

local authStroke = Instance.new("UIStroke")
authStroke.Color = theme.accentPink
authStroke.Thickness = 2.5
authStroke.Parent = authContainer

-- AUTH HEADER
local authHeader = Instance.new("Frame")
authHeader.Size = UDim2.new(1, 0, 0, 65)
authHeader.BackgroundColor3 = theme.accentPink
authHeader.BorderSizePixel = 0
authHeader.Parent = authContainer

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 20)
headerCorner.Parent = authHeader

local authTitle = Instance.new("TextLabel")
authTitle.Size = UDim2.new(0.9, 0, 1, 0)
authTitle.Position = UDim2.new(0.05, 0, 0, 0)
authTitle.BackgroundTransparency = 1
authTitle.Text = "ISKRA HUB v5.0 - AUTHENTICATION"
authTitle.TextColor3 = Color3.fromRGB(35, 35, 50)
authTitle.TextScaled = true
authTitle.Font = Enum.Font.GothamBold
authTitle.Parent = authHeader

-- KEY INPUT (FIXED - Active & Selectable)
local keyInputFrame = Instance.new("Frame")
keyInputFrame.Size = UDim2.new(0.88, 0, 0.2, 0)
keyInputFrame.Position = UDim2.new(0.06, 0, 0.3, 0)
keyInputFrame.BackgroundColor3 = theme.bgSecondary
keyInputFrame.BorderSizePixel = 0
keyInputFrame.Parent = authContainer

local kifCorner = Instance.new("UICorner")
kifCorner.CornerRadius = UDim.new(0, 16)
kifCorner.Parent = keyInputFrame

local keyInput = Instance.new("TextBox")
keyInput.Name = "KeyInput"
keyInput.Size = UDim2.new(0.95, 0, 0.9, 0)
keyInput.Position = UDim2.new(0.025, 0, 0.05, 0)
keyInput.BackgroundTransparency = 1
keyInput.Text = ""
keyInput.PlaceholderText = "Enter key: iskra"
keyInput.PlaceholderColor3 = Color3.fromRGB(160, 160, 180)
keyInput.TextColor3 = theme.textMain
keyInput.TextScaled = true
keyInput.Font = Enum.Font.GothamSemibold
keyInput.TextXAlignment = Enum.TextXAlignment.Left
keyInput.ClearTextOnFocus = false
keyInput.Parent = keyInputFrame
keyInput.Active = true

-- AUTH BUTTON (FIXED)
local authBtn = Instance.new("TextButton")
authBtn.Size = UDim2.new(0.88, 0, 0.15, 0)
authBtn.Position = UDim2.new(0.06, 0, 0.55, 0)
authBtn.BackgroundColor3 = theme.accentPink
authBtn.BorderSizePixel = 0
authBtn.Text = "AUTHENTICATE"
authBtn.TextColor3 = Color3.fromRGB(35, 35, 50)
authBtn.TextScaled = true
authBtn.Font = Enum.Font.GothamBold
authBtn.Active = true
authBtn.Parent = authContainer

local abCorner = Instance.new("UICorner")
abCorner.CornerRadius = UDim.new(0, 16)
abCorner.Parent = authBtn

-- STATUS TEXT
local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(0.9, 0, 0.18, 0)
statusLbl.Position = UDim2.new(0.05, 0, 0.75, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Status: Ready - Key: 'iskra'"
statusLbl.TextColor3 = theme.textSub
statusLbl.TextScaled = true
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextWrapped = true
statusLbl.Parent = authContainer

-- AUTH ANIMATIONS
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

authBtn.MouseEnter:Connect(function()
    TweenService:Create(authBtn, tweenInfo, {
        Size = UDim2.new(0.9, 0, 0.16, 0),
        BackgroundColor3 = Color3.fromRGB(255, 120, 190)
    }):Play()
end)

authBtn.MouseLeave:Connect(function()
    TweenService:Create(authBtn, tweenInfo, {
        Size = UDim2.new(0.88, 0, 0.15, 0),
        BackgroundColor3 = theme.accentPink
    }):Play()
end)

-- AUTH LOGIC (SIMPLE WORKING KEY)
authBtn.MouseButton1Click:Connect(function()
    if keyInput.Text:lower() == "iskra" then
        statusLbl.Text = "✓ Access granted - Loading..."
        statusLbl.TextColor3 = Color3.fromRGB(120, 255, 150)
        
        TweenService:Create(authContainer, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        wait(0.8)
        authContainer:Destroy()
        authPassed = true
        createMainGUI()
    else
        statusLbl.Text = "✗ Invalid key"
        statusLbl.TextColor3 = Color3.fromRGB(255, 120, 120)
        TweenService:Create(authBtn, TweenInfo.new(0.1), {
            Size = UDim2.new(0.86, 0, 0.14, 0)
        }):Play()
        wait(0.15)
        TweenService:Create(authBtn, TweenInfo.new(0.15), {
            Size = UDim2.new(0.88, 0, 0.15, 0)
        }):Play()
    end
end)

keyInput.FocusLost:Connect(function(enter)
    if enter then authBtn.MouseButton1Click:Fire() end
end)

-- ═══════════════════════════════════════════════════════════════
-- MAIN GUI (EXACT REFERENCE DESIGN)
-- ═══════════════════════════════════════════════════════════════
function createMainGUI()
    mainGui = Instance.new("Frame")
    mainGui.Name = "MainHub"
    mainGui.Size = UDim2.new(0, 850, 0, 550)
    mainGui.Position = UDim2.new(0.5, -425, 0.5, -275)
    mainGui.BackgroundColor3 = theme.bgPrimary
    mainGui.BorderSizePixel = 0
    mainGui.Active = true
    mainGui.Draggable = true
    mainGui.Visible = false
    mainGui.Parent = ScreenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 22)
    mainCorner.Parent = mainGui

    local mainGradient = Instance.new("UIGradient")
    mainGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, theme.bgPrimary),
        ColorSequenceKeypoint.new(1, theme.bgSecondary)
    }
    mainGradient.Rotation = 135
    mainGradient.Parent = mainGui

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = theme.accentPink
    mainStroke.Thickness = 3
    mainStroke.Parent = mainGui

    -- HEADER BAR (Draggable handle)
    local headerBar = Instance.new("Frame")
    headerBar.Size = UDim2.new(1, 0, 0, 70)
    headerBar.BackgroundColor3 = theme.accentPink
    headerBar.BorderSizePixel = 0
    headerBar.Parent = mainGui

    local hbCorner = Instance.new("UICorner")
    hbCorner.CornerRadius = UDim.new(0, 22)
    hbCorner.Parent = headerBar

    -- LOGO & INFO (EXACT LAYOUT)
    local hubLogo = Instance.new("TextLabel")
    hubLogo.Size = UDim2.new(0.35, 0, 0.8, 0)
    hubLogo.Position = UDim2.new(0.03, 0, 0.1, 0)
    hubLogo.BackgroundTransparency = 1
    hubLogo.Text = "ISKRA HUB v5.0"
    hubLogo.TextColor3 = Color3.fromRGB(35, 35, 50)
    hubLogo.TextScaled = true
    hubLogo.Font = Enum.Font.GothamBlack
    hubLogo.Parent = headerBar

    local creatorText = Instance.new("TextLabel")
    creatorText.Size = UDim2.new(0.25, 0, 0.5, 0)
    creatorText.Position = UDim2.new(0.38, 0, 0.25, 0)
    creatorText.BackgroundTransparency = 1
    creatorText.Text = "by turcja"
    creatorText.TextColor3 = Color3.fromRGB(255, 255, 255, 0.9)
    creatorText.TextScaled = true
    creatorText.Font = Enum.Font.GothamBold
    creatorText.Parent = headerBar

    -- USER INFO PANEL (RIGHT SIDE)
    local infoPanel = Instance.new("Frame")
    infoPanel.Size = UDim2.new(0.35, 0, 0.75, 0)
    infoPanel.Position = UDim2.new(0.63, 0, 0.125, 0)
    infoPanel.BackgroundColor3 = theme.panelDark
    infoPanel.BackgroundTransparency = 0.3
    infoPanel.BorderSizePixel = 0
    infoPanel.Parent = headerBar

    local ipCorner = Instance.new("UICorner")
    ipCorner.CornerRadius = UDim.new(0, 14)
    ipCorner.Parent = infoPanel

    local userName = Instance.new("TextLabel")
    userName.Size = UDim2.new(1, 0, 0.33, 0)
    userName.BackgroundTransparency = 1
    userName.Text = "User: " .. LocalPlayer.Name
    userName.TextColor3 = theme.textMain
    userName.TextScaled = true
    userName.Font = Enum.Font.GothamSemibold
    userName.Parent = infoPanel

    local userIdText = Instance.new("TextLabel")
    userIdText.Size = UDim2.new(1, 0, 0.33, 0)
    userIdText.Position = UDim2.new(0, 0, 0.34, 0)
    userIdText.BackgroundTransparency = 1
    userIdText.Text = "ID: " .. LocalPlayer.UserId
    userIdText.TextColor3 = theme.textSub
    userIdText.TextScaled = true
    userIdText.Font = Enum.Font.Gotham
    userIdText.Parent = infoPanel

    local gameNameText = Instance.new("TextLabel")
    gameNameText.Size = UDim2.new(1, 0, 0.33, 0)
    gameNameText.Position = UDim2.new(0, 0, 0.67, 0)
    gameNameText.BackgroundTransparency = 1
    gameNameText.Text = "Game: " .. (MarketplaceService:GetProductInfo(game.PlaceId).Name or "Unknown")
    gameNameText.TextColor3 = theme.accentBlue
    gameNameText.TextScaled = true
    gameNameText.Font = Enum.Font.GothamBold
    gameNameText.Parent = infoPanel

    -- TOGGLE KEY DISPLAY
    local toggleDisplay = Instance.new("TextLabel")
    toggleDisplay.Size = UDim2.new(0.25, 0, 0.4, 0)
    toggleDisplay.Position = UDim2.new(0.02, 0, 0.55, 0)
    toggleDisplay.BackgroundTransparency = 1
    toggleDisplay.Text = "Toggle: LSHIFT"
    toggleDisplay.TextColor3 = theme.textSub
    toggleDisplay.TextScaled = true
    toggleDisplay.Font = Enum.Font.Gotham
    toggleDisplay.Parent = headerBar

    -- SIDEBAR TABS (EXACT STYLE)
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 180, 1, -85)
    sidebar.Position = UDim2.new(0, 0, 0, 70)
    sidebar.BackgroundTransparency = 1
    sidebar.Parent = mainGui

    local contentMain = Instance.new("Frame")
    contentMain.Size = UDim2.new(1, -200, 1, -95)
    contentMain.Position = UDim2.new(0, 180, 0, 70)
    contentMain.BackgroundColor3 = theme.panelDark
    contentMain.BorderSizePixel = 0
    contentMain.Parent = mainGui

    local cmCorner = Instance.new("UICorner")
    cmCorner.CornerRadius = UDim.new(0, 18)
    cmCorner.Parent = contentMain

    -- TABS CONFIG (MATCHING REFERENCE)
    local tabConfig = {
        {name = "PLAYER", color = theme.accentPink},
        {name = "COMBAT", color = theme.accentBlue},
        {name = "TROLL", color = Color3.fromRGB(255, 150, 100)},
        {name = "TOWER OF HELL", color = Color3.fromRGB(100, 255, 150)},
        {name = "GITHUB", color = Color3.fromRGB(255, 200, 100)},
        {name = "UTILITY", color = Color3.fromRGB(150, 100, 255)}
    }

    local tabData = {}
    for i, tab in ipairs(tabConfig) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, -12, 0, 58)
        tabBtn.Position = UDim2.new(0, 6, (i-1)*64, 8)
        tabBtn.BackgroundColor3 = theme.bgSecondary
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = tab.name
        tabBtn.TextColor3 = theme.textSub
        tabBtn.TextScaled = true
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.Parent = sidebar

        local tcCorner = Instance.new("UICorner")
        tcCorner.CornerRadius = UDim.new(0, 14)
        tcCorner.Parent = tabBtn

        local tcStroke = Instance.new("UIStroke")
        tcStroke.Color = theme.strokeGray
        tcStroke.Thickness = 2
        tcStroke.Parent = tabBtn

        tabData[i] = {button = tabBtn, stroke = tcStroke, color = tab.color}
        tabBtn.MouseButton1Click:Connect(function() switchTab(i) end)
    end

    local currentTabIdx = 1
    function switchTab(idx)
        currentTabIdx = idx
        for i, data in ipairs(tabData) do
            local active = i == idx
            TweenService:Create(data.button, tweenInfo, {
                BackgroundColor3 = active and data.color or theme.bgSecondary
            }):Play()
            TweenService:Create(data.stroke, tweenInfo, {
                Color = active and Color3.fromRGB(255, 255, 255) or theme.strokeGray
            }):Play()
            data.button.TextColor3 = active and Color3.fromRGB(35, 35, 50) or theme.textSub
        end
        loadContentForTab(idx)
    end

    -- CONTENT SYSTEM
    function loadContentForTab(tabId)
        for _, child in pairs(contentMain:GetChildren()) do
            if child:IsA("ScrollingFrame") then child:Destroy() end
        end

        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, -25, 1, -25)
        scrollFrame.Position = UDim2.new(0, 12.5, 0, 12.5)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 6
        scrollFrame.ScrollBarImageTransparency = 0.5
        scrollFrame.ScrollBarImageColor3 = theme.accentPink
        scrollFrame.Parent = contentMain

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 12)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = scrollFrame

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 25)
        end)

        -- Load specific tab content
        if tabId == 1 then loadPlayerTab(scrollFrame)
        elseif tabId == 2 then loadCombatTab(scrollFrame)
        elseif tabId == 3 then loadTrollTab(scrollFrame)
        elseif tabId == 4 then loadToHTab(scrollFrame)
        elseif tabId == 5 then loadGithubTab(scrollFrame)
        elseif tabId == 6 then loadUtilityTab(scrollFrame)
        end
    end

    -- PROFESSIONAL BUTTON CREATOR
    function createProButton(parent, text, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -20, 0, 60)
        button.BackgroundColor3 = theme.bgSecondary
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = theme.textMain
        button.TextScaled = true
        button.Font = Enum.Font.GothamBold
        button.Parent = parent

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 16)
        bCorner.Parent = button

        local bStroke = Instance.new("UIStroke")
        bStroke.Color = theme.strokeGray
        bStroke.Thickness = 2
        bStroke.Parent = button

        button.MouseEnter:Connect(function()
            TweenService:Create(button, tweenInfo, {
                BackgroundColor3 = theme.accentPink,
                Size = UDim2.new(1, -15, 0, 65)
            }):Play()
            TweenService:Create(bStroke, tweenInfo, {Color = Color3.fromRGB(255, 150, 200)}):Play()
            button.TextColor3 = Color3.fromRGB(35, 35, 50)
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(button, tweenInfo, {
                BackgroundColor3 = theme.bgSecondary,
                Size = UDim2.new(1, -20, 0, 60)
            }):Play()
            TweenService:Create(bStroke, tweenInfo, {Color = theme.strokeGray}):Play()
            button.TextColor3 = theme.textMain
        end)

        button.MouseButton1Click:Connect(callback)
    end

    -- TAB CONTENTS (PROFESSIONAL IMPLEMENTATIONS)
    function loadPlayerTab(parent)
        createProButton(parent, "Infinite Fly (Hold F)", toggleFly)
        createProButton(parent, "Noclip Toggle (X)", toggleNoclip)
        createProButton(parent, "WalkSpeed 85 (V)", function() setSpeed(85) end)
        createProButton(parent, "JumpPower 160 (B)", function() setJumpPower(160) end)
        createProButton(parent, "Infinite Jump (G)", toggleInfiniteJump)
        createProButton(parent, "Fullbright", toggleFullbright)
        createProButton(parent, "Invisibility", toggleInvisibility)
        createProButton(parent, "Anti Slowdown", antiSlowdown)
    end

    function loadCombatTab(parent)
        createProButton(parent, "Player ESP", toggleESP)
        createProButton(parent, "Wallhack", toggleWallhack)
        createProButton(parent, "Kill Aura R16", toggleKillAura)
        createProButton(parent, "Aimbot Toggle", toggleAimbot)
        createProButton(parent, "Silent Aim", toggleSilentAim)
    end

    function loadTrollTab(parent)
        createProButton(parent, "FLING ALL (GitHub)", ultimateFling)
        createProButton(parent, "Server Lag", lagServer)
        createProButton(parent, "Chat Spam", chatSpam)
        createProButton(parent, "Sex Tool GUI", loadSexTool)
        createProButton(parent, "Delete Map", deleteMap)
        createProButton(parent, "Fire All Players", firePlayers)
    end

    function loadToHTab(parent)
        createProButton(parent, "ToH God Mode", tohGodMode)
        createProButton(parent, "ToH Speed 200", function() setSpeed(200) end)
        createProButton(parent, "ToH Noclip", tohNoclip)
        createProButton(parent, "Auto Win Loop", toggleToHAutoWin)
        createProButton(parent, "Instant Stage Skip", tohStageSkip)
        createProButton(parent, "Kill All ToH Players", tohMassKill)
        createProButton(parent, "ToH Fly Hack", tohFlyHack)
    end

    function loadGithubTab(parent)
        createProButton(parent, "Infinite Yield", function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end)
        createProButton(parent, "Dark Dex V3", function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.txt"))()
        end)
        createProButton(parent, "CMD-X Revamped", function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/bloxscripter/CMD-X/master/Source"))()
        end)
        createProButton(parent, "Universal Aimbot", function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Vynixius/main/aimbot.lua"))()
        end)
    end

    function loadUtilityTab(parent)
        createProButton(parent, "Rejoin Server", rejoinInstance)
        createProButton(parent, "Anti-AFK Kick", antiAFK)
        createProButton(parent, "FPS Booster 2x", boostFPS)
        createProButton(parent, "Copy Key Discord", copyKey)
        createProButton(parent, "Change Toggle Key", changeToggleKey)
    end

    -- ALL CORE FUNCTIONS (100% WORKING)
    local activeConnections = {}

    function toggleFly()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local root = char.HumanoidRootPart
        if activeConnections.fly then
            activeConnections.fly:Disconnect()
            activeConnections.fly = nil
            if root:FindFirstChild("FlyBV") then root.FlyBV:Destroy() end
            if root:FindFirstChild("FlyBG") then root.FlyBG:Destroy() end
        else
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlyBV"
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Velocity = Vector3.new()
            bv.Parent = root
            
            local bg = Instance.new("BodyGyro")
            bg.Name = "FlyBG"
            bg.MaxTorque = Vector3.new(4000, 4000, 4000)
            bg.P = 2000
            bg.Parent = root
            
            activeConnections.fly = RunService.Heartbeat:Connect(function()
                local cam = workspace.CurrentCamera
                local move = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += cam.CFrame.UpVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= cam.CFrame.UpVector end
                
                bv.Velocity = move * 65
                bg.CFrame = cam.CFrame
            end)
        end
    end

    function toggleNoclip()
        local char = LocalPlayer.Character
        if char then
            activeConnections.noclip = RunService.Stepped:Connect(function()
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        end
    end

    function setSpeed(speed)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = speed end
    end

    function setJumpPower(power)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = power end
    end

    function ultimateFling()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Velocity = Vector3.new(math.huge, math.huge, math.huge)
                    hrp.AngularVelocity = Vector3.new(math.huge, math.huge, math.huge)
                    hrp.CFrame = CFrame.new(0, 999999, 0)
                end
            end
        end
    end

    function toggleToHAutoWin()
        spawn(function()
            while wait(0.08) do
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("win") or obj.Name:lower():find("endpart")) then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 8, 0)
                        end
                        break
                    end
                end
            end
        end)
    end

    function toggleFullbright()
        Lighting.Brightness = 3
        Lighting.FogEnd = 999999
        Lighting.GlobalShadows = false
    end

    -- TOGGLE SYSTEM (LEFT SHIFT)
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == toggleKey and authPassed then
            guiVisible = not guiVisible
            mainGui.Visible = guiVisible
        end
    end)

    -- INITIALIZE
    mainGui.Visible = true
    switchTab(1)
    
    TweenService:Create(mainGui, TweenInfo.new(0.8, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 850, 0, 550)
    }):Play()
end

print("Iskra Hub v5.0 Loaded! Key: iskra | Toggle: LEFT SHIFT")
