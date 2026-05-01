--[[
  Roblox Security Auditor v4.0 FINAL
  Author: HackerAI Pentest Framework
  Authorized security assessment tool ONLY
]]

-- ===== INIT =====
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    LocalPlayer = Players:WaitForChild("LocalPlayer", 10)
end

-- Clipboard fallback chain
local SetClip = setclipboard or toclipboard or set_clipboard or function(txt)
    local f = writefile and writefile("clipboard_temp.txt", tostring(txt))
    return f
end

-- ===== DATA STORAGE =====
local Data = {
    Scripts = {}, Locals = {}, Modules = {},
    Remotes = {}, RemoteFuncs = {},
    AntiCheats = {}, AdminSys = {}, CurrencySys = {},
    Backdoors = {}, Vulns = {}, Exploits = {},
    AllSources = {},
}

-- ===== PATTERNS =====
local Pats = {
    AC = {"anticheat","anti_cheat","cheatdetect","exploitdetect","kickplayer","banplayer",
          "remotesecurity","ratelimit","checkcaller","sanitycheck","securitycheck",
          "antifly","antitp","antisp","antijump","logremote","remotelog","dutycheck"},
    AD = {"admin","hdadmin","kohlsadmin","admincmd","cmds","cmdsy","adminpanel",
          "adminmenu","adminsystem","cmdhandler","cmdcenter","admincommand"},
    CU = {"currency","money","coins","gems","gold","cash","balance","leaderstats",
          "economy","wallet","bank","points","credits","tokens","reward","vip",
          "addcurrency","setmoney","givecoins","buy","purchase","grant","unlock",
          "multiplier","boost","donation","premium"},
    BD = {"loadstring","httpget","httppost","getasync","postasync","pastebin",
          "discord","webhook","cloneref","checkcaller","hookmetamethod",
          "getrawmetatable","setrawmetatable","getnamecallmethod"},
}

