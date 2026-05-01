--[[
  Roblox Security Auditor v5.1 - Remote Reference Finder
  Shows which scripts use each RemoteEvent/RemoteFunction
]]

-- ===== INIT =====
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

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
    RemoteRefs = {}, -- remote_name -> {scripts that reference it}
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

-- ===== BUILD UI =====
local UI = {}
local function BuildUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "HackerAudit"
    sg.ResetOnSpawn = false
    sg.Parent = CoreGui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Parent = sg
    main.BackgroundColor3 = Color3.fromRGB(12,12,22)
    main.BorderSizePixel = 0
    main.Position = UDim2.new(0.03,0,0.02,0)
    main.Size = UDim2.new(0.94,0,0.96,0)
    main.Draggable = true
    main.Active = true
    main.ClipsDescendants = true

    -- Title
    local title = Instance.new("TextLabel")
    title.Parent = main
    title.BackgroundColor3 = Color3.fromRGB(20,20,35)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1,0,0,30)
    title.Font = Enum.Font.Code
    title.Text = "  Auditor v5.1 | Source Viewer + Remote References"
    title.TextColor3 = Color3.fromRGB(0,255,120)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = title
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,20,20)
    closeBtn.BorderSizePixel = 0
    closeBtn.Size = UDim2.new(0,26,0,26)
    closeBtn.Position = UDim2.new(1,-30,0,2)
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
    btnRow.Position = UDim2.new(0,0,0,30)
    btnRow.Size = UDim2.new(1,0,0,36)

    local scanBtn = Instance.new("TextButton")
    scanBtn.Parent = btnRow
    scanBtn.BackgroundColor3 = Color3.fromRGB(0,140,50)
    scanBtn.BorderSizePixel = 0
    scanBtn.Position = UDim2.new(0,8,0,4)
    scanBtn.Size = UDim2.new(0,115,0,28)
    scanBtn.Font = Enum.Font.Code
    scanBtn.Text = "▶ START SCAN"
    scanBtn.TextColor3 = Color3.fromRGB(255,255,255)
    scanBtn.TextSize = 12

    local exportBtn = Instance.new("TextButton")
    exportBtn.Parent = btnRow
    exportBtn.BackgroundColor3 = Color3.fromRGB(0,70,170)
    exportBtn.BorderSizePixel = 0
    exportBtn.Position = UDim2.new(0,130,0,4)
    exportBtn.Size = UDim2.new(0,85,0,28)
    exportBtn.Font = Enum.Font.Code
    exportBtn.Text = "📋 COPY"
    exportBtn.TextColor3 = Color3.fromRGB(255,255,255)
    exportBtn.TextSize = 12

    local clearBtn = Instance.new("TextButton")
    clearBtn.Parent = btnRow
    clearBtn.BackgroundColor3 = Color3.fromRGB(100,25,25)
    clearBtn.BorderSizePixel = 0
    clearBtn.Position = UDim2.new(0,222,0,4)
    clearBtn.Size = UDim2.new(0,65,0,28)
    clearBtn.Font = Enum.Font.Code
    clearBtn.Text = "CLEAR"
    clearBtn.TextColor3 = Color3.fromRGB(255,255,255)
    clearBtn.TextSize = 12

    -- Filter buttons
    local filterRow = Instance.new("Frame")
    filterRow.Parent = main
    filterRow.BackgroundColor3 = Color3.fromRGB(16,16,28)
    filterRow.BorderSizePixel = 0
    filterRow.Position = UDim2.new(0,0,0,66)
    filterRow.Size = UDim2.new(1,0,0,22)

    local filterNames = {"ALL","SCRIPTS","LOCALS","MODULES","REMOTES","AC","ADMIN","CURRENCY","BACKDOOR"}
    local filterBtns = {}

    for i, fn in ipairs(filterNames) do
        local fb = Instance.new("TextButton")
        fb.Parent = filterRow
        fb.BackgroundColor3 = Color3.fromRGB(30,30,45)
        fb.BorderSizePixel = 0
        fb.Position = UDim2.new(0, (i-1)*73 + 3, 0, 1)
        fb.Size = UDim2.new(0, 68, 0, 20)
        fb.Font = Enum.Font.Code
        fb.Text = fn
        fb.TextColor3 = Color3.fromRGB(180,180,200)
        fb.TextSize = 9
        fb.Name = fn
        filterBtns[fn] = fb
    end

    -- LEFT: Script list
    local leftPanel = Instance.new("Frame")
    leftPanel.Parent = main
    leftPanel.BackgroundColor3 = Color3.fromRGB(15,15,25)
    leftPanel.BorderSizePixel = 0
    leftPanel.Position = UDim2.new(0,0,0,88)
    leftPanel.Size = UDim2.new(0.32,0,1,-88)

    local leftLabel = Instance.new("TextLabel")
    leftLabel.Parent = leftPanel
    leftLabel.BackgroundColor3 = Color3.fromRGB(20,20,33)
    leftLabel.BorderSizePixel = 0
    leftLabel.Size = UDim2.new(1,0,0,18)
    leftLabel.Font = Enum.Font.Code
    leftLabel.Text = "  Items"
    leftLabel.TextColor3 = Color3.fromRGB(150,200,255)
    leftLabel.TextSize = 9
    leftLabel.TextXAlignment = Enum.TextXAlignment.Left

    local scriptList = Instance.new("ScrollingFrame")
    scriptList.Parent = leftPanel
    scriptList.BackgroundColor3 = Color3.fromRGB(10,10,18)
    scriptList.BorderSizePixel = 0
    scriptList.Position = UDim2.new(0,0,0,18)
    scriptList.Size = UDim2.new(1,0,1,-18)
    scriptList.CanvasSize = UDim2.new(0,0,0,0)
    scriptList.ScrollBarThickness = 5
    scriptList.ScrollBarImageColor3 = Color3.fromRGB(50,50,70)

    -- RIGHT: Source viewer
    local rightPanel = Instance.new("Frame")
    rightPanel.Parent = main
    rightPanel.BackgroundColor3 = Color3.fromRGB(8,8,16)
    rightPanel.BorderSizePixel = 0
    rightPanel.Position = UDim2.new(0.32, 2, 0, 88)
    rightPanel.Size = UDim2.new(0.68, -2, 1, -88)

    local rightLabel = Instance.new("TextLabel")
    rightLabel.Parent = rightPanel
    rightLabel.BackgroundColor3 = Color3.fromRGB(20,20,33)
    rightLabel.BorderSizePixel = 0
    rightLabel.Size = UDim2.new(1,0,0,18)
    rightLabel.Font = Enum.Font.Code
    rightLabel.Text = "  Source Viewer"
    rightLabel.TextColor3 = Color3.fromRGB(150,200,255)
    rightLabel.TextSize = 9
    rightLabel.TextXAlignment = Enum.TextXAlignment.Left

    local sourceView = Instance.new("ScrollingFrame")
    sourceView.Parent = rightPanel
    sourceView.BackgroundColor3 = Color3.fromRGB(5,5,12)
    sourceView.BorderSizePixel = 0
    sourceView.Position = UDim2.new(0,0,0,18)
    sourceView.Size = UDim2.new(1,0,1,-18)
    sourceView.CanvasSize = UDim2.new(0,0,0,0)
    sourceView.ScrollBarThickness = 6
    sourceView.ScrollBarImageColor3 = Color3.fromRGB(50,50,70)

    local sourceText = Instance.new("TextLabel")
    sourceText.Parent = sourceView
    sourceText.BackgroundTransparency = 1
    sourceText.Size = UDim2.new(1,-10,0,0)
    sourceText.Position = UDim2.new(0,5,0,5)
    sourceText.Font = Enum.Font.Code
    sourceText.Text = "Ready. Click START SCAN to begin."
    sourceText.TextColor3 = Color3.fromRGB(150,150,180)
    sourceText.TextSize = 11
    sourceText.TextXAlignment = Enum.TextXAlignment.Left
    sourceText.TextYAlignment = Enum.TextYAlignment.Top
    sourceText.RichText = true

    -- Status bar
    local status = Instance.new("TextLabel")
    status.Parent = main
    status.BackgroundColor3 = Color3.fromRGB(16,16,28)
    status.BorderSizePixel = 0
    status.Position = UDim2.new(0,0,1,-20)
    status.Size = UDim2.new(1,0,0,20)
    status.Font = Enum.Font.Code
    status.Text = "Ready."
    status.TextColor3 = Color3.fromRGB(130,180,220)
    status.TextSize = 9
    status.TextXAlignment = Enum.TextXAlignment.Left

    UI.ScreenGui = sg
    UI.ScanBtn = scanBtn
    UI.ExportBtn = exportBtn
    UI.ClearBtn = clearBtn
    UI.FilterBtns = filterBtns
    UI.ScriptList = scriptList
    UI.SourceView = sourceView
    UI.SourceText = sourceText
    UI.Status = status
    UI.LeftLabel = leftLabel
    UI.CurrentFilter = "ALL"
