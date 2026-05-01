--[[
  Roblox Security Auditor v3.1
  Authorized Pentest Tool
]]

-- Delay to ensure everything loaded
task.wait(1)

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

-- Safety check
if not LocalPlayer then
    warn("LocalPlayer not found, waiting...")
    LocalPlayer = Players.LocalPlayer or Players:WaitForChild("LocalPlayer", 5)
    Mouse = LocalPlayer and LocalPlayer:GetMouse()
end

-- Storage for results
local ScanData = {
    Scripts = {},
    LocalScripts = {},
    ModuleScripts = {},
    RemoteEvents = {},
    RemoteFunctions = {},
    AntiCheats = {},
    AdminSystems = {},
    CurrencySystems = {},
    Backdoors = {},
    Vulnerabilities = {},
    ExploitVectors = {},
    AllScriptSources = {},
}

-- Patterns
local Patterns = {
    AntiCheat = {
        "anticheat", "anti_cheat", "ac_", "cheatdetect", "exploitdetect",
        "hunk", "kickplayer", "banplayer", "remotesecurity", "validation",
        "ratelimit", "callfire", "checkcaller", "securitycheck",
        "sanitycheck", "antituck", "antispeed", "antifly", "antitp",
        "detectexploit", "servercheck", "dutycheck", "sanitycheck",
        "logremote", "remotelog", "remotespy",
    },
    Admin = {
        "admin", "hdadmin", "kohlsadmin", "admincmd", "admincommand",
        "cmds", "cmdsy", "adminpanel", "adminmenu", "adminsystem",
        "commandsystem", "cmdhandler", "cmdexecute", "admins",
        "cmdcenter", "admincmds",
    },
    Currency = {
        "currency", "money", "coins", "gems", "gold", "cash",
        "balance", "leaderstats", "stats", "economy", "wallet",
        "bank", "points", "score", "credits", "tokens", "crystals",
        "stars", "tickets", "vouchers", "premium", "vip",
        "reward", "multiplier", "boost",
        "addcurrency", "setmoney", "givecoins", "removecurrency",
        "updatestats", "buy", "purchase", "unlock", "grant",
    },
    Backdoor = {
                "loadstring", "httpget", "httppost", "getasync", "postasync",
        "pastebin", "discord", "webhook", "require(",
        "cloneref", "checkcaller", "hookmetamethod", "getrawmetatable",
        "setrawmetatable", "getnamecallmethod", "fireserver",
        "firefunction",
    },
    Suspicious = {
        "debug.", "getfenv", "setfenv", "newcclosure", "syn",
        "protosmasher", "krnl", "scriptware", "electron",
    },
}