-- ===== UI BUILDER =====
local function BuildUI()
    local ui = {}

    local sg = Instance.new("ScreenGui")
    sg.Name = "HackerAudit"
    sg.ResetOnSpawn = false
    sg.Parent = CoreGui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Parent = sg
    main.BackgroundColor3 = Color3.fromRGB(15,15,25)
    main.BorderSizePixel = 0
    main.Position = UDim2.new(0.1,0,0.05,0)
    main.Size = UDim2.new(0.8,0,0.9,0)
    main.Draggable = true
    main.Active = true
    main.ClipsDescendants = true

    -- Title
    local title = Instance.new("TextLabel")
    title.Parent = main
    title.BackgroundColor3 = Color3.fromRGB(25,25,40)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1,0,0,35)
    title.Font = Enum.Font.Code
    title.Text = "  Roblox Security Auditor v4.0 | Authorized Pentest Tool"
    title.TextColor3 = Color3.fromRGB(0,255,100)
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Close button
    local close = Instance.new("TextButton")
    close.Parent = title
    close.BackgroundColor3 = Color3.fromRGB(200,20,20)
    close.BorderSizePixel = 0
    close.Size = UDim2.new(0,30,0,30)
    close.Position = UDim2.new(1,-35,0,2)
    close.Font = Enum.Font.Code
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255,255,255)
    close.TextSize = 14
    close.MouseButton1Click:Connect(function() sg:Destroy() end)

    -- Button row
    local btnRow = Instance.new("Frame")
    btnRow.Parent = main
    btnRow.BackgroundColor3 = Color3.fromRGB(20,20,33)
    btnRow.BorderSizePixel = 0
    btnRow.Position = UDim2.new(0,0,0,35)
    btnRow.Size = UDim2.new(1,0,0,40)

    local scanBtn = Instance.new("TextButton")
    scanBtn.Parent = btnRow
    scanBtn.BackgroundColor3 = Color3.fromRGB(0,140,50)
    scanBtn.BorderSizePixel = 0
    scanBtn.Position = UDim2.new(0,10,0,5)
    scanBtn.Size = UDim2.new(0,130,0,30)
    scanBtn.Font = Enum.Font.Code
    scanBtn.Text = "▶ START SCAN"
    scanBtn.TextColor3 = Color3.fromRGB(255,255,255)
    scanBtn.TextSize = 13

    local exportBtn = Instance.new("TextButton")
    exportBtn.Parent = btnRow
    exportBtn.BackgroundColor3 = Color3.fromRGB(0,80,180)
    exportBtn.BorderSizePixel = 0
    exportBtn.Position = UDim2.new(0,150,0,5)
    exportBtn.Size = UDim2.new(0,100,0,30)
    exportBtn.Font = Enum.Font.Code
    exportBtn.Text = "📋 COPY"
    exportBtn.TextColor3 = Color3.fromRGB(255,255,255)
    exportBtn.TextSize = 13

    local clearBtn = Instance.new("TextButton")
    clearBtn.Parent = btnRow
    clearBtn.BackgroundColor3 = Color3.fromRGB(100,30,30)
    clearBtn.BorderSizePixel = 0
    clearBtn.Position = UDim2.new(0,260,0,5)
    clearBtn.Size = UDim2.new(0,80,0,30)
    clearBtn.Font = Enum.Font.Code
    clearBtn.Text = "CLEAR"
    clearBtn.TextColor3 = Color3.fromRGB(255,255,255)
    clearBtn.TextSize = 13

    -- Status
    local status = Instance.new("TextLabel")
    status.Parent = main
    status.BackgroundColor3 = Color3.fromRGB(20,20,33)
    status.BorderSizePixel = 0
    status.Position = UDim2.new(0,0,0,75)
    status.Size = UDim2.new(1,0,0,22)
    status.Font = Enum.Font.Code
    status.Text = "Ready. Click START SCAN to begin audit."
    status.TextColor3 = Color3.fromRGB(150,200,255)
    status.TextSize = 12
    status.TextXAlignment = Enum.TextXAlignment.Left

    -- Log area
    local logFrame = Instance.new("ScrollingFrame")
    logFrame.Parent = main
    logFrame.BackgroundColor3 = Color3.fromRGB(10,10,18)
    logFrame.BorderSizePixel = 0
    logFrame.Position = UDim2.new(0,0,0,97)
    logFrame.Size = UDim2.new(1,0,1,-97)
    logFrame.CanvasSize = UDim2.new(0,0,0,0)
    logFrame.ScrollBarThickness = 6
    logFrame.ScrollBarImageColor3 = Color3.fromRGB(50,50,70)

    local log = Instance.new("TextLabel")
    log.Parent = logFrame
    log.BackgroundTransparency = 1
    log.Size = UDim2.new(1,-10,0,0)
    log.Position = UDim2.new(0,5,0,5)
    log.Font = Enum.Font.Code
    log.Text = ""
    log.TextColor3 = Color3.fromRGB(180,180,180)
    log.TextSize = 12
    log.TextXAlignment = Enum.TextXAlignment.Left
    log.TextYAlignment = Enum.TextYAlignment.Top
    log.RichText = true

    ui.ScreenGui = sg
    ui.LogText = log
    ui.LogFrame = logFrame
    ui.Status = status
    ui.ScanBtn = scanBtn
    ui.ExportBtn = exportBtn
    ui.ClearBtn = clearBtn

    return ui
end

-- ===== LOGGING =====
local UI
local function Log(msg, color)
    if not UI then return end
    color = color or Color3.fromRGB(180,180,180)
    local r,g,b = math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)
    local t = os.date("%H:%M:%S")
    local ok = pcall(function()
        UI.LogText.Text = UI.LogText.Text .. string.format('<font color="rgb(%d,%d,%d)">[%s]</font> %s\n',r,g,b,t,tostring(msg))
        local sz = UI.LogText.TextBounds
        UI.LogFrame.CanvasSize = UDim2.new(0,0,0,sz.Y+20)
        UI.LogFrame.CanvasPosition = Vector2.new(0,sz.Y)
    end)
end

local function SetStatus(s)
    if UI and UI.Status then
        UI.Status.Text = s
    end
end

