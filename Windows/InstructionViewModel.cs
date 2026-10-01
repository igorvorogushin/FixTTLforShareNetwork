using TTLFixWindows.Resources;

namespace TTLFixWindows;

public sealed class InstructionViewModel
{
    private readonly string language;
    public InstructionViewModel(string language) => this.language = language;
    private string T(string key) => Texts.All[language][key];

    public string RouteLabel => T("route");
    public string CloseLabel => T("close");
    public string DiagramIntro => T("diagram_intro");
    public string ScenarioOffTitle => T("scenario_off_title");
    public string ScenarioOffText => T("scenario_off_text");
    public string ScenarioOnTitle => T("scenario_on_title");
    public string ScenarioOnText => T("scenario_on_text");
    public string DeviceLabel => T("device");
    public string HotspotLabel => T("hotspot");
    public string CarrierLabel => T("carrier");
    public string DecrementLabel => T("phone_decrements");
}
