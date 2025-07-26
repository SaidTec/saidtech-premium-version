# SAID_TÉCH VPN Installer GUI using Tkinter (Python)

import os
import subprocess
import tkinter as tk
from tkinter import messagebox, simpledialog, filedialog, scrolledtext
import json
import shutil
import requests

# Telegram settings
BOT_TOKEN = '7664045213:AAE2c9ZxKzGEwZuhoGbC77TUGdHwhx-Rs9c'
CHAT_ID = '7108127485'

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
    'Extend User': 'user_tools/extend_user.sh',
    'List Users': 'user_tools/list_users.sh',
    'Check Expiry': 'user_tools/check_expiry.sh',
    'Active Sessions': 'user_tools/sessions.sh'
}

EXPORT_TOOLS = {
    'Export .json': 'export/export_json.sh',
    'Export .ovpn': 'export/export_ovpn.sh',
    'Export .conf': 'export/export_conf.sh',
    'Export .hc': 'export/export_hc.sh'
}

def run_script(script_path):
    if not os.path.exists(script_path):
        messagebox.showerror("Error", f"Script not found: {script_path}")
        return
    try:
        output = subprocess.check_output(['bash', script_path], stderr=subprocess.STDOUT, text=True)
        log.insert(tk.END, f"\n[SUCCESS] {script_path}:\n{output}\n")
    except subprocess.CalledProcessError as e:
        log.insert(tk.END, f"\n[ERROR] {script_path}:\n{e.output}\n")
        messagebox.showerror("Installation Failed", f"Error installing:\n\n{e.output}")


def export_config(script_path):
    if not os.path.exists(script_path):
        messagebox.showerror("Error", f"Export script not found: {script_path}")
        return
    try:
        output = subprocess.check_output(['bash', script_path], stderr=subprocess.STDOUT, text=True)
        log.insert(tk.END, f"\n[EXPORTED] {script_path}:\n{output}\n")

        # Assume output path is printed on last line
        output_path = output.strip().split('\n')[-1]
        if os.path.exists(output_path):
            send_file_to_telegram(output_path)
            messagebox.showinfo("Export Success", f"Config exported and sent to Telegram:\n{output_path}")
        else:
            messagebox.showwarning("Export Failed", f"Output file not found: {output_path}")

    except subprocess.CalledProcessError as e:
        log.insert(tk.END, f"\n[ERROR] Export: {e.output}\n")
        messagebox.showerror("Export Failed", f"Error exporting config:\n\n{e.output}")


def send_file_to_telegram(file_path):
    try:
        with open(file_path, 'rb') as f:
            requests.post(
                f'https://api.telegram.org/bot{BOT_TOKEN}/sendDocument',
                data={'chat_id': CHAT_ID},
                files={'document': f}
            )
    except Exception as e:
        log.insert(tk.END, f"\n[TELEGRAM ERROR] {e}\n")


def switch_theme():
    global dark_mode
    dark_mode = not dark_mode
    bg = "#1e1e1e" if dark_mode else "#ffffff"
    fg = "white" if dark_mode else "black"
    root.configure(bg=bg)
    for widget in root.winfo_children():
        if isinstance(widget, (tk.Button, tk.Label)):
            widget.configure(bg=bg, fg=fg)
    log.configure(bg="black" if dark_mode else "white", fg="lime" if dark_mode else "black")

def check_admin():
    password = simpledialog.askstring("Access Control", "Enter admin password:", show='*')
    return password == "saidtechadmin"

def create_gui():
    global root, log, dark_mode
    dark_mode = True

    root = tk.Tk()
    root.title("SAID_TÉCH VPN Installer")
    root.geometry("500x700")
    root.configure(bg="#1e1e1e")

    if not check_admin():
        messagebox.showerror("Access Denied", "Invalid password.")
        root.destroy()
        return

    tk.Button(root, text="Switch Theme", command=switch_theme, bg="#444", fg="white").pack(pady=5)

    tk.Label(root, text="Install Protocols", bg="#1e1e1e", fg="white").pack()
    for name, path in PROTOCOLS.items():
        tk.Button(root, text=name, width=40, bg="#007acc", fg="white",
                  command=lambda p=path: run_script(p)).pack(pady=2)

    tk.Label(root, text="User Tools", bg="#1e1e1e", fg="white").pack(pady=5)
    for name, path in USER_TOOLS.items():
        tk.Button(root, text=name, width=40, bg="#0055aa", fg="white",
                  command=lambda p=path: run_script(p)).pack(pady=2)

    tk.Label(root, text="Export Configs", bg="#1e1e1e", fg="white").pack(pady=5)
    for name, path in EXPORT_TOOLS.items():
        tk.Button(root, text=name, width=40, bg="#00aa55", fg="white",
                  command=lambda p=path: export_config(p)).pack(pady=2)

    tk.Label(root, text="Status Log", bg="#1e1e1e", fg="white").pack(pady=5)
    log = scrolledtext.ScrolledText(root, height=10, bg="black", fg="lime")
    log.pack(fill=tk.BOTH, padx=10, pady=5, expand=True)

    tk.Button(root, text="Exit", width=40, bg="#cc0000", fg="white", command=root.quit).pack(pady=10)

    root.mainloop()

if __name__ == '__main__':
    create_gui()
