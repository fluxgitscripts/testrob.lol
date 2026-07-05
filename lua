local CHECK_INTERVAL = 3
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local PlaceId = game.PlaceId

local request = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request
local queue_on_teleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport



local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer


local SERVER_HISTORY_FILE = "Flux_ServerHistory.json"
local MAX_HISTORY_SIZE = 20


local function loadServerHistory()
    if isfile and isfile(SERVER_HISTORY_FILE) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(SERVER_HISTORY_FILE))
        end)
        if success and type(data) == "table" then
            return data
        end
    end
    return {}
end

local function saveServerHistory(history)
    if writefile then
        pcall(function()
            writefile(SERVER_HISTORY_FILE, HttpService:JSONEncode(history))
        end)
    end
end


local function addCurrentServerToHistory()
    local currentJobId = game.JobId
    if not currentJobId then return end
    
    local history = loadServerHistory()
    

    for _, serverId in ipairs(history) do
        if serverId == currentJobId then
            return
        end
    end
    

    table.insert(history, 1, currentJobId)
    

    if #history > MAX_HISTORY_SIZE then
        table.remove(history)
    end
    
    saveServerHistory(history)
end

local function findNewServer()
    local currentJobId = game.JobId
    local history = loadServerHistory()
    
    local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100", game.PlaceId)
    
    local success, result = pcall(function()
        local response = game:HttpGet(url)
        return HttpService:JSONDecode(response)
    end)
    
    if not success or not result or not result.data then
        warn("[ServerHop] Error calling ServerList API")
        return nil
    end
    
    local goodServers = {}
    local anyServers = {}    
    
    print(string.format("[ServerHop] Found Server: %d", #result.data))
    
    for _, server in ipairs(result.data) do
        if server.id and server.playing and server.maxPlayers then
            local serverId = tostring(server.id)
            
            local inHistory = false
            for _, histId in ipairs(history) do
                if histId == serverId then
                    inHistory = true
                    break
                end
            end
            
            if serverId ~= currentJobId and not inHistory then
                if server.playing < server.maxPlayers and server.playing > 1 then
                    table.insert(anyServers, server)
                    if server.playing >= 15 then
                        table.insert(goodServers, server)
                    end
                end
            end
        end
    end
    
    print(string.format("[ServerHop] Available Server: %d (Good Servers: %d)", #anyServers, #goodServers))
    
    if #goodServers > 0 then
        local selected = goodServers[math.random(1, #goodServers)]
        print(string.format("[ServerHop] Good Server were choosen: %s (%d/%d Player)", selected.id, selected.playing, selected.maxPlayers))
        return selected
    elseif #anyServers > 0 then
        local selected = anyServers[math.random(1, #anyServers)]
        print(string.format("[ServerHop] Choosed Server: %s (%d/%d Player)", selected.id, selected.playing, selected.maxPlayers))
        return selected
    end
    
    return nil
end


local function performServerHop()
    print("[ServerHop] Starting Serverhop...")
    
    addCurrentServerToHistory()
    
    local payload = [[
        wait(3)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/fluxgitscripts/Flux-Autorob/refs/heads/main/main.lua"))()
    ]]
    
    local q = queue_on_teleport or (syn and syn.queue_on_teleport)
    if q then
        q(payload)
        print("[ServerHop] Auto-Execution for next Server set up.")
    end



    player:Kick("Made by zzkxnsti Searching for new Server. ServerHop happens automatically...")                    
	task.wait(1.5)  


    local newServer = findNewServer()
    
    if newServer then
        print(string.format("[ServerHop] Teleport tried to server %s", newServer.id))
        
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, newServer.id, player)
        end)
        
        if not success then
            warn("[ServerHop] Direct Teleport countered an error: " .. err)
            
            task.wait(2)
            
            pcall(function()
                TeleportService:Teleport(game.PlaceId, player)
            end)
        end
    else
        print("[ServerHop] No Server found → Normal Teleport")
        task.wait(1)
        
        pcall(function()
            TeleportService:Teleport(game.PlaceId, player)
        end)
    end
end


local function notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 2 
    })
end
local PrisonMessageSent = false
task.spawn(function()
    while true do
        local team = player.Team
        if team then
            if team.Name == "Prisoner" then
                if PrisonMessageSent == false then
                    notify("Flux AutoRob", "You are in the Prison - Waiting for release.")
                    PrisonMessageSent = true
                end
                warn("[Prison Check] Team: Prisoner")
            elseif team.Name == "Citizen" then
                notify("Flux AutoRob", "Starting AutoRob...")  
                if game.PlaceId == 7711635737 then
                task.wait(0.5)

                local OrionLib = loadstring(game:HttpGet('https://moon-hub.pages.dev/orion.lua'))()
                local Win = OrionLib:MakeWindow({
                    Name = "Flux Autorob ・ discord.gg/CNWUHTeaYc",
                    IntroEnabled = false,
                })

                local InfosTab = Win:MakeTab({
                    Name = "Infos",
                    Icon = "rbxassetid://110571167375107",
                    PremiumOnly = false,
                })

                local AutoRobTab = Win:MakeTab({
                    Name = "AutoRob",
                    Icon = "rbxassetid://76479561414083",
                    PremiumOnly = false,
                })

                local Section1 = AutoRobTab:AddSection({
                    Name = "AutoRob",
                })
                local Section = InfosTab:AddSection({
                    Name = 'General'
                })

                AutoRobTab:AddParagraph("Important", 'Please read "Infos" before starting AutoRob!')

                InfosTab:AddParagraph("Bomb Issue", "If you got the problem that it buys much bombs, please dont\nopen a ticket. Im working on it!")

                local Section = InfosTab:AddSection({
                    Name = "Others"
                })
                InfosTab:AddParagraph("Other Problems", "If you got any other problems, please open a ticket in our\nDiscord Server")
                InfosTab:AddParagraph("Important", 'This Autorob is in the Early Stage, so expect some bugs and issues. Please report them in our Discord Server!')
                InfosTab:AddLabel("AutoRob V1.1")

                local configFileName = "FluxAutoRob_config5.json"

                local autorobBankClubToggle = false
                local autorobContainersToggle = false
                local autoSellToggle = false
                local tweenSpeed = 175  
                local abortHealth = 47  
                local plrTweenSpeed = 50
                local policeAbort = 25
                local bombDetectionEnabled = true
                local PlayerTeleportEnabled = true

                local function loadConfig()
                    if isfile(configFileName) then
                        local data = readfile(configFileName)
                        local success, config = pcall(function() return game:GetService("HttpService"):JSONDecode(data) end)
                        if success and config then
                            autorobBankClubToggle = config.autorobBankClubToggle or false
                            autorobContainersToggle = config.autorobContainersToggle or false
                            autoSellToggle = config.autoSellToggle or false
                            tweenSpeed = tonumber(config.tweenSpeed) or tweenSpeed
                            plrTweenSpeed = tonumber(config.plrTweenSpeed) or plrTweenSpeed
                            abortHealth = tonumber(config.abortHealth) or abortHealth
                            policeAbort = tonumber(config.policeAbort) or policeAbort
                            if config.bombDetectionEnabled ~= nil then
                                bombDetectionEnabled = config.bombDetectionEnabled
                            end
                        end
                    end
                end

                local function saveConfig()
                    local config = {
                        autorobBankClubToggle = autorobBankClubToggle,
                        autorobContainersToggle = autorobContainersToggle,
                        autoSellToggle = autoSellToggle,
                        plrTweenSpeed = plrTweenSpeed,
                        tweenSpeed = tweenSpeed,
                        abortHealth = abortHealth,
                        policeAbort = policeAbort,
                        bombDetectionEnabled = bombDetectionEnabled,
                    }
                    local json = game:GetService("HttpService"):JSONEncode(config)
                    writefile(configFileName, json)
                end

                loadConfig()

                AutoRobTab:AddToggle({
                    Name = "AutoRob",
                    Default = autorobBankClubToggle,
                    Callback = function(Value)
                        autorobBankClubToggle = Value
                        saveConfig()
                    end    
                })

                local Section = AutoRobTab:AddSection({
                    Name = 'Options'
                })
                AutoRobTab:AddToggle({
                    Name = "Auto Sell",
                    Default = autoSellToggle,
                    Callback = function(Value)
                        autoSellToggle = Value
                        saveConfig()
                    end    
                })

                AutoRobTab:AddToggle({
                    Name = "Bomb Nearby Check",
                    Default = bombDetectionEnabled,
                    Callback = function(Value)
                        bombDetectionEnabled = Value
                        saveConfig()
                    end
                })

                AutoRobTab:AddToggle({
                    Name = "Fast Player Teleports",
                    Default = true,
                    Callback = function(Value)
                        PlayerTeleportEnabled = Value
                    end
                })

                local Section = AutoRobTab:AddSection({
                    Name = 'Settings'
                })
                AutoRobTab:AddSlider({
                    Name = "Teleport Speed",
                    Min = 50,
                    Max = 185,
                    Default = tweenSpeed,
                    Increment = 5,
                    ValueName = "Speed",
                    Color = Color3.fromRGB(137, 207, 240),
                    Callback = function(Value)
                        tweenSpeed = Value
                        saveConfig()
                        print("Tween Speed set to: " .. Value)
                    end    
                })

                AutoRobTab:AddSlider({
                    Name = "Police Abort Distance",
                    Min = 5,
                    Max = 100,
                    Default = policeAbort,
                    Increment = 1,
                    ValueName = "Studs",
                    Color = Color3.fromRGB(137, 207, 240),
                    Callback = function(Value)
                        policeAbort = Value
                        saveConfig()
                        print("Police Abort Distance set to: " .. Value .. " Studs")
                    end    
                })

                AutoRobTab:AddSlider({
                    Name = "Player Movement Speed",
                    Min = 10,
                    Max = 50,
                    Default = plrTweenSpeed,
                    Increment = 1,
                    ValueName = "Speed",
                    Color = Color3.fromRGB(137, 207, 240),
                    Callback = function(Value)
                        plrTweenSpeed = Value
                        saveConfig()
                        print("Player Movement Speed set to: " .. Value)
                    end    
                })

                AutoRobTab:AddSlider({
                    Name = "Abort at Health",
                    Min = 25,
                    Max = 80,
                    Default = abortHealth,
                    Increment = 1,
                    ValueName = "HP",
                    Color = Color3.fromRGB(137, 207, 240),
                    Callback = function(Value)
                        abortHealth = Value
                        saveConfig()
                        print("Abort Health set to: " .. Value .. " HP")
                    end    
                })

                local plr = game:GetService("Players").LocalPlayer
                local buyRemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("EJw"):WaitForChild("29c2c390-e58d-4512-9180-2da58f0d98d8")
                local EquipRemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("EJw"):WaitForChild("b16cb2a5-7735-4e84-a72b-22718da109fc")
                local fireBombRemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("EJw"):WaitForChild("66291b15-ebda-4dbd-964e-cc89f86d2c82")
                local robRemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("GpP"):WaitForChild("0583c22f-b7b6-4a6b-9844-bad9657f2996")
                local sellRemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("EJw"):WaitForChild("eb233e6a-acb9-4169-acb9-129fe8cb06bb")
                local ProximityPromptTimeBet = 2.5
                local VirtualInputManager = game:GetService("VirtualInputManager")
                local key = Enum.KeyCode.E
                local TweenService = game:GetService("TweenService")
                local VirtualInputManager = game:GetService("VirtualInputManager")

                local function checkForBomb()
                    if not bombDetectionEnabled then return false end

                    local player = game.Players.LocalPlayer
                    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                        return false
                    end

                    local playerPos = player.Character.HumanoidRootPart.Position

                    local foldersToCheck = {
                        workspace.Objects and workspace.Objects.Throwables and workspace.Objects.Throwables:FindFirstChild("Bomb"),
                        workspace.Objects and workspace.Objects.Throwables and workspace.Objects.Throwables:FindFirstChild("Grenade")
                    }

                    for _, folder in ipairs(foldersToCheck) do
                        if folder then
                            for _, bombModel in ipairs(folder:GetChildren()) do
                                local shouldIgnore = false

                                local mainPart = bombModel:FindFirstChild("Main")
                                if mainPart and mainPart:IsA("BasePart") then
                                    local color = mainPart.Color
                                    if math.floor(color.R * 255) == 27 and
                                       math.floor(color.G * 255) == 42 and
                                       math.floor(color.B * 255) == 53 then
                                        shouldIgnore = true
                                    end
                                end

                                if not shouldIgnore then
                                    local bombPart = bombModel:FindFirstChild("Handle") or
                                        bombModel:FindFirstChild("MainPart") or
                                        bombModel:FindFirstChildWhichIsA("BasePart")

                                    if bombPart then
                                        if (bombPart.Position - playerPos).Magnitude <= 5 then
                                            return true
                                        end
                                    else
                                        for _, part in ipairs(bombModel:GetDescendants()) do
                                            if part:IsA("BasePart") then
                                                if (part.Position - playerPos).Magnitude <= 5 then
                                                    return true
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    return false
                end

                local function SpawnBomb()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                    task.wait(0.5)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end

                local function JumpOut()
                    local Players = game:GetService("Players")
                    local LocalPlayer = Players.LocalPlayer    
                    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    if character then
                        local humanoid = character:FindFirstChild("Humanoid")
                        if humanoid and humanoid.SeatPart then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end

                local function ensurePlayerInVehicle()
                    local player = game:GetService("Players").LocalPlayer
                    local vehicle = workspace:FindFirstChild("Vehicles") and workspace.Vehicles:FindFirstChild(player.Name)
                    local character = player.Character or player.CharacterAdded:Wait()

                    if vehicle and character then
                        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                        local driveSeat = vehicle:FindFirstChild("DriveSeat")

                        if humanoid and driveSeat and humanoid.SeatPart ~= driveSeat then
                            driveSeat:Sit(humanoid)
                        end
                    end
                end

                local function clickAtCoordinates(scaleX, scaleY, duration)
                    local camera = game.Workspace.CurrentCamera
                    local screenWidth = camera.ViewportSize.X
                    local screenHeight = camera.ViewportSize.Y
                    local VirtualInputManager = game:GetService("VirtualInputManager")
                    local absoluteX = screenWidth * scaleX
                    local absoluteY = screenHeight * scaleY
                            
                    VirtualInputManager:SendMouseButtonEvent(absoluteX, absoluteY, 0, true, game, 0)  
                                
                    if duration and duration > 0 then
                        task.wait(duration)  
                    end
                                
                    VirtualInputManager:SendMouseButtonEvent(absoluteX, absoluteY, 0, false, game, 0) 
                end

                local function plrTween(destination)
                    local plr = game.Players.LocalPlayer
                    local char = plr.Character

                    if not char or not char.PrimaryPart then
                        warn("Character or PrimaryPart not available.")
                        return
                    end

                    local distance = (char.PrimaryPart.Position - destination).Magnitude

                    if PlayerTeleportEnabled and distance < 25 then
                        char:PivotTo(CFrame.new(destination))
                        return
                    end

                    local tweenDuration = distance / plrTweenSpeed

                    local TweenInfoToUse = TweenInfo.new(
                        tweenDuration,
                        Enum.EasingStyle.Linear,
                        Enum.EasingDirection.Out
                    )

                    local TweenValue = Instance.new("CFrameValue")
                    TweenValue.Value = char:GetPivot()

                    TweenValue.Changed:Connect(function(newCFrame)
                        char:PivotTo(newCFrame)
                    end)

                    local targetCFrame = CFrame.new(destination)
                    local tween = TweenService:Create(TweenValue, TweenInfoToUse, { Value = targetCFrame })

                    tween:Play()

                    tween.Completed:Wait()
                    TweenValue:Destroy()
                end

                local function interactWithVisibleMeshParts(folder)
                    if not folder then return end
                    local player = game.Players.LocalPlayer
                    local policeTeam = game:GetService("Teams"):FindFirstChild("Police")
                    if not policeTeam then return end
                    
                    local function isPoliceNearby()
                        for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
                            if plr.Team == policeTeam and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                                local distance = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                                if distance <= policeAbort then
                                    return true
                                end
                            end
                        end
                        return false
                    end

                    local meshParts = {}

                    for _, meshPart in ipairs(folder:GetChildren()) do
                        if meshPart:IsA("MeshPart") and meshPart.Transparency == 0 then
                            table.insert(meshParts, meshPart)
                        end
                    end

                    table.sort(meshParts, function(a, b)
                        local aDist = (a.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        local bDist = (b.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        return aDist < bDist
                    end)

                    for _, meshPart in ipairs(meshParts) do
                        if checkForBomb() then
                            game.StarterGui:SetCore("SendNotification", {
                                Title = "Bomb Detected",
                                Text = "Interaction aborted",
                                Duration = 3
                            })
                            return
                        end

                        if isPoliceNearby() then
                            game.StarterGui:SetCore("SendNotification", {
                                Title = "Police is nearby",
                                Text = "Interaction aborted",
                            })
                            return
                        end

                        if player.Character.Humanoid.Health <= abortHealth then
                            game.StarterGui:SetCore("SendNotification", {
                                Title = "Player is hurt",
                                Text = "Interaction aborted",
                            })
                            return
                        end

                        if meshPart.Transparency == 1 then
                            continue
                        end

                        if meshPart.Parent.Name == "Money" then
                            local args = {meshPart, "wEW", true}
                            robRemoteEvent:FireServer(unpack(args))
                            task.wait(ProximityPromptTimeBet)
                            args[3] = false
                            robRemoteEvent:FireServer(unpack(args))
                        else
                            local args = {meshPart, "2Lo", true}
                            robRemoteEvent:FireServer(unpack(args))
                            task.wait(ProximityPromptTimeBet)
                            args[3] = false
                            robRemoteEvent:FireServer(unpack(args))
                        end
                    end
                end

                local function interactWithVisibleMeshParts2(folder)
                    if not folder then return end
                    local player = game.Players.LocalPlayer
                    local policeTeam = game:GetService("Teams"):FindFirstChild("Police")
                    if not policeTeam then return end

                    local function isPoliceNearby()
                        for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
                            if plr.Team == policeTeam and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                                local distance = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                                if distance <= policeAbort then
                                    return true
                                end
                            end
                        end
                        return false
                    end

                    local meshParts = {}
                    for _, meshPart in ipairs(folder:GetChildren()) do
                        if meshPart:IsA("MeshPart") and meshPart.Transparency == 0 then
                            table.insert(meshParts, meshPart)
                        end
                    end

                    table.sort(meshParts, function(a, b)
                        local aDist = (a.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        local bDist = (b.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        return aDist < bDist
                    end)

                    for i, meshPart in ipairs(meshParts) do
                        if checkForBomb() then
                            game.StarterGui:SetCore("SendNotification", {
                                Title = "Bomb Detected",
                                Text = "Interaction aborted",
                                Duration = 3
                            })
                            return
                        end

                        if isPoliceNearby() then
                            game.StarterGui:SetCore("SendNotification", {
                                Title = "Police is nearby",
                                Text = "Interaction aborted",
                            })
                            return
                        end

                        if player.Character.Humanoid.Health <= abortHealth then
                            game.StarterGui:SetCore("SendNotification", {
                                Title = "Player is hurt",
                                Text = "Interaction aborted",
                            })
                            return
                        end

                        if meshPart.Transparency == 1 then
                            return
                        end

                        plrTween(meshPart.Position)
                        if meshPart.Parent.Name == "Money" then
                            local args3 = {
                                [1] = meshPart,
                                [2] = "wEW",
                                [3] = true,
                            }
                            robRemoteEvent:FireServer(unpack(args3))
                            task.wait(ProximityPromptTimeBet)
                            args3[3] = false
                            robRemoteEvent:FireServer(unpack(args3))
                        else
                            local args4 = {
                                [1] = meshPart,
                                [2] = "2Lo",
                                [3] = true
                            }
                            robRemoteEvent:FireServer(unpack(args4))
                            task.wait(ProximityPromptTimeBet)
                            args4[3] = false
                            robRemoteEvent:FireServer(unpack(args4))
                        end

                        task.wait(0.1)
                    end
                end

                local function startAutoCollect()
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local Workspace = game:GetService("Workspace")
                    local Players = game:GetService("Players")

                    local Player = Players.LocalPlayer
                    local Character = Player.Character or Player.CharacterAdded:Wait()
                    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

                    local Collected = {}
                    local ProximityPromptTimeBet = 2.5
                    local Range = 30
                    local Robberies = {}

                    for _, d in ipairs(Workspace:GetDescendants()) do
                        if d:IsA("Folder") then
                            local n = d.Name:lower()
                            if n:find("robbery") or n:find("robberies") then
                                table.insert(Robberies, d)
                            end
                        end
                    end

                    Workspace.DescendantAdded:Connect(function(d)
                        if d:IsA("Folder") then
                            local n = d.Name:lower()
                            if n:find("robbery") or n:find("robberies") then
                                table.insert(Robberies, d)
                            end
                        end
                    end)

                    local function loot(folder)
                        for _, m in ipairs(folder:GetDescendants()) do
                            if m:IsA("MeshPart") and m.Transparency == 0 then
                                if HumanoidRootPart and not Collected[m] and (m.Position - HumanoidRootPart.Position).Magnitude <= Range then
                                    Collected[m] = true
                                    task.spawn(function()
                                        local a
                                        if m.Parent and m.Parent.Name == "Money" then
                                            a = {m, "wEW", true}
                                        else
                                            a = {m, "2Lo", true}
                                        end
                                        robRemoteEvent:FireServer(unpack(a))
                                        task.wait(ProximityPromptTimeBet)
                                        a[3] = false
                                        robRemoteEvent:FireServer(unpack(a))
                                        if m and m.Parent and m.Transparency == 0 then
                                            Collected[m] = nil
                                        end
                                    end)
                                end
                            end
                        end
                    end

                    while autorobBankClubToggle or autorobContainersToggle do
                        for _, r in ipairs(Robberies) do
                            if r and r.Parent then
                                loot(r)
                            end
                        end
                        task.wait(0.5)
                    end
                end

                -- ============================================================
                -- NEUES TWEEN (instant drop auf Y=-5, dann linear zum Ziel)
                -- ============================================================
                local function tweenTo(destination)
                    local plr = game.Players.LocalPlayer
                    local car = Workspace.Vehicles[plr.Name]

                    car:SetAttribute("ParkingBrake", true)
                    car:SetAttribute("Locked", true)

                    car.PrimaryPart = car:FindFirstChild("DriveSeat", true)
                    local driveSeat = car.DriveSeat
                    driveSeat:Sit(plr.Character.Humanoid)

                    -- Step 1: INSTANT drop auf Y=-5, kein Tween
                    -- Egal ob auf Gebäude Y=40 oder Boden Y=5 — sofort runter
                    local currentPivot = car:GetPivot()
                    local dropY = -5
                    car:PivotTo(CFrame.new(Vector3.new(currentPivot.X, dropY, currentPivot.Z)))
                    driveSeat.AssemblyLinearVelocity = Vector3.zero
                    driveSeat.AssemblyAngularVelocity = Vector3.zero
                    task.wait(0.05)

                    -- Step 2: Linear tween von Y=-5 direkt zum Ziel, konstante Geschwindigkeit
                    local startPos = Vector3.new(currentPivot.X, dropY, currentPivot.Z)
                    local distance = (startPos - destination).Magnitude

                    if distance > 0.5 then
                        local speedVariance = tweenSpeed * (0.92 + math.random() * 0.16)
                        local tweenDuration = distance / speedVariance

                        local TweenInfoToUse = TweenInfo.new(
                            tweenDuration,
                            Enum.EasingStyle.Linear,
                            Enum.EasingDirection.Out
                        )

                        local TweenValue = Instance.new("CFrameValue")
                        TweenValue.Value = car:GetPivot()

                        TweenValue.Changed:Connect(function(newCFrame)
                            car:PivotTo(newCFrame)
                            -- Minimaler Jitter für natürlicheres Verhalten
                            local jitter = Vector3.new(
                                (math.random() - 0.5) * 0.08,
                                0,
                                (math.random() - 0.5) * 0.08
                            )
                            driveSeat.AssemblyLinearVelocity  = jitter
                            driveSeat.AssemblyAngularVelocity = Vector3.zero
                        end)

                        local tween = TweenService:Create(
                            TweenValue,
                            TweenInfoToUse,
                            { Value = CFrame.new(destination) }
                        )

                        tween:Play()
                        tween.Completed:Wait()
                        TweenValue:Destroy()
                    end

                    -- Exakt auf Zielposition setzen
                    car:PivotTo(CFrame.new(destination))
                    driveSeat.AssemblyLinearVelocity = Vector3.zero
                    driveSeat.AssemblyAngularVelocity = Vector3.zero

                    car:SetAttribute("ParkingBrake", true)
                    car:SetAttribute("Locked", true)
                end
                -- ============================================================

                local TeleportService = game:GetService("TeleportService")
                local Players = game:GetService("Players")
                local HttpService = game:GetService("HttpService")
                local player = Players.LocalPlayer

                local function MoveToDealer()
                    local player = game:GetService("Players").LocalPlayer
                    local character = player.Character or player.CharacterAdded:Wait()
                    local vehicle = workspace.Vehicles:FindFirstChild(player.Name)
                    if not vehicle then
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Error",
                            Text = "No vehicle found.",
                            Duration = 3,
                        })
                        return
                    end

                    local dealers = workspace:FindFirstChild("Dealers")
                    if not dealers then
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Error",
                            Text = "Dealers not found.",
                            Duration = 3,
                        })
                        tweenTo(Vector3.new(-1292.9005126953125, -423.63556671142578, 3685.330810546875))
						task.wait(1)
                        performServerHop()
                        return
                    end

                    local closest, shortest = nil, math.huge
                    for _, dealer in pairs(dealers:GetChildren()) do
                        if dealer:FindFirstChild("Head") then
                            local dist = (character.HumanoidRootPart.Position - dealer.Head.Position).Magnitude
                            if dist < shortest then
                                shortest = dist
                                closest = dealer.Head
                            end
                        end
                    end

                    if not closest then
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Error",
                            Text = "No dealer found.",
                            Duration = 3,
                        })
                        tweenTo(Vector3.new(-1292.9005126953125, -423.63556671142578, 3685.330810546875))
						task.wait(1)
                        performServerHop()
                        return
                    end

                    local destination1 = closest.Position + Vector3.new(0, 5, 0)
                    tweenTo(destination1)
                end

                local function robBankAndClub()
                    local player = game.Players.LocalPlayer
                    local character = player.Character or player.CharacterAdded:Wait()
                    local humanoid = character:WaitForChild("Humanoid")
                    local camera = game.Workspace.CurrentCamera

                    local function lockCamera()
                        local rootPart = character.HumanoidRootPart
                        local backOffset = rootPart.CFrame.LookVector * -6
                        local cameraPosition = rootPart.Position + backOffset + Vector3.new(0, 5, 0) 
                        local lookAtPosition = rootPart.Position + Vector3.new(0, 2, 0) 
                        camera.CFrame = CFrame.new(cameraPosition, lookAtPosition)
                    end

                    game:GetService("RunService").Heartbeat:Connect(lockCamera)
                    local musikPos = Vector3.new(-1739.5330810546875, 11, 3052.31103515625)
                    local musikStand = Vector3.new(-1744.177001953125, 11.125, 3012.20263671875)
                    local musikSafe = Vector3.new(-1743.4300537109375, 11.124999046325684, 3049.96630859375) 
                    ensurePlayerInVehicle()
                    task.wait(.5)
                    clickAtCoordinates(0.5, 0.9)
                    task.wait(.5)
                    tweenTo(Vector3.new(-1370.972412109375, 5.499999046325684, 3127.154541015625))
                    task.wait(.5)

                    local musikPart = workspace.Robberies["Club Robbery"].Club.Door.Accessory.Black
                    local bankPart = Workspace.Robberies.BankRobbery.VaultDoor["Meshes/Tresor_Plane (2)"]
                    local bankLight = game.Workspace.Robberies.BankRobbery.LightGreen.Light
                    local bankLight2 = game.Workspace.Robberies.BankRobbery.LightRed.Light
                            if autoSellToggle == true then
                                ensurePlayerInVehicle()
                                MoveToDealer()
                                task.wait(0.5)

                                args = {
                                    [1] = "Gold",
                                    [2] = "Dealer"
                                }
                                sellRemoteEvent:FireServer(unpack(args))
                                sellRemoteEvent:FireServer(unpack(args))
                                sellRemoteEvent:FireServer(unpack(args))

                                tweenTo(Vector3.new(-1370.972412109375, 5.499999046325684, 3127.154541015625))

                            ensurePlayerInVehicle()
                            tweenTo(Vector3.new(-1370.972412109375, 5.499999046325684, 3127.154541015625))
					ensurePlayerInVehicle()
                    tweenTo(Vector3.new(-1370.972412109375, 5.499999046325684, 3127.154541015625))
                    
                    if musikPart.Rotation == Vector3.new(180, 0, 180) then
                        clickAtCoordinates(0.5, 0.9)
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Safe is open",
                            Text = "Going to rob",
                        })

                        local hasBomb = plr.Character:FindFirstChild("Bomb") or plr.Backpack:FindFirstChild("Bomb") 
                        if not hasBomb then
                            ensurePlayerInVehicle()
                            MoveToDealer()
                            task.wait(0.5)
                            args = {[1] = "Bomb", [2] = "Dealer"}
                            buyRemoteEvent:FireServer(unpack(args))
                            task.wait(0.5)
                        end

                        ensurePlayerInVehicle()
                        tweenTo(musikPos)
                        task.wait(0.5)
                        JumpOut()
                        task.wait(0.5)

                        plrTween(Vector3.new(-1744.177001953125, 11.125, 3017.20263671875))
                        task.wait(0.5)

                        args = {[1] = "Bomb"}
                        EquipRemoteEvent:FireServer(unpack(args))
                        task.wait(0.5)
                        
                        local tool = plr.Character:FindFirstChild("Bomb")
                        if tool then
                            SpawnBomb()
                        else
                            warn("Tool 'Bomb' not found in the Backpack!")
                        end

                        task.wait(0.5)
                        fireBombRemoteEvent:FireServer()

                        plrTween(musikSafe)
                        task.wait(1.8)
                        plrTween(musikStand)

                        safeFolder = workspace.Robberies["Club Robbery"].Club
                        interactWithVisibleMeshParts(safeFolder:FindFirstChild("Items"))
                        interactWithVisibleMeshParts(safeFolder:FindFirstChild("Money"))
                        task.wait(0.5)

                        ensurePlayerInVehicle()
                        tweenTo(Vector3.new(-1370.972412109375, 5.499999046325684, 3127.154541015625))

                    else
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Safe is not open",
                            Text = "Going to Bank",
                        })
                    end
                        ensurePlayerInVehicle()
                        tweenTo(Vector3.new(-1370.972412109375, 5.499999046325684, 3127.154541015625))
                    else
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Safe is not open",
                            Text = "Going to Bank",
                        })
                end

                    if bankLight2.Enabled == false and bankLight.Enabled == true then
                        clickAtCoordinates(0.5, 0.9)
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Bank is open",
                            Text = "Going to rob",
                        })

                        ensurePlayerInVehicle()
                        local hasBomb1 = false
                        
                        local function checkContainer(container)
                            for _, item in ipairs(container:GetChildren()) do
                                if item:IsA("Tool") and item.Name == "Bomb" then
                                    return true
                                end
                            end
                            return false
                        end

                        hasBomb1 = checkContainer(plr.Backpack) or checkContainer(plr.Character)
                        if not hasBomb1 then
                            ensurePlayerInVehicle()
                            task.wait(0.5)
                            MoveToDealer()
                            task.wait(0.5)
                            MoveToDealer()
                            task.wait(0.5)
                            args = {
                                [1] = "Bomb",
                                [2] = "Dealer"
                            }
                            buyRemoteEvent:FireServer(unpack(args))
                            task.wait(0.5)
                        end
                        
                        tweenTo(Vector3.new(-1202.86181640625, 7.877995491027832, 3164.614501953125))
                        tweenTo(Vector3.new(-1202.86181640625, 7.877995491027832, 3164.614501953125))
                        JumpOut()
                        task.wait(.5)
                        plrTween(Vector3.new(-1242.367919921875, 7.749999046325684, 3144.705322265625))
                        task.wait(.5)
                        args = {
                            [1] = "Bomb"
                        }
                        EquipRemoteEvent:FireServer(unpack(args))
                        task.wait(.5)
                        
                        tool = plr.Character:FindFirstChild("Bomb")
                        if tool then
                            SpawnBomb()
                        else
                            warn("Tool 'Bomb' not found in the Backpack!")
                        end

                        task.wait(0.5)
                        fireBombRemoteEvent:FireServer()
                        plrTween(Vector3.new(-1246.291015625, 7.749999046325684, 3120.8505859375))
                        task.wait(2.5)
                        safeFolder = Workspace.Robberies.BankRobbery
                        plrTween(Vector3.new(-1249.6793212890625, 7.7235636711120605, 3121.9423828125))
                        task.wait(6)
                        plrTween(Vector3.new(-1231.2696533203125, 7.7235002517700195, 3123.935546875))
                        task.wait(6)
                        plrTween(Vector3.new(-1246.9879150390625, 7.7235002517700195, 3103.03955078125))
                        task.wait(6)
                        plrTween(Vector3.new(-1235.13720703125, 7.7235002517700195, 3103.102783203125))
                        task.wait(6)
                        ensurePlayerInVehicle()
                        tweenTo(Vector3.new(-1143.7784423828125, 5.724719047546387, 3457.9404296875))

                    else
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Bank is not open",
                            Text = "Going to Jeweler",
                        })
                        ensurePlayerInVehicle()
                        tweenTo(Vector3.new(-1143.7784423828125, 5.724719047546387, 3457.9404296875))
                    end

                    local JewelerPart = workspace.Robberies["Jeweler Safe Robbery"].Jeweler.Door.Accessory.Black
                    local JewelerPos = Vector3.new(-426.5001220703125, 21.522781372070312, 3576.979248046875)
                    local JewelerStand = Vector3.new(-439.0592041015625, 21.223413467407227, 3553.52783203125)
                    local JewelerSafe = Vector3.new(-407.1869201660156, 21.223413467407227, 3551.096435546875)

                    if JewelerPart.Rotation == Vector3.new(0, -90, 0) then
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Jeweler Safe is open",
                            Text = "Going to rob",
                        })

                        local hasBomb = plr.Character:FindFirstChild("Bomb") or plr.Backpack:FindFirstChild("Bomb") 
                        if not hasBomb then
                            ensurePlayerInVehicle()
                            MoveToDealer()
                            task.wait(0.5)
                            args = {[1] = "Bomb", [2] = "Dealer"}
                            buyRemoteEvent:FireServer(unpack(args))
                            task.wait(0.5)
                        end

                        ensurePlayerInVehicle()
                        tweenTo(JewelerPos)
                        task.wait(0.5)
                        JumpOut()
                        task.wait(0.5)

                        plrTween(Vector3.new(-437.28814697265625, 21.223413467407227, 3553.262939453125))
                        task.wait(0.5)

                        args = {[1] = "Bomb"}
                        EquipRemoteEvent:FireServer(unpack(args))
                        task.wait(0.5)
                        
                        local tool = plr.Character:FindFirstChild("Bomb")
                        if tool then
                            SpawnBomb()
                        else
                            warn("Tool 'Bomb' not found in the Backpack!")
                        end

                        task.wait(0.5)
                        fireBombRemoteEvent:FireServer()

                        plrTween(JewelerSafe)
                        task.wait(1.8)
                        plrTween(JewelerStand)

                        safeFolder = workspace.Robberies["Jeweler Safe Robbery"].Jeweler
                        interactWithVisibleMeshParts(safeFolder:FindFirstChild("Items"))
                        interactWithVisibleMeshParts(safeFolder:FindFirstChild("Money"))
                        task.wait(0.5)

                        ensurePlayerInVehicle()
                        tweenTo(Vector3.new(-1292.9005126953125, -423.63556671142578, 3685.330810546875))
						task.wait(1)
                        performServerHop()
                    else
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Jeweler Safe is not open",
                            Text = "Going to Server Hop",
                        })
                        tweenTo(Vector3.new(-1292.9005126953125, -423.63556671142578, 3685.330810546875))
						task.wait(1)
                        performServerHop()
                    end
                end

                while task.wait() do
                    if (autorobBankClubToggle or autorobContainersToggle) then
                        task.spawn(startAutoCollect)
                    end
                    
                    if autorobBankClubToggle == true then
                        robBankAndClub()
                    end
                end

                local function robContainers()
                    tweenTo(Vector3.new(1058.7470703125, 5.733738899230957, 2218.6943359375))
                    task.wait(.5)
                    
                    local containerFolder = workspace.Robberies.ContainerRobberies
                    local containers = {}
                    
                    local function getContainerRobberies(folder)
                        local result = {}
                        for _, model in ipairs(folder:GetChildren()) do
                            if model.Name == "ContainerRobbery" then
                                table.insert(result, model)
                            end
                        end
                        return result
                    end

                    containers = getContainerRobberies(containerFolder) 

                    container1 = containers[1]
                    container2 = containers[2]
                    con1Planks = container1:FindFirstChild("WoodPlanks", true)
                    con2Planks = container2:FindFirstChild("WoodPlanks", true)
                                
                    function isPoliceNearby()
                        local policeTeam = game:GetService("Teams"):FindFirstChild("Police")
                        for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
                            if plr.Team == policeTeam and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                                local distance = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                                if distance <= policeAbort then
                                    return true
                                end
                            end
                        end
                        return false
                    end

                    if con1Planks.Transparency == 1 then
                        ensurePlayerInVehicle()
                        task.wait(.5)
                        MoveToDealer()
                        task.wait(.5)
                        args = {
                            [1] = "Bomb",
                            [2] = "Dealer"
                        }
                        buyRemoteEvent:FireServer(unpack(args))
                        task.wait(0.5)
                        tweenTo(con1Planks.Position)
                        tweenTo(con1Planks.Position)
                        task.wait(0.5)
                        JumpOut()
                        task.wait(0.5)
                        plrTween(con1Planks.Position)
                        task.wait(0.5)
                        args = {
                            [1] = "Bomb"
                        }
                        EquipRemoteEvent:FireServer(unpack(args))
                        task.wait(0.5)
                        
                        tool = plr.Character:FindFirstChild("Bomb")
                        if tool then
                            SpawnBomb()
                        else
                            warn("Tool 'Bomb' not found in the Backpack!")
                        end

                        task.wait(.5)
                        fireBombRemoteEvent:FireServer()
                        ensurePlayerInVehicle()
                        tweenTo(Vector3.new(1096.401, 57.31, 2226.765))
                        task.wait(2)
                        tweenTo(con1Planks.Position)
                        JumpOut()
                        task.wait(.5)
                        plrTween(con1Planks.Position)
                        interactWithVisibleMeshParts2(container1:FindFirstChild("Items"))
                        interactWithVisibleMeshParts2(container1:FindFirstChild("Items"))
                        interactWithVisibleMeshParts2(container1:FindFirstChild("Money"))
                        interactWithVisibleMeshParts2(container1:FindFirstChild("Money"))
                        task.wait(.2)
                        ensurePlayerInVehicle()
                        task.wait(.2)
                        tweenTo(Vector3.new(1096.401, 57.31, 2226.765))
                    else
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Container1 not open",
                            Text = "Going to Container2",
                        })
                    end

                    if con2Planks.Transparency == 1 then
                        ensurePlayerInVehicle()
                        task.wait(.5)
                        MoveToDealer()
                        task.wait(.5)
                        args = {
                            [1] = "Bomb",
                            [2] = "Dealer"
                        }
                        buyRemoteEvent:FireServer(unpack(args))
                        task.wait(0.5)
                        tweenTo(con2Planks.Position)
                        task.wait(0.5)
                        JumpOut()
                        task.wait(.5)
                        plrTween(con2Planks.Position)
                        task.wait(0.5)
                        args = {
                            [1] = "Bomb"
                        }
                        EquipRemoteEvent:FireServer(unpack(args))
                        task.wait(0.5)
                        
                        tool = plr.Character:FindFirstChild("Bomb")
                        if tool then
                            SpawnBomb()
                        else
                            warn("Tool 'Bomb' not found in the Backpack!")
                        end

                        task.wait(0.5)
                        fireBombRemoteEvent:FireServer()
                        ensurePlayerInVehicle()
                        tweenTo(Vector3.new(1096.401, 57.31, 2226.765))
                        task.wait(2)
                        tweenTo(con2Planks.Position)
                        JumpOut()
                        task.wait(0.5)
                        plrTween(con2Planks.Position)
                        interactWithVisibleMeshParts2(container2:FindFirstChild("Items"))
                        interactWithVisibleMeshParts2(container2:FindFirstChild("Items"))
                        interactWithVisibleMeshParts2(container2:FindFirstChild("Money"))
                        interactWithVisibleMeshParts2(container2:FindFirstChild("Money"))
                        task.wait(0.5)
                        ensurePlayerInVehicle()
                        tweenTo(Vector3.new(1656.3526611328125, -25.936052322387695, 2821.137451171875))
                        performServerHop()
                    else
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Container2 not open",
                            Text = "Hopping Server :^)",
                        })
                    end

                    ensurePlayerInVehicle()
                    tweenTo(Vector3.new(1656.3526611328125, -25.936052322387695, 2821.137451171875))
                    performServerHop()
                end

                while task.wait() do
                    if autorobBankClubToggle == true then
                        robBankAndClub()
                    end
                    
                    if autorobContainersToggle == true then
                        robContainers()
                    end
                end

                OrionLib:Init()
                end
                break
            end
        end
        task.wait(CHECK_INTERVAL)
    end
end)
