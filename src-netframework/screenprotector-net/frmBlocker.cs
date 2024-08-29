using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace screenprotector_net {
    public partial class frmBlocker : Form {

        [DllImport("user32.dll")]
        public static extern uint SetWindowDisplayAffinity(IntPtr hwnd, uint dwAffinity);
        public frmBlocker(int param) {
            InitializeComponent();
            int twidth = 0;
            int theight = 0;
            twidth = Screen.AllScreens[param].Bounds.Width;
            theight = Screen.AllScreens[param].Bounds.Height;
            this.Width = twidth;
            this.Height = theight;
            this.TopMost = true;
            this.ShowInTaskbar = false;
            SetWindowDisplayAffinity(this.Handle, 1);
        }

        private void frmBlocker_FormClosing(object sender, FormClosingEventArgs e) {
            e.Cancel = true;
        }
    }
}
