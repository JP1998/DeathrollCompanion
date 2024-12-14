
local app = select(2, ...);
local L = app.L;

--[[
 --
 -- General Utility stuff
 --
--]]

app.print = function(self, msg, ...)
    self:_print("", msg, ...);
end
app.log = function(self, msg, ...)
    if self.Data.Debug.Enabled then
        self:_print("DEBUG ", msg, ...);
    end
end
app._print = function(self, prefix, msg, ...)
    local args = {...};
    local lines = { strsplit("\n", type(msg) == "string" and msg or tostring(msg)) };

    for _,line in ipairs(lines) do
        print(string.format("%s[%s]: %s", prefix, L["TITLE"], line));
    end

    if args and #args > 0 then
        self:_print(prefix, unpack(args));
    end
end
app.stringify = function(t)
    if type(t) == "table" then
        local text = "{ ";
        local first = true;

        for k,v in pairs(t) do
            if not first then
                text = text .. ", ";
            end

            first = false;
            text = text .. string.format("[%s] = %s", app.stringify(k), app.stringify(v));
        end

        text = text .. " }";

        return text;
    elseif type(t) == "boolean" then
        return t and "true" or "false"
    elseif type(t) == "number" then
        return "" .. t;
    elseif type(t) == "string" then
        return app.stringEscape(t);
    elseif type(t) == "function" then
        if debug then
            local info = debug.getinfo(t, "S");

            if info.what == "Lua" then
                local where, _ = info.source:gsub("(@)(.*" .. app:GetName() .. ")(.*)", "%1%3");

                return string.format("<function%s:%s>", where, info.linedefined);
            else
                return "<C function:?>";
            end
        else
            return "<function>";
        end
    elseif type(t) == "nil" then
        return "nil";
    end
end

app.Windows = {};
app.RegisterWindow = function(self, suffix, window)
    self.Windows[suffix] = window;
end
app.CreateWindow = function(self, suffix, parent)
    local WindowCreator = {
        ["WorldQuestTracker"] = app.WorldQuestTracker.CreateWorldQuestTrackerFrame;
    };

    if WindowCreator[suffix] then
        return WindowCreator[suffix](suffix, parent or UIParent);
    else
        return nil;
    end
end
app.GetWindow = function(self, suffix, parent)
    local window = self.Windows[suffix];

    if not window then
        window = self:CreateWindow(suffix, parent);
        self.Windows[suffix] = window;
    end

    return window;
end

app.stringEscape = function(str)
    return string.gsub(string.format("%q", str), "\n", "n");
end
app.stringTrim = function(str)
    return (string.gsub(str, "^%s*(.-)%s*$", "%1"));
end
app.eliminateEmptyStrings = function(list)
    local result = {};

    for i,s in ipairs(list) do
        if s ~= "" then
            table.insert(result, s);
        end
    end

    return result;
end

local createSlashCommand = (function()
    local function parseSlashCommandArgs(cmd)
        return app.eliminateEmptyStrings({ strsplit(" ", cmd) });
    end

    return function(func, id, ...)
        local slashes = { ... };
        if #slashes == 0 then
            return; -- cant create slash command without slashes
        end

        if type(id) ~= "string" or id == "" then
            return; -- need id that is a non-empty string
        end

        for i,slash in ipairs(slashes) do
            setglobal(string.format("SLASH_%s%d", id, i), slash);
        end
        _G.SlashCmdList[id] = function(cmd, msgBox)
            func(parseSlashCommandArgs(cmd), msgBox);
        end
    end
end)();

local function dr_slashhandler(args, msgbox)
    app:log("You typed '/dr' or something similar.");

    if #args > 0 then
        local cmd = string.lower(args[1]);

        if cmd == "stats" then
            app:log("Stats for a player");
        elseif cmd == "help" then
            if #args > 1 and string.lower(args[2]) == "advanced" then
                app:print(L["HELP_ADVANCED"]);
            else
                app:print(L["HELP"]);
            end
        elseif cmd == "debug" then
            local value = not app.Data.Debug.Enabled;
            app.Data.Debug.Enabled = value;
            app:print(string.format(L["MESSAGE_DEBUG_TOGGLE"], tostring(value)));
        else
            -- Couldve put in a number for a deathroll
            app:log("Got some args");
        end
    else
        app:log("didnt get any args");
    end
end

createSlashCommand(dr_slashhandler, "DeathrollCompanion", "/deathroll", "/dr");

app.Data = {};

local DeathrollCompanionData_Base = {
    ["Debug"] = {
        ["Enabled"] = false
    },
    ["History"] = {
        --[[
        {
            ["opponent"] = "Name",
            ["amount"] = 1234,
            ["win"] = true/false,
        }, -- [1]
        ]]--
    },
    ["wins"] = {
        ["amount"] = 0,
        ["gold"] = 0,
        ["opponentStats"] = {
            --[[
            ["Name-Server"] = {
                ["amount"] = 0,
                ["gold"] = 0,
            }
            --]]
        }
    },
    ["losses"] = {
        ["amount"] = 0,
        ["gold"] = 0,
        ["opponentStats"] = {
            --[[
            ["Name-Server"] = {
                ["amount"] = 0,
                ["gold"] = 0,
            }
            --]]
        }
    }
}

local GOLD_MULTIPLIER = 10000;

app.GameOffers = {
    --[[
    ["name"] = {
        ["amount"] = 1234,
        ["roll"] = 1234,
    }
    ]]
};

app.CurrentGame = nil;
--[[
    {
        ["amount"] = 0,
        ["latestRoll"] = 0,
        ["opponent"] = "Name";
    }
]]

app:RegisterEvent("ADDON_LOADED", "DeathrollCompanion", function(addon)
    if addon ~= app:GetName() then
        return;
    end

    app.Version = C_AddOns.GetAddOnMetadata(app:GetName(), "Version");

    if not DeathrollCompanionData then
        DeathrollCompanionData = CopyTable(DeathrollCompanionData_Base);
    end

    app.Data = DeathrollCompanionData;

    app:log(L["MESSAGE_DEBUG_GREETING"]);

    app:UnregisterEvent("ADDON_LOADED", "DeathrollCompanion");

    -- You have won against <name>. They owe you <amount>
    -- You have lost against <name>. You owe them <amount>. We will auto-fill the amount for you once you trade them.

    -- You currently have no track record against %s
    -- You have a track record of |cgreen <wins>|r-|cred <losses>|r (|cred or green <diff>) against <name>. You
    --                                                                                                          have |rred or green won/lost|r <amount> from/to them.
    --                                                                                                          are even with them so far.
end);

app:RegisterEvent("CHAT_MSG_SYSTEM", "DeathrollCompanion", function(message)
    local player, roll, minroll, maxroll = strmatch(message, "(.*) rolls (%d+) %((%d+)%-(%d+)%)");

    local name,server = UnitFullName("player");

    if player ~= nil then
        if player == name then
            app:log(string.format("You rolled %s in a roll from %s to %s.", roll, minroll, maxroll));
        else
            if not app.CurrentGame then
                app.GameOffers[player] = {
                    ["amount"] = maxroll * GOLD_MULTIPLIER,
                    ["roll"] = roll,
                };
                app:print(string.format("%s has offered a deathroll for %s. Accept it by using '/dr accept'.", player, C_CurrencyInfo.GetCoinTextureString(maxroll * GOLD_MULTIPLIER)));
            elseif player == app.CurrentGame.opponent then

            end

            -- app:log(string.format("%s rolled %s in a roll from %s to %s.", player, roll, minroll, maxroll));
        end
    else
        app:log("Got the event but nobody rolled.");
    end
end);
