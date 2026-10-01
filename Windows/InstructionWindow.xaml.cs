using System.Windows;

namespace TTLFixWindows;

public partial class InstructionWindow : Window
{
    public InstructionWindow(InstructionViewModel model)
    {
        InitializeComponent();
        DataContext = model;
    }

    private void Close_Click(object sender, RoutedEventArgs e) => Close();
}
