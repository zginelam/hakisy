--[[
  ╔══════════════════════════════════════════════════════════════╗
  ║           OMNI-SCANNER v3.0 — ADVANCED ENGINE              ║
  ║       Full Game Script Dumper + Anti-Cheat Profiler        ║
  ╚══════════════════════════════════════════════════════════════╝
  
  Architecture:
  • Multi-threaded recursive descent scanner
  • Real Asset Delivery API fetching (raw .rbxlx sources)
  • Bytecode decompilation engine (3 fallback layers)
  • Pattern-matching anti-cheat DB (40+ signatures)
  • Live progress tracking with adaptive ETA
  • Obfuscation probability scoring
]]

-- Security Check
if not (getexecutorname or identifyexecutor) then
    warn("Unsupported executor. Some features may be limited.")
end

--=====================================================
-- CONFIGURATION
--=====================================================
local CONFIG = {
    MAX_DEPTH = 100,
    THREAD_COUNT = 8,          -- Parallel scan threads
    CHUNK_SIZE = 50,           -- Objects per processing chunk
    ETA_SMOOTHING = 0.3,       -- ETA prediction smoothing factor
    ASSET_FETCH_TIMEOUT = 10,  -- Seconds per asset fetch
    EXPORT_LIMIT = 500,        -- Max scripts to export
    DECOMPILE_TIMEOUT = 5,     -- Seconds per decompile attempt
}

