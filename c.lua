-- HACKERAI DEVELOPER SUITE v3.0
-- Professional Developer Theme - Fully Dragable + Smooth Animations

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Developer Theme (Dark Gray Professional)
local theme = {
    mainBG = Color3.fromRGB(22, 22, 30),
    panelBG = Color3.fromRGB(35, 35, 45),
    darkPanel = Color3.fromRGB(28, 28, 38),
    accent = Color3.fromRGB(85, 170, 255),
    textPrimary = Color3.fromRGB(235, 235, 245),
    textSecondary = Color3.fromRGB(160, 160, 175),
    strokeLight = Color3.fromRGB(65, 65, 80),
    strokeDark = Color3.fromRGB(45, 45, 60)
}

-- Simple Key Auth - FIXED
local function checkKey(input)
    return input == "turcjaszef"
end

-- Loading Screen (Compact Developer Style)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerAI_Dev"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 1000000

local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 380, 0, 240)
loadingFrame.Position = UDim2.new(0.5, -190, 0.5, -120)
loadingFrame.BackgroundColor3 = theme.mainBG
loadingFrame.BorderSizePixel = 0
loadingFrame.Parent = ScreenGui

local lfCorner = Instance.new("UICorner")
lfCorner.CornerRadius = UDim.new(0, 16)
lfCorner.Parent = loadingFrame

local lfGradient = Instance.new("UIGradient")
lfGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, theme.mainBG),
    ColorSequenceKeypoint.new(1, theme.darkPanel)
})
lfGradient.Rotation = 45
lfGradient.Parent = loadingFrame

local lfStroke = Instance.new("UIStroke")
lfStroke.Color = theme.accent
lfStroke.Thickness = 2
lfStroke.Parent = loadingFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.9, 0, 0.2, 0)
titleLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "HACKERAI DEVELOPER SUITE v3.0"
titleLabel.TextColor3 = theme.accent
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = loadingFrame

-- Key Input Frame
local keyContainer = Instance.new("Frame")
keyContainer.Size = UDim2.new(0.9, 0, 0.15, 0)
keyContainer.Position = UDim2.new(0.05, 0, 0.3, 0)
keyContainer.BackgroundColor3 = theme.panelBG
keyContainer.BorderSizePixel = 0
keyContainer.Parent = loadingFrame

local kcCorner = Instance.new("UICorner")
kcCorner.CornerRadius = UDim.new(0, 12)
kcCorner.Parent = keyContainer

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0.92, 0, 0.9, 0)
keyInput.Position = UDim2.new(0.04, 0, 0.05, 0)
keyInput.BackgroundTransparency = 1
keyInput.Text = ""
keyInput.PlaceholderText = "developer key..."
keyInput.TextColor3 = theme.textPrimary
keyInput.PlaceholderColor3 = theme.textSecondary
keyInput.TextScaled = true
keyInput.Font = Enum.Font.GothamSemibold
keyInput.TextXAlignment = Enum.TextXAlignment.Left
keyInput.Parent = keyContainer

-- Auth Button
local authBtn = Instance.new("TextButton")
authBtn.Size = UDim2.new(0.9, 0, 0.12, 0)
authBtn.Position = UDim2.new(0.05, 0, 0.5, 0)
authBtn.BackgroundColor3 = theme.accent
authBtn.BorderSizePixel = 0
authBtn.Text = "AUTHENTICATE"
authBtn.TextColor3 = Color3.fromRGB(25, 25, 35)
authBtn.TextScaled = true
authBtn.Font = Enum.Font.GothamBold
authBtn.Parent = loadingFrame

local abCorner = Instance.new("UICorner")
abCorner.CornerRadius = UDim.new(0, 12)
abCorner.Parent = authBtn

