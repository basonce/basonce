/*
  # Fix EarnQuest Logo URL
  
  1. Changes
    - Update EarnQuest (EQ) logo URL to correct file path
    
  2. Notes
    - Changes logo from old path to /earnquest-logo-icon-2.png
*/

UPDATE supported_coins 
SET logo_url = '/earnquest-logo-icon-2.png' 
WHERE symbol = 'EQ';