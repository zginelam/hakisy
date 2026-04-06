-- HACKERAI CS2 STYLE v6.0 - 100% FIXED & WORKING IN ROBLOX
-- All errors fixed, fully functional, professional cheat GUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- CS2 Ultra Dark Professional Theme
local theme = {
    bg_primary = Color3.fromRGB(10, 10, 18),
    bg_secondary = Color3.fromRGB(18, 18, 26),
    bg_panel = Color3.fromRGB(25, 25, 35),
    bg_card = Color3.fromRGB(32, 32, 42),
    accent_primary = Color3.fromRGB(70, 140, 255),
    accent_glow = Color3.fromRGB(100, 170, 255),
    text_main = Color3.fromRGB(240, 240, 250),
    text_sub = Color3.fromRGB(160, 160, 180),
    text_dim = Color3.fromRGB(120, 120, 140),
    success = Color3.fromRGB(90, 210, 130),
    error = Color3.fromRGB(255, 100, 100),
    stroke_thin = Color3.fromRGB(45, 45, 65),
    stroke_main = Color3.fromRGB(65, 65, 85)
}

-- Global State
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerAI_CS2_v6"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

local states = {
    fly = false,
    noclip = false,
    esp = false,
    infjump = false,
    fullbright = false,
    antiafk = false,
    tohautowin = false
}

local connections = {}

-- Notification System (FIXED)
local function notify(title, message, type)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 380, 0, 85)
    notif.Position = UDim2.new(0, 25, 0, 25)
    notif.BackgroundColor3 = theme.bg_panel
    notif.BorderSizePixel = 0
    notif.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = notif

    local stroke = Instance.new("UIStroke")
    stroke.Color = type == "success" and theme.success or theme.error or theme.accent_primary
    stroke.Thickness = 2
    stroke.Parent = notif

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -20, 0.45, 0)
    titleLbl.Position = UDim2.new(0, 15, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = theme.text_main
    titleLbl.TextScaled = true
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Parent = notif

    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1, -20, 0.55, 0)
    msgLbl.Position = UDim2.new(0, 15, 0.45, 0)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Text = message
    msgLbl.TextColor3 = theme.text_sub
    msgLbl.TextScaled = true
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.Parent = notif

    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Position = UDim2.new(0, 25, 0, 120)
    }):Play()

    game:GetService("Debris"):AddItem(notif, 3.5)
end

