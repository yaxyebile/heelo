-- Create database trigger function to automatically populate app_notifications when an order status is updated
CREATE OR REPLACE FUNCTION notify_order_status_change()
RETURNS TRIGGER AS $$
DECLARE
  v_title TEXT;
  v_body TEXT;
BEGIN
  -- Perform action only if order status has changed
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    CASE NEW.status
      WHEN 'paymentConfirmed' THEN
        v_title := 'Lacagtada waa la helay';
        v_body := 'Lacagta dalabkaaga waa la xaqiijiyay, hadda waa la diyaarinayaa.';
      WHEN 'approved' THEN
        v_title := 'Dalab la aqbalay';
        v_body := 'Dalabkaaga wuu ka gudbay tijaabada, diyaarinta delivery ayaa bilaabatay.';
      WHEN 'outForDelivery' THEN
        v_title := 'Dalabka wuu soo socdaa';
        v_body := 'Alaabtaada waa la soo qaaday, waxayna ku jirtaa wadada.';
      WHEN 'delivered' THEN
        v_title := 'Dalabkii waa la gaarsiiyay';
        v_body := 'Dalabkaaga waa la gaarsiiyay oo si guul leh ayaa laguu wareejiyay. Mahadsanid!';
      WHEN 'cancelled' THEN
        v_title := 'Dalab la joojiyay';
        v_body := 'Nasiib darro, dalabkaaga waa la joojiyay.';
      ELSE
        RETURN NEW;
    END CASE;

    -- Insert notification record for the custom user
    INSERT INTO app_notifications (id, user_id, title, body, type, related_id, is_read, created_at)
    VALUES (
      coalesce(NEW.id || '-' || NEW.status, 'notif-' || clock_timestamp()::text || '-' || random()::text),
      NEW.user_id,
      v_title,
      v_body,
      'order',
      NEW.id,
      false,
      NOW()
    )
    ON CONFLICT (id) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to orders table
DROP TRIGGER IF EXISTS trg_notify_order_status_change ON orders;
CREATE TRIGGER trg_notify_order_status_change
AFTER UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION notify_order_status_change();
