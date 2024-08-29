namespace screenprotector;

internal static class Program {
    /// <summary>
    ///  The main entry point for the application.
    /// </summary>
    [STAThread]
    static void Main() {
        // To customize application configuration such as set high DPI settings or default font,
        // see https://aka.ms/applicationconfiguration.
        ApplicationConfiguration.Initialize();

        using (Mutex mutex = new Mutex(false, "ScreenProtector-app")) {
            if (!mutex.WaitOne(1000, false)) {
                MessageBox.Show("The application is running...", "Error", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                return;
            } else {
                Application.Run(new frmMain());
            }
        }
        
    }
}