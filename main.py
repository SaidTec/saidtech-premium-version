# SAID_TÉCH VPN Installer GUI using Tkinter (Python)

import os
import subprocess
import tkinter as tk
from tkinter import messagebox

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
    'Extend User': 'user_mgmt/extend_user.sh'
}

def run_script(script_path):
    if not os.path.exists(script_path):
        messagebox.showerror("Error", f"Script not found: {script_path}")
        return
    try:
        output = subprocess.check_output(['bash', script_path], stderr=subprocess.STDOUT, text=True)
        messagebox.showinfo("Success", f"Script executed successfully:\n\n{output}")
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Execution Failed", f"Error running script:\n\n{e.output}")

def create_gui():
    root = tk.Tk()
    root.title("SAID_TÉCH VPN Installer")
    root.geometry("450x700")
    root.configure(bg="#1e1e1e")

    title1 = tk.Label(root, text="Select a protocol to install:", fg="white", bg="#1e1e1e", font=("Arial", 14, "bold"))
    title1.pack(pady=10)

    for name, path in PROTOCOLS.items():
        btn = tk.Button(root, text=name, width=45, height=2, bg="#007acc", fg="white",
                        command=lambda p=path: run_script(p))
        btn.pack(pady=4)

    separator = tk.Label(root, text="\nUser Management", fg="#00ff99", bg="#1e1e1e", font=("Arial", 14, "bold"))
    separator.pack(pady=10)

    for name, path in USER_MANAGEMENT.items():
        btn = tk.Button(root, text=name, width=45, height=2, bg="#444444", fg="white",
                        command=lambda p=path: run_script(p))
        btn.pack(pady=3)

    exit_btn = tk.Button(root, text="Exit", width=45, height=2, bg="#cc0000", fg="white", command=root.quit)
    exit_btn.pack(pady=20)

    root.mainloop()

if __name__ == '__main__':
    create_gui()
