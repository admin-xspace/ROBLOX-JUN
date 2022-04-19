-- // Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- // Vars
local LocalPlayer = Players.LocalPlayer

-- // Config
local Output = ""
local SaveOutput = Enum.KeyCode.Q
local AutoSaveOutput = true
local EnableSpy = false
local TargetScript = LocalPlayer.PlayerGui:WaitForChild("Main").MainScript

-- // Convert table to string (table.concat doesn't play nice so I had to make this.)
local function ArrayToString(t, sep)
    -- // Vars
    local String = ""
    local StringFormat = "%s%s%s"

    -- //
    for _, v in pairs(t) do
        String = string.format(StringFormat, String, tostring(v), sep)
    end

    -- //
    return String
end

-- // __namecall hook
local __namecallFormat = "__namecall -> self   = %s\n              method = %s\n              args   = %s\n"
local __namecall
__namecall = hookmetamethod(game, "__namecall", function(...)
    -- // Vars
    local args = {...}
    local self = args[1]
    local method = getnamecallmethod()
    local callingscript = getcallingscript()

    -- // Make sure the spy is enabled
    if (not EnableSpy and callingscript == TargetScript) then
        -- // Remove self from args
        local args2 = {...}
        table.remove(args2, 1)

        -- // Add to output
        local selfName = self.GetFullName(self)
        local ParsedArgs = ArrayToString(args2, ", ")
        Output = Output .. __namecallFormat.format(__namecallFormat, selfName, method, ParsedArgs)
    end

    -- //
    return __namecall(...)
end)

-- // __index hook
local __indexFormat = "__index    -> self = %s\n              k    = %s\n"
local __index
__index = hookmetamethod(game, "__index", function(t, k)
    -- // Vars
    local callingscript = getcallingscript()

    -- // Make sure the spy is enabled
    if (EnableSpy and callingscript == TargetScript) then
        -- // Add to output
        local tName = t:GetFullName()
        Output = Output .. __indexFormat:format(tName, k)
    end

    -- //
    return __index(t, k)
end)

-- // __newindex hook
local __newindexFormat = "__newindex -> self = %s\n              k    = %s\n              v    = %s\n"
local __newindex
__newindex = hookmetamethod(game, "__index", function(t, k, v)
    -- // Vars
    local callingscript = getcallingscript()

    -- // Make sure the spy is enabled
    if (EnableSpy and callingscript == TargetScript) then
        -- // Add to output
        local stringv = tostring(v)
        Output = Output .. __newindexFormat:format(t:GetFullName(), k, stringv)
    end

    -- //
    return __newindex(t, k, v)
end)

-- // Toggles the spy (when we shoot)
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    -- //
    if (gameProcessedEvent) then
        return
    end

    -- // Check if we shot
    if (input.UserInputType == Enum.UserInputType.MouseButton1) then
        EnableSpy = true
        return
    end

    -- // Check if we want to save the output
    if (input.KeyCode == SaveOutput) then
        writefile("Output.txt", Output)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
    -- //
    if (gameProcessedEvent) then
        return
    end

    -- // Check if we shot
    if (input.UserInputType == Enum.UserInputType.MouseButton1) then
        EnableSpy = false

        -- // Save output
        if (AutoSaveOutput) then
            writefile("Output.txt", Output)
        end
    end
end)