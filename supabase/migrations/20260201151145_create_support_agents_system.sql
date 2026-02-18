/*
  # Create Support Agents System with International Team

  1. New Tables
    - `support_agents`
      - `id` (uuid, primary key)
      - `name` (text) - Agent's full name
      - `country_code` (text) - ISO country code (TR, US, GB, etc.)
      - `country_name` (text) - Full country name
      - `avatar_url` (text) - Professional avatar image
      - `status` (text) - online, away, busy, offline
      - `languages` (text[]) - Supported languages
      - `created_at` (timestamptz)
  
  2. Changes to support_tickets
    - Add `assigned_agent_id` column
    - Add `customer_country` column for country detection
  
  3. Security
    - Enable RLS on `support_agents` table
    - Public read access for agents (for display)
    - Only admins can modify agents
*/

-- Create support agents table
CREATE TABLE IF NOT EXISTS support_agents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  country_code text NOT NULL,
  country_name text NOT NULL,
  avatar_url text NOT NULL,
  status text NOT NULL DEFAULT 'online' CHECK (status IN ('online', 'away', 'busy', 'offline')),
  languages text[] NOT NULL DEFAULT ARRAY['en'],
  created_at timestamptz DEFAULT now()
);

ALTER TABLE support_agents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view agents"
  ON support_agents FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Only admins can insert agents"
  ON support_agents FOR INSERT
  TO authenticated
  WITH CHECK (false);

CREATE POLICY "Only admins can update agents"
  ON support_agents FOR UPDATE
  TO authenticated
  USING (false)
  WITH CHECK (false);

-- Add columns to support_tickets
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'support_tickets' AND column_name = 'assigned_agent_id'
  ) THEN
    ALTER TABLE support_tickets ADD COLUMN assigned_agent_id uuid REFERENCES support_agents(id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'support_tickets' AND column_name = 'customer_country'
  ) THEN
    ALTER TABLE support_tickets ADD COLUMN customer_country text;
  END IF;
END $$;

-- Insert 100 international support agents with professional avatars
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages) VALUES
-- Turkey (20 agents)
('Zeynep Yılmaz', 'TR', 'Turkey', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['tr', 'en']),
('Elif Demir', 'TR', 'Turkey', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['tr', 'en']),
('Ayşe Kaya', 'TR', 'Turkey', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['tr', 'en']),
('Merve Çelik', 'TR', 'Turkey', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['tr', 'en']),
('Selin Arslan', 'TR', 'Turkey', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['tr', 'en']),
('Dilara Özdemir', 'TR', 'Turkey', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['tr', 'en']),
('Büşra Aydın', 'TR', 'Turkey', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['tr', 'en']),
('Ece Şahin', 'TR', 'Turkey', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['tr', 'en']),
('Gizem Yıldız', 'TR', 'Turkey', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['tr', 'en']),
('Deniz Koç', 'TR', 'Turkey', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['tr', 'en']),
('Nazlı Kurt', 'TR', 'Turkey', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['tr', 'en']),
('Ceren Özkan', 'TR', 'Turkey', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['tr', 'en']),
('Ebru Aslan', 'TR', 'Turkey', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['tr', 'en']),
('Pınar Erdoğan', 'TR', 'Turkey', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['tr', 'en']),
('Tuğçe Yurt', 'TR', 'Turkey', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['tr', 'en']),
('Seda Polat', 'TR', 'Turkey', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['tr', 'en']),
('Esra Şen', 'TR', 'Turkey', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['tr', 'en']),
('Gül Taş', 'TR', 'Turkey', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['tr', 'en']),
('Yasemin Acar', 'TR', 'Turkey', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['tr', 'en']),
('Hande Güneş', 'TR', 'Turkey', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['tr', 'en']),

-- United States (15 agents)
('Emily Johnson', 'US', 'United States', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['en']),
('Sarah Williams', 'US', 'United States', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['en', 'es']),
('Jessica Brown', 'US', 'United States', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['en']),
('Ashley Davis', 'US', 'United States', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['en']),
('Amanda Miller', 'US', 'United States', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['en']),
('Rachel Wilson', 'US', 'United States', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['en', 'es']),
('Lauren Moore', 'US', 'United States', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['en']),
('Megan Taylor', 'US', 'United States', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['en']),
('Nicole Anderson', 'US', 'United States', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['en']),
('Jennifer Thomas', 'US', 'United States', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['en']),
('Stephanie Jackson', 'US', 'United States', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['en', 'es']),
('Brittany White', 'US', 'United States', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['en']),
('Rebecca Harris', 'US', 'United States', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['en']),
('Katherine Martin', 'US', 'United States', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['en']),
('Samantha Thompson', 'US', 'United States', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['en']),

-- United Kingdom (10 agents)
('Emma Thompson', 'GB', 'United Kingdom', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['en']),
('Sophie Clarke', 'GB', 'United Kingdom', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['en']),
('Charlotte Davies', 'GB', 'United Kingdom', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['en']),
('Olivia Evans', 'GB', 'United Kingdom', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['en']),
('Lucy Roberts', 'GB', 'United Kingdom', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['en']),
('Grace Walker', 'GB', 'United Kingdom', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['en']),
('Hannah Wright', 'GB', 'United Kingdom', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['en']),
('Amelia Green', 'GB', 'United Kingdom', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['en']),
('Lily Cooper', 'GB', 'United Kingdom', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['en']),
('Isabella King', 'GB', 'United Kingdom', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['en']),

