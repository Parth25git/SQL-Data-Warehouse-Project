# 🗄️ Data Warehouse Project — Environment Setup Guide

This guide walks through the complete environment setup used in this project, so you can replicate it locally.

---

## 📋 Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
- [SQL Server Management Studio (SSMS)](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms) installed
- Your dataset CSV files ready locally

---

## 1. 🐳 SQL Server via Docker

Open the **Docker Desktop** terminal (or any terminal with Docker available) and run the following commands:

```bash
# Check running containers
docker ps

# Pull SQL Server 2022 image
docker pull mcr.microsoft.com/mssql/server:2022-latest

# Verify image was pulled
docker images

# Run SQL Server container
docker run \
  -e "ACCEPT_EULA=Y" \
  -e "MSSQL_SA_PASSWORD=<YOUR_STRONG_PASSWORD>" \
  -p 1433:1433 \
  --name mssql \
  -d mcr.microsoft.com/mssql/server:2022-latest

# Confirm container is running
docker ps
```

> ⚠️ Replace `<YOUR_STRONG_PASSWORD>` with a strong password of your choice.  
> Password must meet SQL Server complexity requirements (uppercase, lowercase, digit, special character).

**If the container exits unexpectedly**, check the logs:

```bash
docker logs mssql
```

---

## 2. 🖥️ SQL Server Management Studio (SSMS) — Setup

### Installation

1. Download SSMS from the [Microsoft official site](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
2. Run the installer (`SSMS-Setup-ENU.exe`) and complete the default installation
3. Restart your system after installation

### Connecting SSMS to Docker SQL Server

Launch SSMS and use the following connection settings:

| Field | Value |
|---|---|
| Server name | `localhost,1433` |
| Authentication | SQL Server Authentication |
| Username | `sa` (or your configured username) |
| Password | `<YOUR_STRONG_PASSWORD>` |
| Encryption | Optional *(suitable for local Docker setup)* |

### Verify Connection

Once connected, run the following query to confirm the SQL Server version:

```sql
SELECT @@VERSION;
```

You should see output confirming **SQL Server 2022**.

---

## 3. 📥 Data Ingestion — Bulk Insert

There are two approaches depending on how SQL Server is running.

---

### ▶️ Case 1 — SQL Server Installed Directly on Windows

If SQL Server is installed natively (not via Docker), use the standard Windows file path:

```sql
BULK INSERT bronze.crm_cust_info
FROM 'C:\path\to\your\file\cust_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
```

---

### ▶️ Case 2 — SQL Server Running in Docker

When SQL Server is inside a Docker container, **Windows paths like `C:\` do not work**. You need to copy your files into the container first.

**Step 1 — Copy your dataset folder from Windows into the container:**

```bash
docker cp "C:\path\to\your\datasets" mssql:/data/
```

**Step 2 — Verify the files were copied successfully:**

```bash
docker exec -it mssql bash
ls /data
ls /data/source_crm
```

**Step 3 — Run BULK INSERT using the Linux path inside the container:**

```sql
BULK INSERT bronze.crm_cust_info
FROM '/data/source_crm/cust_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
```

> 💡 Repeat the `docker cp` and `BULK INSERT` steps for each data source folder (e.g., `source_erp`).

---

## ✅ Result

After completing all steps above, you will have:

- A **SQL Server 2022** instance running inside Docker
- **SSMS** connected and ready for querying
- Your **raw CSV data** loaded into the Bronze layer of the data warehouse

---

## 🔐 Security Notes

- Never commit real passwords to version control
- Use environment variables or a `.env` file (add it to `.gitignore`) for managing credentials
- The `SA` account should be replaced with a dedicated user in production environments

---

## 📁 Project Structure *(update as needed)*

```
project-root/
│
├── datasets/
│   ├── source_crm/
│   └── source_erp/
│
├── scripts/
│   └── bulk_insert.sql
│
└── README.md
```
