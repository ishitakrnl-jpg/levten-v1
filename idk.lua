============================================================
--   ðŸŒŠ TSUNAMI BRAINROT HUB v2.0
--   Game: Escape Tsunami For Brainrots (Roblox)
--   UI: Rayfield
--   Features: Auto Find Secret/Celestial/Divine/Infinity,
--             Auto Doom Event, Auto Collect Cash, Auto Upgrade,
--             Auto Tower, Delete Wall, Auto Rebirth,
--             Auto +10 Speed, Auto AFK, Auto Spawn Brainrot,
--             Auto Spin Wheel, Auto Coin, FPS Boost, God Mode,
--             Gap Teleport, Auto Avoid Tsunami, and more!
-- ============================================================

-- Load Original Base Script
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanbu/Scripts/main/EscapeTsunamiForBrainrots"))()
end)

-- ============================================================
-- LOAD RAYFIELD
-- ============================================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ============================================================
-- SERVICES
-- ============================================================
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local VirtualUser    = game:GetService("VirtualUser")
local TeleportSvc    = game:GetService("TeleportService")
local UserInputSvc   = game:GetService("UserInputService")
local ReplicatedStor = game:GetService("ReplicatedStorage")
local Workspace      = game:GetService("Workspace")
local Lighting       = game:GetService("Lighting")

local LP             = Players.LocalPlayer
local Char           = LP.Character or LP.CharacterAdded:Wait()
local Root           = Char:WaitForChild("HumanoidRootPart")
local Humanoid       = Char:WaitForChild("Humanoid")

-- Refresh character on respawn
LP.CharacterAdded:Connect(function(c)
    Char      = c
    Root      = c:WaitForChild("HumanoidRootPart")
    Humanoid  = c:WaitForChild("Humanoid")
end)

-- ============================================================
-- STATE FLAGS
-- ============================================================
local State = {
    AutoAFK            = false,
    AutoSpawn          = false,
    AutoFindSecret     = false,
    AutoFindCelestial  = false,
    AutoFindDivine     = false,
    AutoFindInfinity   = false,
    AutoDoomEvent      = false,
    AutoCollectCash    = false,
    AutoUpgradeAll     = false,
    AutoTower          = false,
    AutoRebirth        = false,
    AutoSpeed10        = false,
    AutoAvoidTsunami   = false,
    AutoSpinWheel      = false,
    AutoCoin           = false,
    GodMode            = false,
    FPSBoost           = false,
}

local Connections = {}
local SpawnCount  = 0

-- ============================================================
-- HELPERS
-- ============================================================
local function SafeFireRemote(name, ...)
    for _, v in pairs(ReplicatedStor:GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            if v.Name:lower():find(name:lower()) then
                pcall(function()
                    if v:IsA("RemoteEvent") then v:FireServer(...)
                    else v:InvokeServer(...) end
                end)
            end
        end
    end
end

local function ClickGuiButton(keyword)
    for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
        if (gui:IsA("TextButton") or gui:IsA("ImageButton")) then
            if gui.Name:lower():find(keyword:lower()) or
               (gui.Text and gui.Text:lower():find(keyword:lower())) then
                pcall(function() gui.MouseButton1Click:Fire() end)
            end
        end
    end
end

local function TweenTo(pos, speed)
    speed = speed or 1
    if not Root then return end
    local info = TweenInfo.new(speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(Root, info, {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

local function FindPartByKeyword(keywords)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            for _, kw in pairs(keywords) do
                if v.Name:lower():find(kw:lower()) then
                    return v
                end
            end
        end
    end
    return nil
end

local function Notify(title, content, duration)
    Rayfield:Notify({
        Title    = title,
        Content  = content,
        Duration = duration or 3,
        Image    = 4483362458,
    })
end

local function StopConn(key)
    if Connections[key] then
        pcall(function() Connections[key]:Disconnect() end)
        Connections[key] = nil
    end
end

-- ============================================================
-- RAYFIELD WINDOW
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name             = "ðŸŒŠ Tsunami Brainrot Hub v2.0",
    Icon             = 0,
    LoadingTitle     = "Tsunami Brainrot Hub",
    LoadingSubtitle  = "The Ultimate Script",
    Theme            = "Ocean",
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "TsunamiBrainrotHub",
        FileName   = "Config"
    },
    KeySystem = false,
})

-- ============================================================
-- TABS
-- ============================================================
local TabMain     = Window:CreateTab("ðŸ  Main",       4483362458)
local TabFarm     = Window:CreateTab("ðŸ¤– AutoFarm",   4483362458)
local TabRare     = Window:CreateTab("ðŸ’Ž Rare Hunt",  4483362458)
local TabEvent    = Window:CreateTab("ðŸŒ‹ Events",     4483362458)
local TabUpgrade  = Window:CreateTab("â¬†ï¸ Upgrades",   4483362458)
local TabMisc     = Window:CreateTab("âœ¨ Misc",        4483362458)
local TabSettings = Window:CreateTab("âš™ï¸ Settings",   4483362458)

-- ============================================================
-- TAB: MAIN
-- ============================================================
TabMain:CreateSection("ðŸ“‹ Script Info")
TabMain:CreateLabel("ðŸŒŠ Tsunami Brainrot Hub v2.0")
TabMain:CreateLabel("Player: " .. LP.Name)
TabMain:CreateLabel("Game: Escape Tsunami For Brainrots")

TabMain:CreateSection("ðŸ”§ Base Script")
TabMain:CreateButton({
    Name        = "â–¶ Load Original Script",
    Description = "Executes the base EscapeTsunami script",
    Callback    = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanbu/Scripts/main/EscapeTsunamiForBrainrots"))()
        end)
        Notify("Base Script", "Original script loaded!", 3)
    end,
})