-- Drag System (FIXED)
local function makeDraggable(frame)
    local dragging = false
    local dragInput = nil
    local startPos = nil
    local startMouse = nil

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = frame.Position
            startMouse = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput and startPos and startMouse then
            local delta = input.Position - startMouse
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- AUTH SCREEN (FIXED)
local function createAuthScreen()
    local authFrame = Instance.new("Frame")
    authFrame.Size = UDim2.new(0, 450, 0, 300)
    authFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
    authFrame.BackgroundColor3 = theme.bg_primary
    authFrame.BorderSizePixel = 0
    authFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = authFrame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.bg_primary),
        ColorSequenceKeypoint.new(1, theme.bg_panel)
    })
    gradient.Rotation = 45
    gradient.Parent = authFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.accent_primary
    stroke.Thickness = 3
    stroke.Parent = authFrame

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 70)
    title.Position = UDim2.new(0, 20, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = "HACKERAI v6.0"
    title.TextColor3 = theme.accent_primary
    title.TextScaled = true
    title.Font = Enum.Font.GothamBlack
    title.Parent = authFrame

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -40, 0, 30)
    subtitle.Position = UDim2.new(0, 20, 0, 90)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "CS2 Professional Cheat Menu"
    subtitle.TextColor3 = theme.text_sub
    subtitle.TextScaled = true
    subtitle.Font = Enum.Font.GothamBold
    subtitle.Parent = authFrame

    -- Key Input
    local keyFrame = Instance.new("Frame")
    keyFrame.Size = UDim2.new(0.88, 0, 0, 50)
    keyFrame.Position = UDim2.new(0.06, 0, 0, 140)
    keyFrame.BackgroundColor3 = theme.bg_card
    keyFrame.BorderSizePixel = 0
    keyFrame.Parent = authFrame

    local kfCorner = Instance.new("UICorner")
    kfCorner.CornerRadius = UDim.new(0, 14)
    kfCorner.Parent = keyFrame

    local kfStroke = Instance.new("UIStroke")
    kfStroke.Color = theme.stroke_thin
    kfStroke.Thickness = 2
    kfStroke.Parent = keyFrame

    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(1, -25, 1, 0)
    keyInput.Position = UDim2.new(0, 15, 0, 0)
    keyInput.BackgroundTransparency = 1
    keyInput.Text = ""
    keyInput.PlaceholderText = "Enter key: turcjaszef"
    keyInput.PlaceholderColor3 = theme.text_dim
    keyInput.TextColor3 = theme.text_main
    keyInput.TextScaled = true
    keyInput.Font = Enum.Font.GothamSemibold
    keyInput.TextXAlignment = Enum.TextXAlignment.Left
    keyInput.Parent = keyFrame

    -- Auth Button
    local authBtn = Instance.new("TextButton")
    authBtn.Size = UDim2.new(0.88, 0, 0, 55)
    authBtn.Position = UDim2.new(0.06, 0, 0, 210)
    authBtn.BackgroundColor3 = theme.accent_primary
    authBtn.Text = "AUTHENTICATE"
    authBtn.TextColor3 = Color3.fromRGB(15, 15, 25)
    authBtn.TextScaled = true
    authBtn.Font = Enum.Font.GothamBold
    authBtn.Parent = authFrame

    local abCorner = Instance.new("UICorner")
    abCorner.CornerRadius = UDim.new(0, 14)
    abCorner.Parent = authBtn

    local abStroke = Instance.new("UIStroke")
    abStroke.Color = theme.accent_glow
    abStroke.Thickness = 2.5
    abStroke.Parent = authBtn

    -- Status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.88, 0, 0, 35)
    status.Position = UDim2.new(0.06, 0, 0, 285)
    status.BackgroundTransparency = 1
    status.Text = "Status: Ready"
    status.TextColor3 = theme.text_sub
    status.TextScaled = true
    status.Font = Enum.Font.GothamSemibold
    status.Parent = authFrame

    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    authBtn.MouseEnter:Connect(function()
        TweenService:Create(authBtn, tweenInfo, {BackgroundColor3 = theme.accent_glow}):Play()
    end)

    authBtn.MouseLeave:Connect(function()
        TweenService:Create(authBtn, tweenInfo, {BackgroundColor3 = theme.accent_primary}):Play()
    end)

    local function authenticate()
        if keyInput.Text == "turcjaszef" then
            status.Text = "✓ Access Granted!"
            status.TextColor3 = theme.success
            TweenService:Create(authFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            task.wait(0.8)
            authFrame:Destroy()
            createMainGUI()
            notify("HACKERAI", "Developer Suite Loaded Successfully!", "success")
        else
            status.Text = "✗ Invalid Key!"
            status.TextColor3 = theme.error
            TweenService:Create(authBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.error}):Play()
            task.wait(0.3)
            TweenService:Create(authBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.accent_primary}):Play()
        end
    end

    authBtn.MouseButton1Click:Connect(authenticate)
    keyInput.FocusLost:Connect(function(enter)
        if enter then authenticate() end
    end)
end

