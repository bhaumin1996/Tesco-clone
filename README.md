# 🛒 Tesco Clone - Full Stack E-commerce Solution

A high-performance, modern e-commerce application inspired by Tesco, built with a clean architecture using **.NET 8** and **Angular 17+**.

![Tesco Banner](https://img.shields.io/badge/Project-Tesco--Clone-blue?style=for-the-badge&logo=tesco)
![.NET](https://img.shields.io/badge/.NET%208-512BD4?style=for-the-badge&logo=dotnet)
![Angular](https://img.shields.io/badge/Angular%2017-DD0031?style=for-the-badge&logo=angular)
![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server)

---

## 🏗️ Project Structure

The project follows **Clean Architecture** principles to ensure scalability, maintainability, and testability.

```text
Tesco-clone/
├── 📂 database/              # SQL Scripts, Migrations & Seed Data
├── 📂 frontend/              # Frontend Applications
│   ├── 🛒 tesco-storefront/   # Customer-facing Angular App
│   └── 🛡️ tesco-admin/        # Administrative Dashboard
├── 📂 src/                   # Backend (.NET Core)
│   ├── TescoClone.API/        # Web API Layer
│   ├── TescoClone.Application/# Business Logic & MediatR
│   ├── TescoClone.Domain/     # Entities & Core Interfaces
│   └── TescoClone.Infrastructure/ # Data Access & External Services
├── 📂 tests/                 # Unit & Integration Tests
├── 📜 TescoClone.sln         # Visual Studio Solution
└── ⚙️ IIS_Setup.ps1           # Deployment Scripts
```

---

## 🗄️ Database Management

The project uses **SQL Server** with a combination of Entity Framework Core and optimized Stored Procedures.

### Setup & Migrations
1.  **Connection String**: Update `src/TescoClone.API/appsettings.json` with your local SQL Server credentials.
2.  **Schema**: Database scripts are located in `database/`.
    -   `database/migrations/`: Incremental schema changes.
    -   `database/stored-procedures/`: Performance-optimized data operations.
    -   `database/seed/`: Initial data for products, categories, and users.

### Persistence Strategy
-   **EF Core**: Used for complex relational mappings and command-side operations.
-   **Stored Procedures**: Used for high-traffic read operations and specific business logic requirements to ensure maximum performance.

---

## 🚀 Release & Deployment

The project includes automated scripts for hosting on **Local IIS**, making it accessible across your local network.

### Deployment Workflow
1.  **Build & Package**: Run `.\Update_Sites.ps1` to compile the backend and frontend.
2.  **IIS Sync**: The script automatically copies files to the `publish/` directory.
3.  **Access**: Use your local IP (e.g., `http://192.168.1.XX:8082`) to access the site from any device on the network.

> [!TIP]
> For detailed deployment instructions, including firewall configuration and database permissions, see [DEPLOYMENT.md](file:///e:/Tesco/Tesco-clone/DEPLOYMENT.md).

---

## 🌿 Git Workflow

To maintain a clean and stable codebase, follow these guidelines when pushing changes:

### Branching Strategy
-   `main`: Production-ready code.
-   `develop`: Integration branch for features.
-   `feature/*`: New features or enhancements.
-   `fix/*`: Bug fixes.

### Committing Changes
1.  Ensure all local tests pass.
2.  Format code according to project standards.
3.  Commit with descriptive messages (e.g., `feat: add product search functionality`).
4.  Push to your feature branch and create a Pull Request.

---

## 🛠️ Tech Stack

-   **Backend**: .NET 8, ASP.NET Core Web API, MediatR (CQRS), Entity Framework Core.
-   **Frontend**: Angular 17, RxJS, Signals, SCSS.
-   **Database**: Microsoft SQL Server.
-   **Security**: JWT Authentication, ASP.NET Core Identity.
-   **Payment**: Stripe Integration.

---

## 👨‍💻 Development Guide

### Prerequisites
-   .NET 8 SDK
-   Node.js (v18+)
-   SQL Server 2022
-   Angular CLI

### Running Locally
1.  **Backend**:
    ```bash
    cd src/TescoClone.API
    dotnet run
    ```
2.  **Frontend**:
    ```bash
    cd frontend/tesco-storefront
    npm install
    npm start
    ```

---

## 📜 License
This project is for educational purposes as a clone of the Tesco e-commerce platform.
