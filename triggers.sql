-- Trigger to prevent deleting a completed booking
CREATE OR REPLACE TRIGGER trg_no_delete_completed_booking
BEFORE DELETE ON Bookings
FOR EACH ROW
BEGIN
  IF :OLD.status = 'completed' THEN
    RAISE_APPLICATION_ERROR(-20010, 'Cannot delete a completed booking.');
  END IF;
END;
/

-- Trigger: trg_block_slot_on_booking
CREATE OR REPLACE TRIGGER trg_block_slot_on_booking
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
  UPDATE ParkingSlots
  SET is_available = 'N'
  WHERE slot_id = :NEW.slot_id;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Trigger error: ' || SQLERRM);
END;
/