-- Germany (10 agents)
('Anna Müller', 'DE', 'Germany', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['de', 'en']),
('Julia Schmidt', 'DE', 'Germany', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['de', 'en']),
('Laura Schneider', 'DE', 'Germany', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['de', 'en']),
('Sophia Fischer', 'DE', 'Germany', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['de', 'en']),
('Emma Weber', 'DE', 'Germany', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['de', 'en']),
('Marie Meyer', 'DE', 'Germany', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['de', 'en']),
('Lena Wagner', 'DE', 'Germany', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['de', 'en']),
('Hannah Becker', 'DE', 'Germany', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['de', 'en']),
('Mia Schulz', 'DE', 'Germany', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['de', 'en']),
('Emilia Hoffmann', 'DE', 'Germany', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['de', 'en']),

-- France (10 agents)
('Léa Dubois', 'FR', 'France', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['fr', 'en']),
('Chloé Martin', 'FR', 'France', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['fr', 'en']),
('Camille Bernard', 'FR', 'France', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['fr', 'en']),
('Manon Petit', 'FR', 'France', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['fr', 'en']),
('Sarah Robert', 'FR', 'France', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['fr', 'en']),
('Julie Richard', 'FR', 'France', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['fr', 'en']),
('Emma Durand', 'FR', 'France', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['fr', 'en']),
('Marine Moreau', 'FR', 'France', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['fr', 'en']),
('Laura Laurent', 'FR', 'France', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['fr', 'en']),
('Océane Simon', 'FR', 'France', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['fr', 'en']),

-- Spain (8 agents)
('María García', 'ES', 'Spain', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['es', 'en']),
('Carmen Rodríguez', 'ES', 'Spain', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['es', 'en']),
('Laura Martínez', 'ES', 'Spain', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['es', 'en']),
('Ana López', 'ES', 'Spain', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['es', 'en']),
('Sara González', 'ES', 'Spain', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['es', 'en']),
('Paula Sánchez', 'ES', 'Spain', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['es', 'en']),
('Elena Pérez', 'ES', 'Spain', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['es', 'en']),
('Lucía Fernández', 'ES', 'Spain', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['es', 'en']),

-- Italy (7 agents)
('Giulia Rossi', 'IT', 'Italy', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['it', 'en']),
('Francesca Russo', 'IT', 'Italy', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['it', 'en']),
('Chiara Ferrari', 'IT', 'Italy', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['it', 'en']),
('Sofia Esposito', 'IT', 'Italy', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['it', 'en']),
('Martina Bianchi', 'IT', 'Italy', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['it', 'en']),
('Alessia Romano', 'IT', 'Italy', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['it', 'en']),
('Elisa Colombo', 'IT', 'Italy', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['it', 'en']),

-- Netherlands (5 agents)
('Emma de Vries', 'NL', 'Netherlands', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['nl', 'en']),
('Sophie van den Berg', 'NL', 'Netherlands', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['nl', 'en']),
('Lisa Jansen', 'NL', 'Netherlands', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['nl', 'en']),
('Anna Bakker', 'NL', 'Netherlands', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['nl', 'en']),
('Julia Visser', 'NL', 'Netherlands', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['nl', 'en']),

-- UAE (5 agents)
('Fatima Al Ahmed', 'AE', 'United Arab Emirates', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['ar', 'en']),
('Aisha Al Maktoum', 'AE', 'United Arab Emirates', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['ar', 'en']),
('Mariam Al Rashid', 'AE', 'United Arab Emirates', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['ar', 'en']),
('Noura Al Falasi', 'AE', 'United Arab Emirates', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['ar', 'en']),
('Sara Al Hashemi', 'AE', 'United Arab Emirates', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['ar', 'en']),

-- Saudi Arabia (5 agents)
('Lama Al Saud', 'SA', 'Saudi Arabia', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['ar', 'en']),
('Hala Al Qahtani', 'SA', 'Saudi Arabia', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['ar', 'en']),
('Noor Al Otaibi', 'SA', 'Saudi Arabia', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['ar', 'en']),
('Reem Al Ghamdi', 'SA', 'Saudi Arabia', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['ar', 'en']),
('Jana Al Shehri', 'SA', 'Saudi Arabia', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['ar', 'en']),

-- Other countries (5 agents)
('Yuki Tanaka', 'JP', 'Japan', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['ja', 'en']),
('Priya Sharma', 'IN', 'India', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['hi', 'en']),
('Ana Silva', 'BR', 'Brazil', 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg', 'online', ARRAY['pt', 'en']),
('Kim Min-ji', 'KR', 'South Korea', 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg', 'online', ARRAY['ko', 'en']),
('Elena Ivanova', 'RU', 'Russia', 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg', 'online', ARRAY['ru', 'en']);

-- Create index for faster country lookups
CREATE INDEX IF NOT EXISTS idx_support_agents_country ON support_agents(country_code);
CREATE INDEX IF NOT EXISTS idx_support_agents_status ON support_agents(status);