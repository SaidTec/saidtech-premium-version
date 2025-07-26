# SAID_TÉCH VPN Installer GUI using Tkinter (Python)

import os
import subprocess
import tkinter as tk
from tkinter import messagebox, simpledialog, scrolledtext
from datetime import datetime

ADMIN_PASSWORD = "saidtech"

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

USER_TOOLS = {
    'Create User': 'user_tools/create_user.sh',
    'Delete User': 'user_tools/delete_user.sh',
    'List Users': 'user_tools/list_users.sh',
    'Extend User': 'user_tools/extend_user.sh',
    'Check Expiry': 'user_tools/check_expiry.sh',
    'Active Sessions': 'user_tools/active_sessions.sh'
}

EXPORT_CONFIGS = {
    'Export JSON': 'export/export_json.sh',
    'Export OVPN': 'export/export_ovpn.sh',
    'Export CONF': 'export/export_conf.sh',
    'Export HC': 'export/export_hc.sh'
}

def run_script(script_path, log_box):
    if not os.path.exists(script_path):
        messagebox.showerror("Error", f"Script not found: {script_path}")
        return
    try:
        output = subprocess.check_output(['bash', script_path], stderr=subprocess.STDOUT, text=True)
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log_box.insert(tk.END, f"[{timestamp}] SUCCESS: {script_path}\n{output}\n\n")
        log_box.see(tk.END)
    except subprocess.CalledProcessError as e:
        log_box.insert(tk.END, f"ERROR: {script_path}\n{e.output}\n\n")
        log_box.see(tk.END)

def verify_access():
    password = simpledialog.askstring("Access Control", "Enter admin password:", show='*')
    if password != ADMIN_PASSWORD:
        messagebox.showerror("Access Denied", "Incorrect password.")
        exit()

def create_gui():
    verify_access()
    root = tk.Tk()
    root.title("SAID_TÉCH VPN Installer")
    root.geometry("600x700")
    root.configure(bg="#202124")

    title = tk.Label(root, text="SAID_TÉCH VPN Installer", fg="white", bg="#202124", font=("Arial", 16, "bold"))
    title.pack(pady=10)

    protocol_frame = tk.LabelFrame(root, text="VPN Protocols", fg="white", bg="#202124", font=("Arial", 12, "bold"))
    protocol_frame.pack(padx=10, pady=5, fill="both")

    for name, path in PROTOCOLS.items():
        btn = tk.Button(protocol_frame, text=name, width=25, bg="#4285F4", fg="white",
                        command=lambda p=path: run_script(p, log_box))
        btn.pack(pady=2)

    user_frame = tk.LabelFrame(root, text="User Management", fg="white", bg="#202124", font=("Arial", 12, "bold"))
    user_frame.pack(padx=10, pady=5, fill="both")

    for name, path in USER_TOOLS.items():
        btn = tk.Button(user_frame, text=name, width=25, bg="#0F9D58", fg="white",
                        command=lambda p=path: run_script(p, log_box))
        btn.pack(pady=2)

    export_frame = tk.LabelFrame(root, text="Export Configs", fg="white", bg="#202124", font=("Arial", 12, "bold"))
    export_frame.pack(padx=10, pady=5, fill="both")

    for name, path in EXPORT_CONFIGS.items():
        btn = tk.Button(export_frame, text=name, width=25, bg="#F4B400", fg="black",
                        command=lambda p=path: run_script(p, log_box))
        btn.pack(pady=2)

    log_label = tk.Label(root, text="Status Logs:", fg="white", bg="#202124", font=("Arial", 12))
    log_label.pack(pady=5)

    global log_box
    log_box = scrolledtext.ScrolledText(root, height=10, width=70, bg="#1e1e1e", fg="white")
    log_box.pack(padx=10, pady=5)

    exit_btn = tk.Button(root, text="Exit", width=30, height=2, bg="#DB4437", fg="white", command=root.quit)
    exit_btn.pack(pady=10)

    root.mainloop()

if __name__ == '__main__':
    create_gui()
