--[[
=============================================================================
  Roblox Game Security Auditor - Advanced Pentest Suite
  Author: HackerAI Penetration Testing Framework
  Purpose: Authorized security assessment of Roblox games
  DISCLAIMER: For authorized testing ONLY. All users are verified pentesters.
=============================================================================
]]

-- Initialize GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScanButton = Instance.new("TextButton")
local Status = Instance.new("TextLabel")
local LogBox = Instance.new("ScrollingFrame")
local LogText = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local ExportBtn = Instance.new("TextButton")
local Tabs = {}
local CurrentTab = "Scanner"

-- Services
local Services = {
    Workspace = game:GetService("Workspace"),
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    ReplicatedFirst = game:GetService("ReplicatedFirst"),
    ServerScriptService = game:GetService("ServerScriptService"),
    ServerStorage = game:GetService("ServerStorage"),
    StarterGui = game:GetService("StarterGui"),
    StarterPack = game:GetService("StarterPack"),
    StarterPlayer = game:GetService("StarterPlayer"),
    StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"),
    StarterCharacterScripts = game:GetService("StarterPlayer"):WaitForChild("StarterCharacterScripts"),
    Lighting = game:GetService("Lighting"),
    CoreGui = game:GetService("CoreGui"),
    PlayersLocal = game:GetService("Players").LocalPlayer,
    PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"),
    Backpack = game:GetService("Players").LocalPlayer:WaitForChild("Backpack"),
    NLS = game:GetService("NetworkServer") or nil,
    InsertService = game:GetService("InsertService"),
    MarketService = game:GetService("MarketplaceService"),
    TextChatService = game:GetService("TextChatService"),
    Chat = game:GetService("Chat"),
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService"),
}

-- Data storage
local ScanResults = {
    Scripts = {},
    Modules = {},
    LocalScripts = {},
    RemoteEvents = {},
    RemoteFunctions = {},
    AntiCheats = {},
    AdminSystems = {},
    CurrencySystems = {},
    Vulnerabilities = {},
    Backdoors = {},
    SuspiciousPatterns = {},
    ExploitVectors = {},
}

-- Known anti-cheat patterns
local AntiCheatPatterns = {
    "ant[i1]che[a4]t",
    "anti[_-]cheat",
    "ac_",
    "chea[a4]tdet[e3]ct",
    "exploitdetect",
    "h[u4]nk",
    "k[i1]ckpl[a4]yer",
    "b[a4]npl[a4]yer",
    "remotesec[u4]r[i1]ty",
    "v[a4]lid[a4]t[i1]on",
    "r[a4]t[e3]l[i1]m[i1]t",
    "c[a4]llfire",
    "ch[e3]ckc[a4]ll[e3]r",
    "s[e3]cur[i1]tych[e3]ck",
    "s[a4]n[i1]tych[e3]ck",
    "k[i1]ckremote",
    "b[a4]nremote",
    "logremote",
    "remotelog",
    "remotespy",
    "ant[i1]t[u4]ck",
    "ant[i1]sp[e3][e3]d",
    "ant[i1]fly",
    "ant[i1]tp",
    "ant[i1]j[u4]mp",
    "ant[i1]exploit",
    "detectexploit",
    "h[e3]urm[e3]t[i1]c",
    "s[e3]rv[e3]rch[e3]ck",
    "v[a4]lidatormain",
    "dutycheck",
    "sanitycheck",
}

-- Known admin system patterns
local AdminPatterns = {
    "hd[a4]dm[i1]n",
    "kohls[a4]dm[i1]n",
    "[a4]dm[i1]ncmd",
    "[a4]dm[i1]ncomm[a4]nd",
    "cmds",
    "c[m]ds[y]",
    "c[m]d[_-]",
    "[a4]dm[i1]npa[n]el",
    "[a4]dm[i1]nmenu",
    "[a4]dm[i1]nsystem",
    "comm[a4]ndsystem",
    "c[m]dcenter",
    "c[m]dhandler",
    "c[m]dexeccut[e3]",
    "[a4]dmins",
}

-- Known currency patterns
local CurrencyPatterns = {
    "currenc[y]",
    "money",
    "coins",
    "gems",
    "gold",
    "cash",
    "bala[a4]nce",
    "l[e3]ad[e3]rsta[a4]ts",
    "stats",
    "[e3]conom[y]",
    "w[a4]ll[e3]t",
    "b[a4]nk",
    "poi[a4]nts",
    "scor[e3]",
    "cr[e3]d[i1]ts",
    "tokens",
    "cryst[a4]ls",
    "st[a4]rs",
    "t[i1]ck[e3]ts",
    "vouch[e3]rs",
    "premium",
    "v[i1]p",
    "don[a4]t[i1]on",
    "rew[a4]rd",
    "mult[i1]pl[i1]er",
    "boo[a4]st",
    "addcurrency",
    "setmoney",
    "givecoins",
    "removecurrency",
    "updatestats",
}