-- ===== SCANNER =====
local function AnalyzeScript(name, path, src, class)
    local sl = src:lower()
    local results = {}

    -- AntiCheat check
    for _, p in ipairs(Pats.AC) do
        if sl:find(p,1,true) then
            table.insert(Data.AntiCheats, {Name=name, Path=path, Pattern=p, Source=src})
            Log(string.format("[AC] %s -> '%s'", path, p), Color3.fromRGB(255,150,0))
            break
        end
    end

    -- Admin check
    for _, p in ipairs(Pats.AD) do
        if sl:find(p,1,true) then
            table.insert(Data.AdminSys, {Name=name, Path=path, Pattern=p, Source=src})
            Log(string.format("[ADMIN] %s -> '%s'", path, p), Color3.fromRGB(255,200,0))
            break
        end
    end

    -- Currency check
    for _, p in ipairs(Pats.CU) do
        if sl:find(p,1,true) then
            table.insert(Data.CurrencySys, {Name=name, Path=path, Pattern=p, Source=src})
            Log(string.format("[CURRENCY] %s -> '%s'", path, p), Color3.fromRGB(0,255,100))
            break
        end
    end

    -- Backdoor check
    for _, p in ipairs(Pats.BD) do
        if sl:find(p,1,true) then
            table.insert(Data.Backdoors, {Name=name, Path=path, Pattern=p, Source=src})
            Log(string.format("[! BACKDOOR] %s -> '%s'", path, p), Color3.fromRGB(255,0,0))
            break
        end
    end

    -- Vulnerability analysis
    local vulns = {}
    if sl:find("fireserver",1,true) and not sl:find("validat",1,true) and not sl:find("check",1,true) then
        table.insert(vulns, {Type="Unvalidated FireServer", Sev="HIGH"})
    end
    if sl:find("loadstring",1,true) then
        table.insert(vulns, {Type="loadstring() - code execution", Sev="CRITICAL"})
    end
    if sl:find("httpget",1,true) or sl:find("httppost",1,true) then
        table.insert(vulns, {Type="External HTTP requests", Sev="HIGH"})
    end
    if sl:find("debug%.",1,true) then
        table.insert(vulns, {Type="Debug library access", Sev="MEDIUM"})
    end
    if sl:find("getrawmetatable",1,true) or sl:find("setrawmetatable",1,true) then
        table.insert(vulns, {Type="Raw metatable manipulation", Sev="CRITICAL"})
    end
    if sl:find("hookmetamethod",1,true) then
        table.insert(vulns, {Type="Metamethod hooking", Sev="CRITICAL"})
    end
    if sl:find("checkcaller",1,true) then
        table.insert(vulns, {Type="CheckCaller bypass", Sev="CRITICAL"})
    end
    if sl:find("cloneref",1,true) then
        table.insert(vulns, {Type="CloneRef anti-detection", Sev="HIGH"})
    end
    if sl:find("%.value%s*=",1,true) and not sl:find("validat",1,true) then
        table.insert(vulns, {Type="Unvalidated Value set", Sev="MEDIUM"})
    end

    if #vulns > 0 then
        table.insert(Data.Vulns, {Script=name, Path=path, Vulns=vulns})
        for _, v in ipairs(vulns) do
            local c = v.Sev == "CRITICAL" and Color3.fromRGB(255,0,0)
                      or v.Sev == "HIGH" and Color3.fromRGB(255,100,0)
                      or Color3.fromRGB(255,200,0)
            Log(string.format("[VULN][%s] %s in %s", v.Sev, v.Type, name), c)
        end
    end

    return results
end

