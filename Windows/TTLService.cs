using System.Diagnostics;

namespace TTLFixWindows;

internal sealed class TTLService
{
    public async Task<(int? IPv4, int? IPv6)> ReadAsync() =>
        (await ReadOneAsync("IPv4"), await ReadOneAsync("IPv6"));

    private static async Task<int?> ReadOneAsync(string family)
    {
        try
        {
            var start = new ProcessStartInfo("powershell.exe")
            {
                UseShellExecute = false, RedirectStandardOutput = true,
                RedirectStandardError = true, CreateNoWindow = true
            };
            start.ArgumentList.Add("-NoProfile");
            start.ArgumentList.Add("-NonInteractive");
            start.ArgumentList.Add("-Command");
            start.ArgumentList.Add($"(Get-Net{family}Protocol).DefaultHopLimit");
            using var process = Process.Start(start);
            if (process is null) return null;
            string output = await process.StandardOutput.ReadToEndAsync();
            await process.WaitForExitAsync();
            return process.ExitCode == 0 && int.TryParse(output.Trim(), out int value) ? value : null;
        }
        catch { return null; }
    }

    public async Task<bool?> SetAsync(int value)
    {
        try
        {
            string command = $"netsh interface ipv4 set global defaultcurhoplimit={value} && netsh interface ipv6 set global defaultcurhoplimit={value}";
            using var process = Process.Start(new ProcessStartInfo("cmd.exe", "/c " + command)
            {
                Verb = "runas", UseShellExecute = true, CreateNoWindow = true
            });
            if (process is null) return false;
            await process.WaitForExitAsync();
            return process.ExitCode == 0;
        }
        catch (System.ComponentModel.Win32Exception error) when (error.NativeErrorCode == 1223) { return null; }
        catch { return false; }
    }
}