-- Build GUI
local function CreateGUI()
    local success, err = pcall(function()
        -- Main ScreenGui
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "SecurityAuditor"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = CoreGui
        
        -- Main Frame
        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Parent = ScreenGui
        MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        MainFrame.BorderSizePixel = 0
        MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
        MainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.ClipsDescendants = true
        
        -- Title Bar
        local TitleBar = Instance.new("Frame")
        TitleBar.Name = "TitleBar"
        TitleBar.Parent = MainFrame
        TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        TitleBar.BorderSizePixel = 0
        TitleBar.Size = UDim2.new(1, 0, 0, 35)
        
        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.Parent = TitleBar
        Title.BackgroundTransparency = 1
        Title.Size = UDim2.new(1, -40, 1, 0)
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.Font = Enum.Font.Code
        Title.Text = "Roblox Security Auditor v3.1"
        Title.TextColor3 = Color3.fromRGB(0, 255, 100)
        Title.TextSize = 16
        Title.TextXAlignment = Enum.TextXAlignment.Left
        
        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Name = "CloseBtn"
        CloseBtn.Parent = TitleBar
        CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
        CloseBtn.BorderSizePixel = 0
        CloseBtn.Size = UDim2.new(0, 30, 0, 30)
        CloseBtn.Position = UDim2.new(1, -35, 0, 2)
        CloseBtn.Font = Enum.Font.Code
        CloseBtn.Text = "X"
        CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseBtn.TextSize = 14
        CloseBtn.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)
        
        -- Control Bar
        local ControlBar = Instance.new("Frame")
        ControlBar.Name = "ControlBar"
        ControlBar.Parent = MainFrame
        ControlBar.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
        ControlBar.BorderSizePixel = 0
        ControlBar.Position = UDim2.new(0, 0, 0, 35)
        ControlBar.Size = UDim2.new(1, 0, 0, 40)
        
        local ScanBtn = Instance.new("TextButton")
        ScanBtn.Name = "ScanBtn"
        ScanBtn.Parent = ControlBar
        ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 50)
        ScanBtn.BorderSizePixel = 0
        ScanBtn.Position = UDim2.new(0, 10, 0, 5)
        ScanBtn.Size = UDim2.new(0, 120, 0, 30)
        ScanBtn.Font = Enum.Font.Code
        ScanBtn.Text = "START SCAN"
        ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ScanBtn.TextSize = 13
        
        local ExportBtn = Instance.new("TextButton")
        ExportBtn.Name = "ExportBtn"
        ExportBtn.Parent = ControlBar
        ExportBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 180)
        ExportBtn.BorderSizePixel = 0
        ExportBtn.Position = UDim2.new(0, 140, 0, 5)
        ExportBtn.Size = UDim2.new(0, 100, 0, 30)
        ExportBtn.Font = Enum.Font.Code
        ExportBtn.Text = "EXPORT"
        ExportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ExportBtn.TextSize = 13
        
        -- Status Bar
        local StatusBar = Instance.new("Frame")
        StatusBar.Name = "StatusBar"
        StatusBar.Parent = MainFrame
        StatusBar.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
        StatusBar.BorderSizePixel = 0
        StatusBar.Position = UDim2.new(0, 0, 0, 75)
        StatusBar.Size = UDim2.new(1, 0, 0, 25)
        
        local StatusLabel = Instance.new("TextLabel")
        StatusLabel.Name = "StatusLabel"
        StatusLabel.Parent = StatusBar
        StatusLabel.BackgroundTransparency = 1
        StatusLabel.Size = UDim2.new(1, -20, 1, 0)
        StatusLabel.Position = UDim2.new(0, 10, 0, 0)
        StatusLabel.Font = Enum.Font.Code
        StatusLabel.Text = "Ready. Click START SCAN to begin."
        StatusLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
        StatusLabel.TextSize = 13
        StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Log Box
        local LogFrame = Instance.new("ScrollingFrame")
        LogFrame.Name = "LogFrame"
        LogFrame.Parent = MainFrame
        LogFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
        LogFrame.BorderSizePixel = 0
        LogFrame.Position = UDim2.new(0, 0, 0, 100)
        LogFrame.Size = UDim2.new(1, 0, 1, -100)
        LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        LogFrame.ScrollBarThickness = 6
        LogFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
        
        local LogText = Instance.new("TextLabel")
        LogText.Name = "LogText"
        LogText.Parent = LogFrame
        LogText.BackgroundTransparency = 1
        LogText.Size = UDim2.new(1, -10, 0, 0)
        LogText.Position = UDim2.new(0, 5, 0, 5)
        LogText.Font = Enum.Font.Code
        LogText.Text = ""
        LogText.TextColor3 = Color3.fromRGB(180, 180, 180)
        LogText.TextSize = 12
        LogText.TextXAlignment = Enum.TextXAlignment.Left
        LogText.TextYAlignment = Enum.TextYAlignment.Top
        LogText.RichText = true
        
        return ScreenGui, MainFrame, LogFrame, LogText, StatusLabel, ScanBtn, ExportBtn
    end)
    
    if not success then
        warn("Failed to create GUI:", err)
        return nil
    end
    
    return success
end

-- Log function
local LogTextRef = nil
local LogFrameRef = nil
local StatusRef = nil

