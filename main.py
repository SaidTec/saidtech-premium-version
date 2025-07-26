# SAID_TÉCH VPN Installer GUI using Tkinter (Python) with Theming and Access Control

import os
import subprocess
import tkinter as tk
from tkinter import messagebox, scrolledtext, simpledialog

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
    'Create User': 'scripts/create_user.sh',
    'Delete User': 'scripts/delete_user.sh',
    'List Users': 'scripts/list_users.sh',
    'Extend User': 'scripts/extend_user.sh',
    'Check Expiry': 'scripts/check_expiry.sh',
    'Active Sessions': 'scripts/active_sessions.sh'
}

EXPORT_CONFIGS = {
    'Export .json': 'scripts/export_json.sh',
    'Export .ovpn': 'scripts/export_ovpn.sh',
    'Export .conf': 'scripts/export_conf.sh',
    'Export .hc': 'scripts/export_hc.sh'
}

ADMIN_PASSWORD = "saidtech2024"

# Function to run shell scripts and log output

def run_script(script_path, log_area):
    if not os.path.exists(script_path):
        messagebox.showerror("Error", f"Script not found: {script_path}")
        return
    try:
        output = subprocess.check_output(['bash', script_path], stderr=subprocess.STDOUT, text=True)
        log_area.insert(tk.END, f"[SUCCESS] {script_path}\n{output}\n")
        log_area.see(tk.END)
    except subprocess.CalledProcessError as e:
        log_area.insert(tk.END, f"[ERROR] {script_path}\n{e.output}\n")
        log_area.see(tk.END)

# Themed GUI and access control

def authenticate():
    password = simpledialog.askstring("Admin Access", "Enter admin password:", show='*')
    if password != ADMIN_PASSWORD:
        messagebox.showerror("Access Denied", "Incorrect password.")
        return False
    return True

def create_gui():
    if not authenticate():
        return

    root = tk.Tk()
    root.title("SAID_TÉCH VPN Installer")
    root.geometry("800x700")
    root.configure(bg="#1e1e2e")

    title = tk.Label(root, text="Select a VPN Protocol to Install", fg="white", bg="#1e1e2e", font=("Arial", 16))
    title.pack(pady=10)

    for name, path in PROTOCOLS.items():
        btn = tk.Button(root, text=name, width=40, bg="#007acc", fg="white",
                        command=lambda p=path: run_script(p, log_area))
        btn.pack(pady=2)

    user_title = tk.Label(root, text="User Management", fg="white", bg="#1e1e2e", font=("Arial", 14))
    user_title.pack(pady=10)

    for name, path in USER_MANAGEMENT.items():
        btn = tk.Button(root, text=name, width=40, bg="#5e5eff", fg="white",
                        command=lambda p=path: run_script(p, log_area))
        btn.pack(pady=2)

    export_title = tk.Label(root, text="Export Config Files", fg="white", bg="#1e1e2e", font=("Arial", 14))
    export_title.pack(pady=10)

    for name, path in EXPORT_CONFIGS.items():
        btn = tk.Button(root, text=name, width=40, bg="#00cc66", fg="white",
                        command=lambda p=path: run_script(p, log_area))
        btn.pack(pady=2)

    log_label = tk.Label(root, text="Status Log", fg="white", bg="#1e1e2e", font=("Arial", 12))
    log_label.pack(pady=10)

    global log_area
    log_area = scrolledtext.ScrolledText(root, width=100, height=15, bg="#0d0d0d", fg="lime", font=("Courier", 10))
    log_area.pack(padx=10, pady=10)

    exit_btn = tk.Button(root, text="Exit", width=40, bg="#cc0000", fg="white", command=root.quit)
    exit_btn.pack(pady=10)

    root.mainloop()

if __name__ == '__main__':
    create_gui()
