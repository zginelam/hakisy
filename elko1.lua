--[[
  Roblox Security Auditor v5.0 - Source Viewer Edition
  Full script source inspection in GUI
  Authorized pentest tool ONLY
]]

-- ===== INIT =====
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    LocalPlayer = Players:WaitForChild("LocalPlayer", 10)
end

local SetClip = setclipboard or toclipboard or set_clipboard or function(txt)
    local f = writefile and writefile("clipboard_temp.txt", tostring(txt))
    return f
end

-- ===== DATA =====
local Data = {
    Scripts = {}, Locals = {}, Modules = {},
    Remotes = {}, RemoteFuncs = {},
    AntiCheats = {}, AdminSys = {}, CurrencySys = {},
    Backdoors = {}, Vulns = {}, Exploits = {},
    AllSources = {},
    ScanCount = 0,
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

-- ===== UI =====
local UI = {}
local function BuildUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "HackerAudit"
    sg.ResetOnSpawn = false
    sg.Parent = CoreGui

    -- MAIN FRAME
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Parent = sg
    main.BackgroundColor3 = Color3.fromRGB(12,12,22)
    main.BorderSizePixel = 0
    main.Position = UDim2.new(0.05,0,0.03,0)
    main.Size = UDim2.new(0.9,0,0.94,0)
    main.Draggable = true
    main.Active = true
    main.ClipsDescendants = true

    -- Title bar
    local title = Instance.new("TextLabel")
    title.Parent = main
    title.BackgroundColor3 = Color3.fromRGB(20,20,35)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1,0,0,32)
    title.Font = Enum.Font.Code
    title.Text = "  Auditor v5.0 | Source Viewer"
    title.TextColor3 = Color3.fromRGB(0,255,120)
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left

    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = title
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,20,20)
    closeBtn.BorderSizePixel = 0
    closeBtn.Size = UDim2.new(0,28,0,28)
    closeBtn.Position = UDim2.new(1,-32,0,2)
    closeBtn.Font = Enum.Font.Code
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.TextSize = 13
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    -- Button row
    local btnRow = Instance.new("Frame")
    btnRow.Parent = main
    btnRow.BackgroundColor3 = Color3.fromRGB(16,16,28)
    btnRow.BorderSizePixel = 0
    btnRow.Position = UDim2.new(0,0,0,32)
    btnRow.Size = UDim2.new(1,0,0,38)

    local scanBtn = Instance.new("TextButton")
    scanBtn.Parent = btnRow
    scanBtn.BackgroundColor3 = Color3.fromRGB(0,140,50)
    scanBtn.BorderSizePixel = 0
    scanBtn.Position = UDim2.new(0,8,0,5)
    scanBtn.Size = UDim2.new(0,120,0,28)
    scanBtn.Font = Enum.Font.Code
    scanBtn.Text = "▶ SCAN"
    scanBtn.TextColor3 = Color3.fromRGB(255,255,255)
    scanBtn.TextSize = 13

    local exportBtn = Instance.new("TextButton")
    exportBtn.Parent = btnRow
    exportBtn.BackgroundColor3 = Color3.fromRGB(0,70,170)
    exportBtn.BorderSizePixel = 0
    exportBtn.Position = UDim2.new(0,136,0,5)
    exportBtn.Size = UDim2.new(0,90,0,28)
    exportBtn.Font = Enum.Font.Code
    exportBtn.Text = "📋 COPY"
    exportBtn.TextColor3 = Color3.fromRGB(255,255,255)
    exportBtn.TextSize = 13

    local clearBtn = Instance.new("TextButton")
    clearBtn.Parent = btnRow
    clearBtn.BackgroundColor3 = Color3.fromRGB(100,25,25)
    clearBtn.BorderSizePixel = 0
    clearBtn.Position = UDim2.new(0,234,0,5)
    clearBtn.Size = UDim2.new(0,70,0,28)
    clearBtn.Font = Enum.Font.Code
    clearBtn.Text = "CLEAR"
    clearBtn.TextColor3 = Color3.fromRGB(255,255,255)
    clearBtn.TextSize = 13

    -- Category filter buttons
    local filterRow = Instance.new("Frame")
    filterRow.Parent = main
    filterRow.BackgroundColor3 = Color3.fromRGB(16,16,28)
    filterRow.BorderSizePixel = 0
    filterRow.Position = UDim2.new(0,0,0,70)
    filterRow.Size = UDim2.new(1,0,0,24)

    local filterNames = {"ALL","SCRIPTS","LOCALS","MODULES","REMOTES","AC","ADMIN","CURRENCY","BACKDOOR"}
    local filterBtns = {}
    local curFilter = "ALL"

    for i, fn in ipairs(filterNames) do
        local fb = Instance.new("TextButton")
        fb.Parent = filterRow
        fb.BackgroundColor3 = Color3.fromRGB(30,30,45)
        fb.BorderSizePixel = 0
        fb.Position = UDim2.new(0, (i-1)*75 + 4, 0, 2)
        fb.Size = UDim2.new(0, 70, 0, 20)
        fb.Font = Enum.Font.Code
        fb.Text = fn
        fb.TextColor3 = Color3.fromRGB(180,180,200)
        fb.TextSize = 10
        fb.Name = fn
        filterBtns[fn] = fb
    end

    -- SPLIT PANEL: Left = list, Right = source viewer
    -- Left panel
    local leftPanel = Instance.new("Frame")
    leftPanel.Parent = main
    leftPanel.BackgroundColor3 = Color3.fromRGB(15,15,25)
    leftPanel.BorderSizePixel = 0
    leftPanel.Position = UDim2.new(0,0,0,94)
    leftPanel.Size = UDim2.new(0.35,0,1,-94)

    local leftLabel = Instance.new("TextLabel")
    leftLabel.Parent = leftPanel
    leftLabel.BackgroundColor3 = Color3.fromRGB(20,20,33)
    leftLabel.BorderSizePixel = 0
    leftLabel.Size = UDim2.new(1,0,0,20)
    leftLabel.Font = Enum.Font.Code
    leftLabel.Text = "  Scripts (" .. Data.ScanCount .. ")"
    leftLabel.TextColor3 = Color3.fromRGB(150,200,255)
    leftLabel.TextSize = 10
    leftLabel.TextXAlignment = Enum.TextXAlignment.Left

    local scriptList = Instance.new("ScrollingFrame")
    scriptList.Parent = leftPanel
    scriptList.BackgroundColor3 = Color3.fromRGB(10,10,18)
    scriptList.BorderSizePixel = 0
    scriptList.Position = UDim2.new(0,0,0,20)
    scriptList.Size = UDim2.new(1,0,1,-20)
    scriptList.CanvasSize = UDim2.new(0,0,0,0)
    scriptList.ScrollBarThickness = 5
    scriptList.ScrollBarImageColor3 = Color3.fromRGB(50,50,70)

    -- Right panel - source viewer
    local rightPanel = Instance.new("Frame")
    rightPanel.Parent = main
    rightPanel.BackgroundColor3 = Color3.fromRGB(8,8,16)
    rightPanel.BorderSizePixel = 0
    rightPanel.Position = UDim2.new(0.35, 2, 0, 94)
    rightPanel.Size = UDim2.new(0.65, -2, 1, -94)

    local rightLabel = Instance.new("TextLabel")
    rightLabel.Parent = rightPanel
    rightLabel.BackgroundColor3 = Color3.fromRGB(20,20,33)
    rightLabel.BorderSizePixel = 0
    rightLabel.Size = UDim2.new(1,0,0,20)
    rightLabel.Font = Enum.Font.Code
    rightLabel.Text = "  Source Viewer (click a script to view)"
    rightLabel.TextColor3 = Color3.fromRGB(150,200,255)
    rightLabel.TextSize = 10
    rightLabel.TextXAlignment = Enum.TextXAlignment.Left

    local sourceView = Instance.new("ScrollingFrame")
    sourceView.Parent = rightPanel
    sourceView.BackgroundColor3 = Color3.fromRGB(5,5,12)
    sourceView.BorderSizePixel = 0
    sourceView.Position = UDim2.new(0,0,0,20)
    sourceView.Size = UDim2.new(1,0,1,-20)
    sourceView.CanvasSize = UDim2.new(0,0,0,0)
    sourceView.ScrollBarThickness = 6
    sourceView.ScrollBarImageColor3 = Color3.fromRGB(50,50,70)

    local sourceText = Instance.new("TextLabel")
    sourceText.Parent = sourceView
    sourceText.BackgroundTransparency = 1
    sourceText.Size = UDim2.new(1,-10,0,0)
    sourceText.Position = UDim2.new(0,5,0,5)
    sourceText.Font = Enum.Font.Code
    sourceText.Text = "Select a script from the list to view its source code."
    sourceText.TextColor3 = Color3.fromRGB(150,150,180)
    sourceText.TextSize = 12
    sourceText.TextXAlignment = Enum.TextXAlignment.Left
    sourceText.TextYAlignment = Enum.TextYAlignment.Top
    sourceText.RichText = true

    -- Status
    local status = Instance.new("TextLabel")
    status.Parent = main
    status.BackgroundColor3 = Color3.fromRGB(16,16,28)
    status.BorderSizePixel = 0
    status.Position = UDim2.new(0,0,1,-22)
    status.Size = UDim2.new(1,0,0,22)
    status.Font = Enum.Font.Code
    status.Text = "Ready."
    status.TextColor3 = Color3.fromRGB(130,180,220)
    status.TextSize = 10
    status.TextXAlignment = Enum.TextXAlignment.Left

    UI.ScreenGui = sg
    UI.Main = main
    UI.ScanBtn = scanBtn
    UI.ExportBtn = exportBtn
    UI.ClearBtn = clearBtn
    UI.FilterRow = filterRow
    UI.FilterBtns = filterBtns
    UI.ScriptList = scriptList
    UI.SourceView = sourceView
    UI.SourceText = sourceText
    UI.Status = status
    UI.LeftLabel = leftLabel
    UI.CurrentFilter = "ALL"
    UI.AllEntries = {}
