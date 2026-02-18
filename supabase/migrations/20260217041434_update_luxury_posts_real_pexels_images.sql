/*
  # Update Luxury Posts with Real Pexels Images

  ## Overview
  Replaces all /ber*.jpg support agent photos with REAL Pexels stock photos:
  - Luxury cars: Lamborghini, Ferrari, Mercedes, BMW, Porsche
  - Cash money: Dollar stacks, briefcase cash, bundles
  - Luxury lifestyle: Yachts, pools, watches, villas
  
  ## Image Pairs
  - image_url (left): Cash/money/withdrawal proof
  - image_url_2 (right): Luxury car/yacht/watch/villa
  
  ## Changes
  - Updates image_url and image_url_2 for all luxury posts
  - Uses verified Pexels photo URLs
*/

-- Create temp table with image pairs
CREATE TEMP TABLE luxury_images (
  idx serial,
  img1 text,
  img2 text
);

INSERT INTO luxury_images (img1, img2) VALUES
  ('https://images.pexels.com/photos/4386469/pexels-photo-4386469.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554818/pexels-photo-13554818.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/259027/pexels-photo-259027.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248975/pexels-photo-13248975.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4038853/pexels-photo-4038853.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655998/pexels-photo-14655998.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248972/pexels-photo-13248972.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/6266699/pexels-photo-6266699.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248974/pexels-photo-13248974.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/26668817/pexels-photo-26668817.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248973/pexels-photo-13248973.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655997/pexels-photo-14655997.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554824/pexels-photo-13554824.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4386469/pexels-photo-4386469.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/259027/pexels-photo-259027.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554823/pexels-photo-13554823.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4038853/pexels-photo-4038853.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248970/pexels-photo-13248970.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655998/pexels-photo-14655998.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248971/pexels-photo-13248971.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/6266699/pexels-photo-6266699.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554820/pexels-photo-13554820.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/26668817/pexels-photo-26668817.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/33987617/pexels-photo-33987617.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655997/pexels-photo-14655997.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/31145380/pexels-photo-31145380.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4386469/pexels-photo-4386469.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554944/pexels-photo-13554944.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/259027/pexels-photo-259027.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554825/pexels-photo-13554825.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4038853/pexels-photo-4038853.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655998/pexels-photo-14655998.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13555231/pexels-photo-13555231.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/6266699/pexels-photo-6266699.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/33987626/pexels-photo-33987626.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/26668817/pexels-photo-26668817.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/18362446/pexels-photo-18362446.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655997/pexels-photo-14655997.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4386469/pexels-photo-4386469.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/31145367/pexels-photo-31145367.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/259027/pexels-photo-259027.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/33987740/pexels-photo-33987740.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4038853/pexels-photo-4038853.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/18362445/pexels-photo-18362445.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655998/pexels-photo-14655998.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/10563217/pexels-photo-10563217.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/6266699/pexels-photo-6266699.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/17855875/pexels-photo-17855875.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/26668817/pexels-photo-26668817.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554818/pexels-photo-13554818.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655997/pexels-photo-14655997.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248975/pexels-photo-13248975.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4386469/pexels-photo-4386469.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/259027/pexels-photo-259027.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/7546605/pexels-photo-7546605.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4038853/pexels-photo-4038853.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/35463236/pexels-photo-35463236.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655998/pexels-photo-14655998.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248972/pexels-photo-13248972.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/6266699/pexels-photo-6266699.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248974/pexels-photo-13248974.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/26668817/pexels-photo-26668817.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248973/pexels-photo-13248973.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655997/pexels-photo-14655997.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554824/pexels-photo-13554824.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4386469/pexels-photo-4386469.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/259027/pexels-photo-259027.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554823/pexels-photo-13554823.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4038853/pexels-photo-4038853.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248970/pexels-photo-13248970.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655998/pexels-photo-14655998.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248971/pexels-photo-13248971.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/6266699/pexels-photo-6266699.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554820/pexels-photo-13554820.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/26668817/pexels-photo-26668817.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/33987617/pexels-photo-33987617.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655997/pexels-photo-14655997.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/31145380/pexels-photo-31145380.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4386469/pexels-photo-4386469.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554944/pexels-photo-13554944.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/259027/pexels-photo-259027.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554825/pexels-photo-13554825.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4038853/pexels-photo-4038853.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655998/pexels-photo-14655998.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13555231/pexels-photo-13555231.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/6266699/pexels-photo-6266699.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/33987626/pexels-photo-33987626.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/26668817/pexels-photo-26668817.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/18362446/pexels-photo-18362446.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655997/pexels-photo-14655997.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4386469/pexels-photo-4386469.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/31145367/pexels-photo-31145367.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/259027/pexels-photo-259027.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/33987740/pexels-photo-33987740.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4038853/pexels-photo-4038853.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/18362445/pexels-photo-18362445.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655998/pexels-photo-14655998.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/10563217/pexels-photo-10563217.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/6266699/pexels-photo-6266699.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/17855875/pexels-photo-17855875.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/26668817/pexels-photo-26668817.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554818/pexels-photo-13554818.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655997/pexels-photo-14655997.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248975/pexels-photo-13248975.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4386469/pexels-photo-4386469.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/259027/pexels-photo-259027.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/7546605/pexels-photo-7546605.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4038853/pexels-photo-4038853.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/35463236/pexels-photo-35463236.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655998/pexels-photo-14655998.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248972/pexels-photo-13248972.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/6266699/pexels-photo-6266699.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248974/pexels-photo-13248974.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/26668817/pexels-photo-26668817.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248973/pexels-photo-13248973.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655997/pexels-photo-14655997.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554824/pexels-photo-13554824.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4386469/pexels-photo-4386469.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/259027/pexels-photo-259027.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554823/pexels-photo-13554823.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4038853/pexels-photo-4038853.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248970/pexels-photo-13248970.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655998/pexels-photo-14655998.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13248971/pexels-photo-13248971.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/6266699/pexels-photo-6266699.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554820/pexels-photo-13554820.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/26668817/pexels-photo-26668817.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/33987617/pexels-photo-33987617.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655997/pexels-photo-14655997.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/31145380/pexels-photo-31145380.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4386469/pexels-photo-4386469.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554944/pexels-photo-13554944.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/259027/pexels-photo-259027.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554825/pexels-photo-13554825.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4038853/pexels-photo-4038853.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655998/pexels-photo-14655998.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13555231/pexels-photo-13555231.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/6266699/pexels-photo-6266699.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/33987626/pexels-photo-33987626.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/26668817/pexels-photo-26668817.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/18362446/pexels-photo-18362446.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/14655997/pexels-photo-14655997.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4386469/pexels-photo-4386469.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/31145367/pexels-photo-31145367.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/259027/pexels-photo-259027.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/33987740/pexels-photo-33987740.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ('https://images.pexels.com/photos/4038853/pexels-photo-4038853.jpeg?auto=compress&cs=tinysrgb&w=600', 'https://images.pexels.com/photos/18362445/pexels-photo-18362445.jpeg?auto=compress&cs=tinysrgb&w=600');

-- Update luxury posts with real Pexels images
DO $$
DECLARE
  luxury_row RECORD;
  img_row RECORD;
  counter integer := 1;
BEGIN
  FOR luxury_row IN (
    SELECT id FROM social_posts WHERE post_type = 'luxury' ORDER BY created_at
  ) LOOP
    SELECT img1, img2 INTO img_row FROM luxury_images WHERE idx = counter;
    
    IF img_row IS NOT NULL THEN
      UPDATE social_posts 
      SET image_url = img_row.img1, image_url_2 = img_row.img2 
      WHERE id = luxury_row.id;
    END IF;
    
    counter := counter + 1;
    IF counter > 80 THEN counter := 1; END IF;
  END LOOP;
END $$;

DROP TABLE luxury_images;