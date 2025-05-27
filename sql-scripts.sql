-- USERS table
CREATE TABLE Users (
    user_id NUMBER PRIMARY KEY,
    full_name VARCHAR2(100),
    email VARCHAR2(100) UNIQUE,
    phone VARCHAR2(15),
    user_type VARCHAR2(20),
    created_at DATE DEFAULT SYSDATE
);

-- VEHICLES table
CREATE TABLE Vehicles (
    vehicle_id NUMBER PRIMARY KEY,
    user_id NUMBER,
    plate_number VARCHAR2(20) UNIQUE,
    vehicle_type VARCHAR2(20),
    brand VARCHAR2(50),
    color VARCHAR2(30),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- PARKING SLOTS table
CREATE TABLE ParkingSlots (
    slot_id NUMBER PRIMARY KEY,
    slot_number VARCHAR2(10) UNIQUE,
    slot_type VARCHAR2(20),
    is_available CHAR(1) CHECK (is_available IN ('Y', 'N')),
    parking_level VARCHAR2(10),  -- renamed from 'level'
    location_description VARCHAR2(100)
);

-- BOOKINGS table
CREATE TABLE Bookings (
    booking_id NUMBER PRIMARY KEY,
    vehicle_id NUMBER UNIQUE,
    slot_id NUMBER,
    check_in_time DATE,
    check_out_time DATE,
    status VARCHAR2(20),
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id),
    FOREIGN KEY (slot_id) REFERENCES ParkingSlots(slot_id)
);

-- PAYMENTS table
CREATE TABLE Payments (
    payment_id NUMBER PRIMARY KEY,
    booking_id NUMBER UNIQUE,
    payment_time DATE,
    amount NUMBER(8,2),
    payment_method VARCHAR2(20),
    payment_status VARCHAR2(20),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

-- Insert data into Users
INSERT INTO Users VALUES (1, 'Lakith Randula', 'laki@gmail.com', '0712345678', 'customer', SYSDATE);
INSERT INTO Users VALUES (2, 'Amindu Bhashana', 'amin@gmail.com', '0771234567', 'customer', SYSDATE);
INSERT INTO Users VALUES (3, 'Kasun Chamara', 'kasu@gmail.com', '0789876543', 'admin', SYSDATE);
INSERT INTO Users VALUES (4, 'Danushka Kumara', 'dan@gmail.com', '0723456789', 'customer', SYSDATE);
INSERT INTO Users VALUES (5, 'Eranga Wijesinghe', 'eranga@gmail.com', '0701122334', 'customer', SYSDATE);
INSERT INTO Users VALUES (6, 'Janaka Thushan', 'janaa@gmail.com', '0711122233', 'customer', SYSDATE);
INSERT INTO Users VALUES (7, 'Gihan Jayasuriya', 'gayan@gmail.com', '0759988776', 'admin', SYSDATE);

INSERT INTO ParkingSlots VALUES (1, 'S1', 'Car', 'Y', 'L1', 'Near Entrance A');
INSERT INTO ParkingSlots VALUES (2, 'S2', 'Bike', 'Y', 'L1', 'Near Entrance B');
INSERT INTO ParkingSlots VALUES (3, 'S3', 'Car', 'Y', 'L2', 'Corner Slot');
INSERT INTO ParkingSlots VALUES (4, 'S4', 'Van', 'Y', 'L2', 'Center Row');
INSERT INTO ParkingSlots VALUES (5, 'S5', 'Car', 'Y', 'L1', 'Near Lift');
INSERT INTO ParkingSlots VALUES (6, 'S6', 'Car', 'Y', 'L3', 'Beside Exit');
INSERT INTO ParkingSlots VALUES (7, 'S7', 'Bike', 'Y', 'L3', 'Loading Area');

INSERT INTO Vehicles VALUES (1, 1, 'CDC-1234', 'Car', 'Toyota', 'Red');
INSERT INTO Vehicles VALUES (2, 2, 'BAM-5678', 'Bike', 'Honda', 'Black');
INSERT INTO Vehicles VALUES (3, 3, 'KL-9012', 'Car', 'Suzuki', 'Blue');
INSERT INTO Vehicles VALUES (4, 4, 'PG-3456', 'Van', 'Nissan', 'White');
INSERT INTO Vehicles VALUES (5, 5, 'CAD-7890', 'Car', 'Kia', 'Silver');
INSERT INTO Vehicles VALUES (6, 6, 'GHI-4567', 'Car', 'Toyota', 'White');
INSERT INTO Vehicles VALUES (7, 7, 'BIT-6307', 'Bike', 'TVS', 'Red');
INSERT INTO Vehicles VALUES (8, 4, 'BCL-6147', 'Bike', 'Yamaha', 'Black');

INSERT INTO Bookings VALUES (1, 1, 1, SYSDATE - 1, SYSDATE, 'completed');
INSERT INTO Bookings VALUES (2, 2, 2, SYSDATE - 2, SYSDATE - 1, 'completed');
INSERT INTO Bookings VALUES (3, 3, 3, SYSDATE - 1, NULL, 'active');
INSERT INTO Bookings VALUES (4, 4, 4, SYSDATE - 3, SYSDATE - 2, 'completed');
INSERT INTO Bookings VALUES (5, 5, 5, SYSDATE - 1, NULL, 'active');
INSERT INTO Bookings VALUES (6, 6, 6, SYSDATE - 2, SYSDATE - 1, 'completed');
INSERT INTO Bookings VALUES (7, 7, 7, SYSDATE - 5, SYSDATE - 4, 'completed');

INSERT INTO Payments VALUES (1, 1, SYSDATE, 500.00, 'Cash', 'completed');
INSERT INTO Payments VALUES (2, 2, SYSDATE - 1, 200.00, 'Card', 'completed');
INSERT INTO Payments VALUES (3, 4, SYSDATE - 2, 600.00, 'Card', 'completed');
INSERT INTO Payments VALUES (4, 6, SYSDATE - 1, 700.00, 'Online', 'completed');
INSERT INTO Payments VALUES (5, 7, SYSDATE - 4, 800.00, 'Cash', 'completed');
-- Booking 3 and 5 are still active, no payment yet

COMMIT;

-- SELECT * FROM BOOKINGS;