TabMain:CreateSection("ðŸ›¡ï¸ God Mode")
TabMain:CreateToggle({
    Name         = "God Mode (Survive Tsunamis)",
    CurrentValue = false,
    Flag         = "GodMode",
    Description  = "Prevents death from tsunamis by constantly resetting health to max",
    Callback     = function(val)
        State.GodMode = val
        StopConn("GodMode")
        if val then
            Connections["GodMode"] = RunService.Heartbeat:Connect(function()
                if Humanoid then
                    Humanoid.Health = Humanoid.MaxHealth
                    -- Also avoid being flung
                    pcall(function()
                        for _, part in pairs(Char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Velocity = Vector3.zero
                            end
                        end
                    end)
                end
            end)
            Notify("God Mode", "Enabled! You are invincible.", 3)
        else
            Notify("God Mode", "Disabled.", 2)
        end
    end,
})

TabMain:CreateSection("ðŸš€ Gap Teleport")
TabMain:CreateButton({
    Name        = "â© Teleport to Next Gap",
    Description = "Moves to the next brainrot zone",
    Callback    = function()
        local gaps = {"Secret", "Celestial", "Divine", "Infinity", "Mythical", "Legendary", "Epic", "Rare", "Uncommon"}
        local currentZ = Root and Root.Position.Z or 0
        local best = nil
        for _, gapName in pairs(gaps) do
            local part = FindPartByKeyword({gapName, "Gap_" .. gapName, "Area_" .. gapName})
            if part then
                local pos = (part:IsA("Model") and part:GetModelCFrame().Position) or part.Position
                if pos.Z > currentZ then
                    if best == nil or pos.Z < best.Z then
                        best = pos
                    end
                end
            end
        end
        if best then
            Root.CFrame = CFrame.new(best + Vector3.new(0, 5, 0))
            Notify("Gap Teleport", "Teleported to next gap!", 2)
        else
            -- Fallback: just move forward
            if Root then
                Root.CFrame = Root.CFrame + Vector3.new(0, 0, -100)
            end
            Notify("Gap Teleport", "Moved forward 100 units.", 2)
        end
    end,
})

TabMain:CreateButton({
    Name        = "âª Teleport to Previous Gap",
    Description = "Goes back to the previous brainrot zone",
    Callback    = function()
        if Root then
            Root.CFrame = Root.CFrame + Vector3.new(0, 0, 100)
            Notify("Gap Teleport", "Moved back to previous gap.", 2)
        end
    end,
})

TabMain:CreateButton({
    Name        = "ðŸ  Teleport to Safe Zone / Base",
    Description = "Teleports you to your base/safe zone",
    Callback    = function()
        local base = FindPartByKeyword({"SafeZone", "SpeedShop", "Base", "PlayerBase_" .. LP.Name, LP.Name .. "Base"})
        if base then
            local pos = (base:IsA("Model") and base:GetModelCFrame().Position) or base.Position
            Root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
            Notify("Teleport", "Teleported to your base!", 2)
        else
            -- Fallback teleport to spawn
            for _, p in pairs(Workspace:GetDescendants()) do
                if p.Name:lower():find("spawn") or p.Name:lower():find("lobby") then
                    Root.CFrame = CFrame.new(p.Position + Vector3.new(0, 5, 0))
                    break
                end
            end
            Notify("Teleport", "Teleported to spawn area.", 2)
        end
    end,
})

-- ============================================================
-- TAB: AUTOFARM
-- ============================================================
TabFarm:CreateSection("ðŸ¤– Auto AFK")
TabFarm:CreateToggle({
    Name         = "Auto AFK (Anti-Kick)",
    CurrentValue = false,
    Flag         = "AutoAFK",
    Description  = "Prevents AFK kick by simulating input",
    Callback     = function(val)
        State.AutoAFK = val
        StopConn("AutoAFK")
        if val then
            Connections["AutoAFK"] = LP.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
                task.wait(0.1)
                VirtualUser:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
            end)
            -- Heartbeat backup
            Connections["AutoAFK2"] = RunService.Heartbeat:Connect(function()
                if State.AutoAFK then
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.zero)
                    end)
                end
            end)
            Notify("Auto AFK", "Enabled! Won't get kicked.", 3)
        else
            StopConn("AutoAFK2")
            Notify("Auto AFK", "Disabled.", 2)
        end
    end,
})