end

-- ===== LOG =====
local function Log(msg, color)
    color = color or Color3.fromRGB(180,180,180)
    if UI.Status then
        UI.Status.Text = tostring(msg)
    end
end

local function SetStatus(s)
    if UI.Status then
        UI.Status.Text = s
    end
end

-- ===== POPULATE SCRIPT LIST =====
local function PopulateScriptList(filter)
    filter = filter or "ALL"
    UI.CurrentFilter = filter

    -- Clear list
    for _, v in pairs(UI.ScriptList:GetChildren()) do
        if v:IsA("TextButton") or v:IsA("TextLabel") or v:IsA("UIListLayout") then
            v:Destroy()
        end
    end

    local layout = Instance.new("UIListLayout")
    layout.Parent = UI.ScriptList
    layout.Padding = UDim.new(0,1)

    local entries = {}

    if filter == "ALL" or filter == "SCRIPTS" then
        for _, v in ipairs(Data.Scripts) do
            table.insert(entries, {Name=v.Name, Path=v.Path, Source=v.Source, Class="Script", Color=Color3.fromRGB(0,200,255)})
        end
    end
    if filter == "ALL" or filter == "LOCALS" then
        for _, v in ipairs(Data.Locals) do
            table.insert(entries, {Name=v.Name, Path=v.Path, Source=v.Source, Class="LocalScript", Color=Color3.fromRGB(100,255,255)})
        end
    end
    if filter == "ALL" or filter == "MODULES" then
        for _, v in ipairs(Data.Modules) do
            table.insert(entries, {Name=v.Name, Path=v.Path, Source=v.Source, Class="ModuleScript", Color=Color3.fromRGB(180,180,180)})
        end
    end
    if filter == "ALL" or filter == "REMOTES" then
        for _, v in ipairs(Data.Remotes) do
            table.insert(entries, {Name=v.Name, Path=v.Path, Source=nil, Class="RemoteEvent", Color=Color3.fromRGB(200,100,255)})
        end
        for _, v in ipairs(Data.RemoteFuncs) do
            table.insert(entries, {Name=v.Name, Path=v.Path, Source=nil, Class="RemoteFunction", Color=Color3.fromRGB(200,50,255)})
        end
    end
    if filter == "AC" then
        for _, v in ipairs(Data.AntiCheats) do
            table.insert(entries, {Name=v.Name, Path=v.Path, Source=v.Source, Class="AC", Color=Color3.fromRGB(255,150,0)})
        end
    end
    if filter == "ADMIN" then
        for _, v in ipairs(Data.AdminSys) do
            table.insert(entries, {Name=v.Name, Path=v.Path, Source=v.Source, Class="ADMIN", Color=Color3.fromRGB(255,200,0)})
        end
    end
    if filter == "CURRENCY" then
        for _, v in ipairs(Data.CurrencySys) do
            table.insert(entries, {Name=v.Name, Path=v.Path, Source=v.Source, Class="CURRENCY", Color=Color3.fromRGB(0,255,100)})
        end
    end
    if filter == "BACKDOOR" then
        for _, v in ipairs(Data.Backdoors) do
            table.insert(entries, {Name=v.Name, Path=v.Path, Source=v.Source, Class="BACKDOOR", Color=Color3.fromRGB(255,50,50)})
        end
    end

    -- Add entries to list
    for _, entry in ipairs(entries) do
        local btn = Instance.new("TextButton")
        btn.Parent = UI.ScriptList
        btn.BackgroundColor3 = Color3.fromRGB(18,18,30)
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(1,0,0,22)
        btn.Font = Enum.Font.Code
        btn.Text = ""
        btn.TextColor3 = Color3.fromRGB(200,200,200)
        btn.TextSize = 10
        btn.TextXAlignment = Enum.TextXAlignment.Left

        local iconColors = {
            Script = Color3.fromRGB(0,200,255),
            LocalScript = Color3.fromRGB(100,255,255),
            ModuleScript = Color3.fromRGB(180,180,180),
            RemoteEvent = Color3.fromRGB(200,100,255),
            RemoteFunction = Color3.fromRGB(200,50,255),
            AC = Color3.fromRGB(255,150,0),
            ADMIN = Color3.fromRGB(255,200,0),
            CURRENCY = Color3.fromRGB(0,255,100),
            BACKDOOR = Color3.fromRGB(255,50,50),
        }
        local iconColor = iconColors[entry.Class] or Color3.fromRGB(180,180,180)

        -- Color dot + name
        local dot = Instance.new("Frame")
        dot.Parent = btn
        dot.BackgroundColor3 = iconColor
        dot.BorderSizePixel = 0
        dot.Position = UDim2.new(0,3,0,7)
        dot.Size = UDim2.new(0,6,0,6)

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = btn
        nameLabel.BackgroundTransparency = 1
        nameLabel.Position = UDim2.new(0,12,0,0)
        nameLabel.Size = UDim2.new(1,-15,0,22)
        nameLabel.Font = Enum.Font.Code
        nameLabel.Text = entry.Name .. "  (" .. entry.Class .. ")"
        nameLabel.TextColor3 = Color3.fromRGB(200,200,200)
        nameLabel.TextSize = 9
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left

        local pathLabel = Instance.new("TextLabel")
        pathLabel.Parent = btn
        pathLabel.BackgroundTransparency = 1
        pathLabel.Position = UDim2.new(0,12,0,12)
        pathLabel.Size = UDim2.new(1,-15,0,10)
        pathLabel.Font = Enum.Font.Code
        pathLabel.Text = entry.Path
        pathLabel.TextColor3 = Color3.fromRGB(100,100,120)
        pathLabel.TextSize = 8
        pathLabel.TextXAlignment = Enum.TextXAlignment.Left

        -- Click handler - show source
        btn.MouseButton1Click:Connect(function()
            local src = entry.Source
            if src and #src > 0 then
                -- Highlighted display
                local escaped = src:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
                local header = string.format('<font color="rgb(0,255,120)">--[[ %s | %s ]]</font>\n\n', entry.Path, entry.Class)
                UI.SourceText.Text = header .. escaped
                local sz = UI.SourceText.TextBounds
                UI.SourceView.CanvasSize = UDim2.new(0,0,0,sz.Y+20)
                UI.SourceView.CanvasPosition = Vector2.new(0,0)
                SetStatus("Viewing: " .. entry.Path)
            else
                UI.SourceText.Text = string.format('<font color="rgb(255,200,0)">[%s] %s</font>\n\n<font color="rgb(150,150,180)">Path: %s</font>\n\n<font color="rgb(100,100,130)">No source code available (RemoteEvent/RemoteFunction)</font>',
                    entry.Class, entry.Name, entry.Path)
                local sz = UI.SourceText.TextBounds
                UI.SourceView.CanvasSize = UDim2.new(0,0,0,sz.Y+20)
                SetStatus("Viewing: " .. entry.Path)
            end
        end)

        -- Hover effect
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(25,25,40)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(18,18,30)
        end)
    end

    -- Update canvas size
    local count = #entries
    UI.ScriptList.CanvasSize = UDim2.new(0,0,0, count * 24 + 10)

    -- Update label
    local labelMap = {
        ALL = "All Scripts",
        SCRIPTS = "Server Scripts",
        LOCALS = "Local Scripts",
        MODULES = "Module Scripts",
        REMOTES = "Remote Events/Functions",
        AC = "Anti-Cheat Systems",
        ADMIN = "Admin Systems",
        CURRENCY = "Currency Systems",
        BACKDOOR = "Backdoors",
    }
    if UI.LeftLabel then
        UI.LeftLabel.Text = "  " .. (labelMap[filter] or filter) .. " (" .. count .. ")"
    end