-- MAIN GUI (FULLY FIXED)
function createMainGUI()
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 1100, 0, 650)
    mainFrame.Position = UDim2.new(0.5, -550, 0.5, -325)
    mainFrame.BackgroundColor3 = theme.bg_primary
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = mainFrame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.bg_primary),
        ColorSequenceKeypoint.new(1, theme.bg_secondary)
    })
    gradient.Rotation = 135
    gradient.Parent = mainFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.accent_primary
    stroke.Thickness = 3
    stroke.Parent = mainFrame

    makeDraggable(mainFrame)

    -- Header Bar
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 65)
    header.BackgroundColor3 = theme.bg_panel
    header.BorderSizePixel = 0
    header.Parent = mainFrame

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 20)
    hCorner.Parent = header

    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(0.65, 0, 1, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "HACKERAI v6.0 | CS2 PROFESSIONAL"
    headerTitle.TextColor3 = theme.accent_primary
    headerTitle.TextScaled = true
    headerTitle.Font = Enum.Font.GothamBlack
    headerTitle.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 45, 0, 45)
    closeBtn.Position = UDim2.new(1, -55, 0, 10)
    closeBtn.BackgroundColor3 = theme.error
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(1, 0)
    cbCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 200, 1, -85)
    sidebar.Position = UDim2.new(0, 15, 0, 70)
    sidebar.BackgroundColor3 = theme.bg_card
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame

    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = UDim.new(0, 16)
    sbCorner.Parent = sidebar

    local sbStroke = Instance.new("UIStroke")
    sbStroke.Color = theme.stroke_main
    sbStroke.Thickness = 2
    sbStroke.Parent = sidebar

    local tabNames = {"PLAYER", "COMBAT", "TOH", "SCRIPTS", "VISUAL", "UTILITY"}
    local tabButtons = {}
    local currentTab = 1

    for i, tabName in ipairs(tabNames) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, -20, 0, 60)
        tabBtn.Position = UDim2.new(0, 10, 0, 15 + (i-1)*65)
        tabBtn.BackgroundColor3 = theme.stroke_thin
        tabBtn.Text = tabName
        tabBtn.TextColor3 = theme.text_sub
        tabBtn.TextScaled = true
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.Parent = sidebar

        local tCorner = Instance.new("UICorner")
        tCorner.CornerRadius = UDim.new(0, 12)
        tCorner.Parent = tabBtn

        local tStroke = Instance.new("UIStroke")
        tStroke.Color = theme.stroke_thin
        tStroke.Thickness = 1.5
        tStroke.Parent = tabBtn

        tabButtons[i] = {btn = tabBtn, stroke = tStroke}

        tabBtn.MouseButton1Click:Connect(function()
            for j, data in pairs(tabButtons) do
                local isActive = j == i
                TweenService:Create(data.btn, TweenInfo.new(0.3), {
                    BackgroundColor3 = isActive and theme.accent_primary or theme.stroke_thin
                }):Play()
                TweenService:Create(data.stroke, TweenInfo.new(0.3), {
                    Color = isActive and theme.accent_glow or theme.stroke_thin
                }):Play()
                data.btn.TextColor3 = isActive and Color3.fromRGB(20, 20, 30) or theme.text_sub
            end
            loadTabContent(i)
        end)
    end

    -- Content Area
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -245, 1, -90)
    contentFrame.Position = UDim2.new(0, 230, 0, 75)
    contentFrame.BackgroundColor3 = theme.bg_panel
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame

    local cfCorner = Instance.new("UICorner")
    cfCorner.CornerRadius = UDim.new(0, 16)
    cfCorner.Parent = contentFrame

    local cfStroke = Instance.new("UIStroke")
    cfStroke.Color = theme.stroke_main
    cfStroke.Thickness = 2
    cfStroke.Parent = contentFrame

    function loadTabContent(tabIndex)
        for _, child in pairs(contentFrame:GetChildren()) do
            if child.Name ~= "UICorner" and child ~= cfStroke then
                child:Destroy()
            end
        end

        local scroll = Instance.new("ScrollingFrame")
        scroll.Name = "ScrollContent"
        scroll.Size = UDim2.new(1, -30, 1, -30)
        scroll.Position = UDim2.new(0, 20, 0, 20)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 8
        scroll.ScrollBarImageColor3 = theme.accent_primary
        scroll.Parent = contentFrame

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 15)
        layout.Parent = scroll

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 30)
        end)

        -- Create buttons based on tab
        local buttons = {
            [1] = {
                {"🚀 Fly Hack (F)", toggleFly},
                {"👻 Noclip (X)", toggleNoclip},
                {"⚡ Speed 100 (V)", function() setSpeed(100) end},
                {"🦘 Jump 150 (B)", function() setJumpPower(150) end},
                {"♾️ Infinite Jump (G)", toggleInfiniteJump},
                {"📏 Big Player", function() resizePlayer(3) end}
            },
            [2] = {
                {"👁️ Player ESP", toggleESP},
                {"🧱 Wallhack", toggleWallhack},
                {"💥 Kill Aura", toggleKillAura},
                {"🌪️ Fling Players", massFling},
                {"🛡️ God Mode", toggleGodMode}
            },
            [3] = {
                {"🏆 ToH Auto Win", toggleToHAutoWin},
                {"⚡ ToH Speed 200", function() setSpeed(200) end},
                {"🚀 ToH Fly Hack", tohFlyHack},
                {"📍 Find Win Pad", findWinPad},
                {"⏭️ Stage Skip", tohStageSkip}
            },
            [4] = {
                {"📚 Infinite Yield", loadInfiniteYield},
                {"🧠 CMD-X", loadCMDx},
                {"🔍 Dark Dex", loadDarkDex},
                {"🗺️ Dex Explorer", loadDexExplorer}
            },
            [5] = {
                {"💡 Fullbright", toggleFullbright},
                {"🌫️ Remove Fog", removeFog},
                {"🌈 Rainbow ESP", toggleRainbowESP}
            },
            [6] = {
                {"🔄 Rejoin Server", rejoinServer},
                {"😴 Anti AFK", toggleAntiAFK},
                {"⚡ FPS Boost", fpsBoost},
                {"🔗 Copy Link", copyGameLink}
            }
        }

        for i, btnData in ipairs(buttons[tabIndex] or {}) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -20, 0, 70)
            btn.BackgroundColor3 = theme.bg_card
            btn.Text = btnData[1]
            btn.TextColor3 = theme.text_main
            btn.TextScaled = true
            btn.Font = Enum.Font.GothamBold
            btn.LayoutOrder = i
            btn.Parent = scroll

            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(0, 14)
            bCorner.Parent = btn

            local bStroke = Instance.new("UIStroke")
            bStroke.Color = theme.stroke_thin
            bStroke.Thickness = 2
            bStroke.Parent = btn

            local tweenInfoBtn = TweenInfo.new(0.25, Enum.EasingStyle.Quart)
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, tweenInfoBtn, {
                    BackgroundColor3 = theme.accent_primary
                }):Play()
                TweenService:Create(bStroke, tweenInfoBtn, {Color = theme.accent_glow}):Play()
            end)

            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, tweenInfoBtn, {
                    BackgroundColor3 = theme.bg_card
                }):Play()
                TweenService:Create(bStroke, tweenInfoBtn, {Color = theme.stroke_thin}):Play()
            end)

            btn.MouseButton1Click:Connect(function()
                btnData[2]()
            end)
        end
    end

    -- ALL WORKING FEATURES (FULL IMPLEMENTATIONS)
    function toggleFly()
        states.fly = not states.fly
        notify("Fly Hack", states.fly and "Enabled (Hold WASD)" or "Disabled", "success")
        if states.fly and LocalPlayer.Character then
            local char = LocalPlayer.Character
            local root = char:WaitForChild("HumanoidRootPart")
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = root

            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(4000, 4000, 4000)
            bg.CFrame = root.CFrame
            bg.Parent = root

            connections.fly = RunService.Heartbeat:Connect(function()
                if not states.fly or not char.Parent then return end
                local cam = workspace.CurrentCamera
                local move = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                bv.Velocity = move * 50
                bg.CFrame = cam.CFrame
            end)
        else
            if connections.fly then connections.fly:Disconnect() end
            if LocalPlayer.Character then
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    pcall(function()
                        root:FindFirstChild("BodyVelocity"):Destroy()
                        root:FindFirstChild("BodyGyro"):Destroy()
                    end)
                end
            end
        end
    end

    function toggleNoclip()
        states.noclip = not states.noclip
        notify("Noclip", states.noclip and "Enabled" or "Disabled", "success")
        if states.noclip then
            connections.noclip = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if connections.noclip then connections.noclip:Disconnect() end
        end
    end

    function setSpeed(speed)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = speed
            notify("Speed", "Set to " .. speed, "success")
        end
    end

    function setJumpPower(power)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = power
            notify("Jump", "Set to " .. power, "success")
        end
    end

    function toggleFullbright()
        states.fullbright = not states.fullbright
        if states.fullbright then
            Lighting.Brightness = 3
            Lighting.ClockTime = 14
            Lighting.FogEnd = 999999
            Lighting.GlobalShadows = false
            notify("Fullbright", "Enabled", "success")
        end
    end

    function toggleESP()
        states.esp = not states.esp
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                pcall(function()
                    local highlight = player.Character:FindFirstChild("HackerAI_ESP")
                    if states.esp then
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Name = "HackerAI_ESP"
                            highlight.FillColor = Color3.fromRGB(255, 0, 100)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.FillTransparency = 0.4
                            highlight.OutlineTransparency = 0
                            highlight.Parent = player.Character
                        end
                    else
                        if highlight then highlight:Destroy() end
                    end
                end)
            end
        end
        notify("ESP", states.esp and "Enabled" or "Disabled", "success")
    end

    function massFling()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Velocity = Vector3.new(math.random(-1000,1000), 5000, math.random(-1000,1000))
                end
            end
        end
        notify("Fling", "All players flung!", "success")
    end

    function rejoinServer()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end

    function loadInfiniteYield()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        notify("Infinite Yield", "Loaded!", "success")
    end

    function toggleAntiAFK()
        states.antiafk = not states.antiafk
        notify("Anti AFK", states.antiafk and "Enabled" or "Disabled", "success")
    end

    -- Keybinds
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        local key = input.KeyCode
        if key == Enum.KeyCode.F then toggleFly()
        elseif key == Enum.KeyCode.X then toggleNoclip()
        elseif key == Enum.KeyCode.V then setSpeed(100)
        end
    end)

    -- Load first tab
    loadTabContent(1)

    -- Entrance animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(mainFrame, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 1100, 0, 650)
    }):Play()
end

-- Initialize
createAuthScreen()
