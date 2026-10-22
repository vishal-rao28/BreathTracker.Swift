---
description: How to run and modify the BreathTrack website on a personal laptop
---

This guide contains step-by-step instructions to copy, run, and make changes to the BreathTrack web application and database on your personal laptop.

### 1. Prerequisites (What to Install)
Make sure you have the following installed on your personal laptop:
1. **Node.js** (LTS version): Download and install from [nodejs.org](https://nodejs.org/).
2. **VS Code** (or any code editor): Download from [code.visualstudio.com](https://code.visualstudio.com/).
3. **XAMPP**: Download and install from [apachefriends.org](https://www.apachefriends.org/) to run Apache and MySQL.

---

### 2. Copy the Files
Copy the project folder from your current machine to your personal laptop.

---

### 3. Setting Up the Backend (PHP & MySQL)
1. **Deploy PHP Code**:
   * Copy the `nov19` folder into the XAMPP web root directory on your laptop:
     - **macOS**: `/Applications/XAMPP/xamppfiles/htdocs/`
     - **Windows**: `C:\xampp\htdocs\`
2. **Start Servers**:
   * Open XAMPP Control Panel and start **Apache** and **MySQL Server**.
3. **Setup Database**:
   * Open your browser and navigate to `http://localhost/phpmyadmin/`.
   * Create a new database named **`breathtrack`**.
   * Click on the `breathtrack` database, go to the **Import** tab, choose the file **`breathtrack (15).sql`** (located in the `nov19` folder), and click **Import/Go**.
4. **Configure PHP Database Connection**:
   * Open your local `nov19/config.php` on the laptop.
   * Verify/update host, port, username, and password under the `Database` class:
     ```php
     private $host = "127.0.0.1";         // Change port to 127.0.0.1:3307 if your XAMPP mysql runs on port 3307
     private $db_name = "breathtrack";
     private $username = "root";
     private $password = "";              // Default is empty
     ```

---

### 4. Running the Frontend (React / Vite)
1. Open terminal on your laptop and navigate to the `breathtrack-web` folder:
   ```bash
   cd /path/to/copied/breathtrack-web
   ```
2. Install npm dependencies (first time setup):
   ```bash
   npm install
   ```
3. Start the Vite React development server:
   ```bash
   npm run dev
   ```
4. Click on the URL printed in the terminal (usually `http://localhost:5173`) to open the website in your browser.

---

### 5. Making Changes to the Website
* **Edit CSS & Layouts**: Open the `breathtrack-web/src` folder in VS Code to edit pages (under `src/pages/patient` or `src/pages/doctor`), components (under `src/components`), or layouts.
* **Inspect in Browser**: Keep your command line running `npm run dev`. When you edit and save any file in VS Code, the website in your browser will automatically reload and show the changes instantly (Hot Reloading).
* **Database/API changes**: If you want to change what data is returned or saved, edit the PHP files in your `htdocs/nov19` folder.
