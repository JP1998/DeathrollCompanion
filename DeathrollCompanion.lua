
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
    if self.Settings.Data.Debug.Enabled then
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

local function GetCharacterFullName(name)
    local _,playerServer = UnitFullName("player");
    local characterName, characterServer = UnitFullName(name);

    if not characterServer then
        characterServer = playerServer;
    end

    return characterName .. "-" .. characterServer;
end

local GOLD_MULTIPLIER = 10000;

app.GameOffers = {
    ["history"] = {},
    ["player"] = {}
    --[[
    {
        ["opponent"] = "Name",
        ["opponentFullName"] = "Name-Server",
        ["amount"] = 1234,
        ["roll"] = 1234
    }
    ]]
};

app.CurrentGame = nil;
--[[
    {
        ["amount"] = 0,
        ["latestRoll"] = 0,
        ["opponent"] = "Name",
        ["opponentFullName"] = "Name-Server"
    }
]]

app.TradingQueue = {};
-- ["Name-Server"] = amount;

local function dr_slashhandler(args, msgbox)
    if #args > 0 then
        local cmd = string.lower(args[1]);

        if cmd == "accept" then
            -- TODO: Make it able to be accepted through given name or target
            local offer = app.GameOffers.history[1];

            app.CurrentGame = {
                ["amount"] = offer.amount,
                ["latestRoll"] = offer.roll,
                ["opponent"] = offer.opponent,
                ["opponentFullName"] = offer.opponentFullName,
            };
            RandomRoll(1, offer.roll);
        elseif cmd == "abort" then
            app.CurrentGame = nil;
            app:print("Aborted current game. Feel free to initiate or accept another death roll.");
        elseif cmd == "stats" then
            app:log("Stats for a player");
        elseif cmd == "help" then
            if #args > 1 and string.lower(args[2]) == "advanced" then
                app:print(L["HELP_ADVANCED"]);
            else
                app:print(L["HELP"]);
            end
        elseif cmd == "debug" then
            local value = not app.Settings.Data.Debug.Enabled;
            app.Settings.Data.Debug.Enabled = value;
            app:print(string.format(L["MESSAGE_DEBUG_TOGGLE"], tostring(value)));
            app.Settings.DebugCheckBox:OnRefresh();
        else
            local roll = tonumber(cmd);

            if roll == nil then
                app:print(string.format(L["ERROR_UNKNOWN_COMMAND"], cmd));
            else
                app.CurrentGame = {
                    ["amount"] = roll * GOLD_MULTIPLIER,
                    ["latestRoll"] = roll,
                    ["opponent"] = nil,
                    ["opponentFullName"] = nil,
                };
                RandomRoll(1, roll);
            end
        end
    else
        app:print(L["ERROR_NO_COMMAND"]);
    end
end

createSlashCommand(dr_slashhandler, "DeathrollCompanion", "/deathroll", "/dr");

app.Data = {};

local DeathrollCompanionData_Base = {
    ["History"] = {
        --[[
        {
            ["opponent"] = "Name-Server",
            ["amount"] = 1234,
            ["win"] = true/false,
        }, -- [1]
        ]]--
        ["wins"] = 0,
        ["losses"] = 0,
        ["goldWon"] = 0,
        ["goldLost"] = 0,
        ["goldDiff"] = 0,
    },
    ["OpponentStats"] = {
        --[[
        ["Name-Server"] = {
            ["wins"] = 0,
            ["losses"] = 0,
            ["goldWon"] = 0,
            ["goldLost"] = 0,
            ["goldDiff"] = 0,
        }
        --]]
    }
}

