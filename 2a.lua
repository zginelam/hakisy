local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Window creation
local Window = Rayfield:CreateWindow({
    Name = "Advanced Scanner",
    Icon = 0,
    LoadingTitle = "turcja scanner",
    LoadingSubtitle = "by turcja",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AdvScanner",
        FileName = "Config"
    }
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

-- State
local scanResults = {
    scripts = {},
    remoteEvents = {},
    antiCheats = {},
    adminPanels = {},
    currencySystems = {},
    totalScanned = 0,
    startTime = 0
}

local knownAntiCheats = {
    ["Adonis"] = {
        patterns = {"Adonis", "adonis_", "MainEvent", "AdminLoader"},
        severity = "Critical"
    },
    ["Krnl AntiCheat"] = {
        patterns = {"KrnlACL", "krnl_anticheat", "KrnlAntiExploit"},
        severity = "High"
    },
    ["Infinite Yield Detection"] = {
        patterns = {"infinite_yield", "infiniteyield", "IYDetect"},
        severity = "Medium"
    },
    ["SimpleSpy Detection"] = {
        patterns = {"SimpleSpy", "simplespy_", "SS_Detect"},
        severity = "Medium"
    },
    ["RemoteSpy Detection"] = {
        patterns = {"RemoteSpy", "remotespy_anti"},
        severity = "Medium"
    },
    ["Custom Remote Validator"] = {
        patterns = {"validateRemote", "remoteValidator", "checkRemote", "sanitizeRemote", "verifyRemote"},
        severity = "Variable"
    },
    ["Hook Detection"] = {
        patterns = {"hookfunction", "hookmetamethod", "cloneref", "checkcaller", "getcaller", "debug.getinfo"},
        severity = "High"
    },
    ["Script Integrity Check"] = {
        patterns = {"getscript", "getscriptbytecode", "gethash", "gethui", "sethiddenproperty"},
        severity = "High"
    }
}

local adminPanelPatterns = {
    "Admin", "admin", "PANEL", "panel", "ControlPanel", "AdminPanel",
    "StaffPanel", "ModPanel", "AdminCommands", "cmds", "Commands",
    "giveAdmin", "setAdmin", "isAdmin", "checkAdmin", "getAdminRank",
    "CMD_", "cmdHandler", "runCommand", "executeCommand"
}

local currencyPatterns = {
    "Money", "money", "Cash", "cash", "Coins", "coins", "Gems", "gems",
    "Currency", "currency", "Wallet", "wallet", "Balance", "balance",
    "addMoney", "removeMoney", "setMoney", "giveMoney", "spendMoney",
    "getBalance", "setBalance", "addBalance", "updateCurrency",
    "leaderstats", "DataStore", "datastore", "ProfileStore"
}

-- Main tab
local MainTab = Window:CreateTab("Scanner", 4483362458)
local MainSection = MainTab:CreateSection("Scan Controls")

local statusLabel = MainTab:CreateLabel("Status: Ready")

MainTab:CreateButton({
    Name = "▶ Start Full Scan",
    Callback = function()
        startFullScan()
    end
})

MainTab:CreateButton({
    Name = "■ Stop Scan",
    Callback = function()
        scanning = false
        statusLabel:Set("Status: Stopped")
    end
})

-- Results tab
local ResultsTab = Window:CreateTab("Results", "file-search")
local ResultsSection = ResultsTab:CreateSection("Scan Results")

local resultsLabel = ResultsTab:CreateLabel("No scan results yet")

-- Anti-cheat tab
local ACTab = Window:CreateTab("Anti-Cheat", "shield")
local ACSection = ACTab:CreateSection("Detected Anti-Cheat Systems")

local acLabel = ACTab:CreateLabel("No anti-cheat systems detected")

-- Admin panels tab
local AdminTab = Window:CreateTab("Admin Panels", "users")
local AdminSection = AdminTab:CreateSection("Detected Admin Systems")

local adminLabel = AdminTab:CreateLabel("No admin panels detected")

-- Currency tab
local CurrencyTab = Window:CreateTab("Currency", "dollar-sign")
local CurrencySection = CurrencyTab:CreateSection("Currency Systems")

local currencyLabel = CurrencyTab:CreateLabel("No currency systems detected")

-- Raw data tab
local DataTab = Window:CreateTab("Raw Data", "code")
local DataSection = DataTab:CreateSection("Script Contents")

local dataLabel = DataTab:CreateLabel("Click a result to view script content")

-- Functions

function scanInstance(instance, depth)
    if not scanning then return end
    if depth > 50 then return end
    
    pcall(function()
        local children = instance:GetChildren()
        for _, child in pairs(children) do
            if not scanning then break end
            
            scanResults.totalScanned = scanResults.totalScanned + 1
            
            -- Script detection
            if child:IsA("LocalScript") or child:IsA("ModuleScript") or child:IsA("Script") then
                local scriptData = analyzeScript(child)
                if scriptData then
                    table.insert(scanResults.scripts, scriptData)
                end
            end
            
            -- Remote event/mapping
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") or child:IsA("UnreliableRemoteEvent") then
                table.insert(scanResults.remoteEvents, {
                    Name = child.Name,
                    ClassName = child.ClassName,
                    Path = child:GetFullName(),
                    Parent = child.Parent and child.Parent.Name or "None"
                })
            end
            
            -- Recurse
            scanInstance(child, depth + 1)
        end
    end)
end

function analyzeScript(scriptInstance)
    pcall(function()
        local source = ""
        local success, decompiled = pcall(function()
            -- Try different decompilation methods
            if decompile then
                return decompile(scriptInstance)
            elseif scriptInstance.Source then
                return scriptInstance.Source
            else
                return "-- No source available"
            end
        end)
        
        if success then
            source = decompiled or "-- Empty source"
        else
            source = "-- Failed to decompile (bytecode/obfuscated)"
        end
        
        -- Run detection algorithms
        local antiCheatMatches = detectAntiCheats(source, scriptInstance)
        local adminMatches = detectAdminPanels(source, scriptInstance)
        local currencyMatches = detectCurrencySystems(source, scriptInstance)
        
        return {
            Name = scriptInstance.Name,
            ClassName = scriptInstance.ClassName,
            Path = scriptInstance:GetFullName(),
            Source = source,
            Size = #source,
            AntiCheats = antiCheatMatches,
            IsAdminPanel = #adminMatches > 0,
            AdminMatches = adminMatches,
            HasCurrency = #currencyMatches > 0,
            CurrencyMatches = currencyMatches,
            IsObfuscated = isObfuscated(source)
        }
    end)
    
    return nil
end

function detectAntiCheats(source, instance)
    local matches = {}
    
    for acName, acData in pairs(knownAntiCheats) do
        for _, pattern in pairs(acData.patterns) do
            if source:find(pattern, 1, true) or instance.Name:find(pattern, 1, true) then
                local match = {
                    name = acName,
                    severity = acData.severity,
                    matched = pattern,
                    path = instance:GetFullName()
                }
                table.insert(matches, match)
                
                -- Add to global anti-cheat list if not already there
                local found = false
                for _, existing in pairs(scanResults.antiCheats) do
                    if existing.name == acName then found = true; break end
                end
                if not found then
                    table.insert(scanResults.antiCheats, match)
                end
                
                break
            end
        end
    end
    
    return matches
end

function detectAdminPanels(source, instance)
    local matches = {}
    
    for _, pattern in pairs(adminPanelPatterns) do
        if source:find(pattern, 1, true) or instance.Name:find(pattern, 1, true) then
            table.insert(matches, pattern)
            
            local found = false
            for _, existing in pairs(scanResults.adminPanels) do
                if existing.Name == instance.Name and existing.Path == instance:GetFullName() then
                    found = true; break
                end
            end
            if not found then
                table.insert(scanResults.adminPanels, {
                    Name = instance.Name,
                    ClassName = instance.ClassName,
                    Path = instance:GetFullName(),
                    MatchedPattern = pattern
                })
            end
            
            break
        end
    end
    
    return matches
end

function detectCurrencySystems(source, instance)
    local matches = {}
    
    for _, pattern in pairs(currencyPatterns) do
        if source:find(pattern, 1, true) or instance.Name:find(pattern, 1, true) then
            table.insert(matches, pattern)
            
            local found = false
            for _, existing in pairs(scanResults.currencySystems) do
                if existing.Name == instance.Name and existing.Path == instance:GetFullName() then
                    found = true; break
                end
            end
            if not found then
                table.insert(scanResults.currencySystems, {
                    Name = instance.Name,
                    Path = instance:GetFullName(),
                    MatchedPattern = pattern
                })
            end
            
            break
        end
    end
    
    return matches
end

function isObfuscated(source)
    -- Detect common obfuscation patterns
    local obfuscationSigns = {
        "loadstring", "bytecode", "\\x", "char(", "string.byte", "string.char",
        "_0x", "0x[0-9a-fA-F]+", "%\\(%\\)", "math.floor", "table.concat",
        "local _=", "local _0", "__o__", "__m__", "Moonsec", "MoonsecV3",
        "Lura.ph", "Obfuscated", "PROTECTED", "ENCRYPTED"
    }
    
    local count = 0
    for _, sign in pairs(obfuscationSigns) do
        if source:find(sign) then
            count = count + 1
        end
    end
    
    -- Heuristic: 3+ signs = likely obfuscated
    return count >= 3
end

function startFullScan()
    scanning = true
    scanResults = {
        scripts = {},
        remoteEvents = {},
        antiCheats = {},
        adminPanels = {},
        currencySystems = {},
        totalScanned = 0,
        startTime = tick()
    }
    
    statusLabel:Set("Status: Scanning...")
    resultsLabel:Set("Scanning in progress...")
    
    -- Clear old results display
    scanResults.totalScanned = 0
    
    -- Scan all major containers
    local containers = {
        Workspace,
        ReplicatedStorage,
        ServerStorage,
        CoreGui,
        StarterGui,
        Players,
        game:GetService("Lighting"),
        game:GetService("Teams"),
        game:GetService("SoundService"),
        game
    }
    
    spawn(function()
        for _, container in pairs(containers) do
            if not scanning then break end
            statusLabel:Set("Status: Scanning " .. container.ClassName .. "...")
            scanInstance(container, 0)
            task.wait()
        end
        
        if scanning then
            finishScan()
        end
    end)
end

function finishScan()
    scanning = false
    local elapsed = math.floor(tick() - scanResults.startTime)
    
    statusLabel:Set("Status: Complete (" .. elapsed .. "s)")
    
    -- Update results labels
    updateLabels()
    
    -- Notify
    Rayfield:Notify({
        Title = "Scan Complete",
        Content = string.format(
            "Found %d scripts\n%d remote events\n%d anti-cheats\n%d admin panels\n%d currency systems",
            #scanResults.scripts,
            #scanResults.remoteEvents,
            #scanResults.antiCheats,
            #scanResults.adminPanels,
            #scanResults.currencySystems
        ),
        Duration = 5
    })
end

function updateLabels()
    -- General results
    resultsLabel:Set(string.format(
        "Total Objects Scanned: %d\nScripts Found: %d\nRemote Events: %d\nAnti-Cheats: %d\nAdmin Panels: %d\nCurrency Systems: %d",
        scanResults.totalScanned,
        #scanResults.scripts,
        #scanResults.remoteEvents,
        #scanResults.antiCheats,
        #scanResults.adminPanels,
        #scanResults.currencySystems
    ))
    
    -- Anti-cheat results
    if #scanResults.antiCheats > 0 then
        local acText = "Detected Anti-Cheat Systems:\n"
        for _, ac in pairs(scanResults.antiCheats) do
            acText = acText .. string.format("• %s [%s] - %s\n", ac.name, ac.severity, ac.path)
        end
        acLabel:Set(acText)
    else
        acLabel:Set("No anti-cheat systems detected")
    end
    
    -- Admin panel results
    if #scanResults.adminPanels > 0 then
        local adminText = "Detected Admin Systems:\n"
        for _, panel in pairs(scanResults.adminPanels) do
            adminText = adminText .. string.format("• %s (%s) - %s\n", panel.Name, panel.ClassName, panel.Path)
        end
        adminLabel:Set(adminText)
    else
        adminLabel:Set("No admin panels detected")
    end
    
    -- Currency results
    if #scanResults.currencySystems > 0 then
        local currencyText = "Detected Currency Systems:\n"
        for _, sys in pairs(scanResults.currencySystems) do
            currencyText = currencyText .. string.format("• %s - %s (matched: %s)\n", sys.Name, sys.Path, sys.MatchedPattern)
        end
        currencyLabel:Set(currencyText)
    else
        currencyLabel:Set("No currency systems detected")
    end
    
    -- Update script list in Raw Data tab
    updateScriptList()
end

function updateScriptList()
    -- Clear old buttons (workaround)
    -- For a cleaner approach, we'd use a ScrollingFrame, but for Rayfield:
    local scriptListText = "Scripts Found:\n\n"
    
    for i, script in pairs(scanResults.scripts) do
        local obfLabel = script.IsObfuscated and " [OBFUSCATED]" or ""
        local adminLabel = script.IsAdminPanel and " [ADMIN]" or ""
        local currencyLabel = script.HasCurrency and " [CURRENCY]" or ""
        local acLabel2 = #script.AntiCheats > 0 and " [ANTICHEAT]" or ""
        
        scriptListText = scriptListText .. string.format(
            "%d. %s%s%s%s%s\n   %s\n   (%d bytes)\n\n",
            i,
            script.Name,
            obfLabel,
            adminLabel,
            currencyLabel,
            acLabel2,
            script.Path,
            script.Size
        )
        
        if i >= 50 then
            scriptListText = scriptListText .. "... and " .. (#scanResults.scripts - 50) .. " more\n"
            break
        end
    end
    
    dataLabel:Set(scriptListText)
end

-- Export button
MainTab:CreateButton({
    Name = "📁 Export Results to Clipboard",
    Callback = function()
        local exportData = "=== ADVANCED SCANNER RESULTS ===\n"
        exportData = exportData .. "Date: " .. os.date() .. "\n"
        exportData = exportData .. "Game: " .. game.GameId .. " - " .. game.Name .. "\n\n"
        
        exportData = exportData .. "=== ANTI-CHEAT SYSTEMS ===\n"
        for _, ac in pairs(scanResults.antiCheats) do
            exportData = exportData .. string.format("[%s] %s - %s\n", ac.severity, ac.name, ac.path)
        end
        
        exportData = exportData .. "\n=== ADMIN PANELS ===\n"
        for _, panel in pairs(scanResults.adminPanels) do
            exportData = exportData .. string.format("%s (%s) - %s\n", panel.Name, panel.ClassName, panel.Path)
        end
        
        exportData = exportData .. "\n=== CURRENCY SYSTEMS ===\n"
        for _, sys in pairs(scanResults.currencySystems) do
            exportData = exportData .. string.format("%s - %s\n", sys.Name, sys.Path)
        end
        
        exportData = exportData .. "\n=== REMOTE EVENTS ===\n"
        for _, ev in pairs(scanResults.remoteEvents) do
            exportData = exportData .. string.format("%s (%s) - %s\n", ev.Name, ev.ClassName, ev.Path)
        end
        
        exportData = exportData .. "\n=== SCRIPTS (" .. #scanResults.scripts .. " total) ===\n"
        for i, script in pairs(scanResults.scripts) do
            exportData = exportData .. string.format("\n--- %d. %s ---\n%s\n--- END ---\n", i, script.Path, script.Source)
            if i >= 20 then
                exportData = exportData .. "\n... (truncated, full results available in UI)\n"
                break
            end
        end
        
        setclipboard(exportData)
        Rayfield:Notify({
            Title = "Exported",
            Content = "Results copied to clipboard",
            Duration = 2
        })
    end
})

-- Load config
Rayfield:LoadConfiguration()

print("Advanced Scanner loaded. Click 'Start Full Scan' to begin.")
