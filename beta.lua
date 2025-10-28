-- =============================================================
-- ULTRA FAST FISH (BiteDelay Tetap 1.0)
-- =============================================================
local ToolSlot = 1         
local BiteDelay = 1.0      -- Tetap 1.0 sesuai requirement
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

-- Cache untuk performa
local tick = tick
local pcall = pcall

-- =============================================================
-- LOGIKA ULTRA FAST FISHING (OPTIMIZED)
-- =============================================================

local function EquipFishingRod(slot)
    EquipToolEvent:FireServer(slot)
end

local function UltraCombinedChargeAndCast()
    -- Pre-calculate args untuk menghindari table creation berulang
    local currentTime = tick()
    
    -- Charge dan Cast dalam satu sequence tanpa delay
    local charge_success = pcall(ChargeRodFunc.InvokeServer, ChargeRodFunc)
    
    if charge_success then
        -- Langsung cast setelah charge success
        local cast_success, cast_result = pcall(RequestMinigameFunc.InvokeServer, RequestMinigameFunc, CastingX, CastingY, currentTime)
        return cast_success and (cast_result == true or type(cast_result) == "table")
    end
    
    return false
end

local function UltraFastCastAndReel()
    if UltraCombinedChargeAndCast() then
        -- Tunggu BiteDelay yang tetap 1.0
        local waitStart = tick()
        while tick() - waitStart < BiteDelay do
            task.wait()  -- Biarkan game breath sedikit
        end
        
        -- Sequence cepat untuk completion
        FishingCompletedEvent:FireServer()
        
        -- Reset sequence dengan delay super minimal
        task.wait(0.001)  -- Dari 0.005 jadi 0.001
        
        -- Reset tools tanpa pengecekan berlebihan
        pcall(CancelInputsFunc.InvokeServer, CancelInputsFunc)
        EquipToolEvent:FireServer(0)
        
        return true
    end
    return false
end

-- =============================================================
-- EKSEKUSI UTAMA DENGAN HIGH-FREQUENCY LOOP
-- =============================================================

local function UltraFastAutoFish()
    print("--- ULTRA FAST FISHING SCRIPT DIMULAI (BiteDelay: 1.0) ---")

    EquipFishingRod(ToolSlot)
    task.wait(0.3)  -- Initial wait dikurangi

    local failCount = 0
    local successCount = 0
    
    while true do
        local success = UltraFastCastAndReel()
        
        if success then
            successCount = successCount + 1
            failCount = 0
            
            -- No delay antara successful cycles
            -- Langsung lanjut ke cast berikutnya
        else
            failCount = failCount + 1
            successCount = 0
            
            -- Short delay hanya jika gagal
            if failCount >= 2 then
                task.wait(0.01)  -- Very short delay untuk avoid spam detection
            else
                task.wait(0.002)  -- Minimal delay
            end
        end
        
        -- Optional: Reset equipment setiap 10 success untuk prevent bug
        if successCount >= 10 then
            EquipToolEvent:FireServer(0)
            task.wait(0.05)
            EquipFishingRod(ToolSlot)
            successCount = 0
        end
    end
end

-- Start dengan spawn
task.spawn(UltraFastAutoFish)
