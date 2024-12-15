

if GetLocale() ~= "deDE" then
    return;
end

local _, app = ...;
local L = app.L;

for key, value in pairs({
    -- ["TITLE"] = "|cFFD13653Deathroll Companion|r";
    ["HELP"] = "Du kannst '/dr' mit folgenden Argumenten benutzen:\n - 'help': Zeigt diese Hilfe-Nachricht\n - 'stats': Zeigt dir deine Deathroll-Statistiken gegen dein Ziel\n - eine Zahl: Startet ein Deathroll mit der Zahl als sein Einsatz";
    ["HELP_ADVANCED"] = "Du kannst '/dr' mit folgenden Argumenten benutzen:\n - 'help': Zeigt diese Hilfe-Nachricht\n - 'stats': Zeigt dir deine Deathroll-Statistiken gegen dein Ziel\n - eine Zahl: Startet ein Deathroll mit der Zahl als sein Einsatz";
    ["ERROR_UNKNOWN_COMMAND"] = "Unbekannter Befehl: '%s'. Gib '/dr help' ein, um die Hilfe anzuzeigen.";
    ["ERROR_NO_COMMAND"] = "Sie haben keinen Befehl zum ausführen angegeben. Nutzen Sie '/dr help' um alle Möglichketen zu sehen.";
    ["MESSAGE_DEBUG_TOGGLE"] = "Debug-Modus wurde getoggelt. Derzeitiger Wert: %s";
    ["MESSAGE_DEBUG_DISABLED"] = "Dieser Befehl kann nur genutzt werden, wenn der Debug-Modus eingestellt ist.";
    ["MESSAGE_DEBUG_GREETING"] = "Sie haben den Debug-Modus aktiv. Um ihn auszuschalten, geben Sie '/dr debug' in Ihren Chat ein.";

    --[[
        Deathroll Companion Strings
    ]]

    -- Deathroll
    ["DEATHROLL_ERROR_MINROLLNOTONE"] = "%s hat einen Fehler mit seinem Würfel gemacht. Der Minimalwert war %s.";
    ["DEATHROLL_ERROR_MAXROLLNOTCORRECT"] = "%s hat einen Fehler mit seinem Würfel gemacht. Der Maximalwert war %s. Er hätte %s sein sollen.";
    ["DEATHROLL_NEWOFFER"] = "%s hat ein Deathroll mit einem Einsatz von %s angeboten. Nutze '/dr accept' um das Angebot anzunehmen.";
    ["DEATHROLL_OPPONENTACCEPTED"] = "%s hat dein Angebot zu einem Deathroll mit einem Einsatz von %s angenommen. Viel Glück!";
})
do L[key] = value; end
