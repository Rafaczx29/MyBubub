local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "PELER HUB | Pickaxe Simulator",
    Icon = 0,
    LoadingTitle = "Loading Script...",
    LoadingSubtitle = "by Rafaczx",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

local Tab = Window:CreateTab("Main", 4483362458)

-- SECTION: HATCH SETTINGS
local SectionHatch = Tab:CreateSection("Hatch Settings")

local HatchSlider = Tab:CreateSlider({
    Name = "Hatch Speed",
    Range = {1, 14},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 1,
    Callback = function(Value)
        local Stats = game:GetService("ReplicatedStorage"):FindFirstChild("Stats")
        if Stats then
            local PlayerStats = Stats:FindFirstChild(game.Players.LocalPlayer.Name)
            if PlayerStats and PlayerStats:FindFirstChild("EggStats") then
                local HatchSpeed = PlayerStats.EggStats:FindFirstChild("HatchSpeed")
                if HatchSpeed then
                    HatchSpeed.Value = Value
                end
            end
        end
    end,
})

-- SECTION: AUTO ROLL
local SectionRoll = Tab:CreateSection("Auto Roll Settings")

local _G.AutoRoll = false -- Variabel global untuk mengontrol loop
Tab:CreateToggle({
    Name = "Auto Roll",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoRoll = Value
        
        if _G.AutoRoll then
            -- Menjalankan loop di thread terpisah agar GUI tidak hang
            task.spawn(function()
                while _G.AutoRoll do
                    -- Menggunakan pcall agar script tidak berhenti jika terjadi error di server
                    pcall(function()
                        game:GetService("ReplicatedStorage").Paper.Remotes.__remotefunction:InvokeServer("Roll")
                    end)
                    
                    -- Kita cek setiap 0.1 detik agar "menangkap" waktu tepat saat cooldown habis
                    task.wait(0.1) 
                end
            end)
        end
    end,
})

-- SECTION: SETTINGS
local SettingTab = Window:CreateTab("Setting", 4483362476)
SettingTab:CreateSection("UI Control")

SettingTab:CreateButton({
    Name = "Destroy Gui",
    Callback = function()
        _G.AutoRoll = false -- Matikan auto roll sebelum menghapus UI
        Rayfield:Destroy()
    end,
})

Rayfield:Notify({
    Title = "Script Loaded",
    Content = "Auto Roll dan Hatch Speed siap digunakan!",
    Duration = 5
})
