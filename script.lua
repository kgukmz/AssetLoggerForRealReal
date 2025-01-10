--// Variables
local RunService: RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerTable = {}

local ScriptData = {
    SelectedPlayer = nil;
}

--// Fetch library
local SourceURL = 'https://github.com/depthso/Roblox-ImGUI/raw/main/ImGui.lua'
ImGui = loadstring(game:HttpGet(SourceURL))()

--// Window 
local Window = ImGui:CreateWindow({
	Title = "Asset Logger",
	Size = UDim2.new(0, 400, 0, 250),
	Position = UDim2.new(0.5, 0, 0, 70)
})

local ActiveTabs = {
    ConsoleTab = Window:CreateTab({
        Name = "CONSOLE"
    });

    PlayerTab = Window:CreateTab({
        Name = "PLAYERS"
    });

    ToolsTab = Window:CreateTab({
        Name = "TOOLS";
    });

    DebugTab = Window:CreateTab({
        Name = "DEBUG";
    })
}

-- // Functions

local function ModalNotify(Text)
    local NewModal = ImGui:CreateModal({
        Title = "Notification";
        AutoSize = "Y";
    })

    NewModal:Label({
        Text = Text;
    })
    NewModal:Separator()
    NewModal:Button({
        Text = "Continue";
        Callback = function()
            NewModal:Close()
        end
    })
end

local function DebugLog(...)
    if (_G.ScriptDebugConsole == nil) then
        return
    end
    Color3.fromRGB(0, 255)
    _G.ScriptDebugConsole:AppendText(`<font color="rgb(0, 255, 0)">[DEBUG]:</font>`, table.unpack({...}))
end

local function ConsoleLog(...)
    if (_G.MainConsole == nil) then
        return
    end

    _G.MainConsole:AppendText(`<font color="rgb(0, 100, 255)">[CLIENT]:</font>`, table.unpack({...}))
end

local function LogAnimations(Player, Table)
    local Character = Player.Character

    if (Character == nil) then
        return
    end


end

task.defer(function()
    for _,Plr in Players:GetPlayers() do
        if (PlayerTable[Plr.Name]) then
            continue
        end
    
        PlayerTable[Plr.Name] = Plr
        DebugLog("Added existing player:", Plr.Name, "to list")
    end
end)

_G.PlayerAddedConn = Players.PlayerAdded:Connect(function(Plr)
    if (PlayerTable[Plr.Name]) then
        return
    end

    PlayerTable[Plr.Name] = Plr
    DebugLog("Added player:", Plr.Name, "to list")
end)

_G.PlayerRemovingConn = Players.PlayerRemoving:Connect(function(Plr)
    if (not PlayerTable[Plr.Name]) then
        return
    end

    PlayerTable[Plr.Name] = nil
    DebugLog("Removed player:", Plr.Name, "from list")
end)

-- // Console Tab
ActiveTabs.ConsoleTab:Separator({
	Text = "Console Output:"
})

_G.MainConsole = ActiveTabs.ConsoleTab:Console({
	Text = "-- [MAIN] //",
	ReadOnly = true,
	LineNumbers = false,
	Border = false,
	Fill = true,
	Enabled = true,
	AutoScroll = true,
	RichText = true,
	MaxLines = math.huge
})

local ConsoleButtonRow = ActiveTabs.ConsoleTab:Row()
ConsoleButtonRow:Button({
	Text = "Clear",
	Callback = _G.MainConsole.Clear
})
ConsoleButtonRow:Button({
	Text = "Copy"
})
ConsoleButtonRow:Fill()

-- // Player Tab

local PlayerButtonRow = ActiveTabs.PlayerTab:Row()

PlayerButtonRow:Button({
    Text = "Save Player Model";
    Callback = function()
        if (getgenv().saveinstance == nil) then
            ModalNotify("Executor does not support saveinstance")
            return
        end

        if (ScriptData.SelectedPlayer == nil) then
            ModalNotify("No player has been selected")
            return
        end

        if (ScriptData.SelectedPlayer.Character == nil) then
            return
        end
        
        local Success, Error = pcall(function()
            saveinstance(ScriptData.SelectedPlayer.Character)
        end)
        
        if (Success == false) then
            ModalNotify("Error saving player:", Error)
            return
        end

        ModalNotify("Saved: " .. ScriptData.SelectedPlayer.Name .. " to workspace")
        ConsoleLog("Successfuly saved:", ScriptData.SelectedPlayer.Name .. " to workspace")
    end
})

PlayerButtonRow:Fill()

ActiveTabs.PlayerTab:Separator({
    Text = "Players:"
})

ActiveTabs.PlayerTab:Combo({
    Placeholder = "...";
    Label = "Players";
    Items = PlayerTable;
    Callback = function(self, Value)
        ScriptData.SelectedPlayer = Value
    end
})

--// Tools Tab

ActiveTabs.ToolsTab:Separator({
    Text = "Tools:"
})

ActiveTabs.ToolsTab:Combo({
    Placeholder = "...";
    Label = "Load Scripts";
    Items = {
        "Dark Dex";
        "Hydroxide";
        "Simple Spy";
    };
    Callback = function(self, Value)
        if (Value == "Dark Dex") then
            local Success, Error = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
            end)

            if (Success == false) then
                ModalNotify("Error loading script: " .. Value .. " | " .. Error)
                return
            end
        elseif (Value == "Hydroxide") then
            local Success, Error = pcall(function()
                local function webImport(file)
                    return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua"):format("Upbolt", "revision", file)), file .. '.lua')()
                end
                
                webImport("init")
                webImport("ui/main")
            end)

            if (Success == false) then
                ModalNotify("Error loading script: " .. Value .. " | " .. Error)
                return
            end
        elseif (Value == "Simple Spy") then
            local Success, Error = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/refs/heads/master/SimpleSpy.lua"))()
            end)

            if (Success == false) then
                ModalNotify("Error loading script: " .. Value .. " | " .. Error)
                return
            end
        end
        
        ConsoleLog("Loaded script:", Value)
    end
})

-- // Debug Tab
ActiveTabs.DebugTab:Separator({
	Text = "Script Debug:"
})

_G.ScriptDebugConsole = ActiveTabs.DebugTab:Console({
	Text = "-- [DEBUG] //",
	ReadOnly = true,
	LineNumbers = false,
	Border = false,
	Fill = true,
	Enabled = true,
	AutoScroll = true,
	RichText = true,
	MaxLines = math.huge
})

Window:Center()
Window:ShowTab(ActiveTabs.ConsoleTab) 
