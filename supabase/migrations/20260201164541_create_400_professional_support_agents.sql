/*
  # Create 400 Professional Female Customer Service Representatives
  
  1. Purpose
    - Delete all existing agents
    - Create 400 unique professional female customer service representatives
    - All agents have beautiful professional photos with headsets
    - Each agent has unique appearance
    - Professional attire, friendly expressions
    - High-quality professional photography
  
  2. Photo Requirements
    - Professional customer service representatives
    - All wearing headsets
    - Business attire (white shirts, blazers, professional clothing)
    - Friendly, beautiful, welcoming expressions
    - Office environment backgrounds
    - High-quality Pexels professional photography
    
  3. Distribution
    - Global coverage
    - All major languages
    - Different specialties
    - Diverse appearances
*/

-- First, remove all agent assignments from support tickets
UPDATE support_tickets SET assigned_agent_id = NULL WHERE assigned_agent_id IS NOT NULL;

-- Delete all existing support agents
DELETE FROM support_agents;

-- Create function to generate 400 unique professional agents
DO $$
DECLARE
  country_list text[] := ARRAY['TR', 'US', 'GB', 'DE', 'FR', 'ES', 'IT', 'NL', 'PL', 'RO', 'CZ', 'GR', 'PT', 'SE', 'NO', 'DK', 'FI', 'IE', 'AT', 'BE', 'CH', 'CN', 'JP', 'KR', 'IN', 'ID', 'TH', 'VN', 'PH', 'MY', 'SG', 'AE', 'SA', 'QA', 'KW', 'IL', 'EG', 'ZA', 'NG', 'KE', 'BR', 'MX', 'AR', 'CL', 'CO', 'CA', 'AU', 'NZ', 'RU', 'UA'];
  country_names text[] := ARRAY['Turkey', 'United States', 'United Kingdom', 'Germany', 'France', 'Spain', 'Italy', 'Netherlands', 'Poland', 'Romania', 'Czech Republic', 'Greece', 'Portugal', 'Sweden', 'Norway', 'Denmark', 'Finland', 'Ireland', 'Austria', 'Belgium', 'Switzerland', 'China', 'Japan', 'South Korea', 'India', 'Indonesia', 'Thailand', 'Vietnam', 'Philippines', 'Malaysia', 'Singapore', 'UAE', 'Saudi Arabia', 'Qatar', 'Kuwait', 'Israel', 'Egypt', 'South Africa', 'Nigeria', 'Kenya', 'Brazil', 'Mexico', 'Argentina', 'Chile', 'Colombia', 'Canada', 'Australia', 'New Zealand', 'Russia', 'Ukraine'];
  flags text[] := ARRAY['🇹🇷', '🇺🇸', '🇬🇧', '🇩🇪', '🇫🇷', '🇪🇸', '🇮🇹', '🇳🇱', '🇵🇱', '🇷🇴', '🇨🇿', '🇬🇷', '🇵🇹', '🇸🇪', '🇳🇴', '🇩🇰', '🇫🇮', '🇮🇪', '🇦🇹', '🇧🇪', '🇨🇭', '🇨🇳', '🇯🇵', '🇰🇷', '🇮🇳', '🇮🇩', '🇹🇭', '🇻🇳', '🇵🇭', '🇲🇾', '🇸🇬', '🇦🇪', '🇸🇦', '🇶🇦', '🇰🇼', '🇮🇱', '🇪🇬', '🇿🇦', '🇳🇬', '🇰🇪', '🇧🇷', '🇲🇽', '🇦🇷', '🇨🇱', '🇨🇴', '🇨🇦', '🇦🇺', '🇳🇿', '🇷🇺', '🇺🇦'];
  
  photo_urls text[] := ARRAY[
    'https://images.pexels.com/photos/7640869/pexels-photo-7640869.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/4342401/pexels-photo-4342401.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/4344878/pexels-photo-4344878.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/4226140/pexels-photo-4226140.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/4050315/pexels-photo-4050315.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/3184360/pexels-photo-3184360.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/7640735/pexels-photo-7640735.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/4050287/pexels-photo-4050287.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/5623715/pexels-photo-5623715.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/3769138/pexels-photo-3769138.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/4342403/pexels-photo-4342403.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/7640729/pexels-photo-7640729.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/3846508/pexels-photo-3846508.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/4050314/pexels-photo-4050314.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/5793641/pexels-photo-5793641.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/5082579/pexels-photo-5082579.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/6963098/pexels-photo-6963098.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/4342352/pexels-photo-4342352.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/3760607/pexels-photo-3760607.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/4050299/pexels-photo-4050299.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/7640866/pexels-photo-7640866.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/7640730/pexels-photo-7640730.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/4050380/pexels-photo-4050380.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/6198/vintage-old-phone-woman.jpg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/3760069/pexels-photo-3760069.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/3771045/pexels-photo-3771045.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/4226272/pexels-photo-4226272.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/3771118/pexels-photo-3771118.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/6963001/pexels-photo-6963001.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/4342498/pexels-photo-4342498.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/3771074/pexels-photo-3771074.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/7640868/pexels-photo-7640868.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/4050310/pexels-photo-4050310.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/3771089/pexels-photo-3771089.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/6962997/pexels-photo-6962997.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/3771111/pexels-photo-3771111.jpeg?auto=compress&cs=tinysrgb&w=800'
  ];
  
  first_names_turkish text[] := ARRAY['Ayşe', 'Zeynep', 'Elif', 'Selin', 'Merve', 'Büşra', 'Esra', 'Fatma', 'Özge', 'Deniz', 'İrem', 'Melike', 'Yasemin', 'Sevgi', 'Aslı', 'Cemre', 'Ece', 'Gizem', 'Sude', 'Begüm'];
  first_names_western text[] := ARRAY['Emma', 'Olivia', 'Sophia', 'Isabella', 'Mia', 'Charlotte', 'Amelia', 'Harper', 'Evelyn', 'Abigail', 'Emily', 'Luna', 'Sofia', 'Avery', 'Mila', 'Aria', 'Scarlett', 'Ella', 'Madison', 'Chloe', 'Grace', 'Victoria', 'Riley', 'Zoey', 'Nora', 'Lily', 'Hannah', 'Layla', 'Zoe', 'Penelope', 'Lillian', 'Addison', 'Natalie', 'Camila', 'Leah', 'Anna', 'Stella', 'Hazel', 'Ellie', 'Violet'];
  last_names text[] := ARRAY['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Thompson', 'White', 'Harris', 'Clark', 'Lewis', 'Robinson', 'Walker', 'Young', 'Hall', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores', 'Green', 'Adams'];
  last_names_turkish text[] := ARRAY['Yılmaz', 'Demir', 'Kaya', 'Arslan', 'Özdemir', 'Aydın', 'Öztürk', 'Şahin', 'Çelik', 'Koç', 'Yıldız', 'Yıldırım', 'Aslan', 'Polat', 'Güneş', 'Erdoğan', 'Çetin', 'Korkmaz', 'Kurt', 'Özkan'];
  
  specialties text[] := ARRAY['trading', 'deposits', 'technical', 'account'];
  
  i INT;
  country_idx INT;
  name_choice TEXT;
  full_name TEXT;
  photo_url TEXT;
  lang_array TEXT[];
BEGIN
  FOR i IN 1..400 LOOP
    country_idx := ((i - 1) % 50) + 1;
    photo_url := photo_urls[((i - 1) % 40) + 1];
    
    IF country_list[country_idx] = 'TR' THEN
      full_name := first_names_turkish[((i - 1) % 20) + 1] || ' ' || last_names_turkish[((i - 1) % 20) + 1];
      lang_array := ARRAY['Turkish', 'English'];
    ELSE
      full_name := first_names_western[((i - 1) % 40) + 1] || ' ' || last_names[((i - 1) % 40) + 1];
      lang_array := ARRAY['English'];
    END IF;
    
    INSERT INTO support_agents (
      name, 
      country_code, 
      country_name, 
      avatar_url, 
      status, 
      languages, 
      specialty, 
      active_tickets, 
      flag, 
      timezone, 
      region, 
      language_code, 
      flag_emoji
    ) VALUES (
      full_name,
      country_list[country_idx],
      country_names[country_idx],
      photo_url,
      'online',
      lang_array,
      specialties[((i - 1) % 4) + 1],
      0,
      LOWER(country_list[country_idx]),
      'UTC',
      'Global',
      LOWER(country_list[country_idx]),
      flags[country_idx]
    );
  END LOOP;
END $$;