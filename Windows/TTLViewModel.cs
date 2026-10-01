using System.ComponentModel;
using System.Windows.Media;
using TTLFixWindows.Resources;

namespace TTLFixWindows;

public sealed class TTLViewModel : INotifyPropertyChanged
{
    private readonly TTLService service = new();
    private string language = "ru", statusKey = "checking";
    private int? ipv4, ipv6;
    private bool isWorking;

    public event PropertyChangedEventHandler? PropertyChanged;

    public string Language { get => language; set { language = value; NotifyAll(); } }
    private string T(string key) => Texts.All[Language][key];

    public bool IsEnabled => ipv4 == 65 && ipv6 == 65;
    public int? CurrentTTL => ipv4 == ipv6 ? ipv4 : null;
    public bool CanToggle => !isWorking;
    public bool IsWorking { get => isWorking; private set { isWorking = value; NotifyAll(); } }
    public bool HasError => statusKey is "cancelled" or "failed";

    public string Title => T("title");
    public string Subtitle => T("subtitle");
    public string RussianLabel => T("russian");
    public string EnglishLabel => T("english");
    public string RouteLabel => T("route");
    public string Footer => T("footer");
    public string ErrorTitle => T("error_title");
    public string Status => T(statusKey);
    public string NormalStatus => IsEnabled ? T("active_status") : T("inactive_status");
    public string ToggleLabel => CurrentTTL is null ? T("ttl_unknown_button") : IsEnabled ? T("ttl_active_button") : T("ttl_inactive_button");
    public string ToggleIcon => IsEnabled ? "✓" : "×";
    public Brush ToggleBrush => IsEnabled ? new SolidColorBrush(Color.FromRgb(51, 179, 99)) : new SolidColorBrush(Color.FromRgb(235, 79, 79));
    public Brush StatusBrush => HasError ? Brushes.Firebrick : IsEnabled ? new SolidColorBrush(Color.FromRgb(51, 179, 99)) : new SolidColorBrush(Color.FromRgb(235, 79, 79));

    public async Task RefreshAsync()
    {
        IsWorking = true;
        SetStatus("reading");
        (ipv4, ipv6) = await service.ReadAsync();
        SetStatus(IsEnabled ? "already" : "ready");
        IsWorking = false;
    }

    public Task ToggleAsync() => IsEnabled ? ChangeAsync(64, "restored") : ChangeAsync(65, "success");

    private async Task ChangeAsync(int value, string successKey)
    {
        IsWorking = true;
        SetStatus("auth");
        bool? commandSucceeded = await service.SetAsync(value);
        if (commandSucceeded is null) { SetStatus("cancelled"); IsWorking = false; return; }
        if (commandSucceeded == false) { SetStatus("failed"); IsWorking = false; return; }

        SetStatus("verify");
        (ipv4, ipv6) = await service.ReadAsync();
        SetStatus(ipv4 == value && ipv6 == value ? successKey : "failed");
        IsWorking = false;
    }

    private void SetStatus(string key) { statusKey = key; NotifyAll(); }
    private void NotifyAll() => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(null));
}
