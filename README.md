# 🅿️ Parking Management System – PL/SQL Backend

This project implements the backend logic of a **Parking Management System** using Oracle PL/SQL. It includes all core functionalities such as managing parking slots, handling bookings, enforcing business constraints, and updating slot availability dynamically via triggers and procedures.

---

## 📁 Project Structure

| File Name         | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| `package.sql`     | Contains the PL/SQL package definition and body (`create_booking`, helpers).|
| `sql-scripts.sql` | Schema creation: tables, sequences, and initial data population.           |
| `test-scripts.sql`| Sample test data and procedure execution for functional validation.        |
| `triggers.sql`    | Trigger definitions to automate status updates and enforce constraints.    |

---

## 🚀 Features

- 🔄 **Dynamic Slot Management**: Automatically updates slot availability based on bookings.
- ✅ **Business Rule Enforcement**: Prevents multiple active bookings per vehicle.
- 🛑 **Trigger-based Integrity**: Restricts deletion of completed bookings.
- 📦 **Modular Design**: Encapsulated logic via packages and public procedures.

---

## 🛠️ Requirements

- Oracle Database 11g or higher
- SQL*Plus, Oracle SQL Developer, or any compatible PL/SQL environment

---

## ⚙️ How to Run

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/parking-management-plsql.git
   cd parking-management-plsql

2. **Execute the SQL Scripts in Order**
```bash
-- 1. Create tables and insert base data
@sql-scripts.sql

-- 2. Create triggers
@triggers.sql

-- 3. Create package (procedures/functions)
@package.sql

-- 4. Run test cases
@test-scripts.sql
```

## 📌 Key Procedures

- create_booking(p_vehicle_id, p_slot_id): Adds a new booking and updates slot status.

- update_slot_availability(p_slot_id, p_status): Manually update slot status (Y/N).

- Triggers like trg_block_slot_on_booking, trg_no_delete_completed_booking maintain data integrity automatically.

## 📋 Example Use Case
  ```bash
  -- Attempt to book a slot
  BEGIN
     pkg_parking.create_booking(101, 3);
  END;
```
## 🧪 Testing

**Use test-scripts.sql to simulate real-world scenarios:**

- Create bookings

- Attempt invalid deletions

- Test slot availability

- Validate business constraints

