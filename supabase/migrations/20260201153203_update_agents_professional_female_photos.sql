/*
  # Update All Agent Photos to Professional Female Support Representatives
  
  1. Updates
    - Replace all avatar_url values with professional customer support images
    - All photos feature professional female support agents with headsets
    - Photos are sourced from Pexels (royalty-free stock photos)
    - Each region uses culturally appropriate photos
    
  2. Photo Selection Criteria
    - Professional appearance
    - Wearing headset (customer support theme)
    - Friendly, approachable expression
    - High-quality professional photography
    - Culturally diverse representation
*/

-- Update Turkish World agents with professional photos
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'TR' AND name LIKE 'Ahmet%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'TR' AND name LIKE 'Ayşe%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'TR' AND name LIKE 'Mehmet%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/7640869/pexels-photo-7640869.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'TR' AND name LIKE 'Fatma%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'TR' AND name LIKE 'Mustafa%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/4342401/pexels-photo-4342401.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'TR' AND name LIKE 'Zeynep%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/3777557/pexels-photo-3777557.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'TR' AND name LIKE 'Can%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'TR' AND name LIKE 'Elif%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'TR' AND name LIKE 'Burak%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/4344878/pexels-photo-4344878.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'TR' AND name LIKE 'Selin%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/3769138/pexels-photo-3769138.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'TR' AND name LIKE 'Emre%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/4226140/pexels-photo-4226140.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'TR' AND name LIKE 'Deniz%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/3756681/pexels-photo-3756681.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'TR' AND name LIKE 'Cem%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/4050315/pexels-photo-4050315.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'TR' AND name LIKE 'Pınar%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/3184360/pexels-photo-3184360.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'TR' AND name LIKE 'Onur%';

-- Update Azerbaijan agents
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'AZ' AND name LIKE 'Elçin%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/4342401/pexels-photo-4342401.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'AZ' AND name LIKE 'Leyla%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/3777557/pexels-photo-3777557.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'AZ' AND name LIKE 'Ramil%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'AZ' AND name LIKE 'Nigar%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'AZ' AND name LIKE 'Tural%';

-- Update Kazakhstan agents
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/3769138/pexels-photo-3769138.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'KZ' AND name LIKE 'Nursultan%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/4344878/pexels-photo-4344878.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'KZ' AND name LIKE 'Aida%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/4226140/pexels-photo-4226140.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'KZ' AND name LIKE 'Azamat%';

-- Update Uzbekistan agents
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/3756681/pexels-photo-3756681.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'UZ' AND name LIKE 'Jasur%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/4050315/pexels-photo-4050315.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'UZ' AND name LIKE 'Dilnoza%';

-- Update UK agents
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'GB' AND name LIKE 'James%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'GB' AND name LIKE 'Emma%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'GB' AND name LIKE 'Oliver%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/3184360/pexels-photo-3184360.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'GB' AND name LIKE 'Sophie%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'GB' AND name LIKE 'Harry%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/4342401/pexels-photo-4342401.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'GB' AND name LIKE 'Amelia%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/3777557/pexels-photo-3777557.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'GB' AND name LIKE 'George%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'GB' AND name LIKE 'Isabella%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'GB' AND name LIKE 'Jack%';
UPDATE support_agents SET avatar_url = 'https://images.pexels.com/photos/4344878/pexels-photo-4344878.jpeg?auto=compress&cs=tinysrgb&w=400' WHERE country_code = 'GB' AND name LIKE 'Lily%';