-- Known backdoor/suspicious patterns
local BackdoorPatterns = {
    "loadstr[i1]ng",
    "httppost",
    "httpget",
    "getasync",
    "postasync",
    "http://",
    "https://",
    "pastebin",
    "github",
    "raw\\.githubusercontent",
    "discord",
    "webhook",
    "require%(",
    "game:GetService\"",
    "game['\"]",
    "Ident[i1]ty",
    "clon[e3]r[e3]f",
    "ch[e3]ckcaller",
    "hookmetamethod",
    "g[e3]trawmetatable",
    "s[e3]trawmetatable",
    "getnamecallmethod",
    "n[i1]cecall",
    "f[i1]restorm",
    "syn[x]",
    "protosmasher",
    "krnl",
    "scriptblox",
    "simpleSpy",
    "remotespy",
}

-- Vulnerability patterns
local VulnerabilityPatterns = {
    -- Weak remote validation
    pattern = "RemoteEvent%.OnServerEvent:Connect",
    check = "RemoteEvent%.FireServer",
    -- No caller check
    noCaller = "FireServer$",
    -- Direct currency manipulation  
    currencyRemote = "Currency|Money|Coins|Give|Add|Set",
    -- Lack of type checking
    noTypeCheck = "%.Value$",
    -- Admin give
    adminGive = "Admin|Cmds|Command",
}

-- Build GUI
local function BuildGUI()
    ScreenGui.Name = "SecurityAuditor"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")
    
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    MainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Title
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0.06, 0)
    Title.Font = Enum.Font.Code
    Title.Text = "Roblox Security Auditor v3.0 | Authorized Pentest Tool"
    Title.TextColor3 = Color3.fromRGB(0, 255, 100)
    Title.TextSize = 18
    
    -- Close button
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = MainFrame
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(0.95, 0, 0.005, 0)
    CloseBtn.Size = UDim2.new(0.045, 0, 0.045, 0)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 16
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Scan button
    ScanButton.Name = "ScanButton"
    ScanButton.Parent = MainFrame
    ScanButton.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
    ScanButton.BorderSizePixel = 0
    ScanButton.Position = UDim2.new(0.02, 0, 0.07, 0)
    ScanButton.Size = UDim2.new(0.15, 0, 0.05, 0)
    ScanButton.Font = Enum.Font.Code
    ScanButton.Text = "► START SCAN"
    ScanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanButton.TextSize = 14
    
    -- Export button
    ExportBtn.Name = "ExportBtn"
    ExportBtn.Parent = MainFrame
    ExportBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    ExportBtn.BorderSizePixel = 0
    ExportBtn.Position = UDim2.new(0.18, 0, 0.07, 0)
    ExportBtn.Size = UDim2.new(0.12, 0, 0.05, 0)
    ExportBtn.Font = Enum.Font.Code
    ExportBtn.Text = "EXPORT"
    ExportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExportBtn.TextSize = 14
    
    -- Status
    Status.Name = "Status"
    Status.Parent = MainFrame
    Status.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Status.BorderSizePixel = 0
    Status.Position = UDim2.new(0.02, 0, 0.13, 0)
    Status.Size = UDim2.new(0.96, 0, 0.03, 0)
    Status.Font = Enum.Font.Code
    Status.Text = "[READY] Waiting for scan command..."
    Status.TextColor3 = Color3.fromRGB(100, 200, 255)
    Status.TextSize = 13
    Status.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Log box
    LogBox.Name = "LogBox"
    LogBox.Parent = MainFrame
    LogBox.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    LogBox.BorderSizePixel = 0
    LogBox.Position = UDim2.new(0.02, 0, 0.17, 0)
    LogBox.Size = UDim2.new(0.96, 0, 0.80, 0)
    LogBox.CanvasSize = UDim2.new(0, 0, 10, 0)
    LogBox.ScrollBarThickness = 8
    
    LogText.Name = "LogText"
    LogText.Parent = LogBox
    LogText.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    LogText.BackgroundTransparency = 1
    LogText.Size = UDim2.new(1, 0, 100, 0)
    LogText.Font = Enum.Font.Code
    LogText.Text = ""
    LogText.TextColor3 = Color3.fromRGB(200, 200, 200)
    LogText.TextSize = 12
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.RichText = true
end

-- Logging function
local function Log(msg, color)
    color = color or Color3.fromRGB(200, 200, 200)
    local r = math.floor(color.R * 255)
    local g = math.floor(color.G * 255)
    local b = math.floor(color.B * 255)
    local timestamp = os.date("%H:%M:%S")
    LogText.Text = LogText.Text .. string.format(
        '<font color="rgb(%d,%d,%d)">[%s]</font> %s\n',
        r, g, b, timestamp, msg
    )
    LogBox.CanvasSize = UDim2.new(0, 0, LogText.TextBounds.Y + 20, 0)
    LogBox.CanvasPosition = Vector2.new(0, LogText.TextBounds.Y)
end

-- Status update
local function SetStatus(msg, color)
    color = color or Color3.fromRGB(100, 200, 255)
    local r = math.floor(color.R * 255)
    local g = math.floor(color.G * 255)
    local b = math.floor(color.B * 255)
    Status.Text = string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, msg)
end

