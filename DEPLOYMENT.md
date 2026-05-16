# 🚀 Local Network Deployment Guide (IIS)

This guide explains how to host the **Tesco Clone** (API, Web, and Admin) on your local network so anyone on your Wi-Fi/Ethernet can access it.

## 📍 Quick Access Links
*   **Storefront (Web):** [http://192.168.10.22:8082](http://192.168.10.22:8082)
*   **Admin Panel:** [http://192.168.10.22:8083](http://192.168.10.22:8083)
*   **API Status:** [http://192.168.10.22:8081/api/v1/status](http://192.168.10.22:8081/api/v1/status)

---

## 🛠️ One-Time Initial Setup
If you haven't configured IIS yet, follow these steps once:

1.  **Run IIS Setup**:
    Open PowerShell as **Administrator** and run:
    ```powershell
    .\IIS_Setup.ps1
    ```
2.  **Open Firewall Ports**:
    To allow other devices to access your site, run these commands in Admin PowerShell:
    ```powershell
    New-NetFirewallRule -DisplayName "Tesco API" -Direction Inbound -LocalPort 8081 -Protocol TCP -Action Allow
    New-NetFirewallRule -DisplayName "Tesco Web" -Direction Inbound -LocalPort 8082 -Protocol TCP -Action Allow
    New-NetFirewallRule -DisplayName "Tesco Admin" -Direction Inbound -LocalPort 8083 -Protocol TCP -Action Allow
    ```
3.  **Grant Database Access**:
    The API needs permission to talk to SQL Server. In **SQL Server Management Studio**, run:
    ```sql
    USE [master]
    GO
    CREATE LOGIN [IIS AppPool\TescoAPI] FROM WINDOWS;
    GO
    USE [TescoCloneDb] -- Replace with your DB name
    GO
    CREATE USER [IIS AppPool\TescoAPI] FOR LOGIN [IIS AppPool\TescoAPI];
    GO
    ALTER ROLE [db_owner] ADD MEMBER [IIS AppPool\TescoAPI];
    GO
    ```

---

## 🔄 How to Publish New Changes
Whenever you change the code and want to update the live sites, simply run this single command:

1.  Open PowerShell in the project root.
2.  Run:
    ```powershell
    .\Update_Sites.ps1
    ```
    *This will rebuild the API, Storefront, and Admin and deploy them to the IIS folders immediately.*

---

## 📁 Folder Structure
*   **Source Code:** `src/` and `frontend/`
*   **Hosted Files (IIS):** `publish/` (This is where IIS looks for the files)
*   **API Logs:** `publish/api/logs/` (Check here if the API has errors)

## ⚠️ Troubleshooting
*   **Site not loading?** Ensure the "World Wide Web Publishing Service" is running in Windows Services.
*   **500 Error?** Check the database permissions (Step 3 above).
*   **IP Changed?** If your computer's IP changes, you must update the IP in `environment.ts` and `appsettings.json` and run `.\Update_Sites.ps1` again.