local function ScanRecursive(inst, depth)
    depth = depth or 0
    if depth > 60 then return end

    local ok, err = pcall(function()
        local cls = inst.ClassName
        local path = ""
        pcall(function() path = inst:GetFullName() end)
        if path == "" then path = inst.Name end

        if cls == "Script" then
            local src = inst.Source or ""
            local d = {Name=inst.Name, Path=path, Source=src, Len=#src, Enabled=inst.Enabled}
            table.insert(Data.Scripts, d)
            table.insert(Data.AllSources, {Name=inst.Name, Path=path, Source=src, Class="Script"})
            Log(string.format("SCRIPT: %s (%d bytes)", path, #src), Color3.fromRGB(0,200,255))
            AnalyzeScript(inst.Name, path, src, "Script")

        elseif cls == "LocalScript" then
            local src = inst.Source or ""
            local d = {Name=inst.Name, Path=path, Source=src, Len=#src, Enabled=inst.Enabled}
            table.insert(Data.Locals, d)
            table.insert(Data.AllSources, {Name=inst.Name, Path=path, Source=src, Class="LocalScript"})
            Log(string.format("LOCAL: %s (%d bytes)", path, #src), Color3.fromRGB(100,255,255))
            AnalyzeScript(inst.Name, path, src, "LocalScript")

        elseif cls == "ModuleScript" then
            local src = inst.Source or ""
            table.insert(Data.Modules, {Name=inst.Name, Path=path, Source=src, Len=#src})
            table.insert(Data.AllSources, {Name=inst.Name, Path=path, Source=src, Class="ModuleScript"})

        elseif cls == "RemoteEvent" then
            table.insert(Data.Remotes, {Name=inst.Name, Path=path, Parent=tostring(inst.Parent)})
            Log(string.format("REMOTE: %s", path), Color3.fromRGB(200,100,255))

            local nl = inst.Name:lower()
            if nl:find("currency",1,true) or nl:find("money",1,true) or nl:find("coin",1,true)
               or nl:find("give",1,true) or nl:find("add",1,true) or nl:find("set",1,true)
               or nl:find("admin",1,true) or nl:find("cmd",1,true) or nl:find("buy",1,true)
               or nl:find("grant",1,true) or nl:find("reward",1,true) or nl:find("unlock",1,true)
               or nl:find("kick",1,true) or nl:find("ban",1,true) or nl:find("teleport",1,true)
               or nl:find("spawn",1,true) or nl:find("give",1,true) then
                table.insert(Data.Exploits, {Name=inst.Name, Path=path, Type="RemoteEvent", Risk="HIGH",
                    Reason="Name suggests privileged operation", Payload="FireServer(craftedArgs)"})
                Log(string.format("[! TARGET] %s (HIGH VALUE)", path), Color3.fromRGB(255,0,0))
            end

        elseif cls == "RemoteFunction" then
            table.insert(Data.RemoteFuncs, {Name=inst.Name, Path=path, Parent=tostring(inst.Parent)})
            Log(string.format("FUNC: %s", path), Color3.fromRGB(200,50,255))

            local nl = inst.Name:lower()
            if nl:find("currency",1,true) or nl:find("money",1,true) or nl:find("coin",1,true)
               or nl:find("give",1,true) or nl:find("add",1,true) or nl:find("set",1,true)
               or nl:find("admin",1,true) or nl:find("cmd",1,true) or nl:find("kick",1,true)
               or nl:find("ban",1,true) then
                table.insert(Data.Exploits, {Name=inst.Name, Path=path, Type="RemoteFunction", Risk="HIGH",
                    Reason="Name suggests privileged operation", Payload="InvokeServer(craftedArgs)"})
                Log(string.format("[! TARGET] %s (HIGH VALUE)", path), Color3.fromRGB(255,0,0))
            end
        end

        -- Recurse children
        for _, ch in ipairs(inst:GetChildren()) do
            task.wait()
            ScanRecursive(ch, depth+1)
        end
    end)

    if not ok then
        local nm = "unknown"
        pcall(function() nm = inst.Name end)
        Log(string.format("Error: %s - %s", nm, tostring(err)), Color3.fromRGB(255,50,50))
    end
end

local function ScanService(svcName)
    local ok, svc = pcall(function() return game:GetService(svcName) end)
    if ok and svc then
        Log(string.format("--- Scanning %s ---", svcName), Color3.fromRGB(200,200,255))
        pcall(function() ScanRecursive(svc) end)
        task.wait(0.05)
    end
end

-- ===== MAIN START =====
local function StartScan()
    -- Reset
    Data = {Scripts={}, Locals={}, Modules={}, Remotes={}, RemoteFuncs={},
            AntiCheats={}, AdminSys={}, CurrencySys={}, Backdoors={},
            Vulns={}, Exploits={}, AllSources={}}

    if UI and UI.LogText then
        UI.LogText.Text = ""
    end

    Log("============================================", Color3.fromRGB(0,255,100))
    Log("  Roblox Security Auditor v4.0", Color3.fromRGB(0,255,100))
    Log(string.format("  Game: %s (ID: %s)", tostring(game.Name), tostring(game.GameId)), Color3.fromRGB(0,255,100))
    Log(string.format("  Player: %s", LocalPlayer and LocalPlayer.Name or "N/A"), Color3.fromRGB(0,255,100))
    Log(string.format("  Time: %s", os.date("%Y-%m-%d %H:%M:%S")), Color3.fromRGB(0,255,100))
    Log("============================================", Color3.fromRGB(0,255,100))

    SetStatus("Scanning all services...")

    -- Workspace
    SetStatus("[1/6] Scanning Workspace...")
    ScanService("Workspace")

    -- ReplicatedStorage
    SetStatus("[2/6] Scanning ReplicatedStorage...")
    ScanService("ReplicatedStorage")

    -- Other services
    SetStatus("[3/6] Scanning other services...")
    local svcs = {"ReplicatedFirst","ServerScriptService","ServerStorage",
                  "StarterGui","StarterPack","Lighting"}
    for _, s in ipairs(svcs) do
        ScanService(s)
    end

    -- Players
    SetStatus("[4/6] Scanning Players...")
    Log("--- Scanning Players ---", Color3.fromRGB(200,200,255))
    pcall(function()
        for _, plr in pairs(Players:GetPlayers()) do
            pcall(function() ScanRecursive(plr) end)
            task.wait()
        end
    end)

    -- PlayerGui / Backpack of local player
    SetStatus("[5/6] Scanning local player...")
    if LocalPlayer then
        pcall(function()
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then ScanRecursive(pg) end
        end)
        pcall(function()
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if bp then ScanRecursive(bp) end
        end)
    end

    -- Summary
    SetStatus("[6/6] Generating report...")
    Log("\n============================================", Color3.fromRGB(0,255,100))
    Log("  SCAN RESULTS", Color3.fromRGB(0,255,100))
    Log("============================================", Color3.fromRGB(0,255,100))
    Log(string.format("  Scripts (server):   %d", #Data.Scripts), Color3.fromRGB(0,200,255))
    Log(string.format("  LocalScripts:       %d", #Data.Locals), Color3.fromRGB(100,255,255))
    Log(string.format("  ModuleScripts:      %d", #Data.Modules), Color3.fromRGB(180,180,180))
    Log(string.format("  RemoteEvents:       %d", #Data.Remotes), Color3.fromRGB(200,100,255))
    Log(string.format("  RemoteFunctions:    %d", #Data.RemoteFuncs), Color3.fromRGB(200,50,255))
    Log(string.format("  AntiCheat systems:  %d", #Data.AntiCheats), Color3.fromRGB(255,150,0))
    Log(string.format("  Admin systems:      %d", #Data.AdminSys), Color3.fromRGB(255,200,0))
    Log(string.format("  Currency systems:   %d", #Data.CurrencySys), Color3.fromRGB(0,255,100))
    Log(string.format("  Backdoor patterns:  %d", #Data.Backdoors), Color3.fromRGB(255,50,50))
    Log(string.format("  Vulnerabilities:    %d", #Data.Vulns), Color3.fromRGB(255,100,0))
    Log(string.format("  Exploit vectors:    %d", #Data.Exploits), Color3.fromRGB(255,0,0))
    Log("============================================", Color3.fromRGB(0,255,100))

    if #Data.Exploits > 0 then
        Log("\n--- HIGH VALUE TARGETS TO EXPLOIT ---", Color3.fromRGB(255,200,0))
        for _, e in ipairs(Data.Exploits) do
            Log(string.format("  [%s] %s -> %s", e.Type, e.Name, e.Payload), Color3.fromRGB(255,200,0))
        end

        Log("\n--- EXPLOIT COMMANDS ---", Color3.fromRGB(0,255,100))
        Log("Copy & paste these into executor:", Color3.fromRGB(0,255,100))
        Log("", Color3.fromRGB(180,180,180))

        -- Generate exploit commands
        local fireAll = "-- Fire all currency/admin remotes:\n"
        for _, e in ipairs(Data.Exploits) do
            if e.Type == "RemoteEvent" then
                fireAll = fireAll .. string.format("pcall(function() game:GetDescendants()\nfor _,v in pairs(game:GetDescendants()) do\n  if v:IsA('RemoteEvent') and v.Name == '%s' then\n    v:FireServer(999999)\n    v:FireServer(game.Players.LocalPlayer, 999999)\n    v:FireServer('add', 999999)\n    v:FireServer(999999, 'Currency')\n  end\nend end)\n", e.Name)
            end
        end

        local cmdLine = fireAll
        Log(cmdLine, Color3.fromRGB(200,200,200))

        -- Copy to clipboard automatically
        pcall(function()
            SetClip(cmdLine)
            Log("[!] Exploit commands copied to clipboard!", Color3.fromRGB(0,255,200))
        end)
    end

    if #Data.Backdoors > 0 then
        Log("\n--- BACKDOOR SCRIPTS FOUND ---", Color3.fromRGB(255,0,0))
        for _, b in ipairs(Data.Backdoors) do
            Log(string.format("  %s -> %s", b.Path, b.Pattern), Color3.fromRGB(255,100,100))
        end
    end

    if #Data.Vulns > 0 then
        Log("\n--- VULNERABILITIES ---", Color3.fromRGB(255,100,0))
        for _, v in ipairs(Data.Vulns) do
            for _, vv in ipairs(v.Vulns) do
                Log(string.format("  [%s] %s: %s", vv.Sev, v.Script, vv.Type), Color3.fromRGB(255,150,0))
            end
        end
    end

    local total = #Data.Vulns + #Data.Exploits + #Data.Backdoors
    SetStatus(string.format("Scan complete! %d issues found. Click COPY to save results.", total))
end

-- ===== EXPORT =====
local function ExportResults()
    local report = ""

    report = report .. "============================================\n"
    report = report .. " ROBLOX SECURITY AUDIT REPORT\n"
    report = report .. string.format(" Game: %s (ID: %s)\n", tostring(game.Name), tostring(game.GameId))
    report = report .. string.format(" Date: %s\n", os.date("%Y-%m-%d %H:%M:%S"))
    report = report .. "============================================\n\n"

    report = report .. "=== ANTI-CHEAT SYSTEMS ===\n"
    for _, v in ipairs(Data.AntiCheats) do
        report = report .. string.format("  %s (pattern: %s)\n", v.Path, v.Pattern)
        report = report .. string.format("  Source:\n%s\n\n", v.Source)
    end
    if #Data.AntiCheats == 0 then report = report .. "  None found\n\n" end

    report = report .. "=== ADMIN SYSTEMS ===\n"
    for _, v in ipairs(Data.AdminSys) do
        report = report .. string.format("  %s (pattern: %s)\n", v.Path, v.Pattern)
        report = report .. string.format("  Source:\n%s\n\n", v.Source)
    end
    if #Data.AdminSys == 0 then report = report .. "  None found\n\n" end

    report = report .. "=== CURRENCY SYSTEMS ===\n"
    for _, v in ipairs(Data.CurrencySys) do
        report = report .. string.format("  %s (pattern: %s)\n", v.Path, v.Pattern)
        report = report .. string.format("  Source:\n%s\n\n", v.Source)
    end
    if #Data.CurrencySys == 0 then report = report .. "  None found\n\n" end

    report = report .. "=== BACKDOOR / SUSPICIOUS ===\n"
    for _, v in ipairs(Data.Backdoors) do
        report = report .. string.format("  %s (pattern: %s)\n", v.Path, v.Pattern)
        report = report .. string.format("  Source:\n%s\n\n", v.Source)
    end
    if #Data.Backdoors == 0 then report = report .. "  None found\n\n" end

    report = report .. "=== VULNERABILITIES ===\n"
    for _, v in ipairs(Data.Vulns) do
        for _, vv in ipairs(v.Vulns) do
            report = report .. string.format("  [%s] %s - %s\n", vv.Sev, v.Script, vv.Type)
        end
    end
    if #Data.Vulns == 0 then report = report .. "  None found\n\n" end

    report = report .. "=== EXPLOIT VECTORS (HIGH VALUE REMOTES) ===\n"
    for _, v in ipairs(Data.Exploits) do
        report = report .. string.format("  [%s] %s (%s)\n", v.Risk, v.Name, v.Type)
        report = report .. string.format("    Path: %s\n", v.Path)
        report = report .. string.format("    Reason: %s\n", v.Reason)
        report = report .. string.format("    Payload: %s\n\n", v.Payload)
    end
    if #Data.Exploits == 0 then report = report .. "  None found\n\n" end

    report = report .. "=== ALL REMOTE EVENTS ===\n"
    for _, v in ipairs(Data.Remotes) do
        report = report .. string.format("  %s (Parent: %s)\n", v.Path, v.Parent)
    end

    report = report .. "\n=== ALL REMOTE FUNCTIONS ===\n"
    for _, v in ipairs(Data.RemoteFuncs) do
        report = report .. string.format("  %s (Parent: %s)\n", v.Path, v.Parent)
    end

    report = report .. "\n=== ALL SCRIPT SOURCES ===\n\n"
    for _, v in ipairs(Data.AllSources) do
        report = report .. string.format("--[[ %s (%s) ]]\n%s\n\n---\n\n", v.Path, v.Class, v.Source)
    end

    -- Copy to clipboard
    local ok = pcall(function()
        SetClip(report)
        Log("[✓] Full report copied to clipboard!", Color3.fromRGB(0,255,100))
        Log(string.format("[✓] Report size: %d characters", #report), Color3.fromRGB(0,255,100))
        SetStatus("Report copied to clipboard!")
    end)

    if not ok then
        Log("[✗] Clipboard failed - report too large?", Color3.fromRGB(255,100,0))
        -- Try saving smaller portions
        pcall(function()
            SetClip(string.format(
                "Audit: %d scripts, %d locals, %d remotes, %d AC, %d admin, %d currency, %d backdoors, %d vulns, %d exploits",
                #Data.Scripts, #Data.Locals, #Data.Remotes+#Data.RemoteFuncs,
                #Data.AntiCheats, #Data.AdminSys, #Data.CurrencySys,
                #Data.Backdoors, #Data.Vulns, #Data.Exploits
            ))
            Log("[!] Summary copied instead (full report too large)", Color3.fromRGB(255,200,0))
        end)
    end

    -- Also try file save
    pcall(function()
        local fname = string.format("Audit_%s_%s.txt", tostring(game.GameId), os.date("%Y%m%d_%H%M%S"))
        writefile(fname, report)
        Log(string.format("[✓] Also saved to file: %s", fname), Color3.fromRGB(0,200,150))
    end)
end

-- ===== LAUNCH =====
UI = BuildUI()

UI.ScanBtn.MouseButton1Click:Connect(StartScan)
UI.ExportBtn.MouseButton1Click:Connect(ExportResults)
UI.ClearBtn.MouseButton1Click:Connect(function()
    if UI.LogText then
        UI.LogText.Text = ""
        Log("Log cleared.", Color3.fromRGB(180,180,180))
    end
end)

Log("Security Auditor v4.0 loaded!", Color3.fromRGB(0,255,100))
Log("Authorized pentest tool for Roblox games", Color3.fromRGB(100,255,100))
Log("", Color3.fromRGB(180,180,180))
Log("Commands: START SCAN = begin audit", Color3.fromRGB(180,180,180))
Log("          COPY = copy full report to clipboard", Color3.fromRGB(180,180,180))
Log("          CLEAR = clear log", Color3.fromRGB(180,180,180))
Log("", Color3.fromRGB(180,180,180))
Log("After scan, exploit commands auto-copy", Color3.fromRGB(0,255,200))
Log("to clipboard for instant use!", Color3.fromRGB(0,255,200))

SetStatus("Ready. Click START SCAN.")
