using System.Windows;

namespace TTLFixWindows;

public partial class MainWindow : Window
{
    private readonly TTLViewModel model = new();
    public MainWindow()
    {
        InitializeComponent();
        DataContext = model;
        Loaded += async (_, _) => await model.RefreshAsync();
    }
    private async void Toggle_Click(object sender, RoutedEventArgs e) => await model.ToggleAsync();
    private void Help_Click(object sender, RoutedEventArgs e)
    {
        new InstructionWindow(new InstructionViewModel(model.Language)) { Owner = this }.ShowDialog();
    }
}
