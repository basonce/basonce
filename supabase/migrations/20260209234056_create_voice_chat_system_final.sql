/*
  # Voice Chat System for Mining Live Chat

  1. New Tables
    - `voice_messages`
      - `id` (uuid, primary key)
      - `user_id` (bigint, references anonymous_profiles) - Speaker
      - `text_content` (text) - What they say
      - `audio_url` (text, nullable) - ElevenLabs generated audio
      - `emotion` (text) - excited, happy, calm, surprised, confident
      - `duration_seconds` (integer) - Audio length
      - `voice_gender` (text) - male, female
      - `voice_name` (text) - Character voice name
      - `category` (text) - earnings, advice, withdrawal, equipment, motivation
      - `play_order` (integer) - Sequence order
      - `is_active` (boolean) - Can be played
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on `voice_messages` table
    - Public read access for all users
    - Only admins can insert/update/delete

  3. Sample Data
    - 60+ realistic voice messages with emotional variety
    - Mix of male/female voices
    - Different categories and emotions
*/

-- Create voice messages table
CREATE TABLE IF NOT EXISTS voice_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id bigint REFERENCES anonymous_profiles(id) ON DELETE CASCADE,
  text_content text NOT NULL,
  audio_url text,
  emotion text DEFAULT 'calm' CHECK (emotion IN ('excited', 'happy', 'calm', 'surprised', 'confident', 'enthusiastic', 'thoughtful', 'emotional')),
  duration_seconds integer DEFAULT 5,
  voice_gender text DEFAULT 'female' CHECK (voice_gender IN ('male', 'female')),
  voice_name text DEFAULT 'Rachel',
  category text DEFAULT 'general' CHECK (category IN ('earnings', 'advice', 'withdrawal', 'equipment', 'motivation', 'question', 'general')),
  play_order integer,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE voice_messages ENABLE ROW LEVEL SECURITY;

-- Public can read active voice messages
CREATE POLICY "Anyone can read active voice messages"
  ON voice_messages FOR SELECT
  USING (is_active = true);

-- Only authenticated users with admin role can modify
CREATE POLICY "Admins can insert voice messages"
  ON voice_messages FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.is_admin = true
    )
  );

CREATE POLICY "Admins can update voice messages"
  ON voice_messages FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.is_admin = true
    )
  );

CREATE POLICY "Admins can delete voice messages"
  ON voice_messages FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.is_admin = true
    )
  );

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_voice_messages_active_order ON voice_messages(is_active, play_order) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_voice_messages_category ON voice_messages(category) WHERE is_active = true;

-- Insert realistic voice messages with random anonymous profile IDs
DO $$
DECLARE
  voice_data record;
  random_user_id bigint;
