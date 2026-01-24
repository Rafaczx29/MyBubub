local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "PELER HUB | Pickaxe Simulator",
    LoadingTitle = "Memuat Script...",
    LoadingSubtitle = "by Rafaczx",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false
})

local Tab = Window:CreateTab("Main", 4483362458)

-- Variabel Lokal untuk Auto Roll
local autoRollActive = false

-- FITUR 1: HATCH SPEED (Sama seperti versi yang work)
Tab:CreateSlider({
    Name = "Hatch Speed",
    Range = {1, 15},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 1,
    Callback = function(Value)
        local success, err = pcall(function()
            local Stats = game:GetService("ReplicatedStorage"):FindFirstChild("Stats")
            if Stats then
                local PlayerStats = Stats:FindFirstChild(game.Players.LocalPlayer.Name)
                if PlayerStats and PlayerStats:FindFirstChild("EggStats") then
                    PlayerStats.EggStats.HatchSpeed.Value = Value
                end
            end
        end)
    end,
})

-- FITUR 2: AUTO ROLL (Toggle ON/OFF)
Tab:CreateToggle({
    Name = "Auto Roll",
    CurrentValue = false,
    Callback = function(Value)
        autoRollActive = Value
        
        if autoRollActive then
            task.spawn(function()
                while autoRollActive do
                    -- Menggunakan pcall agar jika Remote gagal, script tetap jalan
                    local success, result = pcall(function()
                        local remote = game:GetService("ReplicatedStorage").Paper.Remotes.__remotefunction
                        return remote:InvokeServer("Roll")
                    end)
                    
                    -- Jika sukses atau gagal, tetap beri jeda tipis agar tidak lag/crash
                    task.wait(0.1) 
                end
            end)
        end
    end,
})

-- BUTTON: DESTROY UI
local SettingsTab = Window:CreateTab("Settings", 4483362476)
SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        autoRollActive = false -- Matikan loop sebelum destroy
        Rayfield:Destroy()
    end,
})

Rayfield:Notify({
    Title = "Berhasil!",
    Content = "Script siap digunakan.",
    Duration = 3
})