end

-- ===== FILTER SETUP =====
local function SetupFilters()
    for name, btn in pairs(UI.FilterBtns) do
        btn.MouseButton1Click:Connect(function()
            -- Reset all colors
            for _, b in pairs(UI.FilterBtns) do
                b.BackgroundColor3 = Color3.fromRGB(30,30,45)
                b.TextColor3 = Color3.fromRGB(180,180,200)
            end
            -- Highlight selected
            btn.BackgroundColor3 = Color3.fromRGB(0,100,60)
            btn.TextColor3 = Color3.fromRGB(0,255,120)
            -- Populate
            PopulateScriptList(name)
        end)
    end
end

-- ===== SCANNER =====
local function AnalyzeScript(name, path, src, class)
    local sl = src:lower()

    for _, p in ipairs(Pats.AC) do
        if sl:find(p,1,true) then
            table.insert(Data.AntiCheats, {Name=name, Path=path, Pattern=p, Source=src})
            break
        end
    end

    for _, p in ipairs(Pats.AD) do
        if sl:find(p,1,true) then
            table.insert(Data.AdminSys, {Name=name, Path=path, Pattern=p, Source=src})
            break
        end
    end

    for _, p in ipairs(Pats.CU) do
        if sl:find(p,1,true) then
            table.insert(Data.CurrencySys, {Name=name, Path=path, Pattern=p, Source=src})
            break
        end
    end

    for _, p in ipairs(Pats.BD) do
        if sl:find(p,1,true) then
            table.insert(Data.Backdoors, {Name=name, Path=path, Pattern=p, Source=src})
            break
        end
    end

    local vulns = {}
    if sl:find("fireserver",1,true) and not sl:find("validat",1,true) and not sl:find("check",1,true) then
        table.insert(vulns, {Type="Unvalidated FireServer", Sev="HIGH"})
    end
    if sl:find("loadstring",1,true) then
        table.insert(vulns, {Type="loadstring() code execution", Sev="CRITICAL"})
    end
    if sl:find("httpget",1,true) or sl:find("httppost",1,true) then
        table.insert(vulns, {Type="External HTTP requests", Sev="HIGH"})
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

    if #vulns > 0 then
        table.insert(Data.Vulns, {Script=name, Path=path, Vulns=vulns})
    end
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
            table.insert(Data.Scripts, {Name=inst.Name, Path=path, Source=src, Len=#src, Enabled=inst.Enabled})
            table.insert(Data.AllSources, {Name=inst.Name, Path=path, Source=src, Class="Script"})
            AnalyzeScript(inst.Name, path, src, "Script")

        elseif cls == "LocalScript" then
            local src = inst.Source or ""
            table.insert(Data.Locals, {Name=inst.Name, Path=path, Source=src, Len=#src, Enabled=inst.Enabled})
            table.insert(Data.AllSources, {Name=inst.Name, Path=path, Source=src, Class="LocalScript"})
            AnalyzeScript(inst.Name, path, src, "LocalScript")

        elseif cls == "ModuleScript" then
            local src = inst.Source or ""
            table.insert(Data.Modules, {Name=inst.Name, Path=path, Source=src, Len=#src})
            table.insert(Data.AllSources, {Name=inst.Name, Path=path, Source=src, Class="ModuleScript"})

        elseif cls == "RemoteEvent" then
            table.insert(Data.Remotes, {Name=inst.Name, Path=path, Parent=tostring(inst.Parent)})
            local nl = inst.Name:lower()
            if nl:find("currency",1,true) or nl:find("money",1,true) or nl:find("coin",1,true)
               or nl:find("give",1,true) or nl:find("add",1,true) or nl:find("set",1,true)
               or nl:find("admin",1,true) or nl:find("cmd",1,true) or nl:find("buy",1,true)
               or nl:find("grant",1,true) or nl:find("reward",1,true) or nl:find("unlock",1,true)
               or nl:find("kick",1,true) or nl:find("ban",1,true) or nl:find("teleport",1,true)
               or nl:find("spawn",1,true) or nl:find("give",1,true) then
                table.insert(Data.Exploits, {Name=inst.Name, Path=path, Type="RemoteEvent", Risk="HIGH",
                    Reason="Name suggests privileged operation", Payload="FireServer(craftedArgs)"})
            end

        elseif cls == "RemoteFunction" then
            table.insert(Data.RemoteFuncs, {Name=inst.Name, Path=path, Parent=tostring(inst.Parent)})
            local nl = inst.Name:lower()
            if nl:find("currency",1,true) or nl:find("money",1,true) or nl:find("coin",1,true)
               or nl:find("give",1,true) or nl:find("add",1,true) or nl:find("set",1,true)
               or nl:find("admin",1,true) or nl:find("cmd",1,true) or nl:find("kick",1,true)
               or nl:find("ban",1,true) then
                table.insert(Data.Exploits, {Name=inst.Name, Path=path, Type="RemoteFunction", Risk="HIGH",
                    Reason="Name suggests privileged operation", Payload="InvokeServer(craftedArgs)"})
            end
        end

        for _, ch in ipairs(inst:GetChildren()) do
            task.wait()
            ScanRecursive(ch, depth+1)
        end
    end)

    if not ok then
        local nm = "unknown"
        pcall(function() nm = inst.Name end)
    end
end

local function ScanService(svcName)
    local ok, svc = pcall(function() return game:GetService(svcName) end)
    if ok and svc then
        pcall(function() ScanRecursive(svc) end)
        task.wait(0.05)
    end
end

-- ===== MAIN SCAN =====
local function StartScan()
    Data = {Scripts={}, Locals={}, Modules={}, Remotes={}, RemoteFuncs={},
            AntiCheats={}, AdminSys={}, CurrencySys={}, Backdoors={},
            Vulns={}, Exploits={}, AllSources={}, ScanCount=0}

    -- Reset source viewer
    UI.SourceText.Text = "Scanning... please wait."
    UI.SourceView.CanvasSize = UDim2.new(0,0,0,50)

    SetStatus("Starting full scan...")

    local svcs = {"Workspace","ReplicatedStorage","ReplicatedFirst","ServerScriptService",
                  "ServerStorage","StarterGui","StarterPack","Lighting"}
    for _, s in ipairs(svcs) do
        SetStatus("Scanning " .. s .. "...")
        ScanService(s)
    end

    SetStatus("Scanning Players...")
    pcall(function()
        for _, plr in pairs(Players:GetPlayers()) do
            pcall(function() ScanRecursive(plr) end)
            task.wait()
        end
    end)

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

    Data.ScanCount = #Data.Scripts + #Data.Locals + #Data.Modules + #Data.Remotes + #Data.RemoteFuncs

    -- Populate list
    PopulateScriptList("ALL")

    -- Summary in source viewer
    local summary = string.format([[
<font color="rgb(0,255,120)">╔══════════════════════════════════════╗
║        SCAN COMPLETE                 ║
╚══════════════════════════════════════╝</font>

<font color="rgb(0,200,255)">  Scripts (server):   %d</font>
<font color="rgb(100,255,255)">  LocalScripts:       %d</font>
<font color="rgb(180,180,180)">  ModuleScripts:      %d</font>
<font color="rgb(200,100,255)">  RemoteEvents:       %d</font>
<font color="rgb(200,50,255)">  RemoteFunctions:    %d</font>
<font color="rgb(255,150,0)">  AntiCheat systems:  %d</font>
<font color="rgb(255,200,0)">  Admin systems:      %d</font>
<font color="rgb(0,255,100)">  Currency systems:   %d</font>
<font color="rgb(255,50,50)">  Backdoor patterns:  %d</font>
<font color="rgb(255,100,0)">  Vulnerabilities:    %d</font>
<font color="rgb(255,0,0)">  Exploit vectors:    %d</font>

<font color="rgb(150,200,255)">Use the filter buttons at the top to browse.
Click any script name to view its FULL source code.</font>
]],
        #Data.Scripts, #Data.Locals, #Data.Modules,
        #Data.Remotes, #Data.RemoteFuncs,
        #Data.AntiCheats, #Data.AdminSys, #Data.CurrencySys,
        #Data.Backdoors, #Data.Vulns, #Data.Exploits
    )

    UI.SourceText.Text = summary
    local sz = UI.SourceText.TextBounds
    UI.SourceView.CanvasSize = UDim2.new(0,0,0,sz.Y+20)

    -- Generate and copy exploit commands
    if #Data.Exploits > 0 then
        local cmdLine = "-- Fire all currency/admin remotes:\n"
        for _, e in ipairs(Data.Exploits) do
            if e.Type == "RemoteEvent" then
                cmdLine = cmdLine .. string.format("pcall(function() for _,v in pairs(game:GetDescendants()) do if v:IsA('RemoteEvent') and v.Name == '%s' then v:FireServer(999999) v:FireServer(game.Players.LocalPlayer, 999999) v:FireServer('add', 999999) end end end)\n", e.Name)
            end
        end
        pcall(function()
            SetClip(cmdLine)
        end)
    end

    SetStatus(string.format("Done! %d scripts found. Click filter buttons to browse, click script to view source.", Data.ScanCount))
end

-- ===== EXPORT =====
local function ExportResults()
    local report = ""

    report = report .. "============================================\n"
    report = report .. " ROBLOX SECURITY AUDIT REPORT\n"
    report = report .. string.format(" Game: %s (ID: %s)\n", tostring(game.Name), tostring(game.GameId))
    report = report .. string.format(" Date: %s\n", os.date("%Y-%m-%d %H:%M:%S"))
    report = report .. "============================================\n\n"

    report = report .. "=== SCRIPTS (" .. #Data.Scripts + #Data.Locals + #Data.Modules .. " total) ===\n\n"
    for _, v in ipairs(Data.AllSources) do
        report = report .. string.format("--[[ %s (%s) ]]\n%s\n\n---\n\n", v.Path, v.Class, v.Source)
    end

    report = report .. "=== ANTI-CHEAT SYSTEMS ===\n"
    for _, v in ipairs(Data.AntiCheats) do
        report = report .. string.format("  %s (pattern: %s)\n", v.Path, v.Pattern)
    end

    report = report .. "\n=== ADMIN SYSTEMS ===\n"
    for _, v in ipairs(Data.AdminSys) do
        report = report .. string.format("  %s (pattern: %s)\n", v.Path, v.Pattern)
    end

    report = report .. "\n=== CURRENCY SYSTEMS ===\n"
    for _, v in ipairs(Data.CurrencySys) do
        report = report .. string.format("  %s (pattern: %s)\n", v.Path, v.Pattern)
    end

    report = report .. "\n=== BACKDOORS ===\n"
    for _, v in ipairs(Data.Backdoors) do
        report = report .. string.format("  %s (pattern: %s)\n", v.Path, v.Pattern)
    end

    report = report .. "\n=== EXPLOIT VECTORS ===\n"
    for _, v in ipairs(Data.Exploits) do
        report = report .. string.format("  [%s] %s (%s) - %s\n", v.Risk, v.Name, v.Type, v.Payload)
    end

    local ok = pcall(function()
        SetClip(report)
        SetStatus("Full report copied to clipboard!")
    end)

    if not ok then
        -- Too big, just summary
        local summary = string.format(
            "Audit: %d scripts, %d locals, %d modules, %d remotes, %d AC, %d admin, %d currency, %d backdoors, %d vulns, %d exploits",
            #Data.Scripts, #Data.Locals, #Data.Modules,
            #Data.Remotes + #Data.RemoteFuncs,
            #Data.AntiCheats, #Data.AdminSys, #Data.CurrencySys,
            #Data.Backdoors, #Data.Vulns, #Data.Exploits
        )
        pcall(function() SetClip(summary) end)
        SetStatus("Summary copied (full report was too large for clipboard)")
    end

    -- File save if writefile available
    pcall(function()
        local fname = string.format("Audit_%s_%s.txt", tostring(game.GameId), os.date("%Y%m%d_%H%M%S"))
        writefile(fname, report)
    end)
end

-- ===== LAUNCH =====
BuildUI()
SetupFilters()

UI.ScanBtn.MouseButton1Click:Connect(StartScan)
UI.ExportBtn.MouseButton1Click:Connect(ExportResults)
UI.ClearBtn.MouseButton1Click:Connect(function()
    UI.SourceText.Text = "Select a script from the list to view its source code."
    UI.SourceView.CanvasSize = UDim2.new(0,0,0,50)
    SetStatus("Cleared.")
end)

SetStatus("Ready. Click SCAN to audit all scripts.")

-- Show initial instructions
UI.SourceText.Text = [[
<font color="rgb(0,255,120)">╔══════════════════════════════════════╗
║   Roblox Security Auditor v5.0       ║
║   Full Source Viewer Edition         ║
╚══════════════════════════════════════╝</font>

<font color="rgb(150,200,255)">How to use:</font>

<font color="rgb(0,200,255)">1.</font> Click <font color="rgb(0,255,100)">[▶ SCAN]</font> to scan the entire game
<font color="rgb(0,200,255)">2.</font> Use filter buttons to browse categories
<font color="rgb(0,200,255)">3.</font> <font color="rgb(255,255,0)">Click any script name</font> to view its FULL source
<font color="rgb(0,200,255)">4.</font> Click <font color="rgb(50,150,255)">[📋 COPY]</font> to export all to clipboard

<font color="rgb(100,100,130)">The script extracts ALL source code from every
script in the game and displays it here.</font>
]]