end

-- ===== LOG =====
local function SetStatus(s)
    if UI.Status then
        UI.Status.Text = tostring(s)
    end
end

-- ===== POPULATE LIST =====
local function PopulateScriptList(filter)
    filter = filter or "ALL"
    UI.CurrentFilter = filter

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
            table.insert(entries, {Name=v.Name, Path=v.Path, Source=nil, Class="RemoteEvent", Color=Color3.fromRGB(200,100,255), IsRemote=true})
        end
        for _, v in ipairs(Data.RemoteFuncs) do
            table.insert(entries, {Name=v.Name, Path=v.Path, Source=nil, Class="RemoteFunction", Color=Color3.fromRGB(200,50,255), IsRemote=true})
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

    for _, entry in ipairs(entries) do
        local btn = Instance.new("TextButton")
        btn.Parent = UI.ScriptList
        btn.BackgroundColor3 = Color3.fromRGB(18,18,30)
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(1,0,0,20)
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

        local dot = Instance.new("Frame")
        dot.Parent = btn
        dot.BackgroundColor3 = iconColor
        dot.BorderSizePixel = 0
        dot.Position = UDim2.new(0,3,0,7)
        dot.Size = UDim2.new(0,5,0,5)

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = btn
        nameLabel.BackgroundTransparency = 1
        nameLabel.Position = UDim2.new(0,11,0,0)
        nameLabel.Size = UDim2.new(1,-14,0,20)
        nameLabel.Font = Enum.Font.Code
        nameLabel.Text = entry.Name .. "  [" .. entry.Class .. "]"
        nameLabel.TextColor3 = Color3.fromRGB(200,200,200)
        nameLabel.TextSize = 9
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left

        btn.MouseButton1Click:Connect(function()
            if entry.Source and #entry.Source > 0 then
                local escaped = entry.Source:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
                local header = string.format('<font color="rgb(0,255,120)">--[[ %s | %s ]]</font>\n\n', entry.Path, entry.Class)
                UI.SourceText.Text = header .. escaped
                local sz = UI.SourceText.TextBounds
                UI.SourceView.CanvasSize = UDim2.new(0,0,0,sz.Y+20)
                UI.SourceView.CanvasPosition = Vector2.new(0,0)
                SetStatus("Source: " .. entry.Path)
            else
                -- Remote bez source'a - pokaż referencje
                local refs = Data.RemoteRefs[entry.Name] or {}
                local txt = string.format('<font color="rgb(255,200,0)">[%s] %s</font>\n\n<font color="rgb(150,150,180)">Path: %s</font>\n\n',
                    entry.Class, entry.Name, entry.Path)

                if #refs > 0 then
                    txt = txt .. string.format('<font color="rgb(0,255,120)">This remote is referenced in %d script(s):</font>\n\n', #refs)
                    for _, r in ipairs(refs) do
                        local esc = r.Source:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
                        txt = txt .. string.format('<font color="rgb(100,200,255)">─ [%s] %s</font>\n<font color="rgb(100,100,130)">%s</font>\n\n%s\n\n<font color="rgb(60,60,80)">─────────────────────</font>\n\n',
                            r.Class, r.Path, r.Path, esc)
                    end
                else
                    txt = txt .. '<font color="rgb(255,100,50)">No scripts reference this remote by name.</font>\n\n'
                    txt = txt .. '<font color="rgb(150,150,180)">RemoteEvent/RemoteFunction don\'t have their own source code.\nThey are triggered FROM other scripts via FireServer()/InvokeServer().\nThe code that handles them is on the server side and not visible.</font>'
                end
                UI.SourceText.Text = txt
                local sz = UI.SourceText.TextBounds
                UI.SourceView.CanvasSize = UDim2.new(0,0,0,sz.Y+20)
                UI.SourceView.CanvasPosition = Vector2.new(0,0)
                SetStatus("References for: " .. entry.Name .. " (" .. #refs .. " scripts)")
            end
        end)

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(25,25,40)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(18,18,30)
        end)
    end

    local count = #entries
    UI.ScriptList.CanvasSize = UDim2.new(0,0,0, count * 21 + 10)

    local labelMap = {
        ALL = "All Items",
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

-- ===== FILTERS =====
local function SetupFilters()
    for name, btn in pairs(UI.FilterBtns) do
        btn.MouseButton1Click:Connect(function()
            for _, b in pairs(UI.FilterBtns) do
                b.BackgroundColor3 = Color3.fromRGB(30,30,45)
                b.TextColor3 = Color3.fromRGB(180,180,200)
            end
            btn.BackgroundColor3 = Color3.fromRGB(0,100,60)
            btn.TextColor3 = Color3.fromRGB(0,255,120)
            PopulateScriptList(name)
        end)
    end
end

-- ===== ANALYZER =====
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

    -- Find remote references in this script
    -- Match: AnythingThatEndsWith:FireServer(...) or :InvokeServer(...)
    for remName, _ in pairs(Data.RemoteRefs) do
        local escName = remName:gsub("([%.%+%-%*%?%[%]%^%$%(%)%%])", "%%%1")
        if sl:find(escName, 1, true) then
            -- This script references this remote
            local found = false
            for _, r in ipairs(Data.RemoteRefs[remName]) do
                if r.Path == path then found = true; break end
            end
            if not found then
                table.insert(Data.RemoteRefs[remName], {Name=name, Path=path, Source=src, Class=class})
            end
        end
    end

    -- Also scan for FireServer/InvokeServer calls
    local _, countFS = sl:gsub(":fireserver", "")
    local _, countIS = sl:gsub(":invokeserver", "")
    if countFS + countIS > 0 then
        -- Find which remotes are fired
        -- Pattern like: RemoteName:FireServer or "RemoteName":FireServer
        for _, v in ipairs(Data.Remotes) do
            local rn = v.Name:gsub("([%.%+%-%*%?%[%]%^%$%(%)%%])", "%%%1")
            if sl:find(rn, 1, true) then
                local found = false
                for _, r in ipairs(Data.RemoteRefs[v.Name]) do
                    if r.Path == path then found = true; break end
                end
                if not found then
                    table.insert(Data.RemoteRefs[v.Name], {Name=name, Path=path, Source=src, Class=class})
                end
            end
        end
        for _, v in ipairs(Data.RemoteFuncs) do
            local rn = v.Name:gsub("([%.%+%-%*%?%[%]%^%$%(%)%%])", "%%%1")
            if sl:find(rn, 1, true) then
                local found = false
                for _, r in ipairs(Data.RemoteRefs[v.Name]) do
                    if r.Path == path then found = true; break end
                end
                if not found then
                    table.insert(Data.RemoteRefs[v.Name], {Name=name, Path=path, Source=src, Class=class})
                end
            end
        end
    end

    -- Vulnerabilities
    local vulns = {}
    if sl:find("loadstring",1,true) then
        table.insert(vulns, {Type="loadstring() code execution", Sev="CRITICAL"})
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

-- ===== SCANNER =====
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
            AnalyzeScript(inst.Name, path, src, "ModuleScript")

        elseif cls == "RemoteEvent" then
            table.insert(Data.Remotes, {Name=inst.Name, Path=path, Parent=tostring(inst.Parent)})
            Data.RemoteRefs[inst.Name] = Data.RemoteRefs[inst.Name] or {}
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
            Data.RemoteRefs[inst.Name] = Data.RemoteRefs[inst.Name] or {}
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
end

local function ScanService(svcName)
    local ok, svc = pcall(function() return game:GetService(svcName) end)
    if ok and svc then
        pcall(function() ScanRecursive(svc) end)
        task.wait(0.05)
    end
end

-- ===== START SCAN =====
local function StartScan()
    Data = {Scripts={}, Locals={}, Modules={}, Remotes={}, RemoteFuncs={},
            AntiCheats={}, AdminSys={}, CurrencySys={}, Backdoors={},
            Vulns={}, Exploits={}, AllSources={}, RemoteRefs={}, ScanCount=0}

    UI.SourceText.Text = "Scanning... please wait."
    UI.SourceView.CanvasSize = UDim2.new(0,0,0,50)

    SetStatus("Scanning game...")

    local svcs = {"Workspace","ReplicatedStorage","ReplicatedFirst","ServerScriptService",
                  "ServerStorage","StarterGui","StarterPack","Lighting"}
    for _, s in ipairs(svcs) do
        SetStatus("Scanning " .. s)
        ScanService(s)
    end

    SetStatus("Scanning players...")
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

    -- Now do a SECOND PASS to find references to remotes
    -- Scan all script sources for remote names
    SetStatus("Finding remote references...")
    for _, srcData in ipairs(Data.AllSources) do
        for remName, refList in pairs(Data.RemoteRefs) do
            local sl = srcData.Source:lower()
            local escName = remName:gsub("([%.%+%-%*%?%[%]%^%$%(%)%%])", "%%%1")
            if sl:find(escName, 1, true) then
                local found = false
                for _, r in ipairs(refList) do
                    if r.Path == srcData.Path then found = true; break end
                end
                if not found then
                    table.insert(refList, {Name=srcData.Name, Path=srcData.Path, Source=srcData.Source, Class=srcData.Class})
                end
            end
        end
        task.wait()
    end

    PopulateScriptList("ALL")

    -- Summary
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

<font color="rgb(150,200,255)">When you click a RemoteEvent/RemoteFunction,
it will show you which scripts reference it
with their FULL source code.</font>
]],
        #Data.Scripts, #Data.Locals, #Data.Modules,
        #Data.Remotes, #Data.RemoteFuncs,
        #Data.AntiCheats, #Data.AdminSys, #Data.CurrencySys,
        #Data.Backdoors, #Data.Vulns, #Data.Exploits
    )

    UI.SourceText.Text = summary
    local sz = UI.SourceText.TextBounds
    UI.SourceView.CanvasSize = UDim2.new(0,0,0,sz.Y+20)

    -- Auto-copy exploit commands
    if #Data.Exploits > 0 then
        local cmdLine = "-- Exploit commands for " .. #Data.Exploits .. " targets:\n"
        for _, e in ipairs(Data.Exploits) do
            if e.Type == "RemoteEvent" then
                cmdLine = cmdLine .. string.format("for _,v in pairs(game:GetDescendants()) do if v:IsA('RemoteEvent') and v.Name == '%s' then v:FireServer(999999) v:FireServer(game.Players.LocalPlayer, 999999) end end\n", e.Name)
            end
        end
        pcall(function() SetClip(cmdLine) end)
    end

    SetStatus(string.format("Done! %d items. Click REMOTES filter, then click any remote to see its referencers.", Data.ScanCount))
end

-- ===== EXPORT =====
local function ExportResults()
    local report = ""

    report = report .. "============================================\n"
    report = report .. " ROBLOX SECURITY AUDIT REPORT\n"
    report = report .. string.format(" Game: %s (ID: %s)\n", tostring(game.Name), tostring(game.GameId))
    report = report .. string.format(" Date: %s\n", os.date("%Y-%m-%d %H:%M:%S"))
    report = report .. "============================================\n\n"

    report = report .. "=== ALL SCRIPTS ===\n\n"
    for _, v in ipairs(Data.AllSources) do
        report = report .. string.format("--[[ %s (%s) ]]\n%s\n\n---\n\n", v.Path, v.Class, v.Source)
    end

    report = report .. "\n\n=== REMOTE REFERENCES ===\n\n"
    for remName, refs in pairs(Data.RemoteRefs) do
        report = report .. string.format("--- Remote: %s (%d references) ---\n", remName, #refs)
        for _, r in ipairs(refs) do
            report = report .. string.format("  Referenced by: %s (%s)\n", r.Path, r.Class)
            report = report .. r.Source .. "\n\n"
        end
        report = report .. "================================\n\n"
    end

    report = report .. "\n=== EXPLOIT VECTORS ===\n"
    for _, v in ipairs(Data.Exploits) do
        report = report .. string.format("  [%s] %s (%s) - %s\n", v.Risk, v.Name, v.Type, v.Payload)
    end

    local ok = pcall(function() SetClip(report) end)
    if ok then
        SetStatus("Full report copied to clipboard!")
    else
        local summary = string.format("Audit: %d scripts, %d remotes, %d AC, %d backdoors, %d exploits",
            #Data.Scripts + #Data.Locals + #Data.Modules,
            #Data.Remotes + #Data.RemoteFuncs,
            #Data.AntiCheats, #Data.Backdoors, #Data.Exploits)
        pcall(function() SetClip(summary) end)
        SetStatus("Summary copied (full report too large for clipboard)")
    end

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

SetStatus("Ready. Click START SCAN to audit.")

UI.SourceText.Text = [[
<font color="rgb(0,255,120)">╔══════════════════════════════════════════════╗
║   Roblox Security Auditor v5.1              ║
║   With Remote Reference Finder              ║
╚══════════════════════════════════════════════╝</font>

<font color="rgb(150,200,255)">How to use:</font>

<font color="rgb(0,200,255)">1.</font> Click <font color="rgb(0,255,100)">[▶ START SCAN]</font>
<font color="rgb(0,200,255)">2.</font> Browse with filter buttons
<font color="rgb(0,200,255)">3.</font> Click <font color="rgb(255,255,0)">any script</font> → <font color="rgb(0,255,100)">shows its FULL source</font>
<font color="rgb(0,200,255)">4.</font> Click a <font color="rgb(200,100,255)">RemoteEvent/RemoteFunction</font>
    → shows <font color="rgb(255,255,0)">which scripts reference it</font>
    → with their <font color="rgb(0,255,100)">full source code</font>
<font color="rgb(0,200,255)">5.</font> <font color="rgb(50,150,255)">[📋 COPY]</font> = export everything to clipboard
]]
