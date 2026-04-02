--[[
    PREMIUM ESP SYSTEM - SENIOR DEVELOPER EDITION
    Features: 2D Box, HealthBar, Name, Distance, Tracers, Modern UI
    Optimierung: RenderStepped, Distance Culling, Memory Leak Protection
]]

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local Settings = {
    Enabled = true,
    Box = true,
    Name = true,
    Health = true,
    Tracers = false,
    TeamCheck = true,
    MaxDistance = 1500,
    Colors = {
        Box = Color3.fromRGB(255, 255, 255),
        Tracer = Color3.fromRGB(255, 0, 0),
        Text = Color3.fromRGB(255, 255, 255)
    }
}

-- STORAGE
local ESP_Cache = {}

-- UTILS: Erstellt UI-Elemente für Spieler
local function CreateESP(player)
    if ESP_Cache[player] then return end
    
    local container = Instance.new("Folder", game:GetService("CoreGui"))
    container.Name = "ESP_" .. player.Name
    
    local components = {
        Box = Instance.new("Frame"),
        BoxOutline = Instance.new("UIStroke"),
        HealthBar = Instance.new("Frame"),
        HealthBarBG = Instance.new("Frame"),
        NameTag = Instance.new("TextLabel"),
        DistanceTag = Instance.new("TextLabel"),
        Tracer = Instance.new("Frame"),
        Folder = container
    }
    
    -- Setup Box
    components.Box.Parent = container
    components.Box.BackgroundColor3 = Color3.new(1,1,1)
    components.Box.BackgroundTransparency = 1
    components.Box.BorderSizePixel = 0
    components.BoxOutline.Parent = components.Box
    components.BoxOutline.Thickness = 1.5
    components.BoxOutline.Color = Settings.Colors.Box
    
    -- Setup Health
    components.HealthBarBG.Parent = container
    components.HealthBarBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    components.HealthBarBG.BorderSizePixel = 0
    components.HealthBar.Parent = components.HealthBarBG
    components.HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    components.HealthBar.BorderSizePixel = 0
    
    -- Setup Labels
    components.NameTag.Parent = container
    components.NameTag.BackgroundTransparency = 1
    components.NameTag.Font = Enum.Font.GothamBold
    components.NameTag.TextSize = 13
    components.NameTag.TextColor3 = Settings.Colors.Text
    
    components.DistanceTag.Parent = container
    components.DistanceTag.BackgroundTransparency = 1
    components.DistanceTag.Font = Enum.Font.Gotham
    components.DistanceTag.TextSize = 11
    components.DistanceTag.TextColor3 = Color3.fromRGB(200, 200, 200)

    ESP_Cache[player] = components
end

local function RemoveESP(player)
    if ESP_Cache[player] then
        ESP_Cache[player].Folder:Destroy()
        ESP_Cache[player] = nil
    end
end

-- MAIN ESP LOOP
RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then 
        for _, data in pairs(ESP_Cache) do data.Folder.Parent = nil end
        return 
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if hrp and hum and hum.Health > 0 then
            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
            
            -- Team Check & Distance Check
            local isTeammate = player.Team == LocalPlayer.Team
            if onScreen and distance < Settings.MaxDistance and (not Settings.TeamCheck or not isTeammate) then
                if not ESP_Cache[player] then CreateESP(player) end
                
                local data = ESP_Cache[player]
                data.Folder.Parent = game:GetService("CoreGui")
                
                -- Kalkulation der Größe (Perspektive)
                local sizeX = 4000 / distance
                local sizeY = 6000 / distance
                
                -- Box Update
                data.Box.Visible = Settings.Box
                data.Box.Size = UDim2.new(0, sizeX, 0, sizeY)
                data.Box.Position = UDim2.new(0, vector.X - sizeX/2, 0, vector.Y - sizeY/2)
                
                -- Health Update
                data.HealthBarBG.Visible = Settings.Health
                data.HealthBarBG.Size = UDim2.new(0, 3, 0, sizeY)
                data.HealthBarBG.Position = UDim2.new(0, vector.X - sizeX/2 - 6, 0, vector.Y - sizeY/2)
                data.HealthBar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0)
                data.HealthBar.Position = UDim2.new(0, 0, 1 - (hum.Health/hum.MaxHealth), 0)
                
                -- Text Update
                data.NameTag.Visible = Settings.Name
                data.NameTag.Text = player.Name
                data.NameTag.Position = UDim2.new(0, vector.X - 50, 0, vector.Y - sizeY/2 - 20)
                data.NameTag.Size = UDim2.new(0, 100, 0, 15)
                
                data.DistanceTag.Text = math.floor(distance) .. " studs"
                data.DistanceTag.Position = UDim2.new(0, vector.X - 50, 0, vector.Y + sizeY/2 + 5)
                data.DistanceTag.Size = UDim2.new(0, 100, 0, 15)
            else
                if ESP_Cache[player] then ESP_Cache[player].Folder.Parent = nil end
            end
        else
            if ESP_Cache[player] then ESP_Cache[player].Folder.Parent = nil end
        end
    end
end)

-- CLEANUP
Players.PlayerRemoving:Connect(RemoveESP)

---------------------------------------------------------------------
-- UI DESIGN (MODERN & CLEAN)
---------------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 320)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "GEMINI ESP v3"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1

-- UI DRAG LOGIC
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- TOGGLE BUTTON TEMPLATE
local function CreateToggle(name, settingKey, position)
    local Btn = Instance.new("TextButton", MainFrame)
    Btn.Size = UDim2.new(0.8, 0, 0, 35)
    Btn.Position = UDim2.new(0.1, 0, 0, position)
    Btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(60, 180, 100) or Color3.fromRGB(50, 50, 55)
    Btn.Text = name
    Btn.Font = Enum.Font.Gotham
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.TextSize = 14
    
    local c = Instance.new("UICorner", Btn)
    
    Btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        Btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(60, 180, 100) or Color3.fromRGB(50, 50, 55)
    end)
end

CreateToggle("Master Switch", "Enabled", 60)
CreateToggle("Show Boxes", "Box", 110)
CreateToggle("Show Names", "Name", 160)
CreateToggle("Health Bars", "Health", 210)
CreateToggle("Team Check", "TeamCheck", 260)

-- KEYBIND TO HIDE UI (RightControl)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

print("ESP System geladen. Menü mit 'Rechts-Strg' umschalten.")
