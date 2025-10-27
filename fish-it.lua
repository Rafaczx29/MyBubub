-- =============================================================
-- KONFIGURASI AWAL & VARIABEL GLOBAL
-- =============================================================
local ToolSlot = 1         -- Slot Hotbar tempat pancing berada.
local ChargeTime = 1.0     -- Durasi simulasi 'charge' pancing.
local CycleDelay = 0.5     -- Jeda minimal antar siklus memancing.

local isRunning = false
local BiteDelay = 3.0 
local AutoFishThread = nil 

local CastingX = -1.233184814453125
local CastingY = 0.04706447494934768

-- =============================================================
-- SERVICE & REMOTE FUNCTIONS/EVENTS
-- =============================================================
-- Menggunakan FindFirstChild rekursif untuk mencari net service lebih fleksibel
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetService = ReplicatedStorage:FindFirstChild("Packages", true):FindFirstChild("_Index", true):FindFirstChild("sleitnick_net@0.2.0", true):FindFirstChild("net", true)

if not NetService then
    error("Error: NetService tidak ditemukan. Script tidak dapat berjalan.")
end

local EquipToolEvent = NetService:WaitForChild("RE/EquipToolFromHotbar")
local ChargeRodFunc = NetService:WaitForChild("RF/ChargeFishingRod")
local RequestMinigameFunc = NetService:WaitForChild("RF/RequestFishingMinigameStarted") 
local FishingCompletedEvent = NetService:WaitForChild("RE/FishingCompleted")

local function wait(time)
    if time then
        task.wait(time)
    else
        task.wait()
    end
end

-- =============================================================
-- LOGIKA AUTO-FISHING 
-- =============================================================

local function EquipFishingRod(slot)
    EquipToolEvent:FireServer(slot)
    wait(0.5)
end

local function ChargeRod()
    local success, result = pcall(function()
        return ChargeRodFunc:InvokeServer()
    end)
    
    if success then
        wait(ChargeTime) 
        return true
    else
        return false
    end
end

local function CastAndReelFast()
    if not isRunning then return end
    local currentTime = tick()
    
    local args = {
        [1] = CastingX,
        [2] = CastingY,
        [3] = currentTime
    }
    
    local success, result = pcall(function()
        return RequestMinigameFunc:InvokeServer(unpack(args))
    end)

    if success and (result == true or type(result) == "table") then
        
        wait(BiteDelay) 
        if not isRunning then return end 
        FishingCompletedEvent:FireServer()
        return true
    else
        return false
    end
end

local function AutoFishLoop()
    EquipFishingRod(ToolSlot)
    wait(1)

    while isRunning do 
        local isCharged = ChargeRod()
        if not isCharged then
            wait(CycleDelay * 2)
            continue
        end
        
        CastAndReelFast()

        wait(CycleDelay) 
    end
    AutoFishThread = nil
end

-- =============================================================
-- KODE GUI (DIOPTIMALKAN UNTUK EXECUTOR)
-- =============================================================

-- Akses LocalPlayer dan PlayerGui secara langsung
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player and Player:FindFirstChild("PlayerGui")

if not PlayerGui then
    -- Jika PlayerGui tidak ditemukan (kasus umum di Executor), buat ScreenGui di CoreGui
    -- Beberapa Executor memerlukan penempatan di CoreGui atau di ReplicatedStorage
    -- Kita coba taruh di PlayerGui, jika gagal, kita coba di tempat lain.
    -- Namun, penempatan di PlayerGui adalah standar terbaik.
    if Player then
        PlayerGui = Instance.new("PlayerGui", Player)
    else
        -- Jika LocalPlayer pun tidak ditemukan (Executor sangat terbatas), script berhenti.
        warn("LocalPlayer atau PlayerGui tidak ditemukan. GUI gagal dimuat.")
        return 
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFishGUI"
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0.5, -100, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderColor3 = Color3.fromRGB(20, 20, 20)
Frame.Active = true
Frame.Draggable = true 
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🎣 Auto Fish - Fast Reel"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0.9, 0, 0, 30)
ToggleButton.Position = UDim2.new(0.05, 0, 0, 40)
ToggleButton.Text = "STATUS: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = Frame

local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(0.45, 0, 0, 20)
DelayLabel.Position = UDim2.new(0.05, 0, 0, 80)
DelayLabel.Text = "Bite Delay (s):"
DelayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DelayLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
DelayLabel.Font = Enum.Font.SourceSans
DelayLabel.Parent = Frame

local DelayInput = Instance.new("TextBox")
DelayInput.Name = "DelayInput"
DelayInput.Size = UDim2.new(0.45, 0, 0, 25)
DelayInput.Position = UDim2.new(0.5, 0, 0, 80)
DelayInput.Text = tostring(BiteDelay)
DelayInput.PlaceholderText = "3.0"
DelayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayInput.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
DelayInput.Font = Enum.Font.SourceSans
DelayInput.TextXAlignment = Enum.TextXAlignment.Center
DelayInput.Parent = Frame

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.9, 0, 0, 30)
InfoLabel.Position = UDim2.new(0.05, 0, 0, 115) 
InfoLabel.Text = "INFO: Tingkatkan Delay jika ikan gagal ditarik."
InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
InfoLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.TextSize = 12
InfoLabel.Parent = Frame

-- =============================================================
-- KODE PENGHUBUNG (HANDLERS)
-- =============================================================

ToggleButton.MouseButton1Click:Connect(function()
    if isRunning then
        -- MATIKAN SCRIPT
        isRunning = false
        if AutoFishThread and task.cancel then 
            task.cancel(AutoFishThread)
        end
        AutoFishThread = nil
        ToggleButton.Text = "STATUS: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 40, 40) 
    else
        -- HIDUPKAN SCRIPT
        isRunning = true
        ToggleButton.Text = "STATUS: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 150, 40) 
        
        AutoFishThread = task.spawn(AutoFishLoop)
    end
end)

DelayInput.FocusLost:Connect(function()
    local newDelay = tonumber(DelayInput.Text)
    if newDelay and newDelay >= 0.1 then
        BiteDelay = newDelay
    else
        DelayInput.Text = tostring(BiteDelay) 
    end
end)
