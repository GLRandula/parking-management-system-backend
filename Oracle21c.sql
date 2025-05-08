CREATE TABLE ParkingSlots (
    slot_id NUMBER PRIMARY KEY,
    slot_number VARCHAR2(10) UNIQUE,
    slot_type VARCHAR2(20),
    is_available CHAR(1) CHECK (is_available IN ('Y', 'N')),
    parking_level VARCHAR2(10), 
    location_description VARCHAR2(100)
);