local function Log(msg, color)
    color = color or Color3.fromRGB(180, 180, 180)
    if not LogTextRef then return end
    
    local r = math.floor(color.R * 255)
    local g = math.floor(color.G * 255)
    local b = math.floor(color.B * 255)
    local timestamp = os.date("%H:%M:%S")
    
    local success, err = pcall(function()
        LogTextRef.Text = LogTextRef.Text .. string.format(
            '<font color="rgb(%d,%d,%d)">[%s]</font> %s\n',
            r, g, b, timestamp, tostring(msg)
        )
        
        local textBounds = LogTextRef.TextBounds
        LogFrameRef.CanvasSize = UDim2.new(0, 0, 0, textBounds.Y + 20)
        LogFrameRef.CanvasPosition = Vector2.new(0, textBounds.Y)
    end)
end

local function SetStatus(msg)
    if StatusRef then
        StatusRef.Text = msg
    end
end

-- Deep scanner
local function ScanInstance(instance, depth)
    depth = depth or 0
    if depth > 60 then return end
    
    local ok, err = pcall(function()
        local class = instance.ClassName
        local path = ""
        
        ok2, err2 = pcall(function()
            path = instance:GetFullName()
        end)
        if not ok2 then path = instance.Name end
        
        if class == "Script" then
            local src = instance.Source or ""
            local data = {
                Name = instance.Name,
                Path = path,
                Source = src,
                Length = #src,
                Enabled = instance.Enabled,
            }
            table.insert(ScanData.Scripts, data)
            table.insert(ScanData.AllScriptSources, {Name = instance.Name, Path = path, Source = src, Class = "Script"})
            Log(string.format("SCRIPT: %s (%d bytes)", path, #src), Color3.fromRGB(0, 200, 255))
            
            -- Analyze
            local srcL = src:lower()
            
            -- AntiCheat
            for _, pat in ipairs(Patterns.AntiCheat) do
                if srcL:find(pat, 1, true) then
                    table.insert(ScanData.AntiCheats, {Name = instance.Name, Path = path, Pattern = pat, Source = src})
                    Log(string.format("[ANTICHEAT] %s -> %s", path, pat), Color3.fromRGB(255, 150, 0))
                    break
                end
            end
            
            -- Admin
            for _, pat in ipairs(Patterns.Admin) do
                if srcL:find(pat, 1, true) then
                    table.insert(ScanData.AdminSystems, {Name = instance.Name, Path = path, Pattern = pat, Source = src})
                    Log(string.format("[ADMIN] %s -> %s", path, pat), Color3.fromRGB(255, 200, 0))
                    break
                end
            end
            
            -- Currency
            for _, pat in ipairs(Patterns.Currency) do
                if srcL:find(pat, 1, true) then
                    table.insert(ScanData.CurrencySystems, {Name = instance.Name, Path = path, Pattern = pat, Source = src})
                    Log(string.format("[CURRENCY] %s -> %s", path, pat), Color3.fromRGB(0, 255, 100))
                    break
                end
            end
            
            -- Backdoors
            for _, pat in ipairs(Patterns.Backdoor) do
                if srcL:find(pat, 1, true) then
                    table.insert(ScanData.Backdoors, {Name = instance.Name, Path = path, Pattern = pat, Source = src})
                    Log(string.format("[! BACKDOOR] %s -> %s", path, pat), Color3.fromRGB(255, 50, 50))
                    break
                end
            end
            
            -- Vulnerabilities
            local vulns = {}
            if srcL:find("fireserver", 1, true) and not srcL:find("validat", 1, true) then
                table.insert(vulns, {Type = "Unvalidated FireServer", Severity = "HIGH"})
            end
            if srcL:find("loadstring", 1, true) then
                table.insert(vulns, {Type = "loadstring() usage", Severity = "CRITICAL"})
            end
            if srcL:find("httpget", 1, true) or srcL:find("httppost", 1, true) then
                table.insert(vulns, {Type = "External HTTP request", Severity = "HIGH"})
            end
            if srcL:find("debug%.", 1, true) then
                table.insert(vulns, {Type = "Debug library access", Severity = "MEDIUM"})
            end
            if srcL:find("getrawmetatable", 1, true) or srcL:find("setrawmetatable", 1, true) then
                table.insert(vulns, {Type = "Metatable manipulation", Severity = "CRITICAL"})
            end
            if srcL:find("hookmetamethod", 1, true) then
                table.insert(vulns, {Type = "Metamethod hooking", Severity = "CRITICAL"})
            end
            if srcL:find("checkcaller", 1, true) then
                table.insert(vulns, {Type = "Caller check bypass", Severity = "CRITICAL"})
            end
            if srcL:find("cloneref", 1, true) then
                table.insert(vulns, {Type = "Anti-detection (CloneRef)", Severity = "HIGH"})
            end
            
            if #vulns > 0 then
                table.insert(ScanData.Vulnerabilities, {Script = instance.Name, Path = path, Vulns = vulns})
                for _, v in ipairs(vulns) do
                    local sevColor = v.Severity == "CRITICAL" and Color3.fromRGB(255, 0, 0)
                        or v.Severity == "HIGH" and Color3.fromRGB(255, 100, 0)
                        or Color3.fromRGB(255, 200, 0)
                    Log(string.format("[VULN][%s] %s in %s", v.Severity, v.Type, instance.Name), sevColor)
                end
            end
            
        elseif class == "LocalScript" then
            local src = instance.Source or ""
            local data = {
                Name = instance.Name,
                Path = path,
                Source = src,
                Length = #src,
                Enabled = instance.Enabled,
            }
            table.insert(ScanData.LocalScripts, data)
            table.insert(ScanData.AllScriptSources, {Name = instance.Name, Path = path, Source = src, Class = "LocalScript"})
            Log(string.format("LOCALSCRIPT: %s (%d bytes)", path, #src), Color3.fromRGB(100, 255, 255))
            
            -- Same analysis for LocalScripts
            local srcL = src:lower()
            for _, pat in ipairs(Patterns.AntiCheat) do
                if srcL:find(pat, 1, true) then
                    table.insert(ScanData.AntiCheats, {Name = instance.Name, Path = path, Pattern = pat, Source = src})
                    Log(string.format("[ANTICHEAT] %s -> %s", path, pat), Color3.fromRGB(255, 150, 0))
                    break
                end
            end
            for _, pat in ipairs(Patterns.Currency) do
                if srcL:find(pat, 1, true) then
                    table.insert(ScanData.CurrencySystems, {Name = instance.Name, Path = path, Pattern = pat, Source = src})
                    Log(string.format("[CURRENCY] %s -> %s", path, pat), Color3.fromRGB(0, 255, 100))
                    break
                end
            end
            for _, pat in ipairs(Patterns.Admin) do
                if srcL:find(pat, 1, true) then
                    table.insert(ScanData.AdminSystems, {Name = instance.Name, Path = path, Pattern = pat, Source = src})
                    Log(string.format("[ADMIN] %s -> %s", path, pat), Color3.fromRGB(255, 200, 0))
                    break
                end
            end
            
            -- Vulnerabilities in LocalScripts
            local vulns = {}
            if srcL:find("fireserver", 1, true) then
                if not srcL:find("validat", 1, true) then
                    table.insert(vulns, {Type = "Unvalidated FireServer", Severity = "HIGH"})
                end
                table.insert(vulns, {Type = "Client FireServer call - exploitable", Severity = "MEDIUM"})
            end
            
            if #vulns > 0 then
                table.insert(ScanData.Vulnerabilities, {Script = instance.Name, Path = path, Vulns = vulns})
            end
            
        elseif class == "ModuleScript" then
            local src = instance.Source or ""
            local data = {
                Name = instance.Name,
                Path = path,
                Source = src,
                Length = #src,
            }
            table.insert(ScanData.ModuleScripts, data)
            table.insert(ScanData.AllScriptSources, {Name = instance.Name, Path = path, Source = src, Class = "ModuleScript"})
            
        elseif class == "RemoteEvent" then
            table.insert(ScanData.RemoteEvents, {
                Name = instance.Name,
                Path = path,
                Parent = instance.Parent and instance.Parent.Name or "None",
            })
            Log(string.format("REMOTE: %s -> %s", path, instance.Name), Color3.fromRGB(200, 100, 255))
            
            -- Check if exploitable by name
            local nameL = instance.Name:lower()
            if nameL:find("currency", 1, true) or nameL:find("money", 1, true) or nameL:find("coin", 1, true)
                or nameL:find("give", 1, true) or nameL:find("add", 1, true) or nameL:find("set", 1, true)
                or nameL:find("admin", 1, true) or nameL:find("cmd", 1, true) or nameL:find("buy", 1, true)
                or nameL:find("grant", 1, true) or nameL:find("reward", 1, true) or nameL:find("unlock", 1, true)
                or nameL:find("kick", 1, true) or nameL:find("ban", 1, true) or nameL:find("teleport", 1, true)
                or nameL:find("spawn", 1, true) then
                
                table.insert(ScanData.ExploitVectors, {
                    Name = instance.Name,
                    Path = path,
                    Type = "RemoteEvent",
                    Risk = "HIGH",
                    Reason = "Name suggests privileged operation",
                    Exploit = "FireServer with crafted args",
                })
                Log(string.format("[! HIGH VALUE] %s (%s)", path, instance.Name), Color3.fromRGB(255, 0, 0))
            end
            
        elseif class == "RemoteFunction" then
            table.insert(ScanData.RemoteFunctions, {
                Name = instance.Name,
                Path = path,
                Parent = instance.Parent and instance.Parent.Name or "None",
            })
            Log(string.format("REMOTE FUNC: %s -> %s", path, instance.Name), Color3.fromRGB(200, 50, 255))
            
            local nameL = instance.Name:lower()
            if nameL:find("currency", 1, true) or nameL:find("money", 1, true) or nameL:find("coin", 1, true)
                or nameL:find("give", 1, true) or nameL:find("add", 1, true) or nameL:find("set", 1, true)
                or nameL:find("admin", 1, true) or nameL:find("cmd", 1, true) or nameL:find("buy", 1, true)
                or nameL:find("kick", 1, true) or nameL:find("ban", 1, true) then
                
                table.insert(ScanData.ExploitVectors, {
                    Name = instance.Name,
                    Path = path,
                    Type = "RemoteFunction",
                    Risk = "HIGH",
                    Reason = "Name suggests privileged operation",
                    Exploit = "InvokeServer with crafted args",
                })
                Log(string.format("[! HIGH VALUE] %s (%s)", path, instance.Name), Color3.fromRGB(255, 0, 0))
            end
        end
        
        -- Recurse children
        local children = instance:GetChildren()
        for _, child in ipairs(children) do
            task.wait() -- Yield to prevent timeout
            ScanInstance(child, depth + 1)
        end
    end)
    
    if not ok then
        local okName, _ = pcall(function() return instance.Name end)
        Log(string.format("Error scanning %s: %s", okName and instance.Name or "Unknown", tostring(err)), Color3.fromRGB(255, 50, 50))
    end
end

-- Main scan orchestration
local function StartScan()
    -- Reset data
    ScanData = {
        Scripts = {}, LocalScripts = {}, ModuleScripts = {},
        RemoteEvents = {}, RemoteFunctions = {},
        AntiCheats = {}, AdminSystems = {}, CurrencySystems = {},
        Backdoors = {}, Vulnerabilities = {}, ExploitVectors = {},
        AllScriptSources = {},
    }
    
    LogTextRef.Text = ""
    
    Log("========================================", Color3.fromRGB(0, 255, 100))
    Log("  Roblox Security Auditor v3.1", Color3.fromRGB(0, 255, 100))
    Log(string.format("  Game: %s (ID: %s)", game.Name, tostring(game.GameId)), Color3.fromRGB(0, 255, 100))
    Log(string.format("  Player: %s", LocalPlayer and LocalPlayer.Name or "Unknown"), Color3.fromRGB(0, 255, 100))
    Log("========================================", Color3.fromRGB(0, 255, 100))
    
    SetStatus("Phase 1/5: Scanning Workspace...")
    Log("\n--- Scanning Workspace ---", Color3.fromRGB(200, 200, 255))
    local ok, err = pcall(function()
        ScanInstance(game:GetService("Workspace"))
    end)
    task.wait()
    
    SetStatus("Phase 2/5: Scanning ReplicatedStorage...")
    Log("\n--- Scanning ReplicatedStorage ---", Color3.fromRGB(200, 200, 255))
    pcall(function()
        ScanInstance(game:GetService("ReplicatedStorage"))
    end)
    task.wait()
    
    SetStatus("Phase 3/5: Scanning services...")
    Log("\n--- Scanning Other Services ---", Color3.fromRGB(200, 200, 255))
    
    local services = {
        "ReplicatedFirst", "ServerScriptService", "ServerStorage",
        "StarterGui", "StarterPack", "Lighting",
    }
    
    for _, svc in ipairs(services) do
        local s, _ = pcall(function()
            return game:GetService(svc)
        end)
        if s then
            pcall(function()
                Log(string.format("Scanning %s...", svc), Color3.fromRGB(150, 150, 200))
                ScanInstance(game:GetService(svc))
                task.wait()
            end)
        else
            Log(string.format("Service %s not available", svc), Color3.fromRGB(200, 200, 0))
        end
    end
    
    -- Scan players
    SetStatus("Phase 4/5: Scanning Players...")
    Log("\n--- Scanning Players ---", Color3.fromRGB(200, 200, 255))
    pcall(function()
        for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
            pcall(function()
                ScanInstance(plr)
                task.wait()
            end)
        end
    end)
    
    -- Summary
    SetStatus("Phase 5/5: Generating report...")
    
    Log("\n========================================", Color3.fromRGB(0, 255, 100))
    Log("  SCAN COMPLETE - RESULTS", Color3.fromRGB(0, 255, 100))
    Log("========================================", Color3.fromRGB(0, 255, 100))
    Log(string.format("  Scripts (Server):   %d", #ScanData.Scripts), Color3.fromRGB(0, 200, 255))
    Log(string.format("  LocalScripts:       %d", #ScanData.LocalScripts), Color3.fromRGB(100, 255, 255))
    Log(string.format("  ModuleScripts:      %d", #ScanData.ModuleScripts), Color3.fromRGB(180, 180, 180))
    Log(string.format("  RemoteEvents:       %d", #ScanData.RemoteEvents), Color3.fromRGB(200, 100, 255))
    Log(string.format("  RemoteFunctions:    %d", #ScanData.RemoteFunctions), Color3.fromRGB(200, 50, 255))
    Log(string.format("  AntiCheat Systems:  %d", #ScanData.AntiCheats), Color3.fromRGB(255, 150, 0))
    Log(string.format("  Admin Systems:      %d", #ScanData.AdminSystems), Color3.fromRGB(255, 200, 0))
    Log(string.format("  Currency Systems:   %d", #ScanData.CurrencySystems), Color3.fromRGB(0, 255, 100))
    Log(string.format("  Backdoors Found:    %d", #ScanData.Backdoors), Color3.fromRGB(255, 50, 50))
    Log(string.format("  Vulnerabilities:    %d", #ScanData.Vulnerabilities), Color3.fromRGB(255, 100, 0))
    Log(string.format("  Exploit Vectors:    %d", #ScanData.ExploitVectors), Color3.fromRGB(255, 0, 0))
    Log("========================================", Color3.fromRGB(0, 255, 100))
    
    SetStatus(string.format("Scan complete! %d vulnerabilities, %d exploit vectors found. Click EXPORT to save.",
        #ScanData.Vulnerabilities, #ScanData.ExploitVectors))
    
    -- Generate exploit scripts
    Log("\n--- Available Exploit Commands ---", Color3.fromRGB(0, 255, 100))
    
    if #ScanData.RemoteEvents > 0 then
        Log("FIRE ALL REMOTES (try currency/admin exploits):", Color3.fromRGB(0, 255, 200))
        Log([[for _,v in pairs(game:GetDescendants()) do if v:IsA("RemoteEvent") then v:FireServer(999999) end end]], Color3.fromRGB(200, 200, 200))
        Log("", Color3.fromRGB(200, 200, 200))
    end
    
    if #ScanData.ExploitVectors > 0 then
        Log("HIGH VALUE REMOTES (manual try):", Color3.fromRGB(255, 200, 0))
        for _, ev in ipairs(ScanData.ExploitVectors) do
            Log(string.format("  %s (%s) - %s", ev.Name, ev.Type, ev.Exploit), Color3.fromRGB(255, 200, 0))
        end
    end
end

-- Export
local function ExportResults()
    SetStatus("Exporting results...")
    
    local exportData = {
        Game = {
            Name = game.Name,
            GameId = game.GameId,
            PlaceId = game.PlaceId,
            CreatorId = game.CreatorId,
            ScanDate = os.date("%Y-%m-%d %H:%M:%S"),
        },
        Summary = {
            Scripts = #ScanData.Scripts,
            LocalScripts = #ScanData.LocalScripts,
            ModuleScripts = #ScanData.ModuleScripts,
            RemoteEvents = #ScanData.RemoteEvents,
            RemoteFunctions = #ScanData.RemoteFunctions,
            AntiCheats = #ScanData.AntiCheats,
            AdminSystems = #ScanData.AdminSystems,
            CurrencySystems = #ScanData.CurrencySystems,
            Backdoors = #ScanData.Backdoors,
            Vulnerabilities = #ScanData.Vulnerabilities,
            ExploitVectors = #ScanData.ExploitVectors,
        },
        AntiCheatSystems = ScanData.AntiCheats,
        AdminSystems = ScanData.AdminSystems,
        CurrencySystems = ScanData.CurrencySystems,
        Backdoors = ScanData.Backdoors,
        Vulnerabilities = ScanData.Vulnerabilities,
        ExploitVectors = ScanData.ExploitVectors,
        RemoteEvents = ScanData.RemoteEvents,
        RemoteFunctions = ScanData.RemoteFunctions,
    }
    
    -- Try file save
    local ok = pcall(function()
        local json = HttpService:JSONEncode(exportData)
        writefile(string.format("Audit_%s_%s.json", tostring(game.GameId), os.date("%Y%m%d_%H%M%S")), json)
        Log("[EXPORT] JSON report saved!", Color3.fromRGB(0, 200, 100))
    end)
    
    if not ok then
        pcall(function()
            setclipboard(tostring(exportData))
            Log("[EXPORT] Copied to clipboard (file write failed)", Color3.fromRGB(255, 200, 0))
        end)
    end
    
    -- Export all script sources
    local allCode = ""
    for _, s in ipairs(ScanData.AllScriptSources) do
        allCode = allCode .. string.format("--[[ %s (%s) ]]\n%s\n\n---\n\n", s.Path, s.Class, s.Source)
    end
    
    if #allCode > 0 then
        pcall(function()
            writefile(string.format("AllScripts_%s.lua", os.date("%Y%m%d_%H%M%S")), allCode)
            Log(string.format("[EXPORT] All scripts saved! (%d bytes)", #allCode), Color3.fromRGB(0, 200, 100))
        end)
    end
    
    SetStatus("Export complete!")
end

-- Initialize
local gui, frame, logFrame, logText, status, scanBtn, exportBtn = CreateGUI()

if gui then
    LogTextRef = logText
    LogFrameRef = logFrame
    StatusRef = status
    
    Log("Security Auditor v3.1 loaded successfully!", Color3.fromRGB(0, 255, 100))
    Log("Authorized pentest tool for Roblox games", Color3.fromRGB(100, 255, 100))
    Log("Click START SCAN to begin audit", Color3.fromRGB(180, 180, 180))
    
    scanBtn.MouseButton1Click:Connect(StartScan)
    exportBtn.MouseButton1Click:Connect(ExportResults)
else
    warn("GUI creation failed - check if CoreGui is accessible")
end