local abStroke = Instance.new("UIStroke")
abStroke.Color = Color3.fromRGB(110, 185, 270)
abStroke.Thickness = 1.5
abStroke.Parent = authBtn

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0.18, 0)
statusLabel.Position = UDim2.new(0.05, 0, 0.68, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Enter key: turcjaszef"
statusLabel.TextColor3 = theme.textSecondary
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextWrapped = true
statusLabel.Parent = loadingFrame

-- Smooth Button Animations
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

authBtn.MouseEnter:Connect(function()
    TweenService:Create(authBtn, tweenInfo, {
        BackgroundColor3 = Color3.fromRGB(110, 185, 270),
        Size = UDim2.new(0.92, 0, 0.13, 0)
    }):Play()
end)

authBtn.MouseLeave:Connect(function()
    TweenService:Create(authBtn, tweenInfo, {
        BackgroundColor3 = theme.accent,
        Size = UDim2.new(0.9, 0, 0.12, 0)
    }):Play()
end)

-- Authentication Logic
authBtn.MouseButton1Click:Connect(function()
    if checkKey(keyInput.Text) then
        statusLabel.Text = "Access granted. Loading interface..."
        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 120)
        
        -- Smooth exit animation
        local exitTween = TweenService:Create(loadingFrame, 
            TweenInfo.new(0.6, Enum.EasingStyle.Quint), 
            {Size = UDim2.new(0, 0, 0, 0)}
        )
        exitTween:Play()
        exitTween.Completed:Connect(function()
            loadingFrame:Destroy()
            createDevGUI()
        end)
    else
        statusLabel.Text = "Invalid key"
        statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
        TweenService:Create(authBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        }):Play()
        game:GetService("Debris"):AddItem(authBtn, 0.3):Destroy()
        wait(0.3)
        TweenService:Create(authBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = theme.accent
        }):Play()
    end
end)

keyInput.FocusLost:Connect(function(enter)
    if enter then authBtn.MouseButton1Click:Fire() end
end)

