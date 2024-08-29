using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace screenprotector_net {
    internal static class Program {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main() {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
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
}
