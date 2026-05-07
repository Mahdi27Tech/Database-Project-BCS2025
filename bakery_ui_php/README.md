# 🥐 Bakery Inventory System — UI

A simple web UI for the Bakery Inventory MySQL database.
Built with plain HTML/CSS/JS + PHP. Runs on LAMPP.

---

## ⚡ Setup (LAMPP)

### 1. Copy project to htdocs
```
cp -r bakery_ui_php /opt/lampp/htdocs/
```
Or on Windows:
```
copy bakery_ui_php to C:\xampp\htdocs\
```

### 2. Make sure LAMPP is running
```bash
sudo /opt/lampp/lampp start
```

### 3. Import the database
- Open phpMyAdmin: http://localhost/phpmyadmin
- Create database: `bakery_inventory`
- Import `bakery_inventory.sql`

### 4. Configure DB credentials (if needed)
Edit `api/config.php`:
```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');          // change if you set a password
define('DB_NAME', 'bakery_inventory');
```

### 5. Open in browser
```
http://localhost/bakery_ui_php/index.html
```

---

## 📁 Project Structure
```
bakery_ui_php/
├── index.html          ← Main UI (single page)
├── api/
│   ├── config.php      ← DB connection
│   ├── dashboard.php   ← Dashboard stats & alerts
│   ├── ingredients.php ← CRUD for ingredients
│   ├── products.php    ← CRUD for products
│   ├── suppliers.php   ← Suppliers management
│   ├── orders.php      ← Purchase orders
│   ├── movements.php   ← Stock audit trail
│   ├── helpers.php     ← Categories, units, dropdowns
│   └── _routes.php     ← Shared route logic
└── assets/
    ├── css/style.css   ← All styles
    └── js/app.js       ← All frontend logic
```

---

## ✅ Features
- **Dashboard** — live stats, low stock alerts, recipe cost estimator
- **Ingredients** — add, edit, delete, search, status badges
- **Products** — add, edit, delete, search, sale price tracking
- **Suppliers** — add, edit, view linked ingredient count
- **Purchase Orders** — create multi-item orders, mark as received (auto-updates stock)
- **Stock Movements** — full audit trail, color-coded by type

---
*Mbarara University of Science and Technology — DB Project · Juma Dave*
