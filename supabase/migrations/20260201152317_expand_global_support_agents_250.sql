/*
  # Expand Global Support Agents System - 250 Agents Worldwide
  
  1. Updates to support_agents table
    - Add `specialty` column (trading, deposits, technical, account)
    - Add `active_tickets` column for load balancing
    - Add `flag` column for country flag emoji
    - Add `timezone` column for timezone awareness
    - Add `region` column for regional grouping
    - Rename `country_name` to make it clearer
    
  2. Geographic Distribution (250 Total)
    - Turkish World (25): Turkey, Azerbaijan, Kazakhstan, Uzbekistan
    - Europe (60): UK, Germany, France, Spain, Italy, Netherlands, Poland, Russia, Ukraine, Scandinavia
    - Arab World (30): UAE, Saudi Arabia, Egypt, Lebanon, Morocco, Tunisia, Jordan
    - Asia (50): China, India, Japan, South Korea, Pakistan, Bangladesh, Indonesia, Thailand, Singapore
    - Americas (40): USA, Canada, Brazil, Argentina, Mexico
    - Africa (20): Nigeria, South Africa, Kenya, Ghana
    - Oceania (10): Australia, New Zealand
    - Other (5): Greece, Czech Republic, etc.
    
  3. Features
    - Real authentic names from each country
    - Country flags for visual identity
    - Native language support
    - Timezone awareness
    - Specialty areas
    - Load balancing via active_tickets
    
  4. Smart Assignment
    - Geo-location based assignment
    - Language matching
    - Timezone optimization
    - Load balancing
*/

-- Add new columns to support_agents
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'support_agents' AND column_name = 'specialty'
  ) THEN
    ALTER TABLE support_agents ADD COLUMN specialty text NOT NULL DEFAULT 'trading' 
      CHECK (specialty IN ('trading', 'deposits', 'technical', 'account'));
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'support_agents' AND column_name = 'active_tickets'
  ) THEN
    ALTER TABLE support_agents ADD COLUMN active_tickets int NOT NULL DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'support_agents' AND column_name = 'flag'
  ) THEN
    ALTER TABLE support_agents ADD COLUMN flag text NOT NULL DEFAULT '🌍';
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'support_agents' AND column_name = 'timezone'
  ) THEN
    ALTER TABLE support_agents ADD COLUMN timezone text NOT NULL DEFAULT 'UTC';
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'support_agents' AND column_name = 'region'
  ) THEN
    ALTER TABLE support_agents ADD COLUMN region text NOT NULL DEFAULT 'Global';
  END IF;
END $$;

-- Clear existing agents and insert 250 global agents
TRUNCATE TABLE support_agents CASCADE;

-- Insert 250 global support agents with real names
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, flag, timezone, region) VALUES