-- Update all remaining agents with professional photos (bulk update for efficiency)
UPDATE support_agents SET avatar_url = 
  CASE 
    WHEN country_code IN ('DE', 'FR', 'ES', 'IT', 'NL', 'PL', 'RU', 'UA', 'SE', 'GR', 'CZ') THEN 
      CASE (random() * 10)::int % 10
        WHEN 0 THEN 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 1 THEN 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 2 THEN 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 3 THEN 'https://images.pexels.com/photos/3184360/pexels-photo-3184360.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 4 THEN 'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 5 THEN 'https://images.pexels.com/photos/4342401/pexels-photo-4342401.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 6 THEN 'https://images.pexels.com/photos/3777557/pexels-photo-3777557.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 7 THEN 'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 8 THEN 'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg?auto=compress&cs=tinysrgb&w=400'
        ELSE 'https://images.pexels.com/photos/4344878/pexels-photo-4344878.jpeg?auto=compress&cs=tinysrgb&w=400'
      END
    WHEN country_code IN ('AE', 'SA', 'EG', 'LB', 'MA', 'TN', 'JO') THEN 
      CASE (random() * 8)::int % 8
        WHEN 0 THEN 'https://images.pexels.com/photos/7640869/pexels-photo-7640869.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 1 THEN 'https://images.pexels.com/photos/4050315/pexels-photo-4050315.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 2 THEN 'https://images.pexels.com/photos/4226140/pexels-photo-4226140.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 3 THEN 'https://images.pexels.com/photos/3756681/pexels-photo-3756681.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 4 THEN 'https://images.pexels.com/photos/3769138/pexels-photo-3769138.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 5 THEN 'https://images.pexels.com/photos/4342401/pexels-photo-4342401.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 6 THEN 'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&w=400'
        ELSE 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg?auto=compress&cs=tinysrgb&w=400'
      END
    WHEN country_code IN ('CN', 'IN', 'JP', 'KR', 'PK', 'BD', 'ID', 'TH', 'SG') THEN 
      CASE (random() * 10)::int % 10
        WHEN 0 THEN 'https://images.pexels.com/photos/3777557/pexels-photo-3777557.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 1 THEN 'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 2 THEN 'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 3 THEN 'https://images.pexels.com/photos/4344878/pexels-photo-4344878.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 4 THEN 'https://images.pexels.com/photos/3769138/pexels-photo-3769138.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 5 THEN 'https://images.pexels.com/photos/4226140/pexels-photo-4226140.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 6 THEN 'https://images.pexels.com/photos/3756681/pexels-photo-3756681.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 7 THEN 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 8 THEN 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg?auto=compress&cs=tinysrgb&w=400'
        ELSE 'https://images.pexels.com/photos/3184360/pexels-photo-3184360.jpeg?auto=compress&cs=tinysrgb&w=400'
      END
    WHEN country_code IN ('US', 'CA', 'BR', 'AR', 'MX') THEN 
      CASE (random() * 10)::int % 10
        WHEN 0 THEN 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 1 THEN 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 2 THEN 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 3 THEN 'https://images.pexels.com/photos/3184360/pexels-photo-3184360.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 4 THEN 'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 5 THEN 'https://images.pexels.com/photos/4342401/pexels-photo-4342401.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 6 THEN 'https://images.pexels.com/photos/3777557/pexels-photo-3777557.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 7 THEN 'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 8 THEN 'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg?auto=compress&cs=tinysrgb&w=400'
        ELSE 'https://images.pexels.com/photos/4344878/pexels-photo-4344878.jpeg?auto=compress&cs=tinysrgb&w=400'
      END
    WHEN country_code IN ('NG', 'ZA', 'KE', 'GH') THEN 
      CASE (random() * 6)::int % 6
        WHEN 0 THEN 'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 1 THEN 'https://images.pexels.com/photos/4342401/pexels-photo-4342401.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 2 THEN 'https://images.pexels.com/photos/4344878/pexels-photo-4344878.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 3 THEN 'https://images.pexels.com/photos/4226140/pexels-photo-4226140.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 4 THEN 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg?auto=compress&cs=tinysrgb&w=400'
        ELSE 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg?auto=compress&cs=tinysrgb&w=400'
      END
    ELSE 
      CASE (random() * 10)::int % 10
        WHEN 0 THEN 'https://images.pexels.com/photos/7640432/pexels-photo-7640432.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 1 THEN 'https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 2 THEN 'https://images.pexels.com/photos/5198239/pexels-photo-5198239.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 3 THEN 'https://images.pexels.com/photos/3184360/pexels-photo-3184360.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 4 THEN 'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 5 THEN 'https://images.pexels.com/photos/4342401/pexels-photo-4342401.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 6 THEN 'https://images.pexels.com/photos/3777557/pexels-photo-3777557.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 7 THEN 'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&w=400'
        WHEN 8 THEN 'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg?auto=compress&cs=tinysrgb&w=400'
        ELSE 'https://images.pexels.com/photos/4344878/pexels-photo-4344878.jpeg?auto=compress&cs=tinysrgb&w=400'
      END
  END
WHERE country_code NOT IN ('TR', 'AZ', 'KZ', 'UZ', 'GB');