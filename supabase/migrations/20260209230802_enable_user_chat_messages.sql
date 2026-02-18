/*
  # Enable Real User Chat Messages

  1. Changes
    - Add `user_id` column to identify real users vs bots
    - Add insert policy for authenticated users
    - Enable realtime for new messages

  2. Security
    - Users can insert their own messages
    - All messages are publicly readable
*/

-- Add user_id column (nullable for bot messages)
ALTER TABLE mining_chat_messages
ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;

-- Create index for user messages
CREATE INDEX IF NOT EXISTS idx_mining_chat_user_id ON mining_chat_messages(user_id);

-- Allow authenticated users to insert their own chat messages
CREATE POLICY "Users can insert their own chat messages"
  ON mining_chat_messages
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE mining_chat_messages;