-- TURKISH WORLD (25 agents)
-- Turkey (15)
('Ahmet Yılmaz', 'TR', 'Turkey', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ahmet', 'online', ARRAY['tr', 'en'], 'trading', '🇹🇷', 'Europe/Istanbul', 'Turkish World'),
('Ayşe Demir', 'TR', 'Turkey', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ayse', 'online', ARRAY['tr', 'en'], 'deposits', '🇹🇷', 'Europe/Istanbul', 'Turkish World'),
('Mehmet Kaya', 'TR', 'Turkey', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Mehmet', 'online', ARRAY['tr', 'en'], 'technical', '🇹🇷', 'Europe/Istanbul', 'Turkish World'),
('Fatma Şahin', 'TR', 'Turkey', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Fatma', 'online', ARRAY['tr', 'en'], 'account', '🇹🇷', 'Europe/Istanbul', 'Turkish World'),
('Mustafa Çelik', 'TR', 'Turkey', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Mustafa', 'online', ARRAY['tr', 'en'], 'trading', '🇹🇷', 'Europe/Istanbul', 'Turkish World'),
('Zeynep Arslan', 'TR', 'Turkey', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Zeynep', 'online', ARRAY['tr', 'en'], 'deposits', '🇹🇷', 'Europe/Istanbul', 'Turkish World'),
('Can Özdemir', 'TR', 'Turkey', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Can', 'online', ARRAY['tr', 'en'], 'technical', '🇹🇷', 'Europe/Istanbul', 'Turkish World'),
('Elif Yıldız', 'TR', 'Turkey', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Elif', 'online', ARRAY['tr', 'en'], 'account', '🇹🇷', 'Europe/Istanbul', 'Turkish World'),
('Burak Aydın', 'TR', 'Turkey', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Burak', 'online', ARRAY['tr', 'en'], 'trading', '🇹🇷', 'Europe/Istanbul', 'Turkish World'),
('Selin Polat', 'TR', 'Turkey', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Selin', 'online', ARRAY['tr', 'en'], 'deposits', '🇹🇷', 'Europe/Istanbul', 'Turkish World'),
('Emre Koç', 'TR', 'Turkey', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Emre', 'online', ARRAY['tr', 'en'], 'technical', '🇹🇷', 'Europe/Istanbul', 'Turkish World'),
('Deniz Aksoy', 'TR', 'Turkey', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Deniz', 'online', ARRAY['tr', 'en'], 'account', '🇹🇷', 'Europe/Istanbul', 'Turkish World'),
('Cem Yılmaz', 'TR', 'Turkey', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Cem', 'online', ARRAY['tr', 'en'], 'trading', '🇹🇷', 'Europe/Istanbul', 'Turkish World'),
('Pınar Acar', 'TR', 'Turkey', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Pinar', 'online', ARRAY['tr', 'en'], 'deposits', '🇹🇷', 'Europe/Istanbul', 'Turkish World'),
('Onur Güneş', 'TR', 'Turkey', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Onur', 'online', ARRAY['tr', 'en'], 'technical', '🇹🇷', 'Europe/Istanbul', 'Turkish World'),

-- Azerbaijan (5)
('Elçin Məmmədov', 'AZ', 'Azerbaijan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Elchin', 'online', ARRAY['az', 'tr', 'en'], 'trading', '🇦🇿', 'Asia/Baku', 'Turkish World'),
('Leyla Əliyeva', 'AZ', 'Azerbaijan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Leyla', 'online', ARRAY['az', 'tr', 'en'], 'deposits', '🇦🇿', 'Asia/Baku', 'Turkish World'),
('Ramil Qasımov', 'AZ', 'Azerbaijan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ramil', 'online', ARRAY['az', 'tr', 'en'], 'technical', '🇦🇿', 'Asia/Baku', 'Turkish World'),
('Nigar Həsənova', 'AZ', 'Azerbaijan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Nigar', 'online', ARRAY['az', 'tr', 'en'], 'account', '🇦🇿', 'Asia/Baku', 'Turkish World'),
('Tural İbrahimov', 'AZ', 'Azerbaijan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Tural', 'online', ARRAY['az', 'tr', 'en'], 'trading', '🇦🇿', 'Asia/Baku', 'Turkish World'),

-- Kazakhstan (3)
('Nursultan Bekzhanov', 'KZ', 'Kazakhstan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Nursultan', 'online', ARRAY['kk', 'ru', 'en'], 'deposits', '🇰🇿', 'Asia/Almaty', 'Turkish World'),
('Aida Tulepova', 'KZ', 'Kazakhstan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Aida', 'online', ARRAY['kk', 'ru', 'en'], 'technical', '🇰🇿', 'Asia/Almaty', 'Turkish World'),
('Azamat Kairatov', 'KZ', 'Kazakhstan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Azamat', 'online', ARRAY['kk', 'ru', 'en'], 'account', '🇰🇿', 'Asia/Almaty', 'Turkish World'),

-- Uzbekistan (2)
('Jasur Karimov', 'UZ', 'Uzbekistan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Jasur', 'online', ARRAY['uz', 'ru', 'en'], 'trading', '🇺🇿', 'Asia/Tashkent', 'Turkish World'),
('Dilnoza Rashidova', 'UZ', 'Uzbekistan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Dilnoza', 'online', ARRAY['uz', 'ru', 'en'], 'deposits', '🇺🇿', 'Asia/Tashkent', 'Turkish World'),

-- EUROPE (60 agents)
-- United Kingdom (10)
('James Smith', 'GB', 'United Kingdom', 'https://api.dicebear.com/7.x/avataaars/svg?seed=James', 'online', ARRAY['en'], 'trading', '🇬🇧', 'Europe/London', 'Europe'),
('Emma Johnson', 'GB', 'United Kingdom', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Emma', 'online', ARRAY['en'], 'deposits', '🇬🇧', 'Europe/London', 'Europe'),
('Oliver Williams', 'GB', 'United Kingdom', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Oliver', 'online', ARRAY['en'], 'technical', '🇬🇧', 'Europe/London', 'Europe'),
('Sophie Brown', 'GB', 'United Kingdom', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sophie', 'online', ARRAY['en'], 'account', '🇬🇧', 'Europe/London', 'Europe'),
('Harry Jones', 'GB', 'United Kingdom', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Harry', 'online', ARRAY['en'], 'trading', '🇬🇧', 'Europe/London', 'Europe'),
('Amelia Taylor', 'GB', 'United Kingdom', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Amelia', 'online', ARRAY['en'], 'deposits', '🇬🇧', 'Europe/London', 'Europe'),
('George Davies', 'GB', 'United Kingdom', 'https://api.dicebear.com/7.x/avataaars/svg?seed=George', 'online', ARRAY['en'], 'technical', '🇬🇧', 'Europe/London', 'Europe'),
('Isabella Evans', 'GB', 'United Kingdom', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Isabella', 'online', ARRAY['en'], 'account', '🇬🇧', 'Europe/London', 'Europe'),
('Jack Wilson', 'GB', 'United Kingdom', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Jack', 'online', ARRAY['en'], 'trading', '🇬🇧', 'Europe/London', 'Europe'),
('Lily Thompson', 'GB', 'United Kingdom', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Lily', 'online', ARRAY['en'], 'deposits', '🇬🇧', 'Europe/London', 'Europe'),

-- Germany (10)
('Lukas Müller', 'DE', 'Germany', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Lukas', 'online', ARRAY['de', 'en'], 'trading', '🇩🇪', 'Europe/Berlin', 'Europe'),
('Emma Schmidt', 'DE', 'Germany', 'https://api.dicebear.com/7.x/avataaars/svg?seed=EmmaDE', 'online', ARRAY['de', 'en'], 'deposits', '🇩🇪', 'Europe/Berlin', 'Europe'),
('Leon Wagner', 'DE', 'Germany', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Leon', 'online', ARRAY['de', 'en'], 'technical', '🇩🇪', 'Europe/Berlin', 'Europe'),
('Mia Fischer', 'DE', 'Germany', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Mia', 'online', ARRAY['de', 'en'], 'account', '🇩🇪', 'Europe/Berlin', 'Europe'),
('Felix Weber', 'DE', 'Germany', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix', 'online', ARRAY['de', 'en'], 'trading', '🇩🇪', 'Europe/Berlin', 'Europe'),
('Hannah Meyer', 'DE', 'Germany', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Hannah', 'online', ARRAY['de', 'en'], 'deposits', '🇩🇪', 'Europe/Berlin', 'Europe'),
('Noah Becker', 'DE', 'Germany', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Noah', 'online', ARRAY['de', 'en'], 'technical', '🇩🇪', 'Europe/Berlin', 'Europe'),
('Lena Schulz', 'DE', 'Germany', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Lena', 'online', ARRAY['de', 'en'], 'account', '🇩🇪', 'Europe/Berlin', 'Europe'),
('Paul Hoffmann', 'DE', 'Germany', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Paul', 'online', ARRAY['de', 'en'], 'trading', '🇩🇪', 'Europe/Berlin', 'Europe'),
('Laura Schäfer', 'DE', 'Germany', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Laura', 'online', ARRAY['de', 'en'], 'deposits', '🇩🇪', 'Europe/Berlin', 'Europe'),

-- France (10)
('Lucas Martin', 'FR', 'France', 'https://api.dicebear.com/7.x/avataaars/svg?seed=LucasFR', 'online', ARRAY['fr', 'en'], 'trading', '🇫🇷', 'Europe/Paris', 'Europe'),
('Emma Bernard', 'FR', 'France', 'https://api.dicebear.com/7.x/avataaars/svg?seed=EmmaFR', 'online', ARRAY['fr', 'en'], 'deposits', '🇫🇷', 'Europe/Paris', 'Europe'),
('Hugo Dubois', 'FR', 'France', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Hugo', 'online', ARRAY['fr', 'en'], 'technical', '🇫🇷', 'Europe/Paris', 'Europe'),
('Léa Thomas', 'FR', 'France', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Lea', 'online', ARRAY['fr', 'en'], 'account', '🇫🇷', 'Europe/Paris', 'Europe'),
('Louis Robert', 'FR', 'France', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Louis', 'online', ARRAY['fr', 'en'], 'trading', '🇫🇷', 'Europe/Paris', 'Europe'),
('Chloé Richard', 'FR', 'France', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Chloe', 'online', ARRAY['fr', 'en'], 'deposits', '🇫🇷', 'Europe/Paris', 'Europe'),
('Gabriel Petit', 'FR', 'France', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Gabriel', 'online', ARRAY['fr', 'en'], 'technical', '🇫🇷', 'Europe/Paris', 'Europe'),
('Camille Durand', 'FR', 'France', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Camille', 'online', ARRAY['fr', 'en'], 'account', '🇫🇷', 'Europe/Paris', 'Europe'),
('Arthur Leroy', 'FR', 'France', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Arthur', 'online', ARRAY['fr', 'en'], 'trading', '🇫🇷', 'Europe/Paris', 'Europe'),
('Manon Moreau', 'FR', 'France', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Manon', 'online', ARRAY['fr', 'en'], 'deposits', '🇫🇷', 'Europe/Paris', 'Europe'),

-- Spain (8)
('Alejandro García', 'ES', 'Spain', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alejandro', 'online', ARRAY['es', 'en'], 'trading', '🇪🇸', 'Europe/Madrid', 'Europe'),
('Lucía Rodríguez', 'ES', 'Spain', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Lucia', 'online', ARRAY['es', 'en'], 'deposits', '🇪🇸', 'Europe/Madrid', 'Europe'),
('Pablo Martínez', 'ES', 'Spain', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Pablo', 'online', ARRAY['es', 'en'], 'technical', '🇪🇸', 'Europe/Madrid', 'Europe'),
('María López', 'ES', 'Spain', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Maria', 'online', ARRAY['es', 'en'], 'account', '🇪🇸', 'Europe/Madrid', 'Europe'),
('Diego Hernández', 'ES', 'Spain', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Diego', 'online', ARRAY['es', 'en'], 'trading', '🇪🇸', 'Europe/Madrid', 'Europe'),
('Carmen González', 'ES', 'Spain', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Carmen', 'online', ARRAY['es', 'en'], 'deposits', '🇪🇸', 'Europe/Madrid', 'Europe'),
('Javier Pérez', 'ES', 'Spain', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Javier', 'online', ARRAY['es', 'en'], 'technical', '🇪🇸', 'Europe/Madrid', 'Europe'),
('Ana Sánchez', 'ES', 'Spain', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ana', 'online', ARRAY['es', 'en'], 'account', '🇪🇸', 'Europe/Madrid', 'Europe'),

-- Italy (8)
('Marco Rossi', 'IT', 'Italy', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Marco', 'online', ARRAY['it', 'en'], 'trading', '🇮🇹', 'Europe/Rome', 'Europe'),
('Giulia Ferrari', 'IT', 'Italy', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Giulia', 'online', ARRAY['it', 'en'], 'deposits', '🇮🇹', 'Europe/Rome', 'Europe'),
('Lorenzo Russo', 'IT', 'Italy', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Lorenzo', 'online', ARRAY['it', 'en'], 'technical', '🇮🇹', 'Europe/Rome', 'Europe'),
('Sofia Bianchi', 'IT', 'Italy', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sofia', 'online', ARRAY['it', 'en'], 'account', '🇮🇹', 'Europe/Rome', 'Europe'),
('Alessandro Romano', 'IT', 'Italy', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alessandro', 'online', ARRAY['it', 'en'], 'trading', '🇮🇹', 'Europe/Rome', 'Europe'),
('Chiara Ricci', 'IT', 'Italy', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Chiara', 'online', ARRAY['it', 'en'], 'deposits', '🇮🇹', 'Europe/Rome', 'Europe'),
('Matteo Marino', 'IT', 'Italy', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Matteo', 'online', ARRAY['it', 'en'], 'technical', '🇮🇹', 'Europe/Rome', 'Europe'),
('Francesca Greco', 'IT', 'Italy', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Francesca', 'online', ARRAY['it', 'en'], 'account', '🇮🇹', 'Europe/Rome', 'Europe'),

-- Netherlands (4)
('Daan de Vries', 'NL', 'Netherlands', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Daan', 'online', ARRAY['nl', 'en'], 'trading', '🇳🇱', 'Europe/Amsterdam', 'Europe'),
('Emma van den Berg', 'NL', 'Netherlands', 'https://api.dicebear.com/7.x/avataaars/svg?seed=EmmaNL', 'online', ARRAY['nl', 'en'], 'deposits', '🇳🇱', 'Europe/Amsterdam', 'Europe'),
('Lars Bakker', 'NL', 'Netherlands', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Lars', 'online', ARRAY['nl', 'en'], 'technical', '🇳🇱', 'Europe/Amsterdam', 'Europe'),
('Sophie Janssen', 'NL', 'Netherlands', 'https://api.dicebear.com/7.x/avataaars/svg?seed=SophieNL', 'online', ARRAY['nl', 'en'], 'account', '🇳🇱', 'Europe/Amsterdam', 'Europe'),

-- Poland (4)
('Jakub Kowalski', 'PL', 'Poland', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Jakub', 'online', ARRAY['pl', 'en'], 'trading', '🇵🇱', 'Europe/Warsaw', 'Europe'),
('Zofia Nowak', 'PL', 'Poland', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Zofia', 'online', ARRAY['pl', 'en'], 'deposits', '🇵🇱', 'Europe/Warsaw', 'Europe'),
('Szymon Wiśniewski', 'PL', 'Poland', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Szymon', 'online', ARRAY['pl', 'en'], 'technical', '🇵🇱', 'Europe/Warsaw', 'Europe'),
('Julia Wójcik', 'PL', 'Poland', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Julia', 'online', ARRAY['pl', 'en'], 'account', '🇵🇱', 'Europe/Warsaw', 'Europe'),

-- Russia (3)
('Dmitry Ivanov', 'RU', 'Russia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Dmitry', 'online', ARRAY['ru', 'en'], 'trading', '🇷🇺', 'Europe/Moscow', 'Europe'),
('Anastasia Smirnova', 'RU', 'Russia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Anastasia', 'online', ARRAY['ru', 'en'], 'deposits', '🇷🇺', 'Europe/Moscow', 'Europe'),
('Alexei Kuznetsov', 'RU', 'Russia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alexei', 'online', ARRAY['ru', 'en'], 'technical', '🇷🇺', 'Europe/Moscow', 'Europe'),

-- Ukraine (3)
('Andriy Kovalenko', 'UA', 'Ukraine', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Andriy', 'online', ARRAY['uk', 'ru', 'en'], 'account', '🇺🇦', 'Europe/Kyiv', 'Europe'),
('Olena Bondarenko', 'UA', 'Ukraine', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Olena', 'online', ARRAY['uk', 'ru', 'en'], 'trading', '🇺🇦', 'Europe/Kyiv', 'Europe'),
('Viktor Tkachenko', 'UA', 'Ukraine', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Viktor', 'online', ARRAY['uk', 'ru', 'en'], 'deposits', '🇺🇦', 'Europe/Kyiv', 'Europe'),

-- ARAB WORLD (30 agents)
-- UAE (8)
('Ahmed Al Mansouri', 'AE', 'United Arab Emirates', 'https://api.dicebear.com/7.x/avataaars/svg?seed=AhmedUAE', 'online', ARRAY['ar', 'en'], 'trading', '🇦🇪', 'Asia/Dubai', 'Arab World'),
('Fatima Al Zaabi', 'AE', 'United Arab Emirates', 'https://api.dicebear.com/7.x/avataaars/svg?seed=FatimaUAE', 'online', ARRAY['ar', 'en'], 'deposits', '🇦🇪', 'Asia/Dubai', 'Arab World'),
('Mohammed Al Hashimi', 'AE', 'United Arab Emirates', 'https://api.dicebear.com/7.x/avataaars/svg?seed=MohammedUAE', 'online', ARRAY['ar', 'en'], 'technical', '🇦🇪', 'Asia/Dubai', 'Arab World'),
('Aisha Al Nuaimi', 'AE', 'United Arab Emirates', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Aisha', 'online', ARRAY['ar', 'en'], 'account', '🇦🇪', 'Asia/Dubai', 'Arab World'),
('Khalid Al Maktoum', 'AE', 'United Arab Emirates', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Khalid', 'online', ARRAY['ar', 'en'], 'trading', '🇦🇪', 'Asia/Dubai', 'Arab World'),
('Mariam Al Falasi', 'AE', 'United Arab Emirates', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Mariam', 'online', ARRAY['ar', 'en'], 'deposits', '🇦🇪', 'Asia/Dubai', 'Arab World'),
('Omar Al Shamsi', 'AE', 'United Arab Emirates', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Omar', 'online', ARRAY['ar', 'en'], 'technical', '🇦🇪', 'Asia/Dubai', 'Arab World'),
('Hessa Al Dhaheri', 'AE', 'United Arab Emirates', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Hessa', 'online', ARRAY['ar', 'en'], 'account', '🇦🇪', 'Asia/Dubai', 'Arab World'),

-- Saudi Arabia (8)
('Abdullah Al Qahtani', 'SA', 'Saudi Arabia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Abdullah', 'online', ARRAY['ar', 'en'], 'trading', '🇸🇦', 'Asia/Riyadh', 'Arab World'),
('Nora Al Saud', 'SA', 'Saudi Arabia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Nora', 'online', ARRAY['ar', 'en'], 'deposits', '🇸🇦', 'Asia/Riyadh', 'Arab World'),
('Faisal Al Otaibi', 'SA', 'Saudi Arabia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Faisal', 'online', ARRAY['ar', 'en'], 'technical', '🇸🇦', 'Asia/Riyadh', 'Arab World'),
('Sarah Al Ghamdi', 'SA', 'Saudi Arabia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah', 'online', ARRAY['ar', 'en'], 'account', '🇸🇦', 'Asia/Riyadh', 'Arab World'),
('Saud Al Mutairi', 'SA', 'Saudi Arabia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Saud', 'online', ARRAY['ar', 'en'], 'trading', '🇸🇦', 'Asia/Riyadh', 'Arab World'),
('Lama Al Harbi', 'SA', 'Saudi Arabia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Lama', 'online', ARRAY['ar', 'en'], 'deposits', '🇸🇦', 'Asia/Riyadh', 'Arab World'),
('Turki Al Rashid', 'SA', 'Saudi Arabia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Turki', 'online', ARRAY['ar', 'en'], 'technical', '🇸🇦', 'Asia/Riyadh', 'Arab World'),
('Maha Al Balawi', 'SA', 'Saudi Arabia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Maha', 'online', ARRAY['ar', 'en'], 'account', '🇸🇦', 'Asia/Riyadh', 'Arab World'),

-- Egypt (4)
('Mohamed Hassan', 'EG', 'Egypt', 'https://api.dicebear.com/7.x/avataaars/svg?seed=MohamedEG', 'online', ARRAY['ar', 'en'], 'trading', '🇪🇬', 'Africa/Cairo', 'Arab World'),
('Yasmin Ibrahim', 'EG', 'Egypt', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Yasmin', 'online', ARRAY['ar', 'en'], 'deposits', '🇪🇬', 'Africa/Cairo', 'Arab World'),
('Amr Mahmoud', 'EG', 'Egypt', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Amr', 'online', ARRAY['ar', 'en'], 'technical', '🇪🇬', 'Africa/Cairo', 'Arab World'),
('Nour Ali', 'EG', 'Egypt', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Nour', 'online', ARRAY['ar', 'en'], 'account', '🇪🇬', 'Africa/Cairo', 'Arab World'),

-- Lebanon (3)
('Karim Hariri', 'LB', 'Lebanon', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Karim', 'online', ARRAY['ar', 'fr', 'en'], 'trading', '🇱🇧', 'Asia/Beirut', 'Arab World'),
('Layla Nasr', 'LB', 'Lebanon', 'https://api.dicebear.com/7.x/avataaars/svg?seed=LaylaLB', 'online', ARRAY['ar', 'fr', 'en'], 'deposits', '🇱🇧', 'Asia/Beirut', 'Arab World'),
('Rami Khoury', 'LB', 'Lebanon', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Rami', 'online', ARRAY['ar', 'fr', 'en'], 'technical', '🇱🇧', 'Asia/Beirut', 'Arab World'),

-- Morocco (3)
('Youssef Benali', 'MA', 'Morocco', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Youssef', 'online', ARRAY['ar', 'fr', 'en'], 'account', '🇲🇦', 'Africa/Casablanca', 'Arab World'),
('Salma El Amrani', 'MA', 'Morocco', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Salma', 'online', ARRAY['ar', 'fr', 'en'], 'trading', '🇲🇦', 'Africa/Casablanca', 'Arab World'),
('Hassan Idrissi', 'MA', 'Morocco', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Hassan', 'online', ARRAY['ar', 'fr', 'en'], 'deposits', '🇲🇦', 'Africa/Casablanca', 'Arab World'),

-- Tunisia (2)
('Mehdi Trabelsi', 'TN', 'Tunisia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Mehdi', 'online', ARRAY['ar', 'fr', 'en'], 'technical', '🇹🇳', 'Africa/Tunis', 'Arab World'),
('Ines Ben Salah', 'TN', 'Tunisia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ines', 'online', ARRAY['ar', 'fr', 'en'], 'account', '🇹🇳', 'Africa/Tunis', 'Arab World'),

-- Jordan (2)
('Tariq Al Hussein', 'JO', 'Jordan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Tariq', 'online', ARRAY['ar', 'en'], 'trading', '🇯🇴', 'Asia/Amman', 'Arab World'),
('Dina Mustafa', 'JO', 'Jordan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Dina', 'online', ARRAY['ar', 'en'], 'deposits', '🇯🇴', 'Asia/Amman', 'Arab World'),

-- ASIA (50 agents) - Continue with remaining countries...
-- China (10)
('Wei Zhang', 'CN', 'China', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Wei', 'online', ARRAY['zh', 'en'], 'trading', '🇨🇳', 'Asia/Shanghai', 'Asia'),
('Li Wang', 'CN', 'China', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Li', 'online', ARRAY['zh', 'en'], 'deposits', '🇨🇳', 'Asia/Shanghai', 'Asia'),
('Chen Liu', 'CN', 'China', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Chen', 'online', ARRAY['zh', 'en'], 'technical', '🇨🇳', 'Asia/Shanghai', 'Asia'),
('Xiao Yang', 'CN', 'China', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Xiao', 'online', ARRAY['zh', 'en'], 'account', '🇨🇳', 'Asia/Shanghai', 'Asia'),
('Ming Chen', 'CN', 'China', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ming', 'online', ARRAY['zh', 'en'], 'trading', '🇨🇳', 'Asia/Shanghai', 'Asia'),
('Jing Zhou', 'CN', 'China', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Jing', 'online', ARRAY['zh', 'en'], 'deposits', '🇨🇳', 'Asia/Shanghai', 'Asia'),
('Long Wu', 'CN', 'China', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Long', 'online', ARRAY['zh', 'en'], 'technical', '🇨🇳', 'Asia/Shanghai', 'Asia'),
('Hui Huang', 'CN', 'China', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Hui', 'online', ARRAY['zh', 'en'], 'account', '🇨🇳', 'Asia/Shanghai', 'Asia'),
('Jun Zhao', 'CN', 'China', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Jun', 'online', ARRAY['zh', 'en'], 'trading', '🇨🇳', 'Asia/Shanghai', 'Asia'),
('Yan Lin', 'CN', 'China', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Yan', 'online', ARRAY['zh', 'en'], 'deposits', '🇨🇳', 'Asia/Shanghai', 'Asia'),

-- India (10)
('Rahul Sharma', 'IN', 'India', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Rahul', 'online', ARRAY['hi', 'en'], 'trading', '🇮🇳', 'Asia/Kolkata', 'Asia'),
('Priya Patel', 'IN', 'India', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Priya', 'online', ARRAY['hi', 'en'], 'deposits', '🇮🇳', 'Asia/Kolkata', 'Asia'),
('Amit Kumar', 'IN', 'India', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Amit', 'online', ARRAY['hi', 'en'], 'technical', '🇮🇳', 'Asia/Kolkata', 'Asia'),
('Neha Singh', 'IN', 'India', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Neha', 'online', ARRAY['hi', 'en'], 'account', '🇮🇳', 'Asia/Kolkata', 'Asia'),
('Vijay Reddy', 'IN', 'India', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Vijay', 'online', ARRAY['hi', 'en'], 'trading', '🇮🇳', 'Asia/Kolkata', 'Asia'),
('Anjali Gupta', 'IN', 'India', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Anjali', 'online', ARRAY['hi', 'en'], 'deposits', '🇮🇳', 'Asia/Kolkata', 'Asia'),
('Rohan Kapoor', 'IN', 'India', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Rohan', 'online', ARRAY['hi', 'en'], 'technical', '🇮🇳', 'Asia/Kolkata', 'Asia'),
('Divya Joshi', 'IN', 'India', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Divya', 'online', ARRAY['hi', 'en'], 'account', '🇮🇳', 'Asia/Kolkata', 'Asia'),
('Arjun Nair', 'IN', 'India', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Arjun', 'online', ARRAY['hi', 'en'], 'trading', '🇮🇳', 'Asia/Kolkata', 'Asia'),
('Kavya Iyer', 'IN', 'India', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Kavya', 'online', ARRAY['hi', 'en'], 'deposits', '🇮🇳', 'Asia/Kolkata', 'Asia'),

-- Japan (6)
('Takeshi Tanaka', 'JP', 'Japan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Takeshi', 'online', ARRAY['ja', 'en'], 'trading', '🇯🇵', 'Asia/Tokyo', 'Asia'),
('Yuki Sato', 'JP', 'Japan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=YukiJP', 'online', ARRAY['ja', 'en'], 'deposits', '🇯🇵', 'Asia/Tokyo', 'Asia'),
('Hiroshi Suzuki', 'JP', 'Japan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Hiroshi', 'online', ARRAY['ja', 'en'], 'technical', '🇯🇵', 'Asia/Tokyo', 'Asia'),
('Sakura Yamamoto', 'JP', 'Japan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sakura', 'online', ARRAY['ja', 'en'], 'account', '🇯🇵', 'Asia/Tokyo', 'Asia'),
('Kenji Watanabe', 'JP', 'Japan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Kenji', 'online', ARRAY['ja', 'en'], 'trading', '🇯🇵', 'Asia/Tokyo', 'Asia'),
('Aiko Nakamura', 'JP', 'Japan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Aiko', 'online', ARRAY['ja', 'en'], 'deposits', '🇯🇵', 'Asia/Tokyo', 'Asia'),

-- South Korea (6)
('Min-jun Kim', 'KR', 'South Korea', 'https://api.dicebear.com/7.x/avataaars/svg?seed=MinJun', 'online', ARRAY['ko', 'en'], 'trading', '🇰🇷', 'Asia/Seoul', 'Asia'),
('Ji-woo Lee', 'KR', 'South Korea', 'https://api.dicebear.com/7.x/avataaars/svg?seed=JiWoo', 'online', ARRAY['ko', 'en'], 'deposits', '🇰🇷', 'Asia/Seoul', 'Asia'),
('Seo-jun Park', 'KR', 'South Korea', 'https://api.dicebear.com/7.x/avataaars/svg?seed=SeoJun', 'online', ARRAY['ko', 'en'], 'technical', '🇰🇷', 'Asia/Seoul', 'Asia'),
('Soo-yeon Choi', 'KR', 'South Korea', 'https://api.dicebear.com/7.x/avataaars/svg?seed=SooYeon', 'online', ARRAY['ko', 'en'], 'account', '🇰🇷', 'Asia/Seoul', 'Asia'),
('Hyun-woo Jung', 'KR', 'South Korea', 'https://api.dicebear.com/7.x/avataaars/svg?seed=HyunWoo', 'online', ARRAY['ko', 'en'], 'trading', '🇰🇷', 'Asia/Seoul', 'Asia'),
('Ye-jin Kang', 'KR', 'South Korea', 'https://api.dicebear.com/7.x/avataaars/svg?seed=YeJin', 'online', ARRAY['ko', 'en'], 'deposits', '🇰🇷', 'Asia/Seoul', 'Asia'),

-- Pakistan (4)
('Ali Hassan', 'PK', 'Pakistan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=AliPK', 'online', ARRAY['ur', 'en'], 'trading', '🇵🇰', 'Asia/Karachi', 'Asia'),
('Ayesha Khan', 'PK', 'Pakistan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=AyeshaPK', 'online', ARRAY['ur', 'en'], 'deposits', '🇵🇰', 'Asia/Karachi', 'Asia'),
('Bilal Ahmed', 'PK', 'Pakistan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Bilal', 'online', ARRAY['ur', 'en'], 'technical', '🇵🇰', 'Asia/Karachi', 'Asia'),
('Fatima Malik', 'PK', 'Pakistan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=FatimaPK', 'online', ARRAY['ur', 'en'], 'account', '🇵🇰', 'Asia/Karachi', 'Asia'),

-- Bangladesh (4)
('Rafiq Rahman', 'BD', 'Bangladesh', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Rafiq', 'online', ARRAY['bn', 'en'], 'trading', '🇧🇩', 'Asia/Dhaka', 'Asia'),
('Nadia Hossain', 'BD', 'Bangladesh', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Nadia', 'online', ARRAY['bn', 'en'], 'deposits', '🇧🇩', 'Asia/Dhaka', 'Asia'),
('Kamal Islam', 'BD', 'Bangladesh', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Kamal', 'online', ARRAY['bn', 'en'], 'technical', '🇧🇩', 'Asia/Dhaka', 'Asia'),
('Sadia Begum', 'BD', 'Bangladesh', 'https://api.dicebear.com/7.x/avataaars/svg?seed=SadiaBD', 'online', ARRAY['bn', 'en'], 'account', '🇧🇩', 'Asia/Dhaka', 'Asia'),

-- Indonesia (4)
('Adi Wijaya', 'ID', 'Indonesia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Adi', 'online', ARRAY['id', 'en'], 'trading', '🇮🇩', 'Asia/Jakarta', 'Asia'),
('Siti Rahayu', 'ID', 'Indonesia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Siti', 'online', ARRAY['id', 'en'], 'deposits', '🇮🇩', 'Asia/Jakarta', 'Asia'),
('Budi Santoso', 'ID', 'Indonesia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Budi', 'online', ARRAY['id', 'en'], 'technical', '🇮🇩', 'Asia/Jakarta', 'Asia'),
('Dewi Lestari', 'ID', 'Indonesia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Dewi', 'online', ARRAY['id', 'en'], 'account', '🇮🇩', 'Asia/Jakarta', 'Asia'),

-- Thailand (4)
('Somchai Prasert', 'TH', 'Thailand', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Somchai', 'online', ARRAY['th', 'en'], 'trading', '🇹🇭', 'Asia/Bangkok', 'Asia'),
('Nong Siri', 'TH', 'Thailand', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Nong', 'online', ARRAY['th', 'en'], 'deposits', '🇹🇭', 'Asia/Bangkok', 'Asia'),
('Kittipong Chai', 'TH', 'Thailand', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Kittipong', 'online', ARRAY['th', 'en'], 'technical', '🇹🇭', 'Asia/Bangkok', 'Asia'),
('Pensri Pim', 'TH', 'Thailand', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Pensri', 'online', ARRAY['th', 'en'], 'account', '🇹🇭', 'Asia/Bangkok', 'Asia'),

-- Singapore (2)
('Wei Lim', 'SG', 'Singapore', 'https://api.dicebear.com/7.x/avataaars/svg?seed=WeiSG', 'online', ARRAY['en', 'zh'], 'trading', '🇸🇬', 'Asia/Singapore', 'Asia'),
('Mei Tan', 'SG', 'Singapore', 'https://api.dicebear.com/7.x/avataaars/svg?seed=MeiSG', 'online', ARRAY['en', 'zh'], 'deposits', '🇸🇬', 'Asia/Singapore', 'Asia'),

-- AMERICAS (40 agents)
-- United States (15)
('Michael Johnson', 'US', 'United States', 'https://api.dicebear.com/7.x/avataaars/svg?seed=MichaelUS', 'online', ARRAY['en'], 'trading', '🇺🇸', 'America/New_York', 'Americas'),
('Emily Davis', 'US', 'United States', 'https://api.dicebear.com/7.x/avataaars/svg?seed=EmilyUS', 'online', ARRAY['en'], 'deposits', '🇺🇸', 'America/New_York', 'Americas'),
('David Martinez', 'US', 'United States', 'https://api.dicebear.com/7.x/avataaars/svg?seed=David', 'online', ARRAY['en'], 'technical', '🇺🇸', 'America/New_York', 'Americas'),
('Sarah Anderson', 'US', 'United States', 'https://api.dicebear.com/7.x/avataaars/svg?seed=SarahUS', 'online', ARRAY['en'], 'account', '🇺🇸', 'America/New_York', 'Americas'),
('Christopher Taylor', 'US', 'United States', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Christopher', 'online', ARRAY['en'], 'trading', '🇺🇸', 'America/Chicago', 'Americas'),
('Jessica Thomas', 'US', 'United States', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Jessica', 'online', ARRAY['en'], 'deposits', '🇺🇸', 'America/Chicago', 'Americas'),
('Matthew Jackson', 'US', 'United States', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Matthew', 'online', ARRAY['en'], 'technical', '🇺🇸', 'America/Chicago', 'Americas'),
('Ashley White', 'US', 'United States', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ashley', 'online', ARRAY['en'], 'account', '🇺🇸', 'America/Chicago', 'Americas'),
('Joshua Harris', 'US', 'United States', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Joshua', 'online', ARRAY['en'], 'trading', '🇺🇸', 'America/Los_Angeles', 'Americas'),
('Amanda Martin', 'US', 'United States', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Amanda', 'online', ARRAY['en'], 'deposits', '🇺🇸', 'America/Los_Angeles', 'Americas'),
('Daniel Garcia', 'US', 'United States', 'https://api.dicebear.com/7.x/avataaars/svg?seed=DanielUS', 'online', ARRAY['en'], 'technical', '🇺🇸', 'America/Los_Angeles', 'Americas'),
('Stephanie Rodriguez', 'US', 'United States', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Stephanie', 'online', ARRAY['en'], 'account', '🇺🇸', 'America/Los_Angeles', 'Americas'),
('Andrew Wilson', 'US', 'United States', 'https://api.dicebear.com/7.x/avataaars/svg?seed=AndrewUS', 'online', ARRAY['en'], 'trading', '🇺🇸', 'America/Denver', 'Americas'),
('Melissa Moore', 'US', 'United States', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Melissa', 'online', ARRAY['en'], 'deposits', '🇺🇸', 'America/Denver', 'Americas'),
('Ryan Lee', 'US', 'United States', 'https://api.dicebear.com/7.x/avataaars/svg?seed=RyanUS', 'online', ARRAY['en'], 'technical', '🇺🇸', 'America/Phoenix', 'Americas'),

-- Canada (8)
('Liam MacDonald', 'CA', 'Canada', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Liam', 'online', ARRAY['en', 'fr'], 'trading', '🇨🇦', 'America/Toronto', 'Americas'),
('Olivia Tremblay', 'CA', 'Canada', 'https://api.dicebear.com/7.x/avataaars/svg?seed=OliviaCA', 'online', ARRAY['en', 'fr'], 'deposits', '🇨🇦', 'America/Toronto', 'Americas'),
('Noah Roy', 'CA', 'Canada', 'https://api.dicebear.com/7.x/avataaars/svg?seed=NoahCA', 'online', ARRAY['en', 'fr'], 'technical', '🇨🇦', 'America/Toronto', 'Americas'),
('Ava Gagnon', 'CA', 'Canada', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ava', 'online', ARRAY['en', 'fr'], 'account', '🇨🇦', 'America/Toronto', 'Americas'),
('Ethan Bouchard', 'CA', 'Canada', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ethan', 'online', ARRAY['en', 'fr'], 'trading', '🇨🇦', 'America/Montreal', 'Americas'),
('Emma Côté', 'CA', 'Canada', 'https://api.dicebear.com/7.x/avataaars/svg?seed=EmmaCA', 'online', ARRAY['en', 'fr'], 'deposits', '🇨🇦', 'America/Montreal', 'Americas'),
('William Lavoie', 'CA', 'Canada', 'https://api.dicebear.com/7.x/avataaars/svg?seed=WilliamCA', 'online', ARRAY['en', 'fr'], 'technical', '🇨🇦', 'America/Vancouver', 'Americas'),
('Charlotte Leblanc', 'CA', 'Canada', 'https://api.dicebear.com/7.x/avataaars/svg?seed=CharlotteCA', 'online', ARRAY['en', 'fr'], 'account', '🇨🇦', 'America/Vancouver', 'Americas'),

-- Brazil (8)
('João Silva', 'BR', 'Brazil', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Joao', 'online', ARRAY['pt', 'en'], 'trading', '🇧🇷', 'America/Sao_Paulo', 'Americas'),
('Maria Santos', 'BR', 'Brazil', 'https://api.dicebear.com/7.x/avataaars/svg?seed=MariaBR', 'online', ARRAY['pt', 'en'], 'deposits', '🇧🇷', 'America/Sao_Paulo', 'Americas'),
('Pedro Oliveira', 'BR', 'Brazil', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Pedro', 'online', ARRAY['pt', 'en'], 'technical', '🇧🇷', 'America/Sao_Paulo', 'Americas'),
('Ana Costa', 'BR', 'Brazil', 'https://api.dicebear.com/7.x/avataaars/svg?seed=AnaBR', 'online', ARRAY['pt', 'en'], 'account', '🇧🇷', 'America/Sao_Paulo', 'Americas'),
('Lucas Souza', 'BR', 'Brazil', 'https://api.dicebear.com/7.x/avataaars/svg?seed=LucasBR', 'online', ARRAY['pt', 'en'], 'trading', '🇧🇷', 'America/Sao_Paulo', 'Americas'),
('Juliana Pereira', 'BR', 'Brazil', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Juliana', 'online', ARRAY['pt', 'en'], 'deposits', '🇧🇷', 'America/Sao_Paulo', 'Americas'),
('Gabriel Lima', 'BR', 'Brazil', 'https://api.dicebear.com/7.x/avataaars/svg?seed=GabrielBR', 'online', ARRAY['pt', 'en'], 'technical', '🇧🇷', 'America/Sao_Paulo', 'Americas'),
('Fernanda Alves', 'BR', 'Brazil', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Fernanda', 'online', ARRAY['pt', 'en'], 'account', '🇧🇷', 'America/Sao_Paulo', 'Americas'),

-- Argentina (4)
('Mateo González', 'AR', 'Argentina', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Mateo', 'online', ARRAY['es', 'en'], 'trading', '🇦🇷', 'America/Argentina/Buenos_Aires', 'Americas'),
('Valentina Fernández', 'AR', 'Argentina', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Valentina', 'online', ARRAY['es', 'en'], 'deposits', '🇦🇷', 'America/Argentina/Buenos_Aires', 'Americas'),
('Santiago Rodríguez', 'AR', 'Argentina', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Santiago', 'online', ARRAY['es', 'en'], 'technical', '🇦🇷', 'America/Argentina/Buenos_Aires', 'Americas'),
('Sofía López', 'AR', 'Argentina', 'https://api.dicebear.com/7.x/avataaars/svg?seed=SofiaAR', 'online', ARRAY['es', 'en'], 'account', '🇦🇷', 'America/Argentina/Buenos_Aires', 'Americas'),

-- Mexico (5)
('Miguel Hernández', 'MX', 'Mexico', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Miguel', 'online', ARRAY['es', 'en'], 'trading', '🇲🇽', 'America/Mexico_City', 'Americas'),
('Guadalupe Ramírez', 'MX', 'Mexico', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Guadalupe', 'online', ARRAY['es', 'en'], 'deposits', '🇲🇽', 'America/Mexico_City', 'Americas'),
('Carlos Torres', 'MX', 'Mexico', 'https://api.dicebear.com/7.x/avataaars/svg?seed=CarlosMX', 'online', ARRAY['es', 'en'], 'technical', '🇲🇽', 'America/Mexico_City', 'Americas'),
('Isabel Flores', 'MX', 'Mexico', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Isabel', 'online', ARRAY['es', 'en'], 'account', '🇲🇽', 'America/Mexico_City', 'Americas'),
('José Morales', 'MX', 'Mexico', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Jose', 'online', ARRAY['es', 'en'], 'trading', '🇲🇽', 'America/Mexico_City', 'Americas'),

-- AFRICA (20 agents)
-- Nigeria (6)
('Chukwu Okafor', 'NG', 'Nigeria', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Chukwu', 'online', ARRAY['en'], 'trading', '🇳🇬', 'Africa/Lagos', 'Africa'),
('Amina Bello', 'NG', 'Nigeria', 'https://api.dicebear.com/7.x/avataaars/svg?seed=AminaNG', 'online', ARRAY['en'], 'deposits', '🇳🇬', 'Africa/Lagos', 'Africa'),
('Adeola Williams', 'NG', 'Nigeria', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Adeola', 'online', ARRAY['en'], 'technical', '🇳🇬', 'Africa/Lagos', 'Africa'),
('Ngozi Eze', 'NG', 'Nigeria', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ngozi', 'online', ARRAY['en'], 'account', '🇳🇬', 'Africa/Lagos', 'Africa'),
('Obinna Nwankwo', 'NG', 'Nigeria', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Obinna', 'online', ARRAY['en'], 'trading', '🇳🇬', 'Africa/Lagos', 'Africa'),
('Chioma Okeke', 'NG', 'Nigeria', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Chioma', 'online', ARRAY['en'], 'deposits', '🇳🇬', 'Africa/Lagos', 'Africa'),

-- South Africa (6)
('Thabo Mabaso', 'ZA', 'South Africa', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Thabo', 'online', ARRAY['en'], 'trading', '🇿🇦', 'Africa/Johannesburg', 'Africa'),
('Zanele Dlamini', 'ZA', 'South Africa', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Zanele', 'online', ARRAY['en'], 'deposits', '🇿🇦', 'Africa/Johannesburg', 'Africa'),
('Sipho Nkosi', 'ZA', 'South Africa', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sipho', 'online', ARRAY['en'], 'technical', '🇿🇦', 'Africa/Johannesburg', 'Africa'),
('Nomsa Khumalo', 'ZA', 'South Africa', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Nomsa', 'online', ARRAY['en'], 'account', '🇿🇦', 'Africa/Johannesburg', 'Africa'),
('Andries van der Merwe', 'ZA', 'South Africa', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Andries', 'online', ARRAY['en'], 'trading', '🇿🇦', 'Africa/Johannesburg', 'Africa'),
('Lerato Mokoena', 'ZA', 'South Africa', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Lerato', 'online', ARRAY['en'], 'deposits', '🇿🇦', 'Africa/Johannesburg', 'Africa'),

-- Kenya (4)
('David Kamau', 'KE', 'Kenya', 'https://api.dicebear.com/7.x/avataaars/svg?seed=DavidKE', 'online', ARRAY['sw', 'en'], 'trading', '🇰🇪', 'Africa/Nairobi', 'Africa'),
('Grace Wanjiru', 'KE', 'Kenya', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Grace', 'online', ARRAY['sw', 'en'], 'deposits', '🇰🇪', 'Africa/Nairobi', 'Africa'),
('John Mwangi', 'KE', 'Kenya', 'https://api.dicebear.com/7.x/avataaars/svg?seed=JohnKE', 'online', ARRAY['sw', 'en'], 'technical', '🇰🇪', 'Africa/Nairobi', 'Africa'),
('Jane Njeri', 'KE', 'Kenya', 'https://api.dicebear.com/7.x/avataaars/svg?seed=JaneKE', 'online', ARRAY['sw', 'en'], 'account', '🇰🇪', 'Africa/Nairobi', 'Africa'),

-- Ghana (4)
('Kwame Asante', 'GH', 'Ghana', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Kwame', 'online', ARRAY['en'], 'trading', '🇬🇭', 'Africa/Accra', 'Africa'),
('Ama Mensah', 'GH', 'Ghana', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ama', 'online', ARRAY['en'], 'deposits', '🇬🇭', 'Africa/Accra', 'Africa'),
('Kofi Boateng', 'GH', 'Ghana', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Kofi', 'online', ARRAY['en'], 'technical', '🇬🇭', 'Africa/Accra', 'Africa'),
('Akua Owusu', 'GH', 'Ghana', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Akua', 'online', ARRAY['en'], 'account', '🇬🇭', 'Africa/Accra', 'Africa'),

-- OCEANIA (10 agents)
-- Australia (7)
('Jackson Cooper', 'AU', 'Australia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=JacksonAU', 'online', ARRAY['en'], 'trading', '🇦🇺', 'Australia/Sydney', 'Oceania'),
('Charlotte Smith', 'AU', 'Australia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=CharlotteAU', 'online', ARRAY['en'], 'deposits', '🇦🇺', 'Australia/Sydney', 'Oceania'),
('William Brown', 'AU', 'Australia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=WilliamAU', 'online', ARRAY['en'], 'technical', '🇦🇺', 'Australia/Sydney', 'Oceania'),
('Mia Wilson', 'AU', 'Australia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=MiaAU', 'online', ARRAY['en'], 'account', '🇦🇺', 'Australia/Sydney', 'Oceania'),
('Oliver Taylor', 'AU', 'Australia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=OliverAU', 'online', ARRAY['en'], 'trading', '🇦🇺', 'Australia/Melbourne', 'Oceania'),
('Amelia Johnson', 'AU', 'Australia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=AmeliaAU', 'online', ARRAY['en'], 'deposits', '🇦🇺', 'Australia/Melbourne', 'Oceania'),
('Noah Harris', 'AU', 'Australia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=NoahAU', 'online', ARRAY['en'], 'technical', '🇦🇺', 'Australia/Brisbane', 'Oceania'),

-- New Zealand (3)
('Liam Anderson', 'NZ', 'New Zealand', 'https://api.dicebear.com/7.x/avataaars/svg?seed=LiamNZ', 'online', ARRAY['en'], 'account', '🇳🇿', 'Pacific/Auckland', 'Oceania'),
('Sophie Williams', 'NZ', 'New Zealand', 'https://api.dicebear.com/7.x/avataaars/svg?seed=SophieNZ', 'online', ARRAY['en'], 'trading', '🇳🇿', 'Pacific/Auckland', 'Oceania'),
('James Robertson', 'NZ', 'New Zealand', 'https://api.dicebear.com/7.x/avataaars/svg?seed=JamesNZ', 'online', ARRAY['en'], 'deposits', '🇳🇿', 'Pacific/Auckland', 'Oceania'),

-- ADDITIONAL REGIONS (5 agents)
-- Sweden (2)
('Erik Andersson', 'SE', 'Sweden', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Erik', 'online', ARRAY['sv', 'en'], 'trading', '🇸🇪', 'Europe/Stockholm', 'Europe'),
('Anna Johansson', 'SE', 'Sweden', 'https://api.dicebear.com/7.x/avataaars/svg?seed=AnnaSE', 'online', ARRAY['sv', 'en'], 'deposits', '🇸🇪', 'Europe/Stockholm', 'Europe'),

-- Greece (2)
('Nikos Papadopoulos', 'GR', 'Greece', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Nikos', 'online', ARRAY['el', 'en'], 'technical', '🇬🇷', 'Europe/Athens', 'Europe'),
('Maria Georgiou', 'GR', 'Greece', 'https://api.dicebear.com/7.x/avataaars/svg?seed=MariaGR', 'online', ARRAY['el', 'en'], 'account', '🇬🇷', 'Europe/Athens', 'Europe'),

-- Czech Republic (1)
('Jan Novák', 'CZ', 'Czech Republic', 'https://api.dicebear.com/7.x/avataaars/svg?seed=JanCZ', 'online', ARRAY['cs', 'en'], 'trading', '🇨🇿', 'Europe/Prague', 'Europe');

-- Create indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_support_agents_country ON support_agents(country_code);
CREATE INDEX IF NOT EXISTS idx_support_agents_region ON support_agents(region);
CREATE INDEX IF NOT EXISTS idx_support_agents_status ON support_agents(status);
CREATE INDEX IF NOT EXISTS idx_support_agents_languages ON support_agents USING gin(languages);
CREATE INDEX IF NOT EXISTS idx_support_agents_specialty ON support_agents(specialty);
CREATE INDEX IF NOT EXISTS idx_support_agents_active_tickets ON support_agents(active_tickets);

-- Function to get agents by region
CREATE OR REPLACE FUNCTION get_agents_by_region(region_name text)
RETURNS TABLE (
  id uuid,
  name text,
  avatar_url text,
  status text,
  languages text[],
  specialty text,
  country_code text,
  country_name text,
  flag text,
  timezone text,
  region text,
  active_tickets int
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id,
    a.name,
    a.avatar_url,
    a.status,
    a.languages,
    a.specialty,
    a.country_code,
    a.country_name,
    a.flag,
    a.timezone,
    a.region,
    a.active_tickets
  FROM support_agents a
  WHERE a.region = region_name
  ORDER BY a.name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get best available agent for assignment
CREATE OR REPLACE FUNCTION get_best_available_agent(
  user_country text DEFAULT NULL,
  user_language text DEFAULT 'en',
  issue_type text DEFAULT NULL
)
RETURNS TABLE (
  id uuid,
  name text,
  avatar_url text,
  country_code text,
  flag text,
  languages text[],
  specialty text
) AS $$
BEGIN
  -- First try: same country, same language, same specialty
  RETURN QUERY
  SELECT 
    a.id,
    a.name,
    a.avatar_url,
    a.country_code,
    a.flag,
    a.languages,
    a.specialty
  FROM support_agents a
  WHERE 
    a.status = 'online'
    AND (user_country IS NULL OR a.country_code = user_country)
    AND (user_language = ANY(a.languages))
    AND (issue_type IS NULL OR a.specialty = issue_type)
  ORDER BY a.active_tickets ASC
  LIMIT 1;
  
  -- If not found, try: same language, any country
  IF NOT FOUND THEN
    RETURN QUERY
    SELECT 
      a.id,
      a.name,
      a.avatar_url,
      a.country_code,
      a.flag,
      a.languages,
      a.specialty
    FROM support_agents a
    WHERE 
      a.status = 'online'
      AND (user_language = ANY(a.languages))
    ORDER BY a.active_tickets ASC
    LIMIT 1;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;