TabFarm:CreateSection("ðŸ’° Auto Collect Cash")
TabFarm:CreateToggle({
    Name         = "Auto Collect All Cash",
    CurrentValue = false,
    Flag         = "AutoCollectCash",
    Description  = "Automatically collects money from all your brainrots",
    Callback     = function(val)
        State.AutoCollectCash = val
        StopConn("AutoCollectCash")
        if val then
            Connections["AutoCollectCash"] = task.spawn(function()
                while State.AutoCollectCash do
                    pcall(function()
                        -- Fire collect remotes
                        SafeFireRemote("collect")
                        SafeFireRemote("cash")
                        SafeFireRemote("money")
                        SafeFireRemote("income")
                        SafeFireRemote("claim")

                        -- Click collect buttons in GUI
                        ClickGuiButton("collect")
                        ClickGuiButton("claim")

                        -- Find and touch money parts
                        for _, v in pairs(Workspace:GetDescendants()) do
                            if v:IsA("BasePart") then
                                local n = v.Name:lower()
                                if n:find("coin") or n:find("cash") or n:find("money") or n:find("collectible") then
                                    pcall(function()
                                        Root.CFrame = CFrame.new(v.Position)
                                    end)
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
            Notify("Auto Collect", "Collecting all cash!", 3)
        else
            Notify("Auto Collect", "Stopped.", 2)
        end
    end,
})

TabFarm:CreateSection("ðŸŒ€ Auto Spawn Brainrot")
TabFarm:CreateToggle({
    Name         = "Auto Spawn Infinite Brainrot",
    CurrentValue = false,
    Flag         = "AutoSpawn",
    Description  = "Continuously spawns brainrots via the spawn machine",
    Callback     = function(val)
        State.AutoSpawn = val
        if val then
            task.spawn(function()
                while State.AutoSpawn do
                    pcall(function()
                        SafeFireRemote("spawn")
                        SafeFireRemote("brainrot")
                        SafeFireRemote("create")
                        SafeFireRemote("place")
                        ClickGuiButton("spawn")
                        SpawnCount = SpawnCount + 1
                    end)
                    task.wait(_G.SpawnDelay or 0.5)
                end
            end)
            Notify("Auto Spawn", "Infinite brainrot spawning ON!", 3)
        else
            Notify("Auto Spawn", "Spawning stopped. Total: " .. SpawnCount, 3)
        end
    end,
})

TabFarm:CreateButton({
    Name        = "ðŸ“Š Show Spawn Count",
    Description = "Shows total brainrots spawned this session",
    Callback    = function()
        Notify("Spawn Count", "Total Brainrots Spawned: " .. SpawnCount, 4)
    end,
})

TabFarm:CreateSection("ðŸŒŠ Auto Avoid Tsunami")
TabFarm:CreateToggle({
    Name         = "Auto Avoid Tsunami",
    CurrentValue = false,
    Flag         = "AutoAvoid",
    Description  = "Automatically teleports to the nearest safe zone when tsunami approaches",
    Callback     = function(val)
        State.AutoAvoidTsunami = val
        StopConn("AutoAvoid")
        if val then
            Connections["AutoAvoid"] = RunService.Heartbeat:Connect(function()
                pcall(function()
                    for _, v in pairs(Workspace:GetDescendants()) do
                        local n = v.Name:lower()
                        if n:find("tsunami") or n:find("wave") or n:find("water") then
                            if v:IsA("BasePart") then
                                local dist = (v.Position - Root.Position).Magnitude
                                if dist < 150 then
                                    -- Find safe zone and teleport
                                    local safe = FindPartByKeyword({"SafeZone", "Safe", "Shelter", "Base", "SpeedShop"})
                                    if safe then
                                        local p = (safe:IsA("Model") and safe:GetModelCFrame().Position) or safe.Position
                                        Root.CFrame = CFrame.new(p + Vector3.new(0, 10, 0))
                                    else
                                        -- Jump up high
                                        Root.CFrame = Root.CFrame + Vector3.new(0, 50, 0)
                                    end
                                end
                            end
                        end
                    end
                end)
            end)
            Notify("Auto Avoid", "Tsunami avoidance active!", 3)
        else
            Notify("Auto Avoid", "Disabled.", 2)
        end
    end,
})

-- ============================================================
-- TAB: RARE HUNT
-- ============================================================
TabRare:CreateSection("ðŸ” Auto Find Rare Brainrots")
TabRare:CreateLabel("Scans the map and teleports to rare brainrots")

TabRare:CreateToggle({
    Name         = "Auto Find SECRET Brainrot",
    CurrentValue = false,
    Flag         = "AutoFindSecret",
    Description  = "Constantly scans and teleports to Secret-rarity brainrots",
    Callback     = function(val)
        State.AutoFindSecret = val
        StopConn("FindSecret")
        if val then
            Connections["FindSecret"] = task.spawn(function()
                while State.AutoFindSecret do
                    pcall(function()
                        for _, v in pairs(Workspace:GetDescendants()) do
                            local n = v.Name:lower()
                            if n:find("secret") then
                                local pos = v:IsA("Model") and v:GetModelCFrame().Position or v.Position
                                if (pos - Root.Position).Magnitude > 10 then
                                    Root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
                                    SafeFireRemote("grab")
                                    SafeFireRemote("steal")
                                    SafeFireRemote("take")
                                    task.wait(0.3)
                                end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
            Notify("Auto Find", "Hunting SECRET brainrots!", 3)
        else
            Notify("Auto Find", "Stopped hunting Secrets.", 2)
        end
    end,
})

TabRare:CreateToggle({
    Name         = "Auto Find CELESTIAL Brainrot",
    CurrentValue = false,
    Flag         = "AutoFindCelestial",
    Description  = "Scans and teleports to Celestial-rarity brainrots",
    Callback     = function(val)
        State.AutoFindCelestial = val
        StopConn("FindCelestial")
        if val then
            Connections["FindCelestial"] = task.spawn(function()
                while State.AutoFindCelestial do
                    pcall(function()
                        for _, v in pairs(Workspace:GetDescendants()) do
                            if v.Name:lower():find("celestial") then
                                local pos = v:IsA("Model") and v:GetModelCFrame().Position or v.Position
                                Root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
                                SafeFireRemote("grab")
                                SafeFireRemote("steal")
                                task.wait(0.3)
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
            Notify("Auto Find", "Hunting CELESTIAL brainrots!", 3)
        else
            Notify("Auto Find", "Stopped hunting Celestials.", 2)
        end
    end,
})

TabRare:CreateToggle({
    Name         = "Auto Find DIVINE Brainrot",
    CurrentValue = false,
    Flag         = "AutoFindDivine",
    Description  = "Scans and teleports to Divine-rarity brainrots",
    Callback     = function(val)
        State.AutoFindDivine = val
        StopConn("FindDivine")
        if val then
            Connections["FindDivine"] = task.spawn(function()
                while State.AutoFindDivine do
                    pcall(function()
                        for _, v in pairs(Workspace:GetDescendants()) do
                            if v.Name:lower():find("divine") then
                                local pos = v:IsA("Model") and v:GetModelCFrame().Position or v.Position
                                Root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
                                SafeFireRemote("grab")
                                SafeFireRemote("steal")
                                task.wait(0.3)
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
            Notify("Auto Find", "Hunting DIVINE brainrots!", 3)
        else
            Notify("Auto Find", "Stopped hunting Divines.", 2)
        end
    end,
})

TabRare:CreateToggle({
    Name         = "Auto Find INFINITY Brainrot âœ¨",
    CurrentValue = false,
    Flag         = "AutoFindInfinity",
    Description  = "Scans and teleports to Infinity-rarity brainrots (rarest!)",
    Callback     = function(val)
        State.AutoFindInfinity = val
        StopConn("FindInfinity")
        if val then
            Connections["FindInfinity"] = task.spawn(function()
                while State.AutoFindInfinity do
                    pcall(function()
                        for _, v in pairs(Workspace:GetDescendants()) do
                            if v.Name:lower():find("infinity") then
                                local pos = v:IsA("Model") and v:GetModelCFrame().Position or v.Position
                                Root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
                                SafeFireRemote("grab")
                                SafeFireRemote("steal")
                                task.wait(0.3)
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
            Notify("Auto Find", "Hunting INFINITY brainrots! (rarest)", 3)
        else
            Notify("Auto Find", "Stopped hunting Infinity.", 2)
        end
    end,
})

TabRare:CreateSection("ðŸ”’ Delete Walls")
TabRare:CreateButton({
    Name        = "ðŸ’¥ Delete All Walls",
    Description = "Removes all blocking walls on the map so you can freely reach rare areas",
    Callback    = function()
        local removed = 0
        pcall(function()
            for _, v in pairs(Workspace:GetDescendants()) do
                local n = v.Name:lower()
                if n:find("wall") or n:find("barrier") or n:find("block") or n:find("gate") or n:find("door") then
                    if v:IsA("BasePart") and not v:IsDescendantOf(Char) then
                        v.CanCollide = false
                        v.Transparency = 0.8
                        removed = removed + 1
                    end
                end
            end
        end)
        Notify("Delete Walls", "Made " .. removed .. " walls passable!", 3)
    end,
})

TabRare:CreateButton({
    Name        = "ðŸ” Restore Walls",
    Description = "Restores wall collision (toggles back)",
    Callback    = function()
        pcall(function()
            for _, v in pairs(Workspace:GetDescendants()) do
                local n = v.Name:lower()
                if n:find("wall") or n:find("barrier") or n:find("block") or n:find("gate") then
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                        v.Transparency = 0
                    end
                end
            end
        end)
        Notify("Walls", "Walls restored.", 2)
    end,
})

-- ============================================================
-- TAB: EVENTS
-- ============================================================
TabEvent:CreateSection("ðŸŒ‹ Doom Event Automation")
TabEvent:CreateLabel("Auto handles Doom Event tasks (no doom button press)")

TabEvent:CreateToggle({
    Name         = "Auto Doom Event",
    CurrentValue = false,
    Flag         = "AutoDoomEvent",
    Description  = "Auto completes Doom Event by collecting coins, spinning wheel, and event tasks",
    Callback     = function(val)
        State.AutoDoomEvent = val
        StopConn("DoomEvent")
        if val then
            Connections["DoomEvent"] = task.spawn(function()
                while State.AutoDoomEvent do
                    pcall(function()
                        -- Collect doom event coins/tokens
                        for _, v in pairs(Workspace:GetDescendants()) do
                            local n = v.Name:lower()
                            if n:find("doincoin") or n:find("doomcoin") or n:find("eventcoin") or
                               n:find("coin") or n:find("token") or n:find("doom") then
                                if v:IsA("BasePart") then
                                    Root.CFrame = CFrame.new(v.Position + Vector3.new(0, 3, 0))
                                    task.wait(0.1)
                                end
                            end
                        end

                        -- Fire event-related remotes
                        SafeFireRemote("doomevent")
                        SafeFireRemote("doom")
                        SafeFireRemote("eventcoin")
                        SafeFireRemote("doomcoin")
                        SafeFireRemote("event")

                        -- Click doom event GUI buttons (excluding doom START button)
                        for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
                            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                                local n = gui.Name:lower()
                                local t = (gui.Text or ""):lower()
                                -- Skip buttons that would START doom
                                if not n:find("startdoom") and not t:find("start doom") then
                                    if n:find("event") or n:find("coin") or n:find("collect") or n:find("claim") then
                                        pcall(function() gui.MouseButton1Click:Fire() end)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.8)
                end
            end)
            Notify("Doom Event", "Auto Doom Event active!", 3)
        else
            Notify("Doom Event", "Stopped.", 2)
        end
    end,
})

TabEvent:CreateSection("ðŸŽ¡ Auto Spin Wheel")
TabEvent:CreateToggle({
    Name         = "Auto Spin Wheel",
    CurrentValue = false,
    Flag         = "AutoSpinWheel",
    Description  = "Automatically spins the lucky wheel",
    Callback     = function(val)
        State.AutoSpinWheel = val
        StopConn("SpinWheel")
        if val then
            Connections["SpinWheel"] = task.spawn(function()
                while State.AutoSpinWheel do
                    pcall(function()
                        SafeFireRemote("spin")
                        SafeFireRemote("wheel")
                        SafeFireRemote("spinwheel")
                        SafeFireRemote("luckywheel")
                        ClickGuiButton("spin")
                    end)
                    task.wait(3)
                end
            end)
            Notify("Spin Wheel", "Auto spinning the wheel!", 3)
        else
            Notify("Spin Wheel", "Stopped.", 2)
        end
    end,
})

TabEvent:CreateSection("ðŸª™ Auto Coin")
TabEvent:CreateToggle({
    Name         = "Auto Coin Collect",
    CurrentValue = false,
    Flag         = "AutoCoin",
    Description  = "Automatically collects coins that appear during events",
    Callback     = function(val)
        State.AutoCoin = val
        StopConn("AutoCoin")
        if val then
            Connections["AutoCoin"] = RunService.Heartbeat:Connect(function()
                pcall(function()
                    for _, v in pairs(Workspace:GetDescendants()) do
                        if v:IsA("BasePart") then
                            local n = v.Name:lower()
                            if n:find("coin") or n:find("eventitem") or n:find("lucky") then
                                if (v.Position - Root.Position).Magnitude < 300 then
                                    Root.CFrame = CFrame.new(v.Position + Vector3.new(0, 3, 0))
                                end
                            end
                        end
                    end
                end)
            end)
            Notify("Auto Coin", "Collecting coins automatically!", 3)
        else
            Notify("Auto Coin", "Stopped.", 2)
        end
    end,
})

-- ============================================================
-- TAB: UPGRADES
-- ============================================================
TabUpgrade:CreateSection("â¬†ï¸ Auto Upgrade All")
TabUpgrade:CreateToggle({
    Name         = "Auto Upgrade All",
    CurrentValue = false,
    Flag         = "AutoUpgradeAll",
    Description  = "Automatically upgrades base, carry, and all available upgrades",
    Callback     = function(val)
        State.AutoUpgradeAll = val
        StopConn("AutoUpgrade")
        if val then
            Connections["AutoUpgrade"] = task.spawn(function()
                while State.AutoUpgradeAll do
                    pcall(function()
                        SafeFireRemote("upgrade")
                        SafeFireRemote("upgradall")
                        SafeFireRemote("upgradebase")
                        SafeFireRemote("upgradecarry")
                        SafeFireRemote("buyupgrade")

                        -- Click upgrade buttons in GUI
                        for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
                            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                                local n = gui.Name:lower()
                                local t = (gui.Text or ""):lower()
                                if n:find("upgrade") or t:find("upgrade") or t:find("buy") then
                                    pcall(function() gui.MouseButton1Click:Fire() end)
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
            Notify("Auto Upgrade", "Upgrading everything!", 3)
        else
            Notify("Auto Upgrade", "Stopped.", 2)
        end
    end,
})

TabUpgrade:CreateSection("ðŸ° Auto Tower")
TabUpgrade:CreateToggle({
    Name         = "Auto Tower (Build & Upgrade)",
    CurrentValue = false,
    Flag         = "AutoTower",
    Description  = "Automatically builds and upgrades your tower/base floors",
    Callback     = function(val)
        State.AutoTower = val
        StopConn("AutoTower")
        if val then
            Connections["AutoTower"] = task.spawn(function()
                while State.AutoTower do
                    pcall(function()
                        SafeFireRemote("tower")
                        SafeFireRemote("buildtower")
                        SafeFireRemote("upgradetower")
                        SafeFireRemote("addfloor")
                        SafeFireRemote("floor")
                        SafeFireRemote("base")

                        for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
                            if gui:IsA("TextButton") then
                                local t = (gui.Text or ""):lower()
                                local n = gui.Name:lower()
                                if t:find("tower") or n:find("tower") or t:find("floor") or t:find("build") then
                                    pcall(function() gui.MouseButton1Click:Fire() end)
                                end
                            end
                        end
                    end)
                    task.wait(1.5)
                end
            end)
            Notify("Auto Tower", "Building & upgrading tower!", 3)
        else
            Notify("Auto Tower", "Stopped.", 2)
        end
    end,
})

TabUpgrade:CreateSection("ðŸ” Auto Rebirth")
TabUpgrade:CreateToggle({
    Name         = "Auto Rebirth",
    CurrentValue = false,
    Flag         = "AutoRebirth",
    Description  = "Automatically rebirths when eligible to reset and gain bonuses",
    Callback     = function(val)
        State.AutoRebirth = val
        StopConn("AutoRebirth")
        if val then
            Connections["AutoRebirth"] = task.spawn(function()
                while State.AutoRebirth do
                    pcall(function()
                        SafeFireRemote("rebirth")
                        SafeFireRemote("prestige")
                        SafeFireRemote("reset")

                        for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
                            if gui:IsA("TextButton") then
                                local t = (gui.Text or ""):lower()
                                local n = gui.Name:lower()
                                if t:find("rebirth") or n:find("rebirth") or t:find("prestige") then
                                    pcall(function() gui.MouseButton1Click:Fire() end)
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end
            end)
            Notify("Auto Rebirth", "Will rebirth when eligible!", 3)
        else
            Notify("Auto Rebirth", "Stopped.", 2)
        end
    end,
})

TabUpgrade:CreateSection("ðŸ’¨ Auto +10 Speed")
TabUpgrade:CreateToggle({
    Name         = "Auto Buy +10 Speed",
    CurrentValue = false,
    Flag         = "AutoSpeed10",
    Description  = "Constantly buys +10 speed upgrades to max your movement speed",
    Callback     = function(val)
        State.AutoSpeed10 = val
        StopConn("AutoSpeed")
        if val then
            Connections["AutoSpeed"] = task.spawn(function()
                while State.AutoSpeed10 do
                    pcall(function()
                        SafeFireRemote("speed")
                        SafeFireRemote("buyspeed")
                        SafeFireRemote("speedupgrade")
                        SafeFireRemote("addspeed")

                        for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
                            if gui:IsA("TextButton") then
                                local t = (gui.Text or ""):lower()
                                local n = gui.Name:lower()
                                if (t:find("+10") and t:find("speed")) or n:find("speed10") or
                                   (n:find("speed") and n:find("10")) or t:find("speed +10") then
                                    pcall(function() gui.MouseButton1Click:Fire() end)
                                end
                            end
                        end
                    end)
                    task.wait(0.3)
                end
            end)
            Notify("Auto Speed", "Buying +10 speed continuously!", 3)
        else
            Notify("Auto Speed", "Stopped.", 2)
        end
    end,
})

TabUpgrade:CreateButton({
    Name        = "ðŸƒ Max Speed Instantly",
    Description = "Fire speed remote as fast as possible 100 times",
    Callback    = function()
        task.spawn(function()
            for i = 1, 100 do
                pcall(function()
                    SafeFireRemote("speed")
                    SafeFireRemote("buyspeed")
                    SafeFireRemote("speedupgrade")
                end)
                task.wait(0.05)
            end
            Notify("Speed Boost", "Fired 100 speed upgrades!", 3)
        end)
    end,
})

-- ============================================================
-- TAB: MISC
-- ============================================================
TabMisc:CreateSection("ðŸ–¥ï¸ FPS Boost")
TabMisc:CreateToggle({
    Name         = "FPS Boost",
    CurrentValue = false,
    Flag         = "FPSBoost",
    Description  = "Reduces visual quality to maximize FPS",
    Callback     = function(val)
        State.FPSBoost = val
        if val then
            settings().Rendering.QualityLevel = 1
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                    v.Enabled = false
                end
            end
            Notify("FPS Boost", "Performance mode ON!", 3)
        else
            settings().Rendering.QualityLevel = 10
            Lighting.GlobalShadows = true
            Notify("FPS Boost", "Normal quality restored.", 2)
        end
    end,
})

TabMisc:CreateSection("ðŸŽ¯ Misc Actions")
TabMisc:CreateButton({
    Name        = "ðŸ”ƒ Rejoin Server",
    Description = "Rejoins the current game",
    Callback    = function()
        TeleportSvc:Teleport(game.PlaceId, LP)
    end,
})

TabMisc:CreateButton({
    Name        = "ðŸ’€ Reset Character",
    Description = "Resets your character",
    Callback    = function()
        if Humanoid then
            Humanoid.Health = 0
            Notify("Reset", "Character reset!", 2)
        end
    end,
})

TabMisc:CreateButton({
    Name        = "ðŸ›‘ Stop All Scripts",
    Description = "Disables all active automations",
    Callback    = function()
        for k, _ in pairs(State) do
            State[k] = false
        end
        for k, conn in pairs(Connections) do
            pcall(function() conn:Disconnect() end)
            Connections[k] = nil
        end
        Notify("Stop All", "All automations stopped!", 3)
    end,
})

TabMisc:CreateSection("ðŸ“ Teleport Quick Access")
TabMisc:CreateButton({
    Name = "ðŸŒŸ TP to Secret Area",
    Callback = function()
        local p = FindPartByKeyword({"SecretArea", "Secret_Area", "Secret", "GapSecret"})
        if p then
            local pos = p:IsA("Model") and p:GetModelCFrame().Position or p.Position
            Root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
            Notify("Teleport", "Teleported to Secret area!", 2)
        else
            Notify("Teleport", "Secret area not found. Try when brainrot is spawned.", 3)
        end
    end,
})

TabMisc:CreateButton({
    Name = "âœ¨ TP to Celestial Area",
    Callback = function()
        local p = FindPartByKeyword({"CelestialArea", "Celestial_Area", "Celestial"})
        if p then
            local pos = p:IsA("Model") and p:GetModelCFrame().Position or p.Position
            Root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
            Notify("Teleport", "Teleported to Celestial area!", 2)
        else
            Notify("Teleport", "Celestial area not found.", 3)
        end
    end,
})

TabMisc:CreateButton({
    Name = "ðŸ‘‘ TP to Divine Area",
    Callback = function()
        local p = FindPartByKeyword({"DivineArea", "Divine_Area", "Divine"})
        if p then
            local pos = p:IsA("Model") and p:GetModelCFrame().Position or p.Position
            Root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
            Notify("Teleport", "Teleported to Divine area!", 2)
        else
            Notify("Teleport", "Divine area not found.", 3)
        end
    end,
})

TabMisc:CreateButton({
    Name = "â™¾ï¸ TP to Infinity Area",
    Callback = function()
        local p = FindPartByKeyword({"InfinityArea", "Infinity_Area", "Infinity"})
        if p then
            local pos = p:IsA("Model") and p:GetModelCFrame().Position or p.Position
            Root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
            Notify("Teleport", "Teleported to Infinity area!", 2)
        else
            Notify("Teleport", "Infinity area not found.", 3)
        end
    end,
})

-- ============================================================
-- TAB: SETTINGS
-- ============================================================
TabSettings:CreateSection("âš™ï¸ Speed Settings")
TabSettings:CreateSlider({
    Name         = "Spawn Delay (seconds)",
    Range        = {0.1, 5},
    Increment    = 0.1,
    Suffix       = "s",
    CurrentValue = 0.5,
    Flag         = "SpawnDelay",
    Callback     = function(val)
        _G.SpawnDelay = val
    end,
})

TabSettings:CreateSlider({
    Name         = "Walk Speed Override",
    Range        = {16, 500},
    Increment    = 1,
    Suffix       = " studs/s",
    CurrentValue = 16,
    Flag         = "WalkSpeed",
    Callback     = function(val)
        if Humanoid then
            Humanoid.WalkSpeed = val
        end
    end,
})

TabSettings:CreateSlider({
    Name         = "Jump Power Override",
    Range        = {50, 500},
    Increment    = 10,
    Suffix       = "",
    CurrentValue = 50,
    Flag         = "JumpPower",
    Callback     = function(val)
        if Humanoid then
            Humanoid.JumpPower = val
        end
    end,
})

TabSettings:CreateSection("ðŸ’¾ Config")
TabSettings:CreateButton({
    Name        = "ðŸ’¾ Save Config",
    Description = "Saves all current toggle states",
    Callback    = function()
        Rayfield:SaveConfiguration()
        Notify("Config", "Configuration saved!", 2)
    end,
})

TabSettings:CreateButton({
    Name        = "ðŸ—‘ï¸ Destroy UI",
    Description = "Removes this UI entirely",
    Callback    = function()
        Rayfield:Destroy()
    end,
})

-- ============================================================
-- INIT
-- ============================================================
_G.SpawnDelay = 0.5
Rayfield:LoadConfiguration()

Notify(
    "ðŸŒŠ Tsunami Brainrot Hub v2.0",
    "Loaded! Use the tabs to enable features. Good luck hunting Infinity brainrots! ðŸŽ¯",
    6