BEGIN
  FOR voice_data IN
    SELECT * FROM (VALUES
      ('Oh my god guys! I just checked my dashboard and my Quantum Miner made twelve hundred dollars today! I am literally shaking right now! This is absolutely insane!', 'excited', 'female', 'Domi', 'earnings', 1),
      ('Yes! Yes! Yes! Just hit fifteen hundred dollars profit this week! I knew buying that ASIC Pro was the right move! Best decision ever!', 'excited', 'female', 'Bella', 'earnings', 2),
      ('I cannot believe this! My mining equipment paid for itself in three weeks! Three weeks! I am making pure profit now!', 'enthusiastic', 'female', 'Rachel', 'earnings', 3),
      ('Listen up everyone. I made twenty three hundred dollars yesterday. Single day. My Quantum Datacenter is running perfectly. This is not a game anymore, this is real money.', 'confident', 'male', 'Antoni', 'earnings', 4),
      ('Just pulled in eight hundred fifty dollars overnight while I was sleeping. This passive income is changing my life. No cap.', 'confident', 'male', 'Josh', 'equipment', 5),
      ('It is here! My withdrawal just landed! Nine hundred twenty dollars in my wallet! Five minutes! This platform is so fast, I love it!', 'enthusiastic', 'female', 'Domi', 'withdrawal', 6),
      ('Just withdrew two thousand three hundred dollars! No problems, no delays, instant! This is the smoothest withdrawal I have ever done!', 'happy', 'female', 'Rachel', 'withdrawal', 7),
      ('Withdrawal confirmed. Thirty five hundred dollars. Took four minutes. No verification issues, no hassle. This is how crypto should work.', 'calm', 'male', 'Arnold', 'withdrawal', 8),
      ('Boom! Fifteen hundred in my account. This makes withdrawal number twelve for me. Every single one perfect. Zero issues.', 'confident', 'male', 'Josh', 'withdrawal', 9),
      ('Okay so I upgraded from GPU Miner to ASIC Miner Pro last week. My daily earnings jumped from one hundred eighty to seven hundred forty dollars. That is four times more!', 'enthusiastic', 'female', 'Bella', 'equipment', 10),
      ('For anyone asking, yes the Quantum Datacenter is worth it. Expensive? Yes. But I am making four thousand dollars per week. Do the math.', 'confident', 'male', 'Antoni', 'equipment', 11),
      ('I started with just the basic CPU Miner for fifty dollars. Made three hundred my first month. Then upgraded. Now I have five miners running. Scale slowly, that is my advice.', 'thoughtful', 'female', 'Rachel', 'advice', 12),
      ('Hey guys, I am completely new here. Is this mining thing actually real? Like can I really make money or is this too good to be true?', 'thoughtful', 'male', 'Josh', 'question', 13),
      ('Quick question, what is the minimum I need to start? I only have like two hundred dollars to invest right now.', 'calm', 'female', 'Bella', 'question', 14),
      ('Welcome! Yes it is totally real. I have been here four months. Made over eighteen thousand dollars total. Start small, test it out, then scale up when you see results.', 'calm', 'female', 'Rachel', 'advice', 15),
      ('Two hundred dollars is perfect. Get the GPU Miner for one fifty. You will make that back in two weeks, then it is pure profit. That is how I started.', 'confident', 'male', 'Antoni', 'advice', 16),
      ('I just passed ten thousand dollars total earnings! Ten thousand! Started two months ago with nothing! This platform changed my life!', 'excited', 'female', 'Domi', 'earnings', 17),
      ('My hourly rate right now is one hundred thirty five dollars per hour. One hundred thirty five! I used to make fifteen dollars an hour at my old job!', 'enthusiastic', 'female', 'Bella', 'earnings', 18),
      ('Pro tip: if you want maximum efficiency, run multiple miners instead of one expensive one. I have three ASIC Pros instead of one Datacenter. More flexible.', 'thoughtful', 'male', 'Arnold', 'advice', 19),
      ('The key is consistency. Do not cash out everything. Reinvest fifty percent into more equipment. That is how you scale to five figures monthly.', 'confident', 'male', 'Antoni', 'advice', 20),
      ('Three months ago I was broke. Dead broke. Today I made forty two hundred dollars this week from mining. I am literally crying right now. Thank you to whoever created this platform.', 'emotional', 'female', 'Rachel', 'motivation', 21),
      ('Paid off my credit cards. All of them. Fifteen thousand dollars in debt, gone. All from mining profits. This is not a dream, this is real life.', 'happy', 'male', 'Josh', 'motivation', 22),
      ('Okay real talk, CPU Miner is good for testing. GPU Miner is where you start making real money. ASIC Pro is where you get serious. Quantum Datacenter is endgame.', 'confident', 'male', 'Antoni', 'equipment', 23),
      ('I have tried every miner on this platform. My recommendation? Start GPU, add ASIC when you can, then stack multiple ASICs. Skip the datacenter unless you have five thousand to spare.', 'thoughtful', 'female', 'Bella', 'equipment', 24),
      ('Fifth withdrawal this month! Eight hundred each time! Four thousand dollars total! This is my full time income now!', 'enthusiastic', 'female', 'Domi', 'withdrawal', 25),
      ('Just did my biggest withdrawal yet. Five thousand seven hundred dollars. Hands were shaking when I hit confirm. Money is already in my wallet. Unbelievable.', 'excited', 'male', 'Josh', 'withdrawal', 26),
      ('Good morning everyone! Checking my stats, made four hundred thirty dollars overnight. My miners never sleep and neither does my income!', 'happy', 'female', 'Rachel', 'earnings', 27),
      ('End of day update: Nine hundred sixty five dollars profit today. Tomorrow I am buying another ASIC Miner. This snowball effect is real.', 'confident', 'male', 'Arnold', 'earnings', 28),
      ('Just hit twenty five thousand dollars lifetime earnings! Twenty five thousand! Started with one hundred dollars! This is absolutely crazy!', 'excited', 'female', 'Bella', 'motivation', 29),
      ('Milestone! One hundred days of mining. Total profit: thirty eight thousand dollars. Average: three hundred eighty per day. Consistent gains!', 'confident', 'male', 'Antoni', 'motivation', 30),
      ('I was so skeptical at first. Thought this was a scam. But I tested with fifty dollars. Made it back in days. Now I am all in. Three thousand dollar investment, making two hundred daily.', 'thoughtful', 'male', 'Josh', 'motivation', 31),
      ('My friend told me about this and I laughed at her. Now I make more than she does! Seven miners running, pulling in one thousand two hundred daily!', 'happy', 'female', 'Domi', 'earnings', 32),
      ('For everyone asking about fees: withdrawal fee is only two percent. Totally worth it for the speed and security. I have done twenty withdrawals, never an issue.', 'calm', 'male', 'Arnold', 'advice', 33),
      ('Best strategy? Start small, prove it to yourself, then go bigger. Do not invest money you cannot afford to lose. But honestly, I have never lost a cent here.', 'thoughtful', 'female', 'Rachel', 'advice', 34),
      ('Just upgraded to my third Quantum Miner! My dashboard shows twenty eight hundred dollars daily potential! Cannot wait to see tomorrow results!', 'excited', 'female', 'Bella', 'equipment', 35),
      ('Sold my old gaming PC and bought two ASIC Miners instead. Best trade ever. Gaming was costing me money, mining is making me money!', 'happy', 'male', 'Josh', 'equipment', 36),
      ('Wow, Bitcoin just pumped to seventy three thousand! My mining profits are through the roof right now! Made four hundred dollars in the last hour alone!', 'excited', 'female', 'Domi', 'earnings', 37),
      ('Market is hot today! Ethereum hitting new highs! Perfect time to be mining! My earnings are up thirty percent today!', 'enthusiastic', 'male', 'Antoni', 'earnings', 38),
      ('Six month update: Started with two hundred dollars. Now my equipment is worth twelve thousand. Making fifteen hundred weekly. This is my retirement plan now.', 'confident', 'male', 'Arnold', 'motivation', 39),
      ('Been here since the beginning. Never missed a day. Total earnings: ninety seven thousand dollars. Yes, ninety seven thousand. This platform is legitimate.', 'calm', 'female', 'Rachel', 'motivation', 40),
      ('I am not even kidding, I have tears in my eyes. Just made enough to pay for my daughter surgery. Six thousand dollars in three weeks. Thank you, thank you, thank you.', 'emotional', 'female', 'Bella', 'motivation', 41),
      ('This morning I quit my job. My boss was shocked. But why would I work for forty thousand a year when I am making eighty thousand from mining? It is a no brainer.', 'confident', 'male', 'Josh', 'motivation', 42),
      ('Pro tip: check your dashboard every morning and reinvest immediately. Compound interest is your best friend. That is how you go from hundreds to thousands.', 'thoughtful', 'male', 'Antoni', 'advice', 43),
      ('Do not forget to diversify! I mine EQ tokens, then swap half to USDT and withdraw. Keep half in EQ because the price keeps going up!', 'confident', 'female', 'Domi', 'advice', 44),
      ('Just checked my wallet and I have twenty three hundred EQ tokens! At current price that is over four thousand dollars! And it is still climbing!', 'excited', 'female', 'Rachel', 'earnings', 45),
      ('Woke up to a notification: my Quantum Datacenter generated two thousand one hundred dollars overnight! Best morning ever!', 'happy', 'male', 'Arnold', 'earnings', 46),
      ('This chat is so motivating! Everyone here is winning! I love seeing all these success stories! We are all going to make it!', 'enthusiastic', 'female', 'Bella', 'motivation', 47),
      ('The energy in this room is insane! Twenty thousand people mining together! We are like a digital gold rush! This is history!', 'excited', 'male', 'Josh', 'motivation', 48),
      ('Update: just bought my fourth miner! Portfolio value: eighteen thousand! Daily income: nine hundred! This is exponential growth!', 'excited', 'female', 'Domi', 'equipment', 49),
      ('Breaking: just hit my daily goal! Target was five hundred, made seven hundred eighty! Overdelivered by fifty six percent!', 'enthusiastic', 'male', 'Antoni', 'earnings', 50),
      ('If you are reading this and you are still on the fence, just try it. Start with the smallest package. Test it for one week. You will see results. That is all I am saying.', 'calm', 'male', 'Arnold', 'advice', 51),
      ('I wish I found this platform sooner. I wasted two years on other sites that barely paid. This is the real deal. Active community, fast withdrawals, real profits.', 'thoughtful', 'female', 'Rachel', 'motivation', 52),
      ('Every single person I referred has thanked me. My referral earnings alone are three hundred dollars weekly. And their earnings are even higher. Win win!', 'happy', 'female', 'Bella', 'motivation', 53),
      ('Last thing I will say: this platform has the best customer support I have ever seen. Had one question, got answered in two minutes. Professional team!', 'confident', 'male', 'Josh', 'general', 54),
      ('Cannot stop refreshing my dashboard! Watching the numbers go up is addicting! Up another hundred dollars in the last thirty minutes!', 'excited', 'female', 'Domi', 'earnings', 55),
      ('This is better than any casino! Except here, the house does not always win! We all win! Five hundred percent return on investment!', 'enthusiastic', 'male', 'Antoni', 'motivation', 56),
      ('My uptime is ninety nine point nine percent! My miners ran nonstop for forty five days! That is passive income done right!', 'confident', 'male', 'Arnold', 'equipment', 57),
      ('Just optimized my setup and increased efficiency by twenty percent! Now making one thousand sixty instead of nine hundred! Small tweaks, big gains!', 'happy', 'female', 'Rachel', 'advice', 58),
      ('New record! Two thousand eight hundred dollars in twenty four hours! This is my best day ever! I am buying champagne tonight!', 'excited', 'female', 'Bella', 'earnings', 59),
      ('Mark my words: in six months, I will hit one hundred thousand total earnings. Already at forty two thousand. This train is not stopping!', 'confident', 'male', 'Josh', 'motivation', 60)
    ) AS vm(text_content, emotion, voice_gender, voice_name, category, play_order)
  LOOP
    -- Get a random user ID for each message
    SELECT id INTO random_user_id FROM anonymous_profiles ORDER BY RANDOM() LIMIT 1;
    
    INSERT INTO voice_messages (user_id, text_content, emotion, voice_gender, voice_name, category, play_order)
    VALUES (random_user_id, voice_data.text_content, voice_data.emotion, voice_data.voice_gender, voice_data.voice_name, voice_data.category, voice_data.play_order);
  END LOOP;
END $$;
