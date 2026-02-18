/*
  # Reset Support Agents with Professional Customer Service Photos
  
  1. Purpose
    - Delete ALL existing support agents
    - Create new agents with professional female customer service photos
    - All photos show women with headsets in professional business attire
    - Each agent has unique appearance - no duplicates
    - Professional, friendly, approachable appearance
  
  2. Photo Style
    - Professional customer service representatives
    - All wearing headsets
    - Business attire (white shirts, blazers, professional clothing)
    - Friendly smiles and welcoming expressions
    - Office environment backgrounds
    - High-quality professional photography
    
  3. Quality Standards
    - Diverse appearances - different hair colors, styles, ages
    - Professional lighting and composition
    - Clear, high-resolution images
    - Customer service themed
*/

-- First, remove all agent assignments from support tickets
UPDATE support_tickets SET assigned_agent_id = NULL WHERE assigned_agent_id IS NOT NULL;

-- Delete all existing support agents
DELETE FROM support_agents;

-- Insert new professional support agents with unique photos
-- Each agent has a distinct appearance matching reference images

-- Agent 1: Glasses, brown hair, white shirt, headset
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Emma Wilson', 'US', 'United States', 
'https://images.pexels.com/photos/7640869/pexels-photo-7640869.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['English', 'Spanish'], 'account', 0, 'us', 'America/New_York', 'Americas', 'en', '🇺🇸');

-- Agent 2: Brunette, friendly smile, light shirt, headset
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Sofia Martinez', 'ES', 'Spain', 
'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['Spanish', 'English'], 'trading', 0, 'es', 'Europe/Madrid', 'Europe', 'es', '🇪🇸');

-- Agent 3: Long wavy brown hair, white shirt, headset
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Isabella Garcia', 'MX', 'Mexico', 
'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['Spanish', 'English'], 'deposits', 0, 'mx', 'America/Mexico_City', 'Americas', 'es', '🇲🇽');

-- Agent 4: Blonde, professional blazer, headset
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Anna Schmidt', 'DE', 'Germany', 
'https://images.pexels.com/photos/4342401/pexels-photo-4342401.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['German', 'English'], 'technical', 0, 'de', 'Europe/Berlin', 'Europe', 'de', '🇩🇪');

-- Agent 5: Dark hair, professional attire, headset
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Maria Rossi', 'IT', 'Italy', 
'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['Italian', 'English'], 'trading', 0, 'it', 'Europe/Rome', 'Europe', 'it', '🇮🇹');

-- Agent 6: Red hair, white blouse, headset
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Olivia Brown', 'GB', 'United Kingdom', 
'https://images.pexels.com/photos/4344878/pexels-photo-4344878.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['English'], 'account', 0, 'gb', 'Europe/London', 'Europe', 'en', '🇬🇧');

-- Agent 7: Professional, dark blazer, headset
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Li Wei', 'CN', 'China', 
'https://images.pexels.com/photos/4226140/pexels-photo-4226140.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['Chinese', 'English'], 'deposits', 0, 'cn', 'Asia/Shanghai', 'Asia', 'zh', '🇨🇳');

-- Agent 8: Friendly smile, light top, headset
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Sarah Johnson', 'CA', 'Canada', 
'https://images.pexels.com/photos/4050315/pexels-photo-4050315.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['English', 'French'], 'technical', 0, 'ca', 'America/Toronto', 'Americas', 'en', '🇨🇦');

-- Agent 9: Professional, office background, headset
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Priya Sharma', 'IN', 'India', 
'https://images.pexels.com/photos/3184360/pexels-photo-3184360.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['Hindi', 'English'], 'trading', 0, 'in', 'Asia/Kolkata', 'Asia', 'hi', '🇮🇳');

-- Agent 10: Young, professional smile, headset
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Yuki Tanaka', 'JP', 'Japan', 
'https://images.pexels.com/photos/7640735/pexels-photo-7640735.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['Japanese', 'English'], 'account', 0, 'jp', 'Asia/Tokyo', 'Asia', 'ja', '🇯🇵');

-- Agent 11: Professional attire, office setting, headset
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Fatima Hassan', 'AE', 'United Arab Emirates', 
'https://images.pexels.com/photos/4050287/pexels-photo-4050287.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['Arabic', 'English'], 'deposits', 0, 'ae', 'Asia/Dubai', 'Middle East', 'ar', '🇦🇪');

-- Agent 12: White blouse, friendly, headset
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Charlotte Davis', 'FR', 'France', 
'https://images.pexels.com/photos/5623715/pexels-photo-5623715.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['French', 'English'], 'technical', 0, 'fr', 'Europe/Paris', 'Europe', 'fr', '🇫🇷');

-- Agent 13: Professional, customer service, headset
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Nina Kowalski', 'PL', 'Poland', 
'https://images.pexels.com/photos/3769138/pexels-photo-3769138.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['Polish', 'English'], 'trading', 0, 'pl', 'Europe/Warsaw', 'Europe', 'pl', '🇵🇱');

-- Agent 14: Professional blazer, office, headset
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Aisha Mohammed', 'SA', 'Saudi Arabia', 
'https://images.pexels.com/photos/4342403/pexels-photo-4342403.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['Arabic', 'English', 'French'], 'account', 0, 'sa', 'Asia/Riyadh', 'Middle East', 'ar', '🇸🇦');

-- Agent 15: Professional, customer service, headset
INSERT INTO support_agents (name, country_code, country_name, avatar_url, status, languages, specialty, active_tickets, flag, timezone, region, language_code, flag_emoji)
VALUES ('Jessica Lee', 'KR', 'South Korea', 
'https://images.pexels.com/photos/7640729/pexels-photo-7640729.jpeg?auto=compress&cs=tinysrgb&w=800', 
'online', ARRAY['Korean', 'English'], 'deposits', 0, 'kr', 'Asia/Seoul', 'Asia', 'ko', '🇰🇷');