-- Deep scan function - walks through all instances
local function DeepScan(instance, depth, maxDepth)
    depth = depth or 0
    maxDepth = maxDepth or 50
    
    if depth > maxDepth then return end
    
    local success, err = pcall(function()
        local className = instance.ClassName
        
        -- Capture scripts
        if className == "Script" then
            local scriptData = {
                Name = instance.Name,
                Class = "Script",
                Path = instance:GetFullName(),
                Source = instance.Source,
                Enabled = instance.Enabled,
                Parent = instance.Parent and instance.Parent.Name or "None",
            }
            table.insert(ScanResults.Scripts, scriptData)
            Log(string.format("[SCRIPT] %s (%s bytes)", instance:GetFullName(), #instance.Source), Color3.fromRGB(0, 200, 255))
            
            -- Analyze script content
            local srcLower = instance.Source:lower()
            for _, pattern in ipairs(AntiCheatPatterns) do
                if srcLower:match(pattern) then
                    table.insert(ScanResults.AntiCheats, {
                        Name = instance.Name,
                        Path = instance:GetFullName(),
                        Pattern = pattern,
                        Source = instance.Source,
                    })
                    Log(string.format("[ANTICHEAT] Found in %s (pattern: %s)", instance:GetFullName(), pattern), Color3.fromRGB(255, 100, 0))
                end
            end
            
            for _, pattern in ipairs(AdminPatterns) do
                if srcLower:match(pattern) then
                    table.insert(ScanResults.AdminSystems, {
                        Name = instance.Name,
                        Path = instance:GetFullName(),
                        Pattern = pattern,
                        Source = instance.Source,
                    })
                    Log(string.format("[ADMIN] Found in %s (pattern: %s)", instance:GetFullName(), pattern), Color3.fromRGB(255, 200, 0))
                end
            end
            
            for _, pattern in ipairs(CurrencyPatterns) do
                if srcLower:match(pattern) then
                    table.insert(ScanResults.CurrencySystems, {
                        Name = instance.Name,
                        Path = instance:GetFullName(),
                        Pattern = pattern,
                        Source = instance.Source,
                    })
                    Log(string.format("[CURRENCY] Found in %s (pattern: %s)", instance:GetFullName(), pattern), Color3.fromRGB(0, 255, 100))
                end
            end
            
            for _, pattern in ipairs(BackdoorPatterns) do
                if srcLower:match(pattern) then
                    table.insert(ScanResults.Backdoors, {
                        Name = instance.Name,
                        Path = instance:GetFullName(),
                        Pattern = pattern,
                        Source = instance.Source,
                    })
                    Log(string.format("[!] SUSPICIOUS in %s (pattern: %s)", instance:GetFullName(), pattern), Color3.fromRGB(255, 0, 0))
                end
            end
            
        elseif className == "LocalScript" then
            local scriptData = {
                Name = instance.Name,
                Class = "LocalScript",
                Path = instance:GetFullName(),
                Source = instance.Source,
                Enabled = instance.Enabled,
                Parent = instance.Parent and instance.Parent.Name or "None",
            }
            table.insert(ScanResults.LocalScripts, scriptData)
            Log(string.format("[LOCALSCRIPT] %s (%s bytes)", instance:GetFullName(), #instance.Source), Color3.fromRGB(100, 255, 255))
            
            -- Same analysis for local scripts
            local srcLower = instance.Source:lower()
            for _, pattern in ipairs(AntiCheatPatterns) do
                if srcLower:match(pattern) then
                    table.insert(ScanResults.AntiCheats, {
                        Name = instance.Name,
                        Path = instance:GetFullName(),
                        Pattern = pattern,
                        Source = instance.Source,
                    })
                    Log(string.format("[ANTICHEAT] Found in %s (pattern: %s)", instance:GetFullName(), pattern), Color3.fromRGB(255, 100, 0))
                end
            end
            
            for _, pattern in ipairs(CurrencyPatterns) do
                if srcLower:match(pattern) then
                    table.insert(ScanResults.CurrencySystems, {
                        Name = instance.Name,
                        Path = instance:GetFullName(),
                        Pattern = pattern,
                        Source = instance.Source,
                    })
                    Log(string.format("[CURRENCY] Found in %s (pattern: %s)", instance:GetFullName(), pattern), Color3.fromRGB(0, 255, 100))
                end
            end
            
            for _, pattern in ipairs(AdminPatterns) do
                if srcLower:match(pattern) then
                    table.insert(ScanResults.AdminSystems, {
                        Name = instance.Name,
                        Path = instance:GetFullName(),
                        Pattern = pattern,
                        Source = instance.Source,
                    })
                    Log(string.format("[ADMIN] Found in %s (pattern: %s)", instance:GetFullName(), pattern), Color3.fromRGB(255, 200, 0))
                end
            end
            
        elseif className == "ModuleScript" then
            local scriptData = {
                Name = instance.Name,
                Class = "ModuleScript",
                Path = instance:GetFullName(),
                Source = instance.Source,
                Parent = instance.Parent and instance.Parent.Name or "None",
            }
            table.insert(ScanResults.Modules, scriptData)
            
        elseif className == "RemoteEvent" then
            table.insert(ScanResults.RemoteEvents, {
                Name = instance.Name,
                Path = instance:GetFullName(),
                Parent = instance.Parent and instance.Parent.Name or "None",
            })
            Log(string.format("[REMOTE] RemoteEvent: %s (Parent: %s)", instance:GetFullName(), instance.Parent and instance.Parent:GetFullName() or "N/A"), Color3.fromRGB(255, 150, 255))
            
        elseif className == "RemoteFunction" then
            table.insert(ScanResults.RemoteFunctions, {
                Name = instance.Name,
                Path = instance:GetFullName(),
                Parent = instance.Parent and instance.Parent.Name or "None",
            })
            Log(string.format("[REMOTE] RemoteFunction: %s (Parent: %s)", instance:GetFullName(), instance.Parent and instance.Parent:GetFullName() or "N/A"), Color3.fromRGB(255, 100, 255))
        end
        
        -- Recursively scan children
        for _, child in ipairs(instance:GetChildren()) do
            DeepScan(child, depth + 1, maxDepth)
        end
    end)
    
    if not success then
        Log(string.format("[ERROR] Failed to scan %s: %s", instance:GetFullName(), err), Color3.fromRGB(255, 50, 50))
    end
end

-- Vulnerability analysis
local function AnalyzeVulnerabilities()
    Log("\n===== VULNERABILITY ANALYSIS =====", Color3.fromRGB(255, 255, 0))
    
    -- Analyze all collected scripts for vulnerabilities
    local allScripts = {}
    for _, s in ipairs(ScanResults.Scripts) do table.insert(allScripts, s) end
    for _, s in ipairs(ScanResults.LocalScripts) do table.insert(allScripts, s) end
    
    for _, script in ipairs(allScripts) do
        local src = script.Source or ""
        local srcLower = src:lower()
        local vulnerabilities = {}
        
        -- Check for FireServer without validation
        for remoteName, _ in pairs(ScanResults.RemoteEvents) do
            -- This is checked per-pattern below
        end
        
        -- 1. FireServer calls (potential client-side triggers)
        local fireCount = select(2, src:gsub("FireServer", ""))
        if fireCount > 0 then
            -- Check if there's corresponding server validation
            if not srcLower:match("validat") and not srcLower:match("check") then
                table.insert(vulnerabilities, {
                    Type = "Unvalidated FireServer",
                    Severity = "HIGH",
                    Detail = string.format("Calls FireServer %d time(s) without visible validation", fireCount),
                })
            end
        end
        
        -- 2. Loadstring (code execution)
        if srcLower:match("loadstr") then
            table.insert(vulnerabilities, {
                Type = "Dynamic Code Execution",
                Severity = "CRITICAL",
                Detail = "Uses loadstring() - potential arbitrary code execution",
            })
        end
        
        -- 3. HTTP requests
        if srcLower:match("httpget") or srcLower:match("httppost") then
            table.insert(vulnerabilities, {
                Type = "External HTTP Request",
                Severity = "HIGH",
                Detail = "Makes HTTP requests to external URLs",
            })
        end
        
        -- 4. Debug library usage
        if srcLower:match("debug%.") then
            table.insert(vulnerabilities, {
                Type = "Debug Library Access",
                Severity = "MEDIUM",
                Detail = "Uses debug library - can be used to access restricted functions",
            })
        end
        
        -- 5. GetRawMetatable / SetRawMetatable
        if srcLower:match("getrawmetatable") or srcLower:match("setrawmetatable") then
            table.insert(vulnerabilities, {
                Type = "Metatable Manipulation",
                Severity = "CRITICAL",
                Detail = "Uses raw metatable functions - full exploit capability",
            })
        end
        
        -- 6. HookMetamethod
        if srcLower:match("hookmetamethod") then
            table.insert(vulnerabilities, {
                Type = "Metamethod Hooking",
                Severity = "CRITICAL",
                Detail = "Hooks metamethods - can intercept all function calls",
            })
        end
        
        -- 7. CheckCaller usage (anti-debug bypass)
        if srcLower:match("checkcaller") then
            table.insert(vulnerabilities, {
                Type = "Caller Check Bypass",
                Severity = "CRITICAL",
                Detail = "Uses checkcaller - can bypass anti-exploit caller checks",
            })
        end
        
        -- 8. CloneRef (anti-detection)
        if srcLower:match("cloneref") then
            table.insert(vulnerabilities, {
                Type = "Anti-Detection",
                Severity = "HIGH",
                Detail = "Uses cloneref - bypasses CoreGui detection",
            })
        end
        
        -- 9. Direct value setting without validation
        if srcLower:match("%.Value%s*=") and not srcLower:match("validat") then
            table.insert(vulnerabilities, {
                Type = "Unvalidated Value Set",
                Severity = "MEDIUM",
                Detail = "Sets .Value property without validation",
            })
        end
        
        if #vulnerabilities > 0 then
            table.insert(ScanResults.Vulnerabilities, {
                ScriptName = script.Name,
                ScriptPath = script.Path,
                Vulnerabilities = vulnerabilities,
            })
            
            Log(string.format("\n[!] Vulnerabilities found in: %s (%s)", script.Name, script.Path), Color3.fromRGB(255, 50, 50))
            for _, vuln in ipairs(vulnerabilities) do
                local sevColor = vuln.Severity == "CRITICAL" and Color3.fromRGB(255, 0, 0) 
                    or vuln.Severity == "HIGH" and Color3.fromRGB(255, 100, 0)
                    or Color3.fromRGB(255, 200, 0)
                Log(string.format("    [%s] %s: %s", vuln.Severity, vuln.Type, vuln.Detail), sevColor)
            end
        end
    end
    
    -- Analyze remotes for exploit potential
    Log("\n===== REMOTE EXPLOIT ANALYSIS =====", Color3.fromRGB(255, 255, 0))
    
    for _, remote in ipairs(ScanResults.RemoteEvents) do
        local name = remote.Name:lower()
        local parentName = remote.Parent:lower() if remote.Parent else ""
        
        -- High-value targets for exploitation
        if name:match("currency") or name:match("money") or name:match("coin") 
           or name:match("give") or name:match("add") or name:match("set")
           or name:match("buy") or name:match("purchase") or name:match("upgrade")
           or name:match("reward") or name:match("admin") or name:match("cmd")
           or name:match("grant") or name:match("unlock") or name:match("teleport")
           or name:match("spawn") or name:match("kick") or name:match("ban") then
            
            local exploitData = {
                RemoteName = remote.Name,
                RemotePath = remote.Path,
                RemoteType = "RemoteEvent",
                Risk = "HIGH",
                Reason = string.format("Remote name suggests privileged operation: '%s'", remote.Name),
                ExploitMethod = "FireServer with crafted arguments",
            }
            table.insert(ScanResults.ExploitVectors, exploitData)
            
            Log(string.format("[!] HIGH VALUE TARGET: %s (%s)", remote.Name, remote.Path), Color3.fromRGB(255, 0, 0))
            Log(string.format("    Exploit: Fire %s with crafted arguments", remote.Name), Color3.fromRGB(255, 100, 0))
        end
    end
    
    for _, remote in ipairs(ScanResults.RemoteFunctions) do
        local name = remote.Name:lower()
        local parentName = remote.Parent:lower() if remote.Parent else ""
        
        if name:match("currency") or name:match("money") or name:match("coin")
           or name:match("give") or name:match("add") or name:match("set")
           or name:match("buy") or name:match("admin") or name:match("cmd")
           or name:match("grant") or name:match("kick") or name:match("ban") then
            
            local exploitData = {
                RemoteName = remote.Name,
                RemotePath = remote.Path,
                RemoteType = "RemoteFunction",
                Risk = "HIGH",
                Reason = string.format("Remote function name suggests privileged operation: '%s'", remote.Name),
                ExploitMethod = "InvokeServer with crafted arguments",
            }
            table.insert(ScanResults.ExploitVectors, exploitData)
            
            Log(string.format("[!] HIGH VALUE TARGET: %s (RemoteFunction @ %s)", remote.Name, remote.Path), Color3.fromRGB(255, 0, 0))
            Log(string.format("    Exploit: Invoke %s with crafted arguments", remote.Name), Color3.fromRGB(255, 100, 0))
        end
    end
end

-- Generate exploit scripts
local function GenerateExploitScripts()
    Log("\n===== GENERATING EXPLOIT SCRIPTS =====", Color3.fromRGB(0, 255, 100))
    
    local exploitScripts = {}
    
    -- 1. Remote Event Fire exploit
    if #ScanResults.RemoteEvents > 0 or #ScanResults.RemoteFunctions > 0 then
        local remoteSpy = [[
-- REMOTE SPY / EXPLOIT GENERATOR
-- Captures and displays all remote traffic
-- Enables re-firing with modified arguments

local RemoteSpy = {}
local Connections = {}

-- Hook RemoteEvent
for _, v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        local oldName = v.Name
        local oldParent = v.Parent
        
        if v:IsA("RemoteEvent") then
            local connection
            connection = v.OnClientEvent:Connect(function(...)
                local args = {...}
                local argStr = ""
                for i, arg in ipairs(args) do
                    argStr = argStr .. tostring(arg) .. (i < #args and ", " or "")
                end
                
                -- Create re-fire button in log
                print(string.format("[REMOTE] %s Fired", oldName))
                print(string.format("  Args: %s", argStr))
                
                -- Store for re-fire
                RemoteSpy[oldName] = {
                    Type = "Event",
                    Args = args,
                    Remote = v,
                }
            end)
            table.insert(Connections, connection)
            
        else
            -- RemoteFunction hook via __namecall
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                if method == "InvokeServer" and (self:IsA("RemoteFunction")) then
                    local argStr = ""
                    for i, arg in ipairs(args) do
                        argStr = argStr .. tostring(arg) .. (i < #args and ", " or "")
                    end
                    
                    print(string.format("[REMOTE] %s:InvokeServer()", self.Name))
                    print(string.format("  Args: %s", argStr))
                    
                    RemoteSpy[self.Name] = {
                        Type = "Function",
                        Args = args,
                        Remote = self,
                    }
                end
                
                return oldNamecall(self, ...)
            end)
        end
        
        print(string.format("[SPY] Hooked: %s (%s)", oldName, oldParent and oldParent.Name or "Unknown"))
    end
end

-- Utility to re-fire a captured remote
function ReFire(remoteName, ...)
    local data = RemoteSpy[remoteName]
    if data and data.Remote then
        local newArgs = {...}
        if #newArgs == 0 and data.Args then
            newArgs = data.Args
        end
        
        if data.Type == "Event" then
            data.Remote:FireServer(unpack(newArgs))
            print(string.format("[!] Re-Fired: %s", remoteName))
        end
    end
end

-- Utility to fire arbitrary remotes
function FireRemote(remoteName, ...)
    local remote = game:GetDescendants()
    for _, v in pairs(remote) do
        if v:IsA("RemoteEvent") and v.Name == remoteName then
            v:FireServer(...)
            print(string.format("[!] Fired: %s", remoteName))
            return
        end
    end
    print(string.format("[ERROR] Remote '%s' not found", remoteName))
end

print("\n=== REMOTE SPY ACTIVE ===")
print("Commands:")
print("  ReFire('RemoteName', ...) - Re-fire last seen")
print("  FireRemote('RemoteName', ...) - Fire any remote")
print("  RemoteSpy - View all captured data")
]]
        table.insert(exploitScripts, {Name = "RemoteSpy_Exploit.lua", Code = remoteSpy})
        Log("Generated: RemoteSpy_Exploit.lua", Color3.fromRGB(0, 255, 100))
    end
    
    -- 2. Currency exploit generator
    if #ScanResults.CurrencySystems > 0 then
        local currencyExploit = [[
-- CURRENCY EXPLOIT GENERATOR
-- Attempts to find and exploit currency-related remotes

print("=== CURRENCY EXPLOIT SCANNER ===")

local CurrencyTargets = {}

-- Find all potential currency remotes
for _, v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        local name = v.Name:lower()
        if name:match("currency") or name:match("money") or name:match("coin")
           or name:match("give") or name:match("add") or name:match("set")
           or name:match("buy") or name:match("reward") or name:match("grant")
           or name:match("upgrade") or name:match("purchase") then
            
            table.insert(CurrencyTargets, {
                Name = v.Name,
                Path = v:GetFullName(),
                Type = v.ClassName,
                Target = v,
            })
            
            print(string.format("[TARGET] %s (%s)", v.Name, v.ClassName))
        end
    end
end

-- Exploit functions
function TryExploitCurrency(remoteName, amount)
    amount = amount or 999999
    
    for _, target in ipairs(CurrencyTargets) do
        if target.Name == remoteName then
            print(string.format("[!] Attempting: FireServer('%s', %d)", remoteName, amount))
            
            -- Try common argument patterns
            pcall(function()
                target.Target:FireServer(amount)
            end)
            
            pcall(function()
                target.Target:FireServer(game.Players.LocalPlayer, amount)
            end)
            
            pcall(function()
                target.Target:FireServer(game.Players.LocalPlayer.UserId, amount)
            end)
            
            pcall(function()
                target.Target:FireServer("add", amount)
            end)
            
            pcall(function()
                target.Target:FireServer(amount, "Currency")
            end)
            
            print(string.format("[!] Exhausted payloads for %s", remoteName))
            return
        end
    end
    print(string.format("[ERROR] Remote '%s' not found in targets", remoteName))
end

function TryAllCurrencyExploits()
    print("\n=== ATTEMPTING ALL CURRENCY EXPLOITS ===")
    for _, target in ipairs(CurrencyTargets) do
        TryExploitCurrency(target.Name)
    end
end

print(string.format("\nFound %d currency-related remotes", #CurrencyTargets))
print("Commands:")
print("  TryExploitCurrency('RemoteName', amount)")
print("  TryAllCurrencyExploits()")
]]
        table.insert(exploitScripts, {Name = "Currency_Exploit.lua", Code = currencyExploit})
        Log("Generated: Currency_Exploit.lua", Color3.fromRGB(0, 255, 100))
    end
    
    -- 3. Admin exploit
    if #ScanResults.AdminSystems > 0 then
        local adminExploit = [[
-- ADMIN/CMD EXPLOIT GENERATOR
-- Finds and attempts admin command execution

print("=== ADMIN EXPLOIT SCANNER ===")

-- Find admin-related remotes
for _, v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") then
        local name = v.Name:lower()
        if name:match("admin") or name:match("cmd") or name:match("command")
           or name:match("cmds") or name:match("panel") or name:match("system")
           or name:match("fire") or name:match("exec") then
            
            print(string.format("[FOUND] %s (%s) @ %s", v.Name, v.ClassName, v:GetFullName()))
        end
    end
end

-- Try common admin command patterns
function TryAdminCommand(cmd)
    cmd = cmd or ";cmds"
    
    -- Try Chat-based admin
    pcall(function()
        game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents"):FindFirstChild("SayMessageRequest"):FireServer(cmd)
    end)
    
    pcall(function()
        game:GetService("ReplicatedStorage"):FindFirstChild("SayMessageRequest"):FireServer(cmd)
    end)
    
    -- Try common admin remotes
    local adminRemotes = {
        "AdminEvent", "AdminRemote", "CmdEvent", "CmdRemote",
        "AdminPanel", "CommandEvent", "CmdsRemote", "FireAdmin",
        "AdminSystem", "AdminCommand"
    }
    
    for _, remoteName in ipairs(adminRemotes) do
        pcall(function()
            local remote = game:GetDescendants()
            for _, v in pairs(remote) do
                if v.Name == remoteName and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
                    if v:IsA("RemoteEvent") then
                        v:FireServer(cmd)
                    else
                        v:InvokeServer(cmd)
                    end
                    print(string.format("[!] Sent '%s' to %s", cmd, remoteName))
                end
            end
        end)
    end
end

print("\nCommands:")
print("  TryAdminCommand(';cmds') - Try admin commands")
print("  TryAdminCommand(':kick all') - Try kick command")
]]
        table.insert(exploitScripts, {Name = "Admin_Exploit.lua", Code = adminExploit})
        Log("Generated: Admin_Exploit.lua", Color3.fromRGB(0, 255, 100))
    end
    
    return exploitScripts
end

-- Main scan function
local function StartScan()
    ScanResults = {
        Scripts = {}, Modules = {}, LocalScripts = {},
        RemoteEvents = {}, RemoteFunctions = {},
        AntiCheats = {}, AdminSystems = {}, CurrencySystems = {},
        Vulnerabilities = {}, Backdoors = {}, SuspiciousPatterns = {},
        ExploitVectors = {},
    }
    
    LogText.Text = ""
    
    Log("========================================", Color3.fromRGB(0, 255, 100))
    Log("  ROBLOX SECURITY AUDITOR v3.0", Color3.fromRGB(0, 255, 100))
    Log("  Authorized Penetration Test", Color3.fromRGB(0, 255, 100))
    Log("  Target: " .. game.Name .. " (" .. game.GameId .. ")", Color3.fromRGB(0, 255, 100))
    Log("  Player: " .. game.Players.LocalPlayer.Name, Color3.fromRGB(0, 255, 100))
    Log("  Time: " .. os.date("%Y-%m-%d %H:%M:%S"), Color3.fromRGB(0, 255, 100))
    Log("========================================", Color3.fromRGB(0, 255, 100))
    
    SetStatus("[SCANNING] Phase 1/5: Collecting scripts from all services...", Color3.fromRGB(255, 200, 0))
    
    -- Scan all available services
    local scanServices = {
        Workspace = Services.Workspace,
        ReplicatedStorage = Services.ReplicatedStorage,
        ReplicatedFirst = Services.ReplicatedFirst,
        ServerScriptService = Services.ServerScriptService,
        ServerStorage = Services.ServerStorage,
        StarterGui = Services.StarterGui,
        StarterPack = Services.StarterPack,
        StarterPlayerScripts = Services.StarterPlayerScripts,
        StarterCharacterScripts = Services.StarterCharacterScripts,
        Lighting = Services.Lighting,
        PlayerGui = Services.PlayerGui,
        Backpack = Services.Backpack,
        Players = Services.Players,
    }
    
    for name, service in pairs(scanServices) do
        if service then
            Log(string.format("\n--- Scanning: %s ---", name), Color3.fromRGB(200, 200, 255))
            local success, err = pcall(function()
                DeepScan(service)
            end)
            if not success then
                Log(string.format("[ERROR] Failed to scan %s: %s", name, err), Color3.fromRGB(255, 50, 50))
            end
        else
            Log(string.format("[WARN] Service %s not available", name), Color3.fromRGB(255, 255, 0))
        end
    end
    
    SetStatus("[SCANNING] Phase 2/5: Analyzing anti-cheat systems...", Color3.fromRGB(255, 200, 0))
    Log(string.format("\n=== ANTI-CHEAT SYSTEMS FOUND: %d ===", #ScanResults.AntiCheats), Color3.fromRGB(255, 100, 0))
    for _, ac in ipairs(ScanResults.AntiCheats) do
        Log(string.format("  - %s (pattern: %s)", ac.Path, ac.Pattern), Color3.fromRGB(255, 150, 0))
    end
    
    SetStatus("[SCANNING] Phase 3/5: Analyzing admin systems...", Color3.fromRGB(255, 200, 0))
    Log(string.format("\n=== ADMIN SYSTEMS FOUND: %d ===", #ScanResults.AdminSystems), Color3.fromRGB(255, 200, 0))
    for _, admin in ipairs(ScanResults.AdminSystems) do
        Log(string.format("  - %s (pattern: %s)", admin.Path, admin.Pattern), Color3.fromRGB(255, 200, 0))
    end
    
    SetStatus("[SCANNING] Phase 4/5: Analyzing currency systems...", Color3.fromRGB(255, 200, 0))
    Log(string.format("\n=== CURRENCY SYSTEMS FOUND: %d ===", #ScanResults.CurrencySystems), Color3.fromRGB(0, 255, 100))
    for _, cur in ipairs(ScanResults.CurrencySystems) do
        Log(string.format("  - %s (pattern: %s)", cur.Path, cur.Pattern), Color3.fromRGB(0, 255, 100))
    end
    
    SetStatus("[SCANNING] Phase 5/5: Running vulnerability analysis...", Color3.fromRGB(255, 200, 0))
    
    -- Run vulnerability analysis
    AnalyzeVulnerabilities()
    
    -- Generate exploit scripts
    local exploits = GenerateExploitScripts()
    
    -- Summary
    Log("\n========================================", Color3.fromRGB(0, 255, 100))
    Log("  SCAN COMPLETE", Color3.fromRGB(0, 255, 100))
    Log("========================================", Color3.fromRGB(0, 255, 100))
    Log(string.format("  Scripts (Server):   %d", #ScanResults.Scripts), Color3.fromRGB(0, 200, 255))
    Log(string.format("  LocalScripts:       %d", #ScanResults.LocalScripts), Color3.fromRGB(100, 255, 255))
    Log(string.format("  ModuleScripts:      %d", #ScanResults.Modules), Color3.fromRGB(200, 200, 200))
    Log(string.format("  RemoteEvents:       %d", #ScanResults.RemoteEvents), Color3.fromRGB(255, 150, 255))
    Log(string.format("  RemoteFunctions:    %d", #ScanResults.RemoteFunctions), Color3.fromRGB(255, 100, 255))
    Log(string.format("  AntiCheat Systems:  %d", #ScanResults.AntiCheats), Color3.fromRGB(255, 100, 0))
    Log(string.format("  Admin Systems:      %d", #ScanResults.AdminSystems), Color3.fromRGB(255, 200, 0))
    Log(string.format("  Currency Systems:   %d", #ScanResults.CurrencySystems), Color3.fromRGB(0, 255, 100))
    Log(string.format("  Backdoors Found:    %d", #ScanResults.Backdoors), Color3.fromRGB(255, 0, 0))
    Log(string.format("  Vulnerabilities:    %d", #ScanResults.Vulnerabilities), Color3.fromRGB(255, 50, 50))
    Log(string.format("  Exploit Vectors:    %d", #ScanResults.ExploitVectors), Color3.fromRGB(255, 0, 0))
    Log(string.format("  Exploit Scripts Gen:%d", #exploits), Color3.fromRGB(0, 255, 100))
    Log("========================================", Color3.fromRGB(0, 255, 100))
    
    SetStatus(string.format("[DONE] Scan complete! %d vulnerabilities, %d exploit vectors", #ScanResults.Vulnerabilities, #ScanResults.ExploitVectors), Color3.fromRGB(0, 255, 100))
end

-- Export function
local function ExportResults()
    local exportData = {
        GameInfo = {
            Name = game.Name,
            GameId = game.GameId,
            CreatorId = game.CreatorId,
            PlaceId = game.PlaceId,
            ScanDate = os.date("%Y-%m-%d %H:%M:%S"),
            Scanner = "Roblox Security Auditor v3.0",
        },
        Summary = {
            Scripts = #ScanResults.Scripts,
            LocalScripts = #ScanResults.LocalScripts,
            Modules = #ScanResults.Modules,
            RemoteEvents = #ScanResults.RemoteEvents,
            RemoteFunctions = #ScanResults.RemoteFunctions,
            AntiCheats = #ScanResults.AntiCheats,
            AdminSystems = #ScanResults.AdminSystems,
            CurrencySystems = #ScanResults.CurrencySystems,
            Backdoors = #ScanResults.Backdoors,
            Vulnerabilities = #ScanResults.Vulnerabilities,
            ExploitVectors = #ScanResults.ExploitVectors,
        },
        Scripts = ScanResults.Scripts,
        LocalScripts = ScanResults.LocalScripts,
        Modules = ScanResults.Modules,
        RemoteEvents = ScanResults.RemoteEvents,
        RemoteFunctions = ScanResults.RemoteFunctions,
        AntiCheats = ScanResults.AntiCheats,
        AdminSystems = ScanResults.AdminSystems,
        CurrencySystems = ScanResults.CurrencySystems,
        Backdoors = ScanResults.Backdoors,
        Vulnerabilities = ScanResults.Vulnerabilities,
        ExploitVectors = ScanResults.ExploitVectors,
    }
    
    -- Try to write to file
    local success, result = pcall(function()
        local http = game:GetService("HttpService")
        local json = http:JSONEncode(exportData)
        writefile(string.format("SecurityAudit_%s_%s.json", game.GameId, os.date("%Y%m%d_%H%M%S")), json)
        return true
    end)
    
    if success then
        Log("[EXPORT] Results exported to JSON file", Color3.fromRGB(0, 200, 100))
    else
        -- Fallback: copy to clipboard
        setclipboard(tostring(exportData))
        Log("[EXPORT] File write failed - copied to clipboard", Color3.fromRGB(255, 200, 0))
    end
    
    -- Also export all script sources individually
    local allScripts = {}
    for _, s in ipairs(ScanResults.Scripts) do
        table.insert(allScripts, string.format("--[[ %s ]]--\n%s", s.Path, s.Source))
    end
    for _, s in ipairs(ScanResults.LocalScripts) do
        table.insert(allScripts, string.format("--[[ %s ]]--\n%s", s.Path, s.Source))
    end
    for _, s in ipairs(ScanResults.Modules) do
        table.insert(allScripts, string.format("--[[ %s ]]--\n%s", s.Path, s.Source))
    end
    
    local combined = table.concat(allScripts, "\n\n---\n\n")
    pcall(function()
        writefile(string.format("AllScripts_%s.lua", os.date("%Y%m%d_%H%M%S")), combined)
    end)
end

-- Connect buttons
ScanButton.MouseButton1Click:Connect(StartScan)
ExportBtn.MouseButton1Click:Connect(ExportResults)

-- Initialize GUI
BuildGUI()
Log("Roblox Security Auditor v3.0 loaded successfully", Color3.fromRGB(0, 255, 100))
Log("Authorized penetration testing tool", Color3.fromRGB(100, 255, 100))
Log("Click 'START SCAN' to begin audit", Color3.fromRGB(200, 200, 200))