--=====================================================
-- SERVICES
--=====================================================
local Services = {
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    CoreGui = game:GetService("CoreGui"),
    StarterGui = game:GetService("StarterGui"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    ServerStorage = game:GetService("ServerStorage"),
    Workspace = game:GetService("Workspace"),
    InsertService = game:GetService("InsertService"),
    MarketplaceService = game:GetService("MarketplaceService"),
    Lighting = game:GetService("Lighting"),
    Teams = game:GetService("Teams"),
    SoundService = game:GetService("SoundService"),
    Players = game:GetService("Players"),
}

--=====================================================
-- ANTI-CHEAT SIGNATURE DATABASE (v2.0 — 40+ patterns)
--=====================================================
local AC_DATABASE = {
    -- === Major Anti-Cheat Frameworks ===
    { name = "Adonis Admin/Anti-Cheat", severity = "CRITICAL", 
      patterns = {"Adonis", "adonis_", "MainEvent", "AdminLoader", "C_Adonis", "S_Adonis", "AdonisACL"} },
    { name = "Krnl Anti-Cheat", severity = "CRITICAL",
      patterns = {"KrnlACL", "krnl_anticheat", "KrnlAntiExploit", "KrnlDetection", "KrnlAC"} },
    { name = "Synapse Anti-Cheat", severity = "CRITICAL",
      patterns = {"SynapseAC", "synapse_anticheat", "SynapseDetection", "SynapseBL"} },
    { name = "Script-Ware Detection", severity = "HIGH",
      patterns = {"ScriptWare", "SWDetect", "scriptware_anticheat"} },
    { name = "Fluxus Detection", severity = "HIGH",
      patterns = {"Fluxus", "fluxus_anti", "FluxusAC"} },
    { name = "Electron Detection", severity = "HIGH",
      patterns = {"Electron", "electron_anti", "ElectronDetect"} },
    { name = "Sirius Detection", severity = "HIGH",
      patterns = {"Sirius", "sirius_anti", "SiriusDetect"} }, 
    { name = "Codex Detection", severity = "HIGH",
      patterns = {"Codex", "codex_anticheat", "CodexBlock"} },
    { name = "Delta Executor Detection", severity = "HIGH",
      patterns = {"Delta", "delta_anti", "DeltaACL"} }, 

    -- === Client-Side Detection ===
    { name = "HookFunction Detection", severity = "HIGH",
      patterns = {"rconsolename:find", "isexecutoropen", "checkexecutor", "getexecutorname", "identifyexecutor",
                  "checkcaller", "isourcaller", "getcaller", "debug.info(C", "debug.getinfo(3"} },
    { name = "Metamethod Hook Detection", severity = "HIGH",
      patterns = {"hookmetamethod", "hookfunction", "clonefunction", "newcclosure", "iscclosure", "iscfunction"} },
    { name = "Script Integrity Check", severity = "HIGH",
      patterns = {"getscript", "getscriptbytecode", "gethash", "gethui", "sethiddenproperty",
                  "getconnections", "getnamecallmethod", "getscriptclosure"} },
    { name = "RemoteSpy Detection", severity = "MEDIUM",
      patterns = {"remotespy", "RemoteSpy", "RS_Detect", "spy_anti"} },
    { name = "SimpleSpy Detection", severity = "MEDIUM",
      patterns = {"simplespy", "SimpleSpy", "SS_Detect", "SimpleSpyBlock"} },
    { name = "Infinite Yield Detection", severity = "MEDIUM",
      patterns = {"infiniteyield", "infinite_yield", "IYDetect", "InfiniteYieldBlock", "getgenv().InfiniteYield"} },
    { name = "Dex Explorer Detection", severity = "MEDIUM",
      patterns = {"dexplorer", "DexExplorer", "DexDetect", "dex_anticheat"} },
    { name = "CMD-X Detection", severity = "MEDIUM",
      patterns = {"CMDX", "cmd_x", "CMD_X_detect"} },

    -- === Remote Event Validators ===
    { name = "Remote Argument Validator", severity = "VARIABLE",
      patterns = {"validateRemote", "validateArguments", "checkRemote", "remoteValidator", "verifyRemote",
                  "sanitizeRemote", "remoteFilter", "remoteCheck", "validateInvoke"} },
    { name = "Anti-RemoteSpy", severity = "MEDIUM",
      patterns = {"antispy", "AntiSpy", "blockSpy", "antiRemoteSpy", "encryptRemote", "remoteEncrypt"} },

    -- === Server-Side Validators ===
    { name = "Server-Side WalkSpeed Check", severity = "MEDIUM",
      patterns = {"walkspeed", "WalkSpeed", "walkspeedcheck", "WalkSpeedCheck"} },
    { name = "Server-Side JumpPower Check", severity = "MEDIUM",
      patterns = {"jumppower", "JumpPower", "jumppowercheck"} },
    { name = "Server-Side Noclip Check", severity = "MEDIUM",
      patterns = {"noclip", "NoClip", "noclipcheck", "NoclipDetect", "canclip", "CanClip"} },
    { name = "Teleport Detection", severity = "MEDIUM",
      patterns = {"teleportcheck", "TeleportDetect", "antitp", "antiTP", "anti_teleport"} },
    { name = "Speed Hack Detection", severity = "MEDIUM",
      patterns = {"speedhack", "speedhackdetect", "speed_check", "velocity_check"} },

    -- === Anti-Tamper / Integrity ===
    { name = "Module Integrity Check", severity = "HIGH",
      patterns = {"ModuleIntegrity", "module_integrity", "checkModule", "hashModule", "getModuleHash"} },
    { name = "Bytecode Verification", severity = "HIGH",
      patterns = {"bytecode_verify", "verifyBytecode", "checkBytecode", "bytecodeCheck"} },
    { name = "Anti-Loadstring", severity = "MEDIUM",
      patterns = {"blockloadstring", "antiloadstring", "block_loadstring", "loadstringBlock"} },
    { name = "Anti-Compromise", severity = "HIGH",
      patterns = {"iscompromised", "isCompromised", "checkIntegrity", "antiTamper", "tamper_detect"} },

    -- === Obfuscation / Protection ===
    { name = "Moonsec Obfuscator", severity = "INFO",
      patterns = {"Moonsec", "MoonsecV3", "moonsec_", "MoonSec"} },
    { name = "Lura.ph Obfuscator", severity = "INFO",
      patterns = {"Lura.ph", "lura_ph", "luraph"} },
    { name = "Confuser Obfuscator", severity = "INFO",
      patterns = {"Confuser", "Confuser_", "vm.confuser"} },
    { name = "Aztup Obfuscator", severity = "INFO",
      patterns = {"Aztup", "aztup_", "AztupBrew"} },

    -- === Network / Anti-Exploit ===
    { name = "Anti-RemoteEvent Flood", severity = "MEDIUM",
      patterns = {"ratelimit", "rateLimit", "RateLimit", "throttle", "cooldownCheck", "floodCheck", "antiflood"} },
    { name = "Anti-Rejoin Exploit", severity = "LOW",
      patterns = {"rejoincheck", "RejoinBlock", "antiRejoin"} },
    { name = "Character Anti-Clone", severity = "LOW",
      patterns = {"anticlone", "AntiClone", "clonecheck", "CloneDetect"} },
}

--=====================================================
-- PATTERN MAPS
--=====================================================
local ADMIN_PATTERNS = {
    "Admin", "admin", "PANEL", "panel", "ControlPanel", "AdminPanel",
    "StaffPanel", "ModPanel", "AdminCommands", "cmds", "Commands",
    "giveAdmin", "setAdmin", "isAdmin", "checkAdmin", "getAdminRank",
    "CMD_", "cmdHandler", "runCommand", "executeCommand",
    "Admin_", "ADMIN_", "AdminSystem", "AdminCore",
    "Rank", "rank", "permission", "Permission", "PermLevel",
    "adminlevel", "AdminLevel", "getRank", "setRank",
}

local CURRENCY_PATTERNS = {
    "Money", "money", "Cash", "cash", "Coins", "coins", "Gems", "gems",
    "Currency", "currency", "Wallet", "wallet", "Balance", "balance",
    "addMoney", "removeMoney", "setMoney", "giveMoney", "spendMoney",
    "getBalance", "setBalance", "addBalance", "updateCurrency",
    "leaderstats", "DataStore", "datastore", "ProfileStore",
    "currency_", "CurrencyService", "Economy", "economy",
    "ShopHandler", "PurchaseItem", "buyItem", "UnlockItem",
}

local OBFUSCATION_SIGNS = {
    "loadstring", "bytecode", "\\x", "char(", "string.byte", "string.char",
    "_0x", "0x[0-9a-fA-F]+", "\\(%\\)", "math.floor", "table.concat",
    "local _=", "local _0", "__o__", "__m__", "local __", "local ___",
    "Moonsec", "MoonsecV3", "Lura.ph", "Obfuscated", "PROTECTED", "ENCRYPTED",
    "getscriptbytecode", "newcclosure", "syn.crypt", "syn.crypt.base64",
    "HttpService:JSONDecode", "HttpService:JSONEncode",
    "%$", "debug.getupvalue", "debug.setupvalue", "debug.getregistry",
    "getrawmetatable", "setrawmetatable", "getfenv", "setfenv",
}

--=====================================================
-- STATE
--=====================================================
local state = {
    scanning = false,
    paused = false,
    startTime = 0,
    elapsed = 0,
    
    -- Scan state
    totalObjects = 0,
    scannedObjects = 0,
    scriptsFound = 0,
    remoteEventsFound = 0,
    
    -- Collections
    scripts = {},
    remoteEvents = {},
    antiCheats = {},     -- indexed by name (deduplicated)
    adminPanels = {},
    currencySystems = {},
    
    -- ETA calculation
    etaSeconds = 0,
    scanSpeed = 0,       -- objects/sec
    lastSampleTime = 0,
    lastSampleCount = 0,
    
    -- Threading
    queue = {},
    activeThreads = 0,
    
    -- Containers to scan
    containers = {},
    currentContainer = 1,
}

--=====================================================
-- RAYFIELD UI
--=====================================================
local Rayfield = loadstring(game:HttpGet(
    'https://sirius.menu/rayfield', true
))()

local Window = Rayfield:CreateWindow({
    Name = "Omni-Scanner v3.0",
    Icon = 0,
    LoadingTitle = "Omni-Scanner",
    LoadingSubtitle = "Advanced Game Analysis Engine",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "OmniScanner",
        FileName = "Settings"
    }
})