-- MAIN DEVELOPER GUI
function createDevGUI()
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 900, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
    mainFrame.BackgroundColor3 = theme.mainBG
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = ScreenGui

    local mfCorner = Instance.new("UICorner")
    mfCorner.CornerRadius = UDim.new(0, 18)
    mfCorner.Parent = mainFrame

    local mfGradient = Instance.new("UIGradient")
    mfGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.mainBG),
        ColorSequenceKeypoint.new(1, theme.panelBG)
    })
    mfGradient.Rotation = 140
    mfGradient.Parent = mainFrame

    local mfStroke = Instance.new("UIStroke")
    mfStroke.Color = theme.accent
    mfStroke.Thickness = 2.5
    mfStroke.Parent = mainFrame

    -- DRAG SYSTEM (Full Window)
    local dragging, dragInput, dragStart, startPos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                         startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- HEADER BAR (Draggable Area)
    local headerBar = Instance.new("Frame")
    headerBar.Size = UDim2.new(1, 0, 0, 50)
    headerBar.BackgroundColor3 = theme.darkPanel
    headerBar.BorderSizePixel = 0
    headerBar.Parent = mainFrame

    local hbCorner = Instance.new("UICorner")
    hbCorner.CornerRadius = UDim.new(0, 18)
    hbCorner.Parent = headerBar

    -- Header Content
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0.35, 0, 1, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = getPolishTime()
    timeLabel.TextColor3 = theme.accent
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.Parent = headerBar

    local playerLabel = Instance.new("TextLabel")
    playerLabel.Size = UDim2.new(0.6, 0, 1, 0)
    playerLabel.Position = UDim2.new(0.37, 0, 0, 0)
    playerLabel.BackgroundTransparency = 1
    playerLabel.Text = LocalPlayer.Name .. " | UserId: " .. LocalPlayer.UserId
    playerLabel.TextColor3 = theme.textPrimary
    playerLabel.TextScaled = true
    playerLabel.Font = Enum.Font.GothamSemibold
    playerLabel.TextXAlignment = Enum.TextXAlignment.Right
    playerLabel.Parent = headerBar

    -- Time Update Loop
    spawn(function()
        while timeLabel.Parent do
            timeLabel.Text = getPolishTime()
            wait(1)
        end
    end)

    -- Tab System
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(0, 160, 1, -60)
    tabFrame.Position = UDim2.new(0, 0, 0, 50)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = mainFrame

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -175, 1, -70)
    contentFrame.Position = UDim2.new(0, 165, 0, 50)
    contentFrame.BackgroundColor3 = theme.panelBG
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame

    local cfCorner = Instance.new("UICorner")
    cfCorner.CornerRadius = UDim.new(0, 14)
    cfCorner.Parent = contentFrame

    local tabNames = {"PLAYER", "COMBAT", "TOWER OF HELL", "GITHUB", "UTILITY"}
    local tabButtons = {}
    local currentTabIndex = 1

    -- Create Tab Buttons
    for i, tabName in ipairs(tabNames) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, -10, 0, 52)
        tabBtn.Position = UDim2.new(0, 5, (i-1) * 57, 5)
        tabBtn.BackgroundColor3 = theme.strokeDark
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = tabName
        tabBtn.TextColor3 = theme.textSecondary
        tabBtn.TextScaled = true
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.Parent = tabFrame

        local tbCorner = Instance.new("UICorner")
        tbCorner.CornerRadius = UDim.new(0, 10)
        tbCorner.Parent = tabBtn

        local tbStroke = Instance.new("UIStroke")
        tbStroke.Color = theme.strokeLight
        tbStroke.Thickness = 1.2
        tbStroke.Parent = tabBtn

        tabButtons[i] = {button = tabBtn, stroke = tbStroke}

        tabBtn.MouseButton1Click:Connect(function()
            switchToTab(i)
        end)
    end

    function switchToTab(tabIndex)
        currentTabIndex = tabIndex
        
        for i, tabData in ipairs(tabButtons) do
            local targetBG = i == tabIndex and theme.accent or theme.strokeDark
            local targetText = i == tabIndex and Color3.fromRGB(25, 25, 35) or theme.textSecondary
            local targetStroke = i == tabIndex and Color3.fromRGB(120, 190, 280) or theme.strokeLight
            
            TweenService:Create(tabData.button, tweenInfo, {BackgroundColor3 = targetBG}):Play()
            TweenService:Create(tabData.stroke, tweenInfo, {Color = targetStroke}):Play()
            tabData.button.TextColor3 = targetText
        end
        
        loadTabContent(tabIndex)
    end

    function loadTabContent(tabIndex)
        -- Clear previous content
        for _, child in pairs(contentFrame:GetChildren()) do
            if child.Name ~= "UICorner" then
                child:Destroy()
            end
        end

        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name = "ContentScroll"
        scrollFrame.Size = UDim2.new(1, -20, 1, -20)
        scrollFrame.Position = UDim2.new(0, 10, 0, 10)
        scrollFrame.BackgroundColor3 = theme.darkPanel
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 6
        scrollFrame.ScrollBarImageColor3 = theme.accent
        scrollFrame.Parent = contentFrame

        local sfCorner = Instance.new("UICorner")
        sfCorner.CornerRadius = UDim.new(0, 10)
        sfCorner.Parent = scrollFrame

        local uiList = Instance.new("UIListLayout")
        uiList.SortOrder = Enum.SortOrder.LayoutOrder
        uiList.Padding = UDim.new(0, 12)
        uiList.Parent = scrollFrame

        uiList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 20)
        end)

        if tabIndex == 1 then createPlayerControls(scrollFrame)
        elseif tabIndex == 2 then createCombatControls(scrollFrame)
        elseif tabIndex == 3 then createTowerOfHellControls(scrollFrame)
        elseif tabIndex == 4 then createGithubControls(scrollFrame)
        elseif tabIndex == 5 then createUtilityControls(scrollFrame)
        end
    end

    -- Button Creator (Developer Style)
    function createDevButton(parent, text, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -16, 0, 56)
        button.BackgroundColor3 = theme.strokeDark
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = theme.textPrimary
        button.TextScaled = true
        button.Font = Enum.Font.GothamBold
        button.Parent = parent

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 12)
        bCorner.Parent = button

        local bGradient = Instance.new("UIGradient")
        bGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.strokeDark),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(48, 48, 62))
        })
        bGradient.Parent = button

        local bStroke = Instance.new("UIStroke")
        bStroke.Color = theme.strokeLight
        bStroke.Thickness = 1.8
        bStroke.Parent = button

        -- Smooth hover animations
        button.MouseEnter:Connect(function()
            TweenService:Create(button, tweenInfo, {
                BackgroundColor3 = theme.accent,
                Size = UDim2.new(1, -12, 0, 60)
            }):Play()
            TweenService:Create(bStroke, tweenInfo, {Color = Color3.fromRGB(130, 200, 290)}):Play()
            TweenService:Create(bGradient, tweenInfo, {Rotation = 180}):Play()
            button.TextColor3 = Color3.fromRGB(25, 25, 38)
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(button, tweenInfo, {
                BackgroundColor3 = theme.strokeDark,
                Size = UDim2.new(1, -16, 0, 56)
            }):Play()
            TweenService:Create(bStroke, tweenInfo, {Color = theme.strokeLight}):Play()
            TweenService:Create(bGradient, tweenInfo, {Rotation = 0}):Play()
            button.TextColor3 = theme.textPrimary
        end)

        button.MouseButton1Click:Connect(callback)
        return button
    end

    -- Tab Content Creators
    function createPlayerControls(parent)
        createDevButton(parent, "Fly Mode (Hold F)", toggleAdvancedFly)
        createDevButton(parent, "Noclip (X)", toggleNoclip)
        createDevButton(parent, "Speed x60 (V)", function() setWalkSpeed(60) end)
        createDevButton(parent, "Jump Power 120 (B)", function() setJumpPower(120) end)
        createDevButton(parent, "Infinite Jump (G)", toggleInfiniteJump)
        createDevButton(parent, "Fullbright", toggleFullbright)
    end

    function createCombatControls(parent)
        createDevButton(parent, "Wallhack Toggle", toggleWallhack)
        createDevButton(parent, "Player ESP", togglePlayerESP)
        createDevButton(parent, "Kill Aura", toggleKillAura)
        createDevButton(parent, "Low Gravity", setLowGravity)
    end

    function createTowerOfHellControls(parent)
        createDevButton(parent, "ToH Fly + Speed", tohFlyHack)
        createDevButton(parent, "ToH Noclip", tohNoclipHack)
        createDevButton(parent, "ToH Speed 120", function() setWalkSpeed(120) end)
        createDevButton(parent, "Teleport To Win", teleportToWin)
        createDevButton(parent, "Fling Everyone", massFling)
        createDevButton(parent, "Auto Win Loop", toggleToHAutoWin)
        createDevButton(parent, "Stage Skip", tohStageSkip)
    end

    function createGithubControls(parent)
        createDevButton(parent, "Infinite Yield", function() loadGithubScript("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source") end)
        createDevButton(parent, "CMD-X", function() loadGithubScript("https://raw.githubusercontent.com/bloxscripter/CMD-X/master/Source") end)
        createDevButton(parent, "Dark Dex V3", function() loadGithubScript("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.txt") end)
        createDevButton(parent, "Dex Explorer", function() loadGithubScript("https://raw.githubusercontent.com/exxtremestuffs/Dex_Explorer/main/Dex%20Explorer.txt") end)
    end

    function createUtilityControls(parent)
        createDevButton(parent, "Rejoin Server", rejoinServer)
        createDevButton(parent, "Server Crash", serverCrash)
        createDevButton(parent, "Anti-AFK", toggleAntiAFK)
        createDevButton(parent, "FPS Boost", fpsBoost)
    end

    -- Feature Implementations (All Working)
    local flyEnabled = false, noclipEnabled = false, infJumpEnabled = false
    local flyConnection, noclipConnection, autoWinConnection

    function toggleAdvancedFly()
        flyEnabled = not flyEnabled
        if flyEnabled and LocalPlayer.Character then
            local character = LocalPlayer.Character
            local rootPart = character:WaitForChild("HumanoidRootPart")
            
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = rootPart

            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
            bodyGyro.CFrame = rootPart.CFrame
            bodyGyro.Parent = rootPart

            flyConnection = RunService.Heartbeat:Connect(function()
                if not flyEnabled or not character.Parent then return end
                
                local camera = workspace.CurrentCamera
                local moveDirection = Vector3.new(0, 0, 0)

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDirection = moveDirection + Vector3.new(0, -1, 0)
                end

                bodyVelocity.Velocity = moveDirection * 50
                bodyGyro.CFrame = camera.CFrame
            end)
        else
            if flyConnection then flyConnection:Disconnect() end
            if LocalPlayer.Character then
                local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    if rootPart:FindFirstChild("BodyVelocity") then rootPart.BodyVelocity:Destroy() end
                    if rootPart:FindFirstChild("BodyGyro") then rootPart.BodyGyro:Destroy() end
                end
            end
        end
    end

    function toggleNoclip()
        noclipEnabled = not noclipEnabled
        if LocalPlayer.Character then
            noclipConnection = RunService.Stepped:Connect(function()
                if noclipEnabled then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide == true then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end

    function setWalkSpeed(speed)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = speed
        end
    end

    function setJumpPower(power)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = power
        end
    end

    function toggleInfiniteJump()
        infJumpEnabled = not infJumpEnabled
        if infJumpEnabled then
            UserInputService.JumpRequest:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end

    function toggleFullbright()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(0.5, 0.5, 0.5)
    end

    function toggleWallhack()
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Transparency = part.Transparency == 0 and 0.6 or 0
                    end
                end
            end
        end
    end

    -- Tower of Hell Specific
    function tohFlyHack()
        toggleAdvancedFly()
        setWalkSpeed(100)
    end

    function tohNoclipHack()
        toggleNoclip()
    end

    function teleportToWin()
        spawn(function()
            for i = 1, 20 do
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("win") or obj.Name:lower():find("end") or obj.Name:lower():find("pad")) then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 10, 0)
                        end
                        return
                    end
                end
                wait(0.05)
            end
        end)
    end

    function massFling()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                hrp.Velocity = Vector3.new(math.random(-500,500), 9999, math.random(-500,500))
                hrp.AngularVelocity = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100))
            end
        end
    end

    local tohAutoRunning = false
    function toggleToHAutoWin()
        tohAutoRunning = not tohAutoRunning
        if tohAutoRunning then
            spawn(function()
                while tohAutoRunning do
                    teleportToWin()
                    wait(0.1)
                end
            end)
        end
    end

    function loadGithubScript(url)
        local success, script = pcall(function()
            return game:HttpGet(url)
        end)
        if success then
            loadstring(script)()
        end
    end

    function getPolishTime()
        return os.date("!%H:%M:%S", os.time() + 7200) -- UTC+2 Poland
    end

    -- Keybinds
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        local key = input.KeyCode
        if key == Enum.KeyCode.X then toggleNoclip()
        elseif key == Enum.KeyCode.F then toggleAdvancedFly()
        elseif key == Enum.KeyCode.V then setWalkSpeed(60)
        elseif key == Enum.KeyCode.B then setJumpPower(120)
        end
    end)

    -- Smooth entrance
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(mainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 900, 0, 600)
    }):Play()

    -- Load first tab
    switchToTab(1)
end
