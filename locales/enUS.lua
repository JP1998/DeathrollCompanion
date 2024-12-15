
local name, app = ...;
app.L = {
    ["TITLE"] = "|cFFD13653Deathroll Companion|r";
    ["HELP"] = "Use '/dr' with following arguments:\n - 'help': shows this help\n - 'stats': shows the stats for deathrolls against your current target\n - a number: starts a deathroll with your number as its bounty";
    ["HELP_ADVANCED"] = "Use '/dr' with following arguments:\n - 'help': shows this help\n - 'stats': shows the stats for deathrolls against your current target\n - a number: starts a deathroll with your number as its bounty";
    ["ERROR_UNKNOWN_COMMAND"] = "Unknown command: '%s'. Type '/dr help' for some help.";
    ["ERROR_NO_COMMAND"] = "You didn't provide a command to perform. Type '/dr help' to see what you can do.";
    ["MESSAGE_DEBUG_TOGGLE"] = "Toggled debug state. Current value: %s";
    ["MESSAGE_DEBUG_DISABLED"] = "This command is only usable with debug mode on.";
    ["MESSAGE_DEBUG_GREETING"] = "You have debug mode enabled. To disable type '/dr debug' into chat.";

    --[[
        Deathroll Companion Strings
    ]]

    -- Deathroll
    ["DEATHROLL_ERROR_MINROLLNOTONE"] = "%s made a mistake in their roll. Their minimum value in the roll was %s.";
    ["DEATHROLL_ERROR_MAXROLLNOTCORRECT"] = "%s made a mistake in their roll. Their maximum value in the roll was %s. It should've been %s.";
    ["DEATHROLL_NEWOFFER"] = "%s has offered a deathroll for %s. Accept it by using '/dr accept'.";
    ["DEATHROLL_OPPONENTACCEPTED"] = "%s has accepted your deathroll offer for %s. Good Luck!";
};
