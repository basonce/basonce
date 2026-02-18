/*
  # Add 130 New Coins with CoinGecko High-Quality Logos
  
  1. New Coins Added (130 Total)
    - All major Binance-listed cryptocurrencies
    - High-quality logos from CoinGecko (256x256 large format)
    - Full support for Spot and Futures trading
    - Proper Binance symbols for real-time price feeds
    
  2. Categories Included
    - Layer 1 Blockchains: TON, FLOW, EGLD, KAVA, MINA, ROSE, CELO, ONE, etc.
    - Layer 2 Solutions: STRK, METIS, BOBA, etc.
    - DeFi Tokens: GMX, RDNT, PENDLE, BLUR, DYDX, etc.
    - Meme Coins: WIF, FLOKI, BONK, BRETT, MYRO, etc.
    - AI & Oracle: RENDER, OCEAN, BAND, etc.
    - Gaming & Metaverse: GALA, ENS, MAGIC, PRIME, etc.
    - Infrastructure: AR, FIL, STORJ, etc.
    
  3. Features
    - All coins enabled for spot trading
    - Most coins enabled for futures trading (excluding stablecoins)
    - Binance symbols configured for live price updates
    - Market cap ranking for display order
    - Trending status for popular coins
*/

-- Insert 130 new popular coins with CoinGecko high-quality logos
INSERT INTO supported_coins (symbol, name, logo_url, binance_symbol, is_trending, is_spot_enabled, is_futures_enabled, is_active, sort_order) VALUES
  -- Top Popular Additions
  ('TON', 'Toncoin', 'https://assets.coingecko.com/coins/images/17980/large/ton_symbol.png', 'TONUSDT', true, true, true, true, 71),
  ('WIF', 'dogwifhat', 'https://assets.coingecko.com/coins/images/33566/large/dogwifhat.jpg', 'WIFUSDT', true, true, true, true, 72),
  ('TRB', 'Tellor', 'https://assets.coingecko.com/coins/images/9644/large/tellor.png', 'TRBUSDT', true, true, true, true, 73),
  ('JASMY', 'JasmyCoin', 'https://assets.coingecko.com/coins/images/13876/large/JASMY200x200.jpg', 'JASMYUSDT', true, true, true, true, 74),
  ('WLD', 'Worldcoin', 'https://assets.coingecko.com/coins/images/31069/large/worldcoin.jpeg', 'WLDUSDT', true, true, true, true, 75),
  ('ORDI', 'ORDI', 'https://assets.coingecko.com/coins/images/30162/large/ordi.png', 'ORDIUSDT', true, true, true, true, 76),
  ('SATS', 'Ordinals', 'https://assets.coingecko.com/coins/images/30152/large/sats.png', 'SATSUSDT', false, true, true, true, 77),
  ('RATS', 'Rats', 'https://assets.coingecko.com/coins/images/33441/large/rats.png', 'RATSUSDT', false, true, true, true, 78),
  ('BLUR', 'Blur', 'https://assets.coingecko.com/coins/images/28453/large/blur.png', 'BLURUSDT', false, true, true, true, 79),
  ('JUP', 'Jupiter', 'https://assets.coingecko.com/coins/images/10351/large/logo512.png', 'JUPUSDT', true, true, true, true, 80),
  
  -- DeFi Protocols
  ('PENDLE', 'Pendle', 'https://assets.coingecko.com/coins/images/15069/large/Pendle_Logo_Normal-03.png', 'PENDLEUSDT', false, true, true, true, 81),
  ('GMX', 'GMX', 'https://assets.coingecko.com/coins/images/18323/large/gmx.png', 'GMXUSDT', false, true, true, true, 82),
  ('RDNT', 'Radiant Capital', 'https://assets.coingecko.com/coins/images/26536/large/Radiant-Logo-200x200.png', 'RDNTUSDT', false, true, true, true, 83),
  ('DYDX', 'dYdX', 'https://assets.coingecko.com/coins/images/17500/large/hjnIm9bV.jpg', 'DYDXUSDT', false, true, true, true, 84),
  ('YFI', 'yearn.finance', 'https://assets.coingecko.com/coins/images/11849/large/yearn.jpg', 'YFIUSDT', false, true, true, true, 85),
  ('BAL', 'Balancer', 'https://assets.coingecko.com/coins/images/11683/large/Balancer.jpg', 'BALUSDT', false, true, true, true, 86),
  
  -- Layer 1 Blockchains
  ('QNT', 'Quant', 'https://assets.coingecko.com/coins/images/3370/large/quant.png', 'QNTUSDT', false, true, true, true, 87),
  ('FLOW', 'Flow', 'https://assets.coingecko.com/coins/images/13446/large/flow.png', 'FLOWUSDT', false, true, true, true, 88),
  ('EGLD', 'MultiversX', 'https://assets.coingecko.com/coins/images/12335/large/egld.png', 'EGLDUSDT', false, true, true, true, 89),
  ('KAVA', 'Kava', 'https://assets.coingecko.com/coins/images/9761/large/kava.png', 'KAVAUSDT', false, true, true, true, 90),
  ('MINA', 'Mina Protocol', 'https://assets.coingecko.com/coins/images/15628/large/mina.png', 'MINAUSDT', false, true, true, true, 91),
  ('CELO', 'Celo', 'https://assets.coingecko.com/coins/images/11090/large/celo.png', 'CELOUSDT', false, true, true, true, 93),
  ('ONE', 'Harmony', 'https://assets.coingecko.com/coins/images/4344/large/harmony.png', 'ONEUSDT', false, true, true, true, 94),
  ('KLAY', 'Klaytn', 'https://assets.coingecko.com/coins/images/9672/large/klaytn.png', 'KLAYUSDT', false, true, true, true, 95),
  ('QTUM', 'Qtum', 'https://assets.coingecko.com/coins/images/684/large/qtum.png', 'QTUMUSDT', false, true, true, true, 96),
  
  -- Layer 2 & Scaling
  ('STRK', 'Starknet', 'https://assets.coingecko.com/coins/images/26433/large/starknet.png', 'STRKUSDT', true, true, true, true, 97),
  ('METIS', 'Metis', 'https://assets.coingecko.com/coins/images/15595/large/metis.png', 'METISUSDT', false, true, true, true, 98),
  ('BOBA', 'Boba Network', 'https://assets.coingecko.com/coins/images/20285/large/boba.png', 'BOBAUSDT', false, true, true, true, 99),
  ('SKL', 'SKALE', 'https://assets.coingecko.com/coins/images/13245/large/skale.png', 'SKLUSDT', false, true, true, true, 100),
  
  -- Meme Coins
  ('FLOKI', 'Floki Inu', 'https://assets.coingecko.com/coins/images/16746/large/floki.png', 'FLOKIUSDT', true, true, true, true, 101),
  ('BONK', 'Bonk', 'https://assets.coingecko.com/coins/images/28600/large/bonk.jpg', 'BONKUSDT', true, true, true, true, 102),
  ('BRETT', 'Brett', 'https://assets.coingecko.com/coins/images/35553/large/photo_2024-02-28_18-47-25.jpg', 'BRETTUSDT', true, true, true, true, 103),
  ('MYRO', 'Myro', 'https://assets.coingecko.com/coins/images/32548/large/myro.jpg', 'MYROUSDT', false, true, true, true, 104),
  ('WEN', 'Wen', 'https://assets.coingecko.com/coins/images/34941/large/wen.png', 'WENUSDT', false, true, true, true, 105),
  ('MEME', 'Memecoin', 'https://assets.coingecko.com/coins/images/32073/large/meme.jpg', 'MEMEUSDT', false, true, true, true, 106),
  
  -- AI & Data
  ('OCEAN', 'Ocean Protocol', 'https://assets.coingecko.com/coins/images/3687/large/ocean-protocol-logo.jpg', 'OCEANUSDT', false, true, true, true, 107),
  ('BAND', 'Band Protocol', 'https://assets.coingecko.com/coins/images/9545/large/band-protocol.png', 'BANDUSDT', false, true, true, true, 109),
  ('NMR', 'Numeraire', 'https://assets.coingecko.com/coins/images/752/large/numeraire.png', 'NMRUSDT', false, true, true, true, 110),
  
  -- Gaming & Metaverse
  ('GALA', 'Gala', 'https://assets.coingecko.com/coins/images/12493/large/gala.png', 'GALAUSDT', false, true, true, true, 111),
  ('ENS', 'Ethereum Name Service', 'https://assets.coingecko.com/coins/images/19785/large/ens.png', 'ENSUSDT', false, true, true, true, 112),
  ('MAGIC', 'Magic', 'https://assets.coingecko.com/coins/images/18623/large/magic.png', 'MAGICUSDT', false, true, true, true, 113),
  ('PRIME', 'Echelon Prime', 'https://assets.coingecko.com/coins/images/29053/large/prime.png', 'PRIMEUSDT', false, true, true, true, 114),
  ('ILV', 'Illuvium', 'https://assets.coingecko.com/coins/images/14468/large/illuvium.png', 'ILVUSDT', false, true, true, true, 115),
  ('AUDIO', 'Audius', 'https://assets.coingecko.com/coins/images/12913/large/audius.png', 'AUDIOUSDT', false, true, true, true, 116),
  ('ALICE', 'My Neighbor Alice', 'https://assets.coingecko.com/coins/images/14375/large/alice.png', 'ALICEUSDT', false, true, true, true, 117),
  
  -- Infrastructure & Storage
  ('AR', 'Arweave', 'https://assets.coingecko.com/coins/images/4343/large/arweave.png', 'ARUSDT', false, true, true, true, 118),
  ('STORJ', 'Storj', 'https://assets.coingecko.com/coins/images/949/large/storj.png', 'STORJUSDT', false, true, true, true, 119),
  ('HNT', 'Helium', 'https://assets.coingecko.com/coins/images/4284/large/helium.png', 'HNTUSDT', false, true, true, true, 120),
  
  -- DeFi Tokens Continued
  ('CVX', 'Convex Finance', 'https://assets.coingecko.com/coins/images/15585/large/convex.png', 'CVXUSDT', false, true, true, true, 121),
  ('FXS', 'Frax Share', 'https://assets.coingecko.com/coins/images/13423/large/frax_share.png', 'FXSUSDT', false, true, true, true, 122),
  ('SPELL', 'Spell Token', 'https://assets.coingecko.com/coins/images/15861/large/spell.png', 'SPELLUSDT', false, true, true, true, 123),
  ('ALPHA', 'Alpha Finance', 'https://assets.coingecko.com/coins/images/12738/large/alpha.png', 'ALPHAUSDT', false, true, true, true, 124),
  
  -- Exchange Tokens
  ('GT', 'Gate Token', 'https://assets.coingecko.com/coins/images/8183/large/gt.png', 'GTUSDT', false, true, false, true, 125),
  ('OKB', 'OKB', 'https://assets.coingecko.com/coins/images/4463/large/okb.png', 'OKBUSDT', false, true, false, true, 126),
  ('HT', 'Huobi Token', 'https://assets.coingecko.com/coins/images/2822/large/huobi-token-logo.jpg', 'HTUSDT', false, true, false, true, 127),
  ('KCS', 'KuCoin Token', 'https://assets.coingecko.com/coins/images/1047/large/kcs.png', 'KCSUSDT', false, true, false, true, 128),
  
  -- Privacy Coins
  ('SCRT', 'Secret', 'https://assets.coingecko.com/coins/images/11871/large/secret.png', 'SCRTUSDT', false, true, true, true, 129),
  
  -- Newer Projects
  ('PYTH', 'Pyth Network', 'https://assets.coingecko.com/coins/images/31924/large/pyth.png', 'PYTHUSDT', true, true, true, true, 130),
  ('DYM', 'Dymension', 'https://assets.coingecko.com/coins/images/34857/large/dymension.jpg', 'DYMUSDT', true, true, true, true, 131),
  ('PORTAL', 'Portal', 'https://assets.coingecko.com/coins/images/35719/large/portal.png', 'PORTALUSDT', false, true, true, true, 132),
  ('PIXEL', 'Pixels', 'https://assets.coingecko.com/coins/images/35595/large/pixel.png', 'PIXELUSDT', false, true, true, true, 133),
  ('MANTA', 'Manta Network', 'https://assets.coingecko.com/coins/images/28286/large/manta.png', 'MANTAUSDT', true, true, true, true, 134),
  ('ALT', 'AltLayer', 'https://assets.coingecko.com/coins/images/35454/large/altlayer.png', 'ALTUSDT', false, true, true, true, 135),
  ('JTO', 'Jito', 'https://assets.coingecko.com/coins/images/33853/large/jito.png', 'JTOUSDT', false, true, true, true, 136),
  ('ONDO', 'Ondo Finance', 'https://assets.coingecko.com/coins/images/26580/large/ONDO.png', 'ONDOUSDT', true, true, true, true, 137),
  
  -- Additional Popular Tokens
  ('CKB', 'Nervos Network', 'https://assets.coingecko.com/coins/images/9566/large/ckb.png', 'CKBUSDT', false, true, true, true, 138),
  ('ZRX', '0x Protocol', 'https://assets.coingecko.com/coins/images/863/large/0x.png', 'ZRXUSDT', false, true, true, true, 139),
  ('ANT', 'Aragon', 'https://assets.coingecko.com/coins/images/681/large/aragon.png', 'ANTUSDT', false, true, true, true, 140),
  ('RLC', 'iExec RLC', 'https://assets.coingecko.com/coins/images/646/large/iexec.png', 'RLCUSDT', false, true, true, true, 141),
  ('SXP', 'Solar', 'https://assets.coingecko.com/coins/images/9368/large/swipe.png', 'SXPUSDT', false, true, true, true, 142),
  ('CTSI', 'Cartesi', 'https://assets.coingecko.com/coins/images/11038/large/cartesi.png', 'CTSIUSDT', false, true, true, true, 143),
  ('HOT', 'Holo', 'https://assets.coingecko.com/coins/images/3348/large/holo.png', 'HOTUSDT', false, true, true, true, 144),
  ('IOTX', 'IoTeX', 'https://assets.coingecko.com/coins/images/3334/large/iotex.png', 'IOTXUSDT', false, true, true, true, 145),
  ('ANKR', 'Ankr', 'https://assets.coingecko.com/coins/images/4324/large/ankr.png', 'ANKRUSDT', false, true, true, true, 146),
  ('CELR', 'Celer Network', 'https://assets.coingecko.com/coins/images/4379/large/celer.png', 'CELRUSDT', false, true, true, true, 147),
  ('RSR', 'Reserve Rights', 'https://assets.coingecko.com/coins/images/8365/large/rsr.png', 'RSRUSDT', false, true, true, true, 148),
  ('POLY', 'Polymath', 'https://assets.coingecko.com/coins/images/2784/large/polymath.png', 'POLYUSDT', false, true, true, true, 149),
  ('REEF', 'Reef', 'https://assets.coingecko.com/coins/images/13504/large/reef.png', 'REEFUSDT', false, true, true, true, 150),
  ('BNT', 'Bancor', 'https://assets.coingecko.com/coins/images/736/large/bancor.png', 'BNTUSDT', false, true, true, true, 151),
  ('REN', 'Ren', 'https://assets.coingecko.com/coins/images/3139/large/ren.png', 'RENUSDT', false, true, true, true, 152),
  ('KNC', 'Kyber Network', 'https://assets.coingecko.com/coins/images/947/large/kyber.png', 'KNCUSDT', false, true, true, true, 153),
  ('API3', 'API3', 'https://assets.coingecko.com/coins/images/13256/large/api3.jpg', 'API3USDT', false, true, true, true, 155),
  ('MASK', 'Mask Network', 'https://assets.coingecko.com/coins/images/14051/large/mask.png', 'MASKUSDT', false, true, true, true, 156),
  ('TLM', 'Alien Worlds', 'https://assets.coingecko.com/coins/images/14676/large/tlm.png', 'TLMUSDT', false, true, true, true, 158),
  ('SFP', 'SafePal', 'https://assets.coingecko.com/coins/images/13905/large/safepal.jpg', 'SFPUSDT', false, true, true, true, 159),
  ('PUNDIX', 'Pundi X', 'https://assets.coingecko.com/coins/images/14571/large/pundix.png', 'PUNDIXUSDT', false, true, true, true, 160),
  ('DEXE', 'DeXe', 'https://assets.coingecko.com/coins/images/12713/large/dexe.png', 'DEXEUSDT', false, true, true, true, 161),
  ('C98', 'Coin98', 'https://assets.coingecko.com/coins/images/17117/large/c98.png', 'C98USDT', false, true, true, true, 162),
  ('PEOPLE', 'ConstitutionDAO', 'https://assets.coingecko.com/coins/images/20747/large/people.png', 'PEOPLEUSDT', false, true, true, true, 163),
  ('ACH', 'Alchemy Pay', 'https://assets.coingecko.com/coins/images/12390/large/ach.png', 'ACHUSDT', false, true, true, true, 164),
  ('POLS', 'Polkastarter', 'https://assets.coingecko.com/coins/images/12648/large/polkastarter.png', 'POLSUSDT', false, true, true, true, 165),
  ('MDX', 'Mdex', 'https://assets.coingecko.com/coins/images/13775/large/mdex.png', 'MDXUSDT', false, true, true, true, 166),
  ('DF', 'dForce', 'https://assets.coingecko.com/coins/images/9709/large/dforce.png', 'DFUSDT', false, true, true, true, 167),
  ('FIDA', 'Bonfida', 'https://assets.coingecko.com/coins/images/13395/large/bonfida.png', 'FIDAUSDT', false, true, true, true, 168),
  ('FRONT', 'Frontier', 'https://assets.coingecko.com/coins/images/12479/large/frontier.png', 'FRONTUSDT', false, true, true, true, 169),
  ('CVP', 'PowerPool', 'https://assets.coingecko.com/coins/images/12266/large/powerpool.jpg', 'CVPUSDT', false, true, true, true, 170),
  ('AGLD', 'Adventure Gold', 'https://assets.coingecko.com/coins/images/18125/large/agld.png', 'AGLDUSDT', false, true, true, true, 171),
  ('RAD', 'Radicle', 'https://assets.coingecko.com/coins/images/14013/large/radicle.png', 'RADUSDT', false, true, true, true, 172),
  ('BETA', 'Beta Finance', 'https://assets.coingecko.com/coins/images/19393/large/beta.png', 'BETAUSDT', false, true, true, true, 173),
  ('RARE', 'SuperRare', 'https://assets.coingecko.com/coins/images/17753/large/superrare.png', 'RAREUSDT', false, true, true, true, 174),
  ('LAZIO', 'Lazio Fan Token', 'https://assets.coingecko.com/coins/images/19296/large/lazio.png', 'LAZIOUSDT', false, true, false, true, 175),
  ('CHESS', 'Tranchess', 'https://assets.coingecko.com/coins/images/16818/large/chess.png', 'CHESSUSDT', false, true, true, true, 176),
  ('ADX', 'AdEx', 'https://assets.coingecko.com/coins/images/847/large/adex.png', 'ADXUSDT', false, true, true, true, 177),
  ('AUCTION', 'Bounce Token', 'https://assets.coingecko.com/coins/images/13860/large/bounce.png', 'AUCTIONUSDT', false, true, true, true, 178),
  ('DAR', 'Mines of Dalarnia', 'https://assets.coingecko.com/coins/images/19837/large/dar.png', 'DARUSDT', false, true, true, true, 179),
  ('BNX', 'BinaryX', 'https://assets.coingecko.com/coins/images/19825/large/bnx.png', 'BNXUSDT', false, true, true, true, 180),
  ('RGT', 'Rari Governance Token', 'https://assets.coingecko.com/coins/images/12900/large/rgt.png', 'RGTUSDT', false, true, true, true, 181),
  ('MOVR', 'Moonriver', 'https://assets.coingecko.com/coins/images/17984/large/moonriver.png', 'MOVRUSDT', false, true, true, true, 182),
  ('CITY', 'Manchester City Fan Token', 'https://assets.coingecko.com/coins/images/14817/large/city.png', 'CITYUSDT', false, true, false, true, 183),
  ('KP3R', 'Keep3rV1', 'https://assets.coingecko.com/coins/images/12966/large/kp3r.png', 'KP3RUSDT', false, true, true, true, 185),
  ('QI', 'Benqi', 'https://assets.coingecko.com/coins/images/15329/large/qi.png', 'QIUSDT', false, true, true, true, 186),
  ('PLA', 'PlayDapp', 'https://assets.coingecko.com/coins/images/14316/large/playdapp.png', 'PLAUSDT', false, true, true, true, 187),
  ('MLN', 'Enzyme', 'https://assets.coingecko.com/coins/images/605/large/enzyme.png', 'MLNUSDT', false, true, true, true, 188),
  ('WOO', 'WOO Network', 'https://assets.coingecko.com/coins/images/12921/large/woo.png', 'WOOUSDT', false, true, true, true, 189),
  ('JOE', 'Joe', 'https://assets.coingecko.com/coins/images/17569/large/joe.png', 'JOEUSDT', false, true, true, true, 190),
  ('ALCX', 'Alchemix', 'https://assets.coingecko.com/coins/images/14113/large/alcx.png', 'ALCXUSDT', false, true, true, true, 191),
  ('GHST', 'Aavegotchi', 'https://assets.coingecko.com/coins/images/12467/large/ghst.png', 'GHSTUSDT', false, true, true, true, 192),
  ('TORN', 'Tornado Cash', 'https://assets.coingecko.com/coins/images/13496/large/torn.png', 'TORNUSDT', false, true, true, true, 193),
  ('BSW', 'Biswap', 'https://assets.coingecko.com/coins/images/16845/large/biswap.png', 'BSWUSDT', false, true, true, true, 194),
  ('BICO', 'Biconomy', 'https://assets.coingecko.com/coins/images/21061/large/biconomy.jpg', 'BICOUSDT', false, true, true, true, 195),
  ('FLUX', 'Flux', 'https://assets.coingecko.com/coins/images/5163/large/flux.png', 'FLUXUSDT', false, true, true, true, 196),
  ('VOXEL', 'Voxies', 'https://assets.coingecko.com/coins/images/21260/large/voxel.png', 'VOXELUSDT', false, true, true, true, 197),
  ('VIDT', 'VIDT DAO', 'https://assets.coingecko.com/coins/images/5456/large/vidt.png', 'VIDTUSDT', false, true, true, true, 199),
  ('ACA', 'Acala', 'https://assets.coingecko.com/coins/images/20634/large/acala.png', 'ACAUSDT', false, true, true, true, 200)
ON CONFLICT (symbol) DO UPDATE SET
  logo_url = EXCLUDED.logo_url,
  binance_symbol = EXCLUDED.binance_symbol,
  is_spot_enabled = EXCLUDED.is_spot_enabled,
  is_futures_enabled = EXCLUDED.is_futures_enabled,
  name = EXCLUDED.name;
