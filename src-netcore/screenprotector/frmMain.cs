using System.Runtime.InteropServices;

namespace screenprotector;

public partial class frmMain : Form {
    [DllImport("user32.dll")]
    public static extern uint SetWindowDisplayAffinity(IntPtr hwnd, uint dwAffinity);

    [DllImport("user32.dll")]
    public static extern long SetWindowPos(IntPtr hwnd, int hWndInsertAfter, int X, int y, int cx, int cy, int wFlagslong);
    const short SWP_NOSIZE = 0x0001;
    const short SWP_NOMOVE = 0x0002;
    const int SWP_NOZORDER = 0x0004;
    const int SWP_SHOWWINDOW = 0x0040;

    [DllImport("user32.dll", EntryPoint = "GetWindowLong")]
    public static extern int GetWindowLong(
        IntPtr hwnd,
        int nIndex
    );

    const int WS_THICKFRAME = 0x00040000;
    const int GWL_STYLE = -16;

    [DllImport("user32.dll", EntryPoint = "SetWindowLong")]
    public static extern int SetWindowLong(
        IntPtr hwnd,
        int nIndex,
        int dwNewLong
    );


    bool errflag = false;
    public frmMain() {
        InitializeComponent();

        OperatingSystem os = Environment.OSVersion;
        Version vs = os.Version;
        if (os.Platform == PlatformID.Unix || os.Platform == PlatformID.Other) {
            errflag = true;
        } else if (os.Platform == PlatformID.Win32NT) {
            errflag = true;
            if (vs.Major >= 6) {
                if (vs.Major == 6) {
                    if (vs.Minor >= 1) { 
                        errflag = false;
                    }
                }
                if (vs.Major > 6)
                    errflag = false;
            }
        }

        if (!errflag) {
            int twidth = 0;
            int theight = 0;
            for (int i = 0; i < Screen.AllScreens.Length; i++) {
                Rectangle monitor = Screen.AllScreens[i].Bounds;
                frmBlocker blk = new frmBlocker(i);
                blk.Show();
                SetWindowPos(blk.Handle, 0, monitor.Left, monitor.Top, monitor.Width, monitor.Height, 0);
                //twidth += Screen.AllScreens[i].Bounds.Width;
                //theight += Screen.AllScreens[i].Bounds.Height;
            }
            this.Left = 0;
            this.Top = 0;
            this.Width = twidth;
            this.Height = theight;
            this.TopMost = true;
            this.ShowInTaskbar = false;
            SetWindowDisplayAffinity(this.Handle, 1);
        }

    }

    private void frmMain_FormClosing(object sender, FormClosingEventArgs e) {
        if (!errflag)
            e.Cancel = true;
    }

    private void frmMain_Load(object sender, EventArgs e) {
        if (errflag) {
            MessageBox.Show("This application supported minimum OS Windows 7", "Error", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            Application.Exit();
        }
    }
}
