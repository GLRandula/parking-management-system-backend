-- Test create_booking procedure
BEGIN
  pkg_parking_mgmt.create_booking(p_vehicle_id => 11, p_slot_id => 10);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test failed: ' || SQLERRM);
END;
/

-- Test make_payment
BEGIN
  pkg_parking_mgmt.make_payment(p_booking_id => 23, p_amount => 1500.00, p_payment_method => 'Card');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in make_payment: ' || SQLERRM);
END;
/

-- Test get_active_booking
DECLARE
  v_status VARCHAR2(50);
BEGIN
  v_status := pkg_parking_mgmt.get_active_booking(p_vehicle_id => 5);
  DBMS_OUTPUT.PUT_LINE('Active booking status: ' || v_status);
END;
/

-- Test display_available_slots
BEGIN
  pkg_parking_mgmt.display_available_slots;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in display_available_slots: ' || SQLERRM);
END;
/

-- Test calculate_duration
DECLARE
  v_duration NUMBER;
BEGIN
  v_duration := pkg_parking_mgmt.calculate_duration(p_booking_id => 2);
  IF v_duration >= 0 THEN
    DBMS_OUTPUT.PUT_LINE('Duration in hours: ' || v_duration);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Error calculating duration. Code: ' || v_duration);
  END IF;
END;
/

-- Test get_payment_status
DECLARE
  v_status VARCHAR2(50);
BEGIN
  v_status := pkg_parking_mgmt.get_payment_status(p_booking_id => 1);
  DBMS_OUTPUT.PUT_LINE('Payment Status: ' || v_status);
END;
/

-- Test check_out_vehicle
BEGIN
  pkg_parking_mgmt.check_out_vehicle(p_booking_id => 4);
  DBMS_OUTPUT.PUT_LINE('Vehicle checked out successfully.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in check_out_vehicle: ' || SQLERRM);
END;
/

SELECT * FROM Bookings WHERE vehicle_id = 1 OR slot_id = 2;

COMMIT;
