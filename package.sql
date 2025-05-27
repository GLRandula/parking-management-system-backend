-- Package Specification
CREATE OR REPLACE PACKAGE pkg_parking_mgmt AS
  PROCEDURE check_out_vehicle(p_booking_id IN NUMBER);
  FUNCTION get_active_booking(p_vehicle_id IN NUMBER) RETURN VARCHAR2;
  PROCEDURE create_booking(p_vehicle_id IN NUMBER, p_slot_id IN NUMBER);
  PROCEDURE make_payment(p_booking_id IN NUMBER, p_amount IN NUMBER, p_payment_method IN VARCHAR2);
  FUNCTION calculate_duration(p_booking_id IN NUMBER) RETURN NUMBER;
  PROCEDURE display_available_slots;
  FUNCTION get_payment_status(p_booking_id IN NUMBER) RETURN VARCHAR2;
  PROCEDURE list_user_bookings(p_user_id IN NUMBER);
END pkg_parking_mgmt;
/

CREATE SEQUENCE bookings_seq start WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE SEQUENCE Payments_seq START WITH 1000 INCREMENT BY 1;

-- Package Body (Fixed Version)
CREATE OR REPLACE PACKAGE BODY pkg_parking_mgmt AS

  -- Private procedure to update slot availability
  PROCEDURE update_slot_availability(p_slot_id IN NUMBER, p_status IN CHAR) IS
  BEGIN
    UPDATE ParkingSlots SET is_available = p_status WHERE slot_id = p_slot_id;
  END update_slot_availability;

  -- Public procedure for making payments
   procedure make_payment (
      p_booking_id     in number,
      p_amount         in number,
      p_payment_method in varchar2
   ) is
      v_booking_exists number;
   begin
  -- Check if booking exists
      select count(*)
        into v_booking_exists
        from bookings
       where booking_id = p_booking_id;

      if v_booking_exists = 0 then
         raise_application_error(
            -20004,
            'Booking does not exist.'
         );
      end if;

  -- Insert payment record
      insert into payments (
         payment_id,
         booking_id,
         payment_time,
         amount,
         payment_method,
         payment_status
      ) values ( payments_seq.nextval,
                 p_booking_id,
                 sysdate,
                 p_amount,
                 p_payment_method,
                 'completed' );

      dbms_output.put_line('Payment successful.');
   exception
      when dup_val_on_index then
         dbms_output.put_line('Payment already made for this booking.');
      when others then
         dbms_output.put_line('Error during payment: ' || sqlerrm);
   end make_payment;

  -- Private function to check if a payment is completed
  FUNCTION is_payment_completed(p_booking_id IN NUMBER) RETURN BOOLEAN IS
    v_status Payments.payment_status%TYPE;
  BEGIN
    SELECT payment_status INTO v_status FROM Payments WHERE booking_id = p_booking_id;
    RETURN v_status = 'completed';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
  END is_payment_completed;

  -- Public function to get the active booking status
  FUNCTION get_active_booking(p_vehicle_id IN NUMBER) RETURN VARCHAR2 IS
    v_status VARCHAR2(20);
  BEGIN
    SELECT status INTO v_status
    FROM Bookings
    WHERE vehicle_id = p_vehicle_id AND status = 'active';

    RETURN v_status;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'No active booking';
    WHEN OTHERS THEN
      RETURN 'Error occurred';
  END get_active_booking;

    -- Public procedure for display available slots.
    procedure display_available_slots is
        cursor slot_cur is
        select slot_number,
                slot_type,
                parking_level,
                location_description
        from parkingslots
        where is_available = 'Y';

        v_slot slot_cur%rowtype;
    begin
        open slot_cur;
        loop
            fetch slot_cur into v_slot;
            exit when slot_cur%notfound;
            dbms_output.put_line('Slot: '
                                || v_slot.slot_number
                                || ', Type: '
                                || v_slot.slot_type
                                || ', Level: '
                                || v_slot.parking_level
                                || ', Location: '
                                || v_slot.location_description);
        end loop;
        close slot_cur;
    end display_available_slots;

  -- Public procedure to check out vehicle
  PROCEDURE check_out_vehicle(p_booking_id IN NUMBER) IS
    v_slot_id Bookings.slot_id%TYPE;
    v_valid BOOLEAN;
  BEGIN
    SELECT slot_id INTO v_slot_id FROM Bookings WHERE booking_id = p_booking_id;

    v_valid := is_payment_completed(p_booking_id);

    IF NOT v_valid THEN
      RAISE_APPLICATION_ERROR(-20001, 'Payment must be completed before checkout.');
    END IF;

    UPDATE Bookings
    SET check_out_time = SYSDATE,
        status = 'completed'
    WHERE booking_id = p_booking_id;

    update_slot_availability(v_slot_id, 'Y');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Booking or Payment not found.');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error during check-out: ' || SQLERRM);
  END check_out_vehicle;

    -- Public procedure to create a booking
    PROCEDURE create_booking(p_vehicle_id IN NUMBER, p_slot_id IN NUMBER) IS
    v_booking_count NUMBER;
    v_slot_status ParkingSlots.is_available%TYPE;
    v_new_booking_id NUMBER;
    BEGIN
    -- Check for active booking
    SELECT COUNT(*) INTO v_booking_count
    FROM Bookings
    WHERE vehicle_id = p_vehicle_id AND status = 'active';

    IF v_booking_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Vehicle already has an active booking.');
    END IF;

    -- Check if slot is available
    SELECT is_available INTO v_slot_status
    FROM ParkingSlots
    WHERE slot_id = p_slot_id;

    IF v_slot_status != 'Y' THEN
        RAISE_APPLICATION_ERROR(-20003, 'Selected slot is not available.');
    END IF;

    -- Generate new booking ID using sequence
    SELECT Bookings_seq.NEXTVAL INTO v_new_booking_id FROM dual;

    -- Insert new booking
    INSERT INTO Bookings (booking_id, vehicle_id, slot_id, check_in_time, status)
    VALUES (v_new_booking_id, p_vehicle_id, p_slot_id, SYSDATE, 'active');

    -- Update slot availability
    update_slot_availability(p_slot_id, 'N');
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Booking created with ID: ' || v_new_booking_id);

    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error during create_booking: ' || SQLERRM);
    END create_booking;

  -- Public function to calculate parking duration in hours
  FUNCTION calculate_duration(p_booking_id IN NUMBER) RETURN NUMBER IS
    v_checkin DATE;
    v_checkout DATE;
    v_duration NUMBER;
  BEGIN
    SELECT check_in_time, NVL(check_out_time, SYSDATE)
    INTO v_checkin, v_checkout
    FROM Bookings
    WHERE booking_id = p_booking_id;

    v_duration := ROUND((v_checkout - v_checkin) * 24, 2);
    RETURN v_duration;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN -1;
    WHEN OTHERS THEN
      RETURN -2;
  END calculate_duration;

  -- Public function to get payment status for a booking
  FUNCTION get_payment_status(p_booking_id IN NUMBER) RETURN VARCHAR2 IS
    v_status Payments.payment_status%TYPE;
  BEGIN
    SELECT payment_status INTO v_status FROM Payments WHERE booking_id = p_booking_id;
    RETURN v_status;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'No payment found';
  END get_payment_status;

  -- Public procedure to list all bookings of a user using a cursor
  PROCEDURE list_user_bookings(p_user_id IN NUMBER) IS
    CURSOR booking_cur IS
      SELECT b.booking_id, v.plate_number, s.slot_id, b.status
      FROM Bookings b
      JOIN Vehicles v ON b.vehicle_id = v.vehicle_id
      JOIN ParkingSlots s ON b.slot_id = s.slot_id
      WHERE v.user_id = p_user_id;

    v_booking booking_cur%ROWTYPE;
  BEGIN
    OPEN booking_cur;
    LOOP
      FETCH booking_cur INTO v_booking;
      EXIT WHEN booking_cur%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('Booking ID: ' || v_booking.booking_id ||
                           ', Plate Number: ' || v_booking.plate_number ||
                           ', Slot ID: ' || v_booking.slot_id ||
                           ', Status: ' || v_booking.status);
    END LOOP;
    CLOSE booking_cur;
  END list_user_bookings;

END pkg_parking_mgmt;
/