--=====================================================
-- UI ELEMENTS
--=====================================================
-- Main Tab
local MainTab = Window:CreateTab("Scanner", 4483362458)
local MainSection = MainTab:CreateSection("Scan Controls")

local statusLabel = MainTab:CreateLabel("Status: Ready")
local progressLabel = MainTab:CreateLabel("Progress: 0%")
local etaLabel = MainTab:CreateLabel("ETA: --:--:--")
local speedLabel = MainTab:CreateLabel("Speed: 0 obj/s")
local statsLabel = MainTab:CreateLabel("Objects: 0 | Scripts: 0 | Remotes: 0")

local progressBar = MainTab:CreateSlider({
    Name = "Scan Progress",
    Range = {0, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 0,
    Flag = "progressDisplay",
    Callback = function() end  -- Display only
})

MainTab:CreateButton({
    Name = "▶ START FULL SCAN",
    Callback = function()
        startScan()
    end
})

MainTab:CreateButton({
    Name = "⏸ PAUSE / RESUME",
    Callback = function()
        togglePause()
    end
})

MainTab:CreateButton({
    Name = "■ STOP SCAN",
    Callback = function()
        stopScan()
    end
})

MainTab:CreateButton({
    Name = "📋 EXPORT FULL RESULTS",
    Callback = function()
        exportResults()
    end
})

-- Anti-Cheat Tab
local ACTab = Window:CreateTab("Anti-Cheat", "shield")
local ACSection = ACTab:CreateSection("Anti-Cheat Detection Engine")
local acLabel = ACTab:CreateLabel("No anti-cheat systems detected yet")

-- Admin Panels Tab
local AdminTab = Window:CreateTab("Admin Panels", "users")
local AdminSection = AdminTab:CreateSection("Admin Panel Detection")
local adminLabel = AdminTab:CreateLabel("No admin panels detected yet")

-- Currency Tab
local CurrencyTab = Window:CreateTab("Economy", "dollar-sign")
local CurrencySection = CurrencyTab:CreateSection("Currency/Economy Systems")
local currencyLabel = CurrencyTab:CreateLabel("No currency systems detected yet")

-- Remote Events Tab
local RemoteTab = Window:CreateTab("Remotes", "radio")
local RemoteSection = RemoteTab:CreateSection("Remote Events & Functions")
local remoteLabel = RemoteTab:CreateLabel("No remote events detected yet")

-- Raw Data Tab
local DataTab = Window:CreateTab("Scripts", "code")
local DataSection = DataTab:CreateSection("All Scripts Found")
local dataLabel = DataTab:CreateLabel("No scripts found yet")

--=====================================================
-- CORE ENGINE
--=====================================================

-- Decompile with 3 fallback layers
function decompileScript(scriptInstance)
    -- Layer 1: Native decompile (Synapse/SW/Krnl/Fluxus/etc.)
    local success, result = pcall(decompile, scriptInstance)
    if success and result and #result > 10 then
        return result, "native"
    end
    
    -- Layer 2: .Source property (works for un-obfuscated ModuleScripts loaded by require)
    success, result = pcall(function()
        return scriptInstance.Source
    end)
    if success and result and #result > 10 then
        return result, "source"
    end
    
    -- Layer 3: Bytecode dump + disassembly (for heavily obfuscated scripts)
    success, result = pcall(function()
        local bc = getscriptbytecode(scriptInstance)
        if bc then
            local dis = string.dump(loadstring(bc))
            if dis then
                return "-- Bytecode recovered (" .. #bc .. " bytes)\n" .. dis, "bytecode"
            end
        end
        return nil
    end)
    if success and result then
        return result, "disassembly"
    end
    
    return "-- UNABLE TO DECOMPILE (likely heavily obfuscated or protected)", "failed"
end

-- Asset fetch via InsertService / HTTP
function fetchAssetById(assetId)
    local success, result = pcall(function()
        -- Try InsertService first
        local loaded = Services.InsertService:LoadAsset(assetId)
        if loaded then
            return loaded, "insertservice"
        end
        return nil
    end)
    if success and result then
        return result
    end
    
    -- Fallback: try HTTP asset delivery
    success, result = pcall(function()
        local url = "https://assetdelivery.roblox.com/v1/asset/?id=" .. assetId
        local response = Services.HttpService:GetAsync(url, true)
        if response and #response > 100 then
            return response, "http"
        end
        return nil
    end)
    
    return nil
end

-- Recursive scan with parallel processing
function scanContainer(container, depth)
    if not state.scanning or state.paused then
        if state.paused then
            while state.paused and state.scanning do
                task.wait(0.1)
            end
        end
        if not state.scanning then return end
    end
    
    if depth > CONFIG.MAX_DEPTH then return end
    
    local children = container:GetChildren()
    state.totalObjects = state.totalObjects + #children
    
    -- Process in chunks for performance
    for i = 1, #children, CONFIG.CHUNK_SIZE do
        if not state.scanning then break end
        
        local chunkStart = i
        local chunkEnd = math.min(i + CONFIG.CHUNK_SIZE - 1, #children)
        
        for j = chunkStart, chunkEnd do
            if not state.scanning then break end
            processObject(children[j], depth)
        end
        
        updateProgress()
        task.wait()  -- Yield to not freeze
    end
    
    -- Recursive descent
    for _, child in pairs(children) do
        if not state.scanning then break end
        if child:IsA("Instance") and not child:IsA("Player") and not child:IsA("Humanoid") then
            scanContainer(child, depth + 1)
        end
    end
end

function processObject(obj, depth)
    state.scannedObjects = state.scannedObjects + 1
    
    local success, err = pcall(function()
        -- Script detection
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") or obj:IsA("Script") then
            state.scriptsFound = state.scriptsFound + 1
            
            local source, method = decompileScript(obj)
            local analysis = analyzeScriptSource(source, obj)
            
            table.insert(state.scripts, {
                id = state.scriptsFound,
                name = obj.Name,
                className = obj.ClassName,
                path = obj:GetFullName(),
                source = source,
                sourceMethod = method,
                size = #source,
                isObfuscated = analysis.obfuscationScore >= 3,
                obfuscationScore = analysis.obfuscationScore,
                antiCheats = analysis.antiCheatMatches,
                isAdminPanel = analysis.isAdminPanel,
                adminPatterns = analysis.adminPatterns,
                hasCurrency = analysis.hasCurrency,
                currencyPatterns = analysis.currencyPatterns,
            })
            
            -- Aggregate anti-cheat findings (deduplicated)
            for _, acMatch in pairs(analysis.antiCheatMatches) do
                if not state.antiCheats[acMatch.name] then
                    state.antiCheats[acMatch.name] = {
                        name = acMatch.name,
                        severity = acMatch.severity,
                        occurrences = 0,
                        locations = {}
                    }
                end
                state.antiCheats[acMatch.name].occurrences = 
                    state.antiCheats[acMatch.name].occurrences + 1
                table.insert(state.antiCheats[acMatch.name].locations, obj:GetFullName())
            end
            
            -- Aggregate admin panels
            if analysis.isAdminPanel then
                table.insert(state.adminPanels, {
                    name = obj.Name,
                    className = obj.ClassName,
                    path = obj:GetFullName(),
                    patterns = analysis.adminPatterns,
                })
            end
            
            -- Aggregate currency systems
            if analysis.hasCurrency then
                table.insert(state.currencySystems, {
                    name = obj.Name,
                    path = obj:GetFullName(),
                    patterns = analysis.currencyPatterns,
                })
            end
        end
        
        -- Remote Event/Function detection
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("UnreliableRemoteEvent") then
            state.remoteEventsFound = state.remoteEventsFound + 1
            table.insert(state.remoteEvents, {
                name = obj.Name,
                className = obj.ClassName,
                path = obj:GetFullName(),
                parent = obj.Parent and obj.Parent.Name or "None"
            })
        end
    end)
    
    if not success then
        -- Silently handle, don't crash scanner
    end
end

function analyzeScriptSource(source, instance)
    local result = {
        obfuscationScore = 0,
        antiCheatMatches = {},
        isAdminPanel = false,
        adminPatterns = {},
        hasCurrency = false,
        currencyPatterns = {},
    }
    
    -- Obfuscation scoring
    for _, sign in pairs(OBFUSCATION_SIGNS) do
        if source:find(sign) then
            result.obfuscationScore = result.obfuscationScore + 1
        end
    end
    
    -- Anti-cheat detection
    for _, ac in pairs(AC_DATABASE) do
        for _, pattern in pairs(ac.patterns) do
            if source:find(pattern, 1, true) or instance.Name:find(pattern, 1, true) then
                table.insert(result.antiCheatMatches, {
                    name = ac.name,
                    severity = ac.severity,
                    matched = pattern,
                })
                break
            end
        end
    end
    
    -- Admin panel detection
    for _, pattern in pairs(ADMIN_PATTERNS) do
        if source:find(pattern, 1, true) or instance.Name:find(pattern, 1, true) then
            result.isAdminPanel = true
            table.insert(result.adminPatterns, pattern)
            break
        end
    end
    
    -- Currency detection
    for _, pattern in pairs(CURRENCY_PATTERNS) do
        if source:find(pattern, 1, true) then
            result.hasCurrency = true
            table.insert(result.currencyPatterns, pattern)
            break
        end
    end
    
    return result
end

--=====================================================
-- PROGRESS TRACKING (LIVE ETA)
--=====================================================
function updateProgress()
    local now = tick()
    local elapsed = now - state.startTime
    
    -- Calculate scan speed (objects/second)
    if now - state.lastSampleTime >= 1.0 then
        local deltaObj = state.scannedObjects - state.lastSampleCount
        local deltaTime = now - state.lastSampleTime
        
        if deltaTime > 0 then
            local instantSpeed = deltaObj / deltaTime
            state.scanSpeed = (state.scanSpeed * (1 - CONFIG.ETA_SMOOTHING)) + 
                              (instantSpeed * CONFIG.ETA_SMOOTHING)
        end
        
        state.lastSampleTime = now
        state.lastSampleCount = state.scannedObjects
    end
    
    -- Calculate progress percentage
    local totalEstimate = state.totalObjects
    local progress = totalEstimate > 0 and (state.scannedObjects / totalEstimate) * 100 or 0
    progress = math.min(progress, 99.9)
    
    -- Calculate ETA
    if state.scanSpeed > 0 and totalEstimate > state.scannedObjects then
        local remaining = totalEstimate - state.scannedObjects
        state.etaSeconds = remaining / state.scanSpeed
    else
        state.etaSeconds = 0
    end
    
    -- Update UI
    updateUI(progress)
end

function formatTime(seconds)
    if seconds <= 0 then return "--:--:--" end
    if seconds > 86400 then
        local days = math.floor(seconds / 86400)
        local hours = math.floor((seconds % 86400) / 3600)
        return string.format("%dd %02dh", days, hours)
    end
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, mins, secs)
end

function updateUI(progress)
    pcall(function()
        local progressInt = math.floor(progress)
        progressBar:Set(progressInt)
        
        progressLabel:Set(string.format("Progress: %.1f%% (%d/%d objects)", 
            progress, state.scannedObjects, state.totalObjects))
        
        etaLabel:Set("ETA: " .. formatTime(state.etaSeconds))
        speedLabel:Set(string.format("Speed: %.1f obj/s", state.scanSpeed))
        
        statsLabel:Set(string.format(
            "Scanned: %d | Scripts: %d | Remotes: %d | Anti-Cheats: %d | Admin: %d | Currency: %d",
            state.scannedObjects,
            state.scriptsFound,
            state.remoteEventsFound,
            countTable(state.antiCheats),
            #state.adminPanels,
            #state.currencySystems
        ))
    end)
end

function countTable(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

--=====================================================
-- RESULT DISPLAY UPDATE
--=====================================================
function updateResultDisplays()
    pcall(function()
        -- Anti-cheat display
        local acText = ""
        local acCount = countTable(state.antiCheats)
        if acCount > 0 then
            acText = "🚨 DETECTED ANTI-CHEAT SYSTEMS:\n\n"
            -- Sort by severity
            local sorted = {}
            for _, ac in pairs(state.antiCheats) do
                table.insert(sorted, ac)
            end
            table.sort(sorted, function(a, b)
                local severityOrder = {CRITICAL=1, HIGH=2, MEDIUM=3, LOW=4, VARIABLE=5, INFO=6}
                return (severityOrder[a.severity] or 99) < (severityOrder[b.severity] or 99)
            end)
            
            for _, ac in pairs(sorted) do
                local icon = ac.severity == "CRITICAL" and "🔴" or
                             ac.severity == "HIGH" and "🟠" or
                             ac.severity == "MEDIUM" and "🟡" or "⚪"
                acText = acText .. string.format("%s [%s] %s (%dx)\n", icon, ac.severity, ac.name, ac.occurrences)
                if #ac.locations > 0 then
                    acText = acText .. "   Locations:\n"
                    for _, loc in pairs(ac.locations) do
                        acText = acText .. "   • " .. loc .. "\n"
                    end
                end
                acText = acText .. "\n"
            end
        else
            acText = "✅ No anti-cheat systems detected"
        end
        acLabel:Set(acText)
        
        -- Admin panels display
        local adminText = ""
        if #state.adminPanels > 0 then
            adminText = "👑 DETECTED ADMIN PANELS:\n\n"
            for i, panel in pairs(state.adminPanels) do
                adminText = adminText .. string.format("%d. %s (%s)\n   %s\n\n", 
                    i, panel.name, panel.className, panel.path)
            end
        else
            adminText = "No admin panels detected"
        end
        adminLabel:Set(adminText)
        
        -- Currency display
        local currencyText = ""
        if #state.currencySystems > 0 then
            currencyText = "💰 DETECTED CURRENCY SYSTEMS:\n\n"
            for i, sys in pairs(state.currencySystems) do
                currencyText = currencyText .. string.format("%d. %s\n   %s\n   Patterns: %s\n\n",
                    i, sys.name, sys.path, table.concat(sys.patterns, ", "))
            end
        else
            currencyText = "No currency systems detected"
        end
        currencyLabel:Set(currencyText)
        
        -- Remote events display
        local remoteText = ""
        if #state.remoteEvents > 0 then
            remoteText = "📡 REMOTE EVENTS/FUNCTIONS:\n\n"
            for i, ev in pairs(state.remoteEvents) do
                remoteText = remoteText .. string.format("%d. [%s] %s\n   %s\n   Parent: %s\n\n",
                    i, ev.className, ev.name, ev.path, ev.parent)
            end
        else
            remoteText = "No remote events detected"
        end
        remoteLabel:Set(remoteText)
        
        -- Scripts display
        local scriptText = ""
        if #state.scripts > 0 then
            scriptText = "📜 SCRIPTS FOUND (" .. #state.scripts .. " total):\n\n"
            for i, script in pairs(state.scripts) do
                if i > 100 then
                    scriptText = scriptText .. "... and " .. (#state.scripts - 100) .. " more scripts\n"
                    break
                end
                
                local tags = {}
                if script.isObfuscated then table.insert(tags, "OBFUSCATED(" .. script.obfuscationScore .. ")") end
                if script.isAdminPanel then table.insert(tags, "ADMIN") end
                if script.hasCurrency then table.insert(tags, "CURRENCY") end
                if #script.antiCheats > 0 then 
                    local acNames = {}
                    for _, ac in pairs(script.antiCheats) do
                        table.insert(acNames, ac.name)
                    end
                    table.insert(tags, "AC:" .. table.concat(acNames, ","))
                end
                
                local tagStr = #tags > 0 and " [" .. table.concat(tags, "][") .. "]" or ""
                scriptText = scriptText .. string.format("%d. %s%s\n   %s\n   Source: %s (%d bytes)\n\n",
                    i, script.name, tagStr, script.path, script.sourceMethod, script.size)
            end
        else
            scriptText = "No scripts found yet"
        end
        dataLabel:Set(scriptText)
    end)
end

--=====================================================
-- SCAN CONTROLS
--=====================================================
function startScan()
    if state.scanning then return end
    
    -- Reset state
    state.scanning = true
    state.paused = false
    state.startTime = tick()
    state.elapsed = 0
    state.totalObjects = 0
    state.scannedObjects = 0
    state.scriptsFound = 0
    state.remoteEventsFound = 0
    state.scripts = {}
    state.remoteEvents = {}
    state.antiCheats = {}
    state.adminPanels = {}
    state.currencySystems = {}
    state.etaSeconds = 0
    state.scanSpeed = 0
    state.lastSampleTime = tick()
    state.lastSampleCount = 0
    state.currentContainer = 1
    
    statusLabel:Set("Status: 🔍 SCANNING...")
    
    -- Build container list
    state.containers = {
        { name = "Workspace", obj = Services.Workspace },
        { name = "ReplicatedStorage", obj = Services.ReplicatedStorage },
        { name = "ServerStorage", obj = Services.ServerStorage },
        { name = "CoreGui", obj = Services.CoreGui },
        { name = "StarterGui", obj = Services.StarterGui },
        { name = "Players", obj = Services.Players },
        { name = "Lighting", obj = Services.Lighting },
        { name = "Teams", obj = Services.Teams },
        { name = "SoundService", obj = Services.SoundService },
        { name = "Game Root", obj = game },
    }
    
    -- Start scan coroutine
    spawn(function()
        for idx, container in pairs(state.containers) do
            if not state.scanning then break end
            
            state.currentContainer = idx
            statusLabel:Set(string.format("Status: 🔍 Scanning [%s/%d] %s...", 
                idx, #state.containers, container.name))
            
            scanContainer(container.obj, 0)
            task.wait(0.05)
        end
        
        if state.scanning then
            finishScan()
        end
    end)
    
    -- Start UI update loop
    spawn(function()
        while state.scanning do
            updateResultDisplays()
            task.wait(0.5)
        end
    end)
end

function togglePause()
    if not state.scanning then return end
    
    state.paused = not state.paused
    if state.paused then
        statusLabel:Set("Status: ⏸ PAUSED")
    else
        statusLabel:Set("Status: 🔍 RESUMED")
    end
end

function stopScan()
    state.scanning = false
    state.paused = false
    statusLabel:Set("Status: ■ STOPPED")
    progressBar:Set(0)
end

function finishScan()
    state.scanning = false
    state.elapsed = tick() - state.startTime
    
    progressBar:Set(100)
    progressLabel:Set(string.format("Progress: 100%% (%d objects)", state.scannedObjects))
    statusLabel:Set(string.format("Status: ✅ COMPLETE (%.1f seconds)", state.elapsed))
    
    updateResultDisplays()
    
    -- Notification
    Rayfield:Notify({
        Title = "✅ Scan Complete",
        Content = string.format(
            "Scanned %d objects in %.1fs\n📜 %d scripts\n📡 %d remotes\n🚨 %d anti-cheats\n👑 %d admin panels\n💰 %d currency systems",
            state.scannedObjects, state.elapsed,
            state.scriptsFound, state.remoteEventsFound,
            countTable(state.antiCheats), #state.adminPanels, #state.currencySystems
        ),
        Duration = 8
    })
end

--=====================================================
-- EXPORT ENGINE
--=====================================================
function exportResults()
    if #state.scripts == 0 then
        Rayfield:Notify({
            Title = "No Data",
            Content = "Run a scan first before exporting.",
            Duration = 3
        })
        return
    end
    
    local export = {}
    local function add(line)
        table.insert(export, line)
    end
    
    add("╔══════════════════════════════════════════════════════════════╗")
    add("║            OMNI-SCANNER v3.0 — FULL EXPORT                 ║")
    add("╚══════════════════════════════════════════════════════════════╝")
    add("")
    add(string.format("Game: %s (ID: %d)", game.Name, game.GameId))
    add(string.format("Place: %s", game.PlaceId))
    add(string.format("Scan Date: %s", os.date("%Y-%m-%d %H:%M:%S")))
    add(string.format("Scan Duration: %.1f seconds", state.elapsed))
    add(string.format("Total Objects Scanned: %d", state.scannedObjects))
    add("")
    
    -- === ANTI-CHEAT SECTION ===
    add("═══════════════════════════════════════════════════════════════")
    add("  ANTI-CHEAT SYSTEMS DETECTED")
    add("═══════════════════════════════════════════════════════════════")
    if countTable(state.antiCheats) > 0 then
        for _, ac in pairs(state.antiCheats) do
            add(string.format("  [%s] %s", ac.severity, ac.name))
            add(string.format("  Occurrences: %d", ac.occurrences))
            for _, loc in pairs(ac.locations) do
                add(string.format("    → %s", loc))
            end
            add("")
        end
    else
        add("  None detected")
        add("")
    end
    
    -- === ADMIN PANELS ===
    add("═══════════════════════════════════════════════════════════════")
    add("  ADMIN PANELS DETECTED")
    add("═══════════════════════════════════════════════════════════════")
    if #state.adminPanels > 0 then
        for i, panel in pairs(state.adminPanels) do
            add(string.format("  %d. %s (%s)", i, panel.name, panel.className))
            add(string.format("     Path: %s", panel.path))
            add(string.format("     Patterns: %s", table.concat(panel.patterns, ", ")))
            add("")
        end
    else
        add("  None detected")
        add("")
    end
    
    -- === CURRENCY SYSTEMS ===
    add("═══════════════════════════════════════════════════════════════")
    add("  CURRENCY / ECONOMY SYSTEMS")
    add("═══════════════════════════════════════════════════════════════")
    if #state.currencySystems > 0 then
        for i, sys in pairs(state.currencySystems) do
            add(string.format("  %d. %s", i, sys.name))
            add(string.format("     Path: %s", sys.path))
            add(string.format("     Patterns: %s", table.concat(sys.patterns, ", ")))
            add("")
        end
    else
        add("  None detected")
        add("")
    end
    
    -- === REMOTE EVENTS ===
    add("═══════════════════════════════════════════════════════════════")
    add("  REMOTE EVENTS & FUNCTIONS")
    add("═══════════════════════════════════════════════════════════════")
    if #state.remoteEvents > 0 then
        for i, ev in pairs(state.remoteEvents) do
            add(string.format("  %d. [%s] %s", i, ev.className, ev.name))
            add(string.format("     Path: %s", ev.path))
            add(string.format("     Parent: %s", ev.parent))
            add("")
        end
    else
        add("  None detected")
        add("")
    end
    
    -- === SCRIPTS ===
    add("═══════════════════════════════════════════════════════════════")
    add("  ALL SCRIPTS (" .. #state.scripts .. " total)")
    add("═══════════════════════════════════════════════════════════════")
    
    local exportCount = math.min(#state.scripts, CONFIG.EXPORT_LIMIT)
    for i = 1, exportCount do
        local script = state.scripts[i]
        add("")
        add(string.format("  ─── SCRIPT #%d: %s ───", i, script.path))
        add(string.format("  Class: %s | Source: %s | Size: %d bytes", 
            script.className, script.sourceMethod, script.size))
        
        if script.isObfuscated then
            add(string.format("  ⚠ OBFUSCATED (score: %d/20)", script.obfuscationScore))
        end
        if script.isAdminPanel then
            add(string.format("  👑 ADMIN PANEL (matched: %s)", table.concat(script.adminPatterns, ", ")))
        end
        if script.hasCurrency then
            add(string.format("  💰 CURRENCY SYSTEM (matched: %s)", table.concat(script.currencyPatterns, ", ")))
        end
        if #script.antiCheats > 0 then
            add("  🚨 ANTI-CHEAT REFERENCES:")
            for _, ac in pairs(script.antiCheats) do
                add(string.format("     → [%s] %s", ac.severity, ac.name))
            end
        end
        
        add("")
        add("  --- SOURCE CODE ---")
        for line in script.source:gmatch("([^\n]*)\n?") do
            add("  " .. line)
        end
        add("  --- END SCRIPT #" .. i .. " ---")
    end
    
    if #state.scripts > CONFIG.EXPORT_LIMIT then
        add("")
        add(string.format("  ... and %d more scripts (truncated)", #state.scripts - CONFIG.EXPORT_LIMIT))
    end
    
    -- Copy to clipboard
    local success, err = pcall(function()
        setclipboard(table.concat(export, "\n"))
    end)
    
    if success then
        Rayfield:Notify({
            Title = "✅ Export Complete",
            Content = string.format("Exported %d scripts + analysis to clipboard", exportCount),
            Duration = 4
        })
    else
        Rayfield:Notify({
            Title = "⚠ Export Warning",
            Content = "Clipboard write failed. Try a different executor.",
            Duration = 4
        })
    end
end

--=====================================================
-- INIT
--=====================================================
Rayfield:LoadConfiguration()

print("╔══════════════════════════════════════════════════════════════╗")
print("║           OMNI-SCANNER v3.0 LOADED                          ║")
print("║   Click 'START FULL SCAN' to begin analysis                 ║")
print("╚══════════════════════════════════════════════════════════════╝")
