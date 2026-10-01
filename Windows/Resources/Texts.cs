namespace TTLFixWindows.Resources;

public static class Texts
{
    public static readonly Dictionary<string, Dictionary<string, string>> All = new()
    {
        ["ru"] = new()
        {
            ["title"] = "TTL Fix", ["russian"] = "Русский", ["english"] = "English",
            ["ttl65"] = "TTL 65", ["ttl64"] = "TTL 64",
            ["subtitle"] = "Настройка подключения через раздачу интернета",
            ["ipv4"] = "IPv4 TTL", ["ipv6"] = "IPv6 Hop Limit", ["route"] = "Как это работает",
            ["device"] = "Компьютер", ["hotspot"] = "Раздача", ["carrier"] = "Оператор",
            ["after"] = "После: 65 → 64", ["before"] = "До: 64 → 63",
            ["apply"] = "Применить TTL 65", ["applied"] = "Применено",
            ["restore"] = "Восстановить 64", ["refresh"] = "Обновить",
            ["checking"] = "Проверяю текущие значения…", ["reading"] = "Читаю текущие значения…",
            ["ready"] = "Готово к применению.", ["already"] = "TTL уже применён.",
            ["auth"] = "Windows запрашивает права администратора…", ["verify"] = "Проверяю изменённые настройки…",
            ["success"] = "Готово — TTL применён.", ["restored"] = "Значение 64 установлено.",
            ["cancelled"] = "Отмена: права администратора не были предоставлены.",
            ["failed"] = "Не удалось изменить или подтвердить настройки.",
            ["unavailable"] = "Недоступно",
            ["footer"] = "Изменение может сохраняться после перезагрузки Windows. Для изменения потребуется подтверждение UAC.",
            ["ttl_active_button"] = "TTL 65 — переключить на 64",
            ["ttl_inactive_button"] = "TTL 64 — включить 65",
            ["ttl_unknown_button"] = "TTL не определён — установить 65",
            ["active_status"] = "Включено: после раздачи будет TTL 64",
            ["inactive_status"] = "Выключено: обычный TTL 64",
            ["error_title"] = "Не удалось изменить TTL",
            ["close"] = "Закрыть",
            ["diagram_intro"] = "Раздача на телефоне уменьшает TTL каждого пакета на 1. Сравните значение, которое доходит до оператора.",
            ["scenario_off_title"] = "Без TTL Fix",
            ["scenario_off_text"] = "Компьютер отправляет TTL 64. После телефона оператор получает TTL 63 — значение отличается от обычного трафика телефона.",
            ["scenario_on_title"] = "С TTL Fix",
            ["scenario_on_text"] = "Компьютер отправляет TTL 65. После телефона оператор получает TTL 64 — обычное значение для трафика телефона.",
            ["phone_decrements"] = "−1"
        },
        ["en"] = new()
        {
            ["title"] = "TTL Fix", ["russian"] = "Русский", ["english"] = "English",
            ["ttl65"] = "TTL 65", ["ttl64"] = "TTL 64",
            ["subtitle"] = "Connection settings for Internet Sharing",
            ["ipv4"] = "IPv4 TTL", ["ipv6"] = "IPv6 Hop Limit", ["route"] = "How it works",
            ["device"] = "Computer", ["hotspot"] = "Hotspot", ["carrier"] = "Carrier",
            ["after"] = "After: 65 → 64", ["before"] = "Before: 64 → 63",
            ["apply"] = "Apply TTL 65", ["applied"] = "Applied",
            ["restore"] = "Restore 64", ["refresh"] = "Refresh",
            ["checking"] = "Checking current values…", ["reading"] = "Reading current values…",
            ["ready"] = "Ready to apply.", ["already"] = "TTL is already applied.",
            ["auth"] = "Windows is requesting administrator access…", ["verify"] = "Verifying changes…",
            ["success"] = "Done — TTL has been applied.", ["restored"] = "Value 64 has been set.",
            ["cancelled"] = "Cancelled: administrator access was not granted.",
            ["failed"] = "Couldn't change or verify settings.",
            ["unavailable"] = "Unavailable",
            ["footer"] = "The change may persist after restarting Windows. UAC confirmation is required.",
            ["ttl_active_button"] = "TTL 65 — switch to 64",
            ["ttl_inactive_button"] = "TTL 64 — enable 65",
            ["ttl_unknown_button"] = "TTL unavailable — set 65",
            ["active_status"] = "Enabled: TTL will be 64 after the hotspot",
            ["inactive_status"] = "Disabled: regular TTL is 64",
            ["error_title"] = "Couldn't change TTL",
            ["close"] = "Close",
            ["diagram_intro"] = "The hotspot reduces every packet's TTL by 1. Compare the value that reaches the carrier.",
            ["scenario_off_title"] = "Without TTL Fix",
            ["scenario_off_text"] = "The computer sends TTL 64. After the phone, the carrier receives TTL 63, which differs from normal phone traffic.",
            ["scenario_on_title"] = "With TTL Fix",
            ["scenario_on_text"] = "The computer sends TTL 65. After the phone, the carrier receives TTL 64, the normal value for phone traffic.",
            ["phone_decrements"] = "−1"
        }
    };
}
