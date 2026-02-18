/*
  # Create Live Rooms & Chat System

  ## New Tables

  ### `live_rooms`
  - `id` (uuid, primary key)
  - `title` (text) - Room title (e.g., "The Crypto Radio")
  - `description` (text) - Room description
  - `host_id` (uuid) - References user_profiles
  - `topic` (text) - Room topic/category
  - `listener_count` (integer) - Current listener count
  - `is_active` (boolean) - Room is currently live
  - `started_at` (timestamptz) - When room started
  - `ended_at` (timestamptz) - When room ended
  - `created_at` (timestamptz)

  ### `live_room_participants`
  - `id` (uuid, primary key)
  - `room_id` (uuid) - References live_rooms
  - `user_id` (uuid) - References user_profiles
  - `role` (text) - 'host', 'co-host', 'listener'
  - `is_speaking` (boolean) - Currently speaking
  - `joined_at` (timestamptz)
  - `left_at` (timestamptz)

  ### `live_room_messages`
  - `id` (uuid, primary key)
  - `room_id` (uuid) - References live_rooms
  - `user_id` (uuid) - References user_profiles
  - `message` (text) - Chat message
  - `created_at` (timestamptz)

  ## Security
  - Enable RLS on all tables
  - Public can view active rooms and messages
  - Only authenticated users can create rooms and send messages
  - Only room hosts can manage participants
*/

-- Create live_rooms table
CREATE TABLE IF NOT EXISTS live_rooms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  host_id uuid REFERENCES user_profiles(id) ON DELETE CASCADE,
  topic text DEFAULT 'general',
  listener_count integer DEFAULT 0,
  is_active boolean DEFAULT true,
  started_at timestamptz DEFAULT now(),
  ended_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Create live_room_participants table
CREATE TABLE IF NOT EXISTS live_room_participants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid REFERENCES live_rooms(id) ON DELETE CASCADE NOT NULL,
  user_id uuid REFERENCES user_profiles(id) ON DELETE CASCADE NOT NULL,
  role text DEFAULT 'listener' CHECK (role IN ('host', 'co-host', 'listener')),
  is_speaking boolean DEFAULT false,
  joined_at timestamptz DEFAULT now(),
  left_at timestamptz,
  UNIQUE(room_id, user_id)
);

-- Create live_room_messages table
CREATE TABLE IF NOT EXISTS live_room_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid REFERENCES live_rooms(id) ON DELETE CASCADE NOT NULL,
  user_id uuid REFERENCES user_profiles(id) ON DELETE CASCADE NOT NULL,
  message text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_live_rooms_active ON live_rooms(is_active, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_live_room_participants_room ON live_room_participants(room_id, left_at);
CREATE INDEX IF NOT EXISTS idx_live_room_messages_room ON live_room_messages(room_id, created_at DESC);

-- Enable Row Level Security
ALTER TABLE live_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_room_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_room_messages ENABLE ROW LEVEL SECURITY;

-- RLS Policies for live_rooms
CREATE POLICY "Anyone can view active rooms"
  ON live_rooms FOR SELECT
  USING (is_active = true);

CREATE POLICY "Authenticated users can create rooms"
  ON live_rooms FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = host_id);

CREATE POLICY "Hosts can update own rooms"
  ON live_rooms FOR UPDATE
  TO authenticated
  USING (auth.uid() = host_id)
  WITH CHECK (auth.uid() = host_id);

-- RLS Policies for live_room_participants
CREATE POLICY "Anyone can view room participants"
  ON live_room_participants FOR SELECT
  USING (true);

CREATE POLICY "Users can join rooms"
  ON live_room_participants FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own participation"
  ON live_room_participants FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies for live_room_messages
CREATE POLICY "Anyone can view room messages"
  ON live_room_messages FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can send messages"
  ON live_room_messages FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Enable realtime for live updates
ALTER PUBLICATION supabase_realtime ADD TABLE live_rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE live_room_participants;
ALTER PUBLICATION supabase_realtime ADD TABLE live_room_messages;

-- Insert sample live rooms
INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'The Crypto Radio',
  'Join us live daily at 1PM Dubai time. Discussing market trends, trading strategies, and crypto news.',
  (SELECT id FROM user_profiles LIMIT 1),
  'Market Analysis',
  582,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'BTC & Altcoins Discussion',
  'Live discussion about Bitcoin and altcoin movements. Share your insights!',
  (SELECT id FROM user_profiles LIMIT 1),
  'Trading',
  1243,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'DeFi Deep Dive',
  'Exploring DeFi protocols, yield farming, and new opportunities.',
  (SELECT id FROM user_profiles LIMIT 1),
  'DeFi',
  345,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'NFT Market Updates',
  'Latest NFT trends, collections, and market analysis.',
  (SELECT id FROM user_profiles LIMIT 1),
  'NFTs',
  678,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);
