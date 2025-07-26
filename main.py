# SAID_TÉCH VPN Installer GUI using Tkinter (Python)

import os
import subprocess
import tkinter as tk
from tkinter import messagebox, scrolledtext

# Define protocol names and corresponding script paths
PROTOCOLS = {
    'Install SSH': 'protocols/ssh_setup.sh',
    'Install Dropbear + WS': 'protocols/dropbear_setup.sh',
    'Install Stunnel (SSL)': 'protocols/stunnel_setup.sh',
    'Install SlowDNS': 'protocols/slowdns_setup.sh',
    'Install OpenVPN': 'protocols/openvpn_setup.sh',
    'Install Trojan': 'protocols/trojan_setup.sh',
    'Install Shadowsocks': 'protocols/shadowsocks_setup.sh',
    'Install V2Ray (TLS)': 'protocols/v2ray_tls_setup.sh',
    'Install V2Ray (WS)': 'protocols/v2ray_ws_setup.sh'
}

USER_MANAGEMENT = {
    'Create User': 'user_mgmt/create_user.sh',
    'Delete User': 'user_mgmt/delete_user.sh',
    'List Users': 'user_mgmt/list_users.sh',
    'Extend User': 'user_mgmt/extend_user.sh',
    'Check Expiry': 'user_mgmt/check_expiry.sh',
    'Active Sessions': 'user_mgmt/active_sessions.sh'
}

EXPORT_CONFIGS = {
    'Export .json Config': 'export/export_json.sh',
    'Export .ovpn File': 'export/export_ovpn.sh',
    'Export .conf File': 'export/export_conf.sh',
    'Export .hc File': 'export/export_hc.sh'
}

def run_script(script_path, log_widget=None):
    if not os.path.exists(script_path):
        messagebox.showerror("Error", f"Script not found: {script_path}")
        return
    try:
        output = subprocess.check_output(['bash', script_path], stderr=subprocess.STDOUT, text=True)
        messagebox.showinfo("Success", f"Script executed successfully:\n\n{output}")
        if log_widget:
            log_widget.insert(tk.END, f"\n[✓] {script_path} executed successfully:\n{output}\n")
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Execution Failed", f"Error running script:\n\n{e.output}")
        if log_widget:
            log_widget.insert(tk.END, f"\n[!] Error executing {script_path}:\n{e.output}\n")

def create_gui():
    root = tk.Tk()
    root.title("SAID_TÉCH VPN Installer")
    root.geometry("600x850")
    root.configure(bg="#1e1e1e")

    title1 = tk.Label(root, text="Select a protocol to install:", fg="white", bg="#1e1e1e", font=("Arial", 14, "bold"))
    title1.pack(pady=10)

    for name, path in PROTOCOLS.items():
        btn = tk.Button(root, text=name, width=55, height=2, bg="#007acc", fg="white",
                        command=lambda p=path: run_script(p, log_area))
        btn.pack(pady=4)

    separator1 = tk.Label(root, text="\nUser Management", fg="#00ff99", bg="#1e1e1e", font=("Arial", 14, "bold"))
    separator1.pack(pady=10)

    for name, path in USER_MANAGEMENT.items():
        btn = tk.Button(root, text=name, width=55, height=2, bg="#444444", fg="white",
                        command=lambda p=path: run_script(p, log_area))
        btn.pack(pady=3)

    separator2 = tk.Label(root, text="\nExport Config Files", fg="#ffcc00", bg="#1e1e1e", font=("Arial", 14, "bold"))
    separator2.pack(pady=10)

    for name, path in EXPORT_CONFIGS.items():
        btn = tk.Button(root, text=name, width=55, height=2, bg="#5555aa", fg="white",
                        command=lambda p=path: run_script(p, log_area))
        btn.pack(pady=3)

    separator3 = tk.Label(root, text="\nOutput Logs", fg="#ffffff", bg="#1e1e1e", font=("Arial", 14, "bold"))
    separator3.pack(pady=10)

    global log_area
    log_area = scrolledtext.ScrolledText(root, width=70, height=15, bg="#111", fg="#0f0")
    log_area.pack(padx=10, pady=10)

    exit_btn = tk.Button(root, text="Exit", width=55, height=2, bg="#cc0000", fg="white", command=root.quit)
    exit_btn.pack(pady=20)

    root.mainloop()

if __name__ == '__main__':
    create_gui()
