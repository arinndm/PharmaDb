# 💊 Pharmacy Stock & Billing Management System

##  Description
This project is a **Pharmacy Stock & Billing Database System** built using **MySQL/MariaDB**.  
It manages medicine inventory, billing, and returns with a strong focus on **batch-wise tracking** and **expiry management**.

---

##  Features
- Batch-wise inventory management  
- Expiry date tracking  
- Customer billing system  
- Sales return handling  
- Supplier return handling  
- Automatic stock updates using triggers  
- Normalized relational database design  

---

##  Database Schema

### Main Tables
- `Admin` – System users  
- `Medicine` – Medicine master data  
- `Batch` – Batch-wise stock with expiry  
- `Supplier` – Supplier details  
- `Purchase` & `Purchase_Details` – Stock purchases  
- `Customer` – Customer details  
- `Bill` & `Bill_Details` – Sales transactions  
- `Sales_Return` & `Sales_Return_Details` – Customer returns  
- `Supplier_Return` & `Supplier_Return_Details` – Supplier returns  

---

##  How It Works

###  Stock Management
- Stock is maintained at the **batch level**
- Each batch contains:
  - Manufacturing date  
  - Expiry date  
  - Purchase price  
  - Selling price  
  - Available quantity  

###  Billing
- Sales are recorded in `Bill` and `Bill_Details`
- Stock is automatically reduced using triggers  

###  Returns
- **Sales Return:** Stock is added back  
- **Supplier Return:** Stock is reduced  

---

##  Setup Instructions

### Prerequisites
- MySQL or MariaDB  
- SQL client (MySQL Workbench / phpMyAdmin)

### Installation Steps
1. Clone or download this repository  
2. Open your SQL client  
3. Run the provided SQL script  
4. Database `pharmacy_db` will be created automatically  

---
