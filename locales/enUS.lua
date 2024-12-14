
local name, app = ...;
app.L = {
    ["TITLE"] = "|cFFD13653Deathroll Companion|r";
    ["HELP"] = "Use '/dr' with following arguments:\n - 'help': shows this help\n - 'stats': shows the stats for deathrolls against your current target\n - a number: starts a deathroll with your number as its bounty";
    ["HELP_ADVANCED"] = "Use '/dr' with following arguments:\n - 'help': shows this help\n - 'debug': toggles the debug flag\n    This shows debug messages in chat and gives access to following commands:\n - a number: starts a deathroll with your number as its bounty";
    ["MESSAGE_DEBUG_TOGGLE"] = "Toggled debug state. Current value: %s";
    ["MESSAGE_DEBUG_DISABLED"] = "This command is only usable with debug mode on.";
    ["MESSAGE_DEBUG_GREETING"] = "You have debug mode enabled. To disable type '/dr debug' into chat.";

};
