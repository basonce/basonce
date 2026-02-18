/*
  # Create Support Ticket System

  1. New Tables
    - `support_tickets`
      - `id` (uuid, primary key) - Unique ticket identifier
      - `user_id` (uuid, nullable) - References auth.users if logged in
      - `customer_id` (text) - User provided ID/identifier
      - `email` (text) - Customer email address
      - `status` (text) - Ticket status: 'open', 'in_progress', 'closed'
      - `created_at` (timestamptz) - When ticket was created
      - `updated_at` (timestamptz) - Last update timestamp
      - `closed_at` (timestamptz, nullable) - When ticket was closed
    
    - `support_messages`
      - `id` (uuid, primary key) - Message ID
      - `ticket_id` (uuid) - References support_tickets
      - `sender_type` (text) - Either 'customer' or 'admin'
      - `sender_name` (text) - Name of sender
      - `message` (text) - Message content
      - `created_at` (timestamptz) - When message was sent
      - `read` (boolean) - Whether message has been read

  2. Security
    - Enable RLS on both tables
    - Anyone can view and create tickets/messages (filtered by ticket ID in app)
    - Only admins can update ticket status and mark messages as read

  3. Indexes
    - Index on ticket_id for faster message lookups
    - Index on status for filtering open/closed tickets
    - Index on created_at for sorting
*/

-- Create support_tickets table
CREATE TABLE IF NOT EXISTS support_tickets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid,
  customer_id text NOT NULL,
  email text NOT NULL,
  status text NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'closed')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  closed_at timestamptz
);

-- Create support_messages table
CREATE TABLE IF NOT EXISTS support_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id uuid NOT NULL REFERENCES support_tickets(id) ON DELETE CASCADE,
  sender_type text NOT NULL CHECK (sender_type IN ('customer', 'admin')),
  sender_name text NOT NULL,
  message text NOT NULL,
  created_at timestamptz DEFAULT now(),
  read boolean DEFAULT false
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_support_messages_ticket_id ON support_messages(ticket_id);
CREATE INDEX IF NOT EXISTS idx_support_tickets_status ON support_tickets(status);
CREATE INDEX IF NOT EXISTS idx_support_tickets_created_at ON support_tickets(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_support_messages_created_at ON support_messages(created_at ASC);

-- Enable RLS
ALTER TABLE support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_messages ENABLE ROW LEVEL SECURITY;

-- Support Tickets Policies

-- Anyone can view tickets (filtered by ticket ID in app for security)
CREATE POLICY "Anyone can view support tickets"
  ON support_tickets
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- Anyone can create a ticket
CREATE POLICY "Anyone can create support tickets"
  ON support_tickets
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- Admins can update ticket status
CREATE POLICY "Admins can update tickets"
  ON support_tickets
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.is_admin = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.is_admin = true
    )
  );

-- Support Messages Policies

-- Anyone can view messages (filtered by ticket ID in app for security)
CREATE POLICY "Anyone can view support messages"
  ON support_messages
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- Anyone can send messages
CREATE POLICY "Anyone can send messages to tickets"
  ON support_messages
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- Admins can update messages (mark as read)
CREATE POLICY "Admins can update messages"
  ON support_messages
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.is_admin = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.is_admin = true
    )
  );

-- Function to update ticket updated_at timestamp
CREATE OR REPLACE FUNCTION update_ticket_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE support_tickets
  SET updated_at = now()
  WHERE id = NEW.ticket_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to update ticket timestamp when new message is added
DROP TRIGGER IF EXISTS update_ticket_timestamp_trigger ON support_messages;
CREATE TRIGGER update_ticket_timestamp_trigger
  AFTER INSERT ON support_messages
  FOR EACH ROW
  EXECUTE FUNCTION update_ticket_timestamp();