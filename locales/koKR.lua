

if GetLocale() ~= "koKR" then
    return;
end

local _, app = ...;
local L = app.L;

for key, value in pairs({
    ["TITLE"] = "|cFFD13653죽음의 롤 콤패니언|r";
    -- ["HELP"] = "Use '/dr' with following arguments:\n - 'help': shows this help\n - 'stats': shows the stats for deathrolls against your current target\n - a number: starts a deathroll with your number as its bounty";
    -- ["HELP_ADVANCED"] = "Use '/dr' with following arguments:\n - 'help': shows this help\n - 'stats': shows the stats for deathrolls against your current target\n - a number: starts a deathroll with your number as its bounty";
    ["ERROR_UNKNOWN_COMMAND"] = "알 수없는 명령: '%s'. 도움을 받으려먄 '/dr help' 를 입력하십시오.";
    -- ["ERROR_NO_COMMAND"] = "You didn't provide a command to perform. Type '/dr help' to see what you can do.";
    ["MESSAGE_DEBUG_TOGGLE"] = "디버그 상태를 토글합니다. 현채 값: %s";
    ["MESSAGE_DEBUG_DISABLED"] = "이 명령은 디버그 모드에서만 사용할 수 있습니다.";
    ["MESSAGE_DEBUG_GREETING"] = "디버그 모드가 활성화되어 있습니다. 비활성화하려면 채팅에 '/dr debug'를 입력하십시오.";

    --[[
        Deathroll Companion Strings
    ]]

    -- Deathroll
    -- ["DEATHROLL_ERROR_MINROLLNOTONE"] = "%s made a mistake in their roll. Their minimum value in the roll was %s.";
    -- ["DEATHROLL_ERROR_MAXROLLNOTCORRECT"] = "%s made a mistake in their roll. Their maximum value in the roll was %s. It should've been %s.";
    -- ["DEATHROLL_NEWOFFER"] = "%s has offered a deathroll for %s. Accept it by using '/dr accept'.";
    -- ["DEATHROLL_OPPONENTACCEPTED"] = "%s has accepted your deathroll offer for %s. Good Luck!";
    -- ["DEATHROLL_WON"] = "You have won against %s. They owe you %s.";
    -- ["DEATHROLL_LOST"] = "You have lost against %s. You owe them %s.";
})
do L[key] = value; end