app:RegisterEvent("ADDON_LOADED", "DeathrollCompanion", function(addon)
    if addon ~= app:GetName() then
        return;
    end

    app.Version = C_AddOns.GetAddOnMetadata(app:GetName(), "Version");

    if not DeathrollCompanionData then
        DeathrollCompanionData = CopyTable(DeathrollCompanionData_Base);
    end

    app.Data = DeathrollCompanionData;
    app.Settings:Initialize();
    
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
        app:log("Someone rolled something");

        roll = tonumber(roll);
        minroll = tonumber(minroll);
        maxroll = tonumber(maxroll);

        if minroll ~= 1 then
            app:log("Their minroll wasnt 1");
            if app.CurrentGame and (name == player or player == app.CurrentGame.opponent) and maxroll == app.CurrentGame.latestRoll then
                app:log("and they were involved in the game");
                app:print(string.format(L["DEATHROLL_ERROR_MINROLLNOTONE"], player, minroll));
            end

            return;
        end

        if app.CurrentGame and player ~= name and not app.CurrentGame.opponent and maxroll == app.CurrentGame.latestRoll then
            app:log("Someone accepted our offer to a deathroll.");

            app:print(string.format(L["DEATHROLL_OPPONENTACCEPTED"], player, C_CurrencyInfo.GetCoinTextureString(app.CurrentGame.amount)))
            app.CurrentGame.opponent = player;
            app.CurrentGame.opponentFullName = GetCharacterFullName(player);
        end

        if roll > 1 then
            app:log("Their roll was not 1. The game must go on");
            if player == name then
                app:log("We rolled that");
                if app.CurrentGame and maxroll == app.CurrentGame.latestRoll then
                    app:log("and we are currently in a game");
                    app.CurrentGame.latestRoll = roll;
                end
            else
                app:log("someone else rolled that");
                if not app.CurrentGame then
                    app:log("and we are currently not in a game. They made an offer");

                    local offer = {
                        ["opponentFullName"] = GetCharacterFullName(player),
                        ["opponent"] = player,
                        ["amount"] = maxroll * GOLD_MULTIPLIER,
                        ["roll"] = roll,
                    };

                    app.GameOffers[player] = offer;
                    table.insert(app.GameOffers.history, 1, offer);
                    app:print(string.format(L["DEATHROLL_NEWOFFER"], player, C_CurrencyInfo.GetCoinTextureString(maxroll * GOLD_MULTIPLIER)));
                else
                    app:log("and we are currently in a game.");

                    if player == app.CurrentGame.opponent then
                        app:log("it was our opponent that rolled");
                        if maxroll ~= app.CurrentGame.latestRoll then
                            app:log("but they made a mistake");
                            app:print(string.format(L["DEATHROLL_ERROR_MAXROLLNOTCORRECT"], player, maxroll, app.CurrentGame.latestRoll));
                        else
                            app:log("and the roll was valid. we are rolling ourselves");
                            app.CurrentGame.latestRoll = roll;
                            RandomRoll(1, roll);
                        end
                    end
                end
            end
        else
            app:log("Their roll was 1");

            if app.CurrentGame and app.CurrentGame.opponentFullName then
                if not app.Data.OpponentStats[app.CurrentGame.opponentFullName] then
                    app.Data.OpponentStats[app.CurrentGame.opponentFullName] = {
                        ["wins"] = 0,
                        ["losses"] = 0,
                        ["goldWon"] = 0,
                        ["goldLost"] = 0,
                        ["goldDiff"] = 0
                    };
                end

                if player == name then
                    app:log("it was us that rolled. we lost.");

                    table.insert(app.Data.History, 1, {
                        ["opponent"] = app.CurrentGame.opponentFullName,
                        ["amount"] = app.CurrentGame.amount,
                        ["win"] = false,
                    });
                    app.Data.History.losses = app.Data.History.losses + 1;
                    app.Data.History.goldLost = app.Data.History.goldLost + app.CurrentGame.amount;
                    app.Data.History.goldDiff = app.Data.History.goldDiff - app.CurrentGame.amount;

                    app.Data.OpponentStats[app.CurrentGame.opponentFullName].losses = app.Data.OpponentStats[app.CurrentGame.opponentFullName].losses + 1;
                    app.Data.OpponentStats[app.CurrentGame.opponentFullName].goldLost = app.Data.OpponentStats[app.CurrentGame.opponentFullName].goldLost + app.CurrentGame.amount;
                    app.Data.OpponentStats[app.CurrentGame.opponentFullName].goldDiff = app.Data.OpponentStats[app.CurrentGame.opponentFullName].goldDiff - app.CurrentGame.amount;

                    app:print(string.format(L["DEATHROLL_LOST"], app.CurrentGame.opponentFullName, C_CurrencyInfo.GetCoinTextureString(app.CurrentGame.amount)));

                    if not app.TradingQueue[app.CurrentGame.opponentFullName] then
                        app.TradingQueue[app.CurrentGame.opponentFullName] = app.CurrentGame.amount;
                    else
                        app.TradingQueue[app.CurrentGame.opponentFullName] = app.TradingQueue[app.CurrentGame.opponentFullName] + app.CurrentGame.amount;
                    end
                elseif app.CurrentGame and player == app.CurrentGame.opponent then
                    app:log("it was our opponent that rolled. we won.");

                    table.insert(app.Data.History, 1, {
                        ["opponent"] = app.CurrentGame.opponentFullName,
                        ["amount"] = app.CurrentGame.amount,
                        ["win"] = true,
                    });
                    app.Data.History.wins = app.Data.History.wins + 1;
                    app.Data.History.goldWon = app.Data.History.goldWon + app.CurrentGame.amount;
                    app.Data.History.goldDiff = app.Data.History.goldDiff + app.CurrentGame.amount;

                    app.Data.OpponentStats[app.CurrentGame.opponentFullName].wins = app.Data.OpponentStats[app.CurrentGame.opponentFullName].wins + 1;
                    app.Data.OpponentStats[app.CurrentGame.opponentFullName].goldWon = app.Data.OpponentStats[app.CurrentGame.opponentFullName].goldWon + app.CurrentGame.amount;
                    app.Data.OpponentStats[app.CurrentGame.opponentFullName].goldDiff = app.Data.OpponentStats[app.CurrentGame.opponentFullName].goldDiff + app.CurrentGame.amount;

                    app:print(string.format(L["DEATHROLL_WON"], app.CurrentGame.opponentFullName, C_CurrencyInfo.GetCoinTextureString(app.CurrentGame.amount)));
                end
            else
                if not app.CurrentGame then
                    app:log("Ignoring a 1 roll since we are not in a game");
                elseif not app.CurrentGame.opponent then
                    app:log("Ignoring a 1 roll since we are in a game but have no opponent");
                    -- TODO: Re-roll? since we most definitely made an offer but rolled a 1 straight off
                end
            end

            app.CurrentGame = nil;
        end
    end
end);

app:RegisterEvent("TRADE_SHOW", "DeathrollCompanion", function()
    local name,server = UnitFullName("player");
    local tradername, traderserver = UnitFullName("NPC");

    if traderserver == nil then
        traderserver = server;
    end

    local traderfullname = tradername .. "-" .. traderserver;

    local index;

    if app.TradingQueue[tradername] then
        index = tradername;
    elseif app.TradingQueue[traderfullname] then
        index = traderfullname;
    else
        app:log("Dont have anything to trade that person. Ignoring trade.")
        return;
    end

    local amountToTrade = app.TradingQueue[index];

    if GetMoney() < amountToTrade then
        app:print(string.format(L["DEATHROLL_CANTTRADE"], C_CurrencyInfo.GetCoinTextureString(amountToTrade), traderfullname));
    else
        MoneyInputFrame_SetCopper(TradePlayerInputMoneyFrame, amountToTrade);
        app.TradingQueue[index] = nil;
        app:print(string.format(L["DEATHROLL_ADDEDMONEY"], C_CurrencyInfo.GetCoinTextureString(amountToTrade), traderfullname));
    end
end);
