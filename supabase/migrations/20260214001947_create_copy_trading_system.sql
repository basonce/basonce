/*
  # Create Copy Trading System

  1. New Tables
    - `copy_traders` - 1000 professional copy traders
      - `id` (uuid, primary key)
      - `name` (text) - Trader display name
      - `avatar_url` (text) - Profile photo URL
      - `strategy_type` (text) - Spot Grid, DCA, Futures Grid, etc.
      - `coin_symbol` (text) - Primary traded coin
      - `follower_count` (int) - Current follower count
      - `max_followers` (int) - Maximum allowed followers
      - `pnl_30d` (numeric) - 30-day PnL in USD
      - `roi_30d` (numeric) - 30-day ROI percentage
      - `roi_7d` (numeric) - 7-day ROI percentage
      - `total_pnl` (numeric) - All-time PnL
      - `win_rate` (numeric) - Win rate percentage
      - `runtime_days` (int) - How many days the bot has been running
      - `is_active` (boolean) - Whether trader is active
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on `copy_traders` table
    - Add public read policy for all users
*/

CREATE TABLE IF NOT EXISTS copy_traders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  avatar_url text NOT NULL DEFAULT '',
  strategy_type text NOT NULL DEFAULT 'Spot Grid',
  coin_symbol text NOT NULL DEFAULT 'BTC',
  follower_count int NOT NULL DEFAULT 0,
  max_followers int NOT NULL DEFAULT 300,
  pnl_30d numeric NOT NULL DEFAULT 0,
  roi_30d numeric NOT NULL DEFAULT 0,
  roi_7d numeric NOT NULL DEFAULT 0,
  total_pnl numeric NOT NULL DEFAULT 0,
  win_rate numeric NOT NULL DEFAULT 0,
  runtime_days int NOT NULL DEFAULT 30,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE copy_traders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view copy traders"
  ON copy_traders
  FOR SELECT
  TO authenticated
  USING (auth.uid() IS NOT NULL);

DO $$
DECLARE
  first_names text[] := ARRAY[
    'Alex','James','Michael','David','Robert','Daniel','William','Thomas','Chris','Ryan',
    'Sarah','Emma','Emily','Jessica','Anna','Rachel','Laura','Kate','Sophie','Megan',
    'Liu Wei','Zhang Min','Wang Lei','Chen Yu','Li Na','Marco','Giovanni','Luca','Alessandro','Francesco',
    'Hans','Klaus','Stefan','Andreas','Martin','Pierre','Jean','Paul','Louis','Henri',
    'Yuki','Kenji','Takeshi','Haruki','Ryo','Maria','Carlos','Pablo','Diego','Elena',
    'Ahmed','Omar','Hassan','Ali','Fatima','Raj','Amit','Priya','Vikram','Sanjay',
    'Patrick','Brian','Sean','Kevin','Connor','Olga','Ivan','Dmitri','Andrei','Sergei',
    'Oscar','Erik','Lars','Nils','Magnus','Ava','Noah','Liam','Ella','Jack',
    'Luna','Felix','Hugo','Leo','Max','Mia','Zoe','Lily','Ruby','Ivy',
    'Axel','Finn','Kai','Theo','Otto','Nina','Vera','Rosa','Clara','Eva'
  ];
  last_names text[] := ARRAY[
    'Smith','Johnson','Williams','Brown','Jones','Miller','Davis','Wilson','Taylor','Anderson',
    'Moore','Thomas','Jackson','White','Harris','Martin','Garcia','Thompson','Robinson','Clark',
    'Lewis','Lee','Walker','Hall','Allen','Young','King','Wright','Hill','Green',
    'Adams','Baker','Carter','Turner','Parker','Evans','Edwards','Collins','Stewart','Morris',
    'Murphy','Kelly','Sullivan','Bennett','Coleman','Rogers','Morgan','Cooper','Reed','Bailey',
    'Bell','Howard','Ward','Torres','Peterson','Gray','Watson','Brooks','Sanders','Price',
    'Fox','Russell','Long','Foster','Butler','Barnes','Fisher','Webb','Stone','Hunt',
    'Black','Knight','Rose','Grant','Wells','Cross','Hart','Palmer','Ellis','Pearson',
    'Dixon','Shaw','West','Wood','Burns','Rice','Scott','Ford','Ray','Dunn',
    'Kim','Park','Choi','Jung','Kang','Yamada','Tanaka','Suzuki','Sato','Watanabe'
  ];
  strategies text[] := ARRAY['Spot Grid', 'Futures Grid', 'DCA Bot', 'Smart Trade', 'Grid Trading', 'Swing Trade'];
  coins text[] := ARRAY[
    'BTC','ETH','BNB','SOL','XRP','ADA','DOGE','AVAX','DOT','MATIC',
    'LINK','UNI','LTC','ATOM','FIL','NEAR','APT','ARB','OP','INJ',
    'TRX','SHIB','PEPE','WIF','FET','RENDER','SUI','SEI','TIA','JUP'
  ];
  i int;
  fname text;
  lname text;
  full_name text;
  avatar text;
  strat text;
  coin text;
  followers int;
  max_f int;
  p30 numeric;
  r30 numeric;
  r7 numeric;
  tp numeric;
  wr numeric;
  rt int;
BEGIN
  FOR i IN 1..1000 LOOP
    fname := first_names[1 + floor(random() * array_length(first_names, 1))::int];
    lname := last_names[1 + floor(random() * array_length(last_names, 1))::int];

    IF random() < 0.15 THEN
      full_name := substr(fname, 1, 1) || '***' || substr(lname, 1, 1);
    ELSIF random() < 0.3 THEN
      full_name := fname || ' ' || substr(lname, 1, 1) || '.';
    ELSE
      full_name := fname || '_' || lname || floor(random() * 99)::text;
    END IF;

    avatar := 'https://i.pravatar.cc/150?img=' || (1 + floor(random() * 70)::int)::text;
    strat := strategies[1 + floor(random() * array_length(strategies, 1))::int];
    coin := coins[1 + floor(random() * array_length(coins, 1))::int];

    max_f := 100 + floor(random() * 400)::int;
    followers := floor(random() * max_f * 0.85)::int;

    p30 := round((50 + random() * 9950)::numeric, 2);
    r30 := round((0.5 + random() * 12)::numeric, 2);
    r7 := round((0.1 + random() * 5)::numeric, 2);
    tp := round((p30 * (1 + random() * 4))::numeric, 2);
    wr := round((55 + random() * 40)::numeric, 1);
    rt := 7 + floor(random() * 350)::int;

    INSERT INTO copy_traders (name, avatar_url, strategy_type, coin_symbol, follower_count, max_followers, pnl_30d, roi_30d, roi_7d, total_pnl, win_rate, runtime_days)
    VALUES (full_name, avatar, strat, coin, followers, max_f, p30, r30, r7, tp, wr, rt);
  END LOOP;
END $$;
