/*
  # Add Turkish Support Agents
  
  1. Purpose
    - Add professional Turkish customer service representatives
    - Ensure Turkish users get Turkish-speaking agents
    - All agents match the professional customer service photo style
    - Headsets, professional attire, friendly expressions
  
  2. Turkish Agents
    - 5 professional Turkish female customer service representatives
    - Each with unique appearance
    - Professional photos with headsets
    - Turkish language support
*/

-- Add Turkish Support Agents with Professional Photos

-- Turkish Agent 1: Professional with glasses and headset
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Ayşe Yılmaz', 'TR', 'Turkey', 
'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['Turkish', 'English'], 'account', 0, 'tr', 'Europe/Istanbul', 'Middle East', 'tr', '🇹🇷');

-- Turkish Agent 2: Brunette with professional smile
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Zeynep Demir', 'TR', 'Turkey', 
'https://images.pexels.com/photos/7640869/pexels-photo-7640869.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['Turkish', 'English'], 'trading', 0, 'tr', 'Europe/Istanbul', 'Middle East', 'tr', '🇹🇷');

-- Turkish Agent 3: Blonde with professional blazer
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Elif Kaya', 'TR', 'Turkey', 
'https://images.pexels.com/photos/4342401/pexels-photo-4342401.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['Turkish', 'English'], 'deposits', 0, 'tr', 'Europe/Istanbul', 'Middle East', 'tr', '🇹🇷');

-- Turkish Agent 4: Professional with friendly smile
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Selin Arslan', 'TR', 'Turkey', 
'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['Turkish', 'English'], 'technical', 0, 'tr', 'Europe/Istanbul', 'Middle East', 'tr', '🇹🇷');

-- Turkish Agent 5: Long wavy hair, professional attire
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Merve Özdemir', 'TR', 'Turkey', 
'https://images.pexels.com/photos/4050315/pexels-photo-4050315.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['Turkish', 'English'], 'trading', 0, 'tr', 'Europe/Istanbul', 'Middle East', 'tr', '🇹🇷');