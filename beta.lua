-- =============================================================
-- KONFIGURASI FAST FISH (STRATEGI CANCEL INPUTS)
-- =============================================================
local ToolSlot = 1         -- Slot Hotbar tempat pancing berada (1-9).
local BiteDelay = 1.3      -- NILAI MINIMAL YANG BERHASIL (1.0 detik).

-- ChargeTime tidak digunakan lagi di wait()
local ChargeTime = 0.0 

-- Nilai Casting (x, y)
local CastingX = -1.233184814453125
local CastingY = 0.04706447494934768

-- =============================================================
-- SERVICE & REMOTE FUNCTIONS/EVENTS
-- =============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetService = ReplicatedStorage:FindFirstChild("Packages", true):FindFirstChild("_Index", true):FindFirstChild("sleitnick_net@0.2.0", true):FindFirstChild("net", true)

if not NetService then 
    warn("Error: NetService tidak ditemukan. Script gagal berjalan.")
    return 
end

local EquipToolEvent = NetService:WaitForChild("RE/EquipToolFromHotbar")
local ChargeRodFunc = NetService:WaitForChild("RF/ChargeFishingRod")
local RequestMinigameFunc = NetService:WaitForChild("RF/RequestFishingMinigameStarted") 
local FishingCompletedEvent = NetService:WaitForChild("RE/FishingCompleted")
local CancelInputsFunc = NetService:WaitForChild("RF/CancelFishingInputs") 

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
    wait(0.1) 
end

local function ChargeRod()
    local success, result = pcall(function()
        return ChargeRodFunc:InvokeServer()
    end)
    
    if success then
        return true
    else
        wait(0.01) -- Jeda sangat minimal agar CPU tidak stress
        return false
    end
end

local function CastAndReelFast()
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
        
        -- 1. Tunggu Minimal Menang Minigame
        wait(BiteDelay) 
        
        -- 2. Tarik Pancing (Klaim Kemenangan)
        FishingCompletedEvent:FireServer()
        
        -- 🔥 MODIFIKASI KRITIS: TAMBAH JEDA MICRO 🔥
        -- Beri server 0.1 detik untuk memproses kemenangan sebelum mereset cooldown.
        wait(0.1) 
        
        -- 3. Reset Cooldown/Status
        local cancel_success = pcall(function()
            CancelInputsFunc:InvokeServer() 
        end)
        if cancel_success then
             print("Cooldown reset dipicu via CancelFishingInputs.")
        end
        
        -- 4. Re-equip (strategi lama)
        EquipFishingRod(ToolSlot) 
        
        return true
    else
        return false
    end
end

-- =============================================================
-- EKSEKUSI UTAMA (MEMAKSA PENGULANGAN)
-- =============================================================

local function AutoFishFast()
    print("--- FAST FISHING SCRIPT DIMULAI (BYPASS COOLDOWN) ---")

    EquipFishingRod(ToolSlot)
    wait(1)

    while true do 
        
        local isCharged = ChargeRod()
        
        if isCharged then
            CastAndReelFast()
        end
    end
end

AutoFishFast()
