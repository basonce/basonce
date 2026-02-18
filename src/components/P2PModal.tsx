import { useState } from 'react';
import { X, ChevronDown, Filter, ThumbsUp, Clock, Shield, ArrowLeft, CheckCircle } from 'lucide-react';

interface P2PModalProps {
  isOpen: boolean;
  onClose: () => void;
}

interface Merchant {
  id: string;
  username: string;
  avatar: string;
  trades: number;
  completion: number;
  verified: boolean;
  price: number;
  minLimit: number;
  maxLimit: number;
  available: number;
  paymentMethod: string;
  timeLimit: number;
}

export default function P2PModal({ isOpen, onClose }: P2PModalProps) {
  const [activeMode, setActiveMode] = useState<'express' | 'p2p' | 'block'>('p2p');
  const [activeTab, setActiveTab] = useState<'buy' | 'sell'>('buy');
  const [showBuySheet, setShowBuySheet] = useState(false);
  const [selectedMerchant, setSelectedMerchant] = useState<Merchant | null>(null);
  const [buyAmount, setBuyAmount] = useState('');

  if (!isOpen) return null;

  const merchants: Merchant[] = [
    {
      id: '1',
      username: 'Valiko_USDT',
      avatar: '/ber1.jpg',
      trades: 271,
      completion: 100.00,
      verified: true,
      price: 1.008,
      minLimit: 150,
      maxLimit: 3982,
      available: 3950.60,
      paymentMethod: 'Bank of Georgia',
      timeLimit: 15
    },
    {
      id: '2',
      username: 'PRIMEVA-Wise',
      avatar: '/ber2.jpg',
      trades: 338,
      completion: 98.90,
      verified: true,
      price: 1.029,
      minLimit: 200,
      maxLimit: 2000,
      available: 3207.52,
      paymentMethod: 'Wise',
      timeLimit: 15
    },
    {
      id: '3',
      username: 'crypto_dealer',
      avatar: '/ber3.jpg',
      trades: 183,
      completion: 99.50,
      verified: false,
      price: 1.031,
      minLimit: 100,
      maxLimit: 813,
      available: 789.10,
      paymentMethod: 'Whish MONEY',
      timeLimit: 15
    },
    {
      id: '4',
      username: 'P2P_EXCHANGE',
      avatar: '/ber4.jpg',
      trades: 44,
      completion: 100.00,
      verified: false,
      price: 1.040,
      minLimit: 200,
      maxLimit: 1956,
      available: 1890.97,
      paymentMethod: 'Western Union',
      timeLimit: 15
    },
    {
      id: '5',
      username: 'Dementerio',
      avatar: '/ber5.png',
      trades: 4329,
      completion: 98.60,
      verified: true,
      price: 1.060,
      minLimit: 10,
      maxLimit: 3241,
      available: 3058.34,
      paymentMethod: 'Skrill',
      timeLimit: 15
    },
    {
      id: '6',
      username: 'Romio2030',
      avatar: '/ber6.jpg',
      trades: 53,
      completion: 93.00,
      verified: false,
      price: 1.069,
      minLimit: 10,
      maxLimit: 163,
      available: 152.67,
      paymentMethod: 'Whish MONEY',
      timeLimit: 15
    },
    {
      id: '7',
      username: 'CryptoKing777',
      avatar: '/ber7.jpg',
      trades: 8542,
      completion: 99.85,
      verified: true,
      price: 0.998,
      minLimit: 500000,
      maxLimit: 5000000,
      available: 2847563.45,
      paymentMethod: 'Bank of America',
      timeLimit: 30
    },
    {
      id: '8',
      username: 'FastTrader_Pro',
      avatar: '/ber8.jpg',
      trades: 1205,
      completion: 97.40,
      verified: true,
      price: 1.002,
      minLimit: 10000,
      maxLimit: 500000,
      available: 485920.50,
      paymentMethod: 'Chase Bank',
      timeLimit: 20
    },
    {
      id: '9',
      username: 'BlockchainMaster',
      avatar: '/ber9.jpg',
      trades: 15678,
      completion: 99.92,
      verified: true,
      price: 0.995,
      minLimit: 1000000,
      maxLimit: 10000000,
      available: 8456723.89,
      paymentMethod: 'SWIFT Transfer',
      timeLimit: 45
    },
    {
      id: '10',
      username: 'QuickPay_24',
      avatar: '/ber10.jpg',
      trades: 89,
      completion: 95.20,
      verified: false,
      price: 1.015,
      minLimit: 50,
      maxLimit: 500,
      available: 425.30,
      paymentMethod: 'PayPal',
      timeLimit: 10
    },
    {
      id: '11',
      username: 'TrustMerchant',
      avatar: '/ber11.jpg',
      trades: 3456,
      completion: 98.75,
      verified: true,
      price: 1.005,
      minLimit: 5000,
      maxLimit: 100000,
      available: 95840.20,
      paymentMethod: 'Wells Fargo',
      timeLimit: 15
    },
    {
      id: '12',
      username: 'GlobalTrader',
      avatar: '/ber12.jpg',
      trades: 6789,
      completion: 99.50,
      verified: true,
      price: 0.999,
      minLimit: 100000,
      maxLimit: 2000000,
      available: 1856432.75,
      paymentMethod: 'HSBC',
      timeLimit: 30
    },
    {
      id: '13',
      username: 'MicroPay',
      avatar: '/ber13.jpg',
      trades: 234,
      completion: 96.80,
      verified: false,
      price: 1.025,
      minLimit: 10,
      maxLimit: 100,
      available: 85.50,
      paymentMethod: 'Venmo',
      timeLimit: 10
    },
    {
      id: '14',
      username: 'MegaDealer_Pro',
      avatar: '/ber14.jpg',
      trades: 12453,
      completion: 99.95,
      verified: true,
      price: 0.992,
      minLimit: 2000000,
      maxLimit: 15000000,
      available: 12456789.25,
      paymentMethod: 'Citibank',
      timeLimit: 60
    },
    {
      id: '15',
      username: 'SmallTrades',
      avatar: '/ber15.jpg',
      trades: 145,
      completion: 94.50,
      verified: false,
      price: 1.035,
      minLimit: 20,
      maxLimit: 200,
      available: 178.90,
      paymentMethod: 'Cash App',
      timeLimit: 10
    },
    {
      id: '16',
      username: 'InstantCrypto',
      avatar: '/ber16.jpg',
      trades: 2341,
      completion: 98.20,
      verified: true,
      price: 1.010,
      minLimit: 1000,
      maxLimit: 50000,
      available: 48520.30,
      paymentMethod: 'Revolut',
      timeLimit: 15
    },
    {
      id: '17',
      username: 'WhaleTrader',
      avatar: '/ber17.jpg',
      trades: 9876,
      completion: 99.88,
      verified: true,
      price: 0.990,
      minLimit: 500000,
      maxLimit: 8000000,
      available: 7234567.80,
      paymentMethod: 'Santander',
      timeLimit: 45
    },
    {
      id: '18',
      username: 'BudgetDeals',
      avatar: '/ber18.jpg',
      trades: 67,
      completion: 92.50,
      verified: false,
      price: 1.045,
      minLimit: 5,
      maxLimit: 50,
      available: 42.15,
      paymentMethod: 'Zelle',
      timeLimit: 10
    },
    {
      id: '19',
      username: 'PremiumExchange',
      avatar: '/ber19.jpg',
      trades: 5432,
      completion: 99.30,
      verified: true,
      price: 1.000,
      minLimit: 50000,
      maxLimit: 1000000,
      available: 945678.50,
      paymentMethod: 'BBVA',
      timeLimit: 25
    },
    {
      id: '20',
      username: 'LocalMoney',
      avatar: '/ber20.jpg',
      trades: 456,
      completion: 97.60,
      verified: true,
      price: 1.012,
      minLimit: 500,
      maxLimit: 10000,
      available: 9540.80,
      paymentMethod: 'Garanti Bank',
      timeLimit: 15
    },
    {
      id: '21',
      username: 'UltraFastPay',
      avatar: '/ber21.jpg',
      trades: 1876,
      completion: 98.90,
      verified: true,
      price: 1.007,
      minLimit: 2000,
      maxLimit: 75000,
      available: 72345.60,
      paymentMethod: 'ING Bank',
      timeLimit: 15
    },
    {
      id: '22',
      username: 'CryptoGiant',
      avatar: '/ber22.jpg',
      trades: 18234,
      completion: 99.97,
      verified: true,
      price: 0.988,
      minLimit: 3000000,
      maxLimit: 20000000,
      available: 18567432.90,
      paymentMethod: 'SEPA Transfer',
      timeLimit: 60
    },
    {
      id: '23',
      username: 'MiniBuyer',
      avatar: '/ber23.jpg',
      trades: 98,
      completion: 93.80,
      verified: false,
      price: 1.038,
      minLimit: 15,
      maxLimit: 150,
      available: 125.40,
      paymentMethod: 'Neteller',
      timeLimit: 10
    },
    {
      id: '24',
      username: 'SafeTrader_VIP',
      avatar: '/ber24.jpg',
      trades: 7654,
      completion: 99.65,
      verified: true,
      price: 0.997,
      minLimit: 200000,
      maxLimit: 3000000,
      available: 2845672.35,
      paymentMethod: 'MoneyGram',
      timeLimit: 30
    },
    {
      id: '25',
      username: 'QuickCash',
      avatar: '/ber25.jpg',
      trades: 234,
      completion: 95.70,
      verified: false,
      price: 1.020,
      minLimit: 100,
      maxLimit: 1000,
      available: 875.25,
      paymentMethod: 'Perfect Money',
      timeLimit: 10
    },
    {
      id: '26',
      username: 'EliteExchange',
      avatar: '/ber26.jpg',
      trades: 11234,
      completion: 99.82,
      verified: true,
      price: 0.993,
      minLimit: 750000,
      maxLimit: 7500000,
      available: 6987654.45,
      paymentMethod: 'Yapı Kredi',
      timeLimit: 40
    },
    {
      id: '27',
      username: 'TinyDeals',
      avatar: '/ber27.jpg',
      trades: 123,
      completion: 91.20,
      verified: false,
      price: 1.050,
      minLimit: 5,
      maxLimit: 75,
      available: 62.80,
      paymentMethod: 'Payeer',
      timeLimit: 10
    },
    {
      id: '28',
      username: 'ProTrader_247',
      avatar: '/ber28.jpg',
      trades: 4567,
      completion: 98.55,
      verified: true,
      price: 1.003,
      minLimit: 10000,
      maxLimit: 250000,
      available: 234567.90,
      paymentMethod: 'İş Bank',
      timeLimit: 20
    },
    {
      id: '29',
      username: 'MassiveDealer',
      avatar: '/ber29.jpg',
      trades: 22345,
      completion: 99.98,
      verified: true,
      price: 0.985,
      minLimit: 5000000,
      maxLimit: 25000000,
      available: 23456789.60,
      paymentMethod: 'Swift Transfer',
      timeLimit: 90
    },
    {
      id: '30',
      username: 'SmartPay',
      avatar: '/ber30.jpg',
      trades: 876,
      completion: 97.30,
      verified: true,
      price: 1.008,
      minLimit: 1500,
      maxLimit: 30000,
      available: 28456.70,
      paymentMethod: 'Akbank',
      timeLimit: 15
    },
    {
      id: '31',
      username: 'MicroTrader_88',
      avatar: '/ber31.jpg',
      trades: 156,
      completion: 94.10,
      verified: false,
      price: 1.042,
      minLimit: 10,
      maxLimit: 120,
      available: 98.50,
      paymentMethod: 'Paysera',
      timeLimit: 10
    },
    {
      id: '32',
      username: 'MillionaireMerchant',
      avatar: '/ber32.jpg',
      trades: 14567,
      completion: 99.90,
      verified: true,
      price: 0.991,
      minLimit: 1000000,
      maxLimit: 12000000,
      available: 11234567.85,
      paymentMethod: 'DenizBank',
      timeLimit: 50
    },
    {
      id: '33',
      username: 'PocketDeals',
      avatar: '/ber33.jpg',
      trades: 189,
      completion: 95.90,
      verified: false,
      price: 1.028,
      minLimit: 25,
      maxLimit: 250,
      available: 215.60,
      paymentMethod: 'Advcash',
      timeLimit: 10
    },
    {
      id: '34',
      username: 'SuperExchange',
      avatar: '/ber34.jpg',
      trades: 6543,
      completion: 99.45,
      verified: true,
      price: 0.996,
      minLimit: 100000,
      maxLimit: 1500000,
      available: 1432567.40,
      paymentMethod: 'QNB Finansbank',
      timeLimit: 25
    },
    {
      id: '35',
      username: 'FastCash_Plus',
      avatar: '/ber35.jpg',
      trades: 987,
      completion: 96.50,
      verified: true,
      price: 1.011,
      minLimit: 3000,
      maxLimit: 60000,
      available: 57890.25,
      paymentMethod: 'TEB',
      timeLimit: 15
    },
    {
      id: '36',
      username: 'BillionaireDeals',
      avatar: '/ber36.jpg',
      trades: 28765,
      completion: 99.99,
      verified: true,
      price: 0.982,
      minLimit: 10000000,
      maxLimit: 50000000,
      available: 45678912.70,
      paymentMethod: 'Bank Transfer',
      timeLimit: 120
    },
    {
      id: '37',
      username: 'BasicTrader',
      avatar: '/ber37.jpg',
      trades: 78,
      completion: 92.80,
      verified: false,
      price: 1.048,
      minLimit: 20,
      maxLimit: 180,
      available: 145.30,
      paymentMethod: 'N26',
      timeLimit: 10
    },
    {
      id: '38',
      username: 'VIPMerchant_Gold',
      avatar: '/ber38.jpg',
      trades: 9876,
      completion: 99.70,
      verified: true,
      price: 0.994,
      minLimit: 300000,
      maxLimit: 4000000,
      available: 3765432.95,
      paymentMethod: 'Halkbank',
      timeLimit: 35
    },
    {
      id: '39',
      username: 'InstantDeal',
      avatar: '/ber39.jpg',
      trades: 543,
      completion: 96.20,
      verified: true,
      price: 1.013,
      minLimit: 800,
      maxLimit: 15000,
      available: 14234.85,
      paymentMethod: 'Monzo',
      timeLimit: 12
    },
    {
      id: '40',
      username: 'TopDealer_Pro',
      avatar: '/ber40.jpg',
      trades: 13456,
      completion: 99.85,
      verified: true,
      price: 0.989,
      minLimit: 1500000,
      maxLimit: 18000000,
      available: 16789543.30,
      paymentMethod: 'Vakıfbank',
      timeLimit: 55
    },
    {
      id: '41',
      username: 'CoinQueen',
      avatar: '/ber41.jpg',
      trades: 2345,
      completion: 98.40,
      verified: true,
      price: 1.006,
      minLimit: 5000,
      maxLimit: 120000,
      available: 115678.45,
      paymentMethod: 'Alipay',
      timeLimit: 18
    },
    {
      id: '42',
      username: 'SmallBiz',
      avatar: '/ber42.jpg',
      trades: 112,
      completion: 93.50,
      verified: false,
      price: 1.032,
      minLimit: 30,
      maxLimit: 300,
      available: 267.90,
      paymentMethod: 'WeChat Pay',
      timeLimit: 10
    },
    {
      id: '43',
      username: 'MegaTrust_Exchange',
      avatar: '/ber43.jpg',
      trades: 17890,
      completion: 99.93,
      verified: true,
      price: 0.987,
      minLimit: 2500000,
      maxLimit: 22000000,
      available: 20456789.55,
      paymentMethod: 'Starling Bank',
      timeLimit: 70
    },
    {
      id: '44',
      username: 'QuickBucks',
      avatar: '/ber44.jpg',
      trades: 345,
      completion: 95.40,
      verified: false,
      price: 1.022,
      minLimit: 150,
      maxLimit: 1500,
      available: 1345.70,
      paymentMethod: 'GPay',
      timeLimit: 12
    },
    {
      id: '45',
      username: 'PlatinumTrader',
      avatar: '/ber45.jpg',
      trades: 8765,
      completion: 99.60,
      verified: true,
      price: 0.998,
      minLimit: 400000,
      maxLimit: 5500000,
      available: 5234567.20,
      paymentMethod: 'Paytm',
      timeLimit: 40
    },
    {
      id: '46',
      username: 'NanoDeals',
      avatar: '/ber46.jpg',
      trades: 89,
      completion: 90.50,
      verified: false,
      price: 1.055,
      minLimit: 5,
      maxLimit: 60,
      available: 48.25,
      paymentMethod: 'PhonePe',
      timeLimit: 10
    },
    {
      id: '47',
      username: 'SuperWhale_VIP',
      avatar: '/ber47.jpg',
      trades: 25678,
      completion: 99.96,
      verified: true,
      price: 0.983,
      minLimit: 8000000,
      maxLimit: 35000000,
      available: 32567891.45,
      paymentMethod: 'M-Pesa',
      timeLimit: 100
    },
    {
      id: '48',
      username: 'EasyPay_24',
      avatar: '/ber48.jpg',
      trades: 654,
      completion: 97.80,
      verified: true,
      price: 1.009,
      minLimit: 2500,
      maxLimit: 45000,
      available: 42567.85,
      paymentMethod: 'Vodafone Cash',
      timeLimit: 15
    },
    {
      id: '49',
      username: 'BudgetBuy',
      avatar: '/ber49.jpg',
      trades: 167,
      completion: 94.30,
      verified: false,
      price: 1.040,
      minLimit: 15,
      maxLimit: 175,
      available: 152.60,
      paymentMethod: 'Orange Money',
      timeLimit: 10
    },
    {
      id: '50',
      username: 'UltraMega_Trader',
      avatar: '/ber50.jpg',
      trades: 31245,
      completion: 99.99,
      verified: true,
      price: 0.980,
      minLimit: 15000000,
      maxLimit: 75000000,
      available: 68456789.90,
      paymentMethod: 'Local Bank Transfer',
      timeLimit: 150
    }
  ];

  const handleMerchantClick = (merchant: Merchant) => {
    setSelectedMerchant(merchant);
    setShowBuySheet(true);
  };

  const handleQuickAmount = (amount: string) => {
    setBuyAmount(amount);
  };

  return (
    <div className="fixed inset-0 bg-black/80 z-50 flex items-end justify-center">
      <div className="bg-[#181A20] w-full max-w-[480px] rounded-t-2xl h-[95vh] overflow-hidden flex flex-col">
        <div className="sticky top-0 bg-[#181A20] border-[#2B3139] px-4 py-3 z-10">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-4">
              <button
                onClick={() => setActiveMode('express')}
                className={`text-sm font-medium ${ activeMode === 'express' ? 'text-white' : 'text-gray-400' }`}
              >
                Express
              </button>
              <button
                onClick={() => setActiveMode('p2p')}
                className={`text-sm font-bold ${ activeMode === 'p2p' ? 'text-white' : 'text-gray-400' }`}
              >
                P2P
              </button>
              <button
                onClick={() => setActiveMode('block')}
                className={`text-sm font-medium ${ activeMode === 'block' ? 'text-white' : 'text-gray-400' }`}
              >
                Block Trade
              </button>
            </div>
            <div className="flex items-center gap-2">
              <button className="bg-[#2B3139] text-xs px-2.5 py-1 rounded flex items-center gap-1">
                USD <ChevronDown className="w-3 h-3" />
              </button>
              <button onClick={onClose} className="text-gray-400 hover:text-white">
                <X className="w-5 h-5" />
              </button>
            </div>
          </div>

          <div className="flex items-center gap-2 mb-3">
            <button
              onClick={() => setActiveTab('buy')}
              className={`px-4 py-1.5 rounded-full text-sm font-medium transition-all ${ activeTab === 'buy' ? 'bg-[#474D57] text-white' : 'text-gray-400' }`}
            >
              Buy
            </button>
            <button
              onClick={() => setActiveTab('sell')}
              className={`px-4 py-1.5 rounded-full text-sm font-medium transition-all ${ activeTab === 'sell' ? 'bg-[#474D57] text-white' : 'text-gray-400' }`}
            >
              Sell
            </button>
          </div>

          <div className="flex items-center gap-2">
            <button className="flex-1 bg-[#2B3139] text-xs px-3 py-2 rounded flex items-center justify-between">
              <span className="flex items-center gap-1">
                <span className="w-4 h-4 bg-green-500 rounded-full flex items-center justify-center text-[8px]">T</span>
                USDT
              </span>
              <ChevronDown className="w-3 h-3 text-gray-400" />
            </button>
            <button className="flex-1 bg-[#2B3139] text-xs px-3 py-2 rounded flex items-center justify-between">
              <span>Amount</span>
              <ChevronDown className="w-3 h-3 text-gray-400" />
            </button>
            <button className="flex-1 bg-[#2B3139] text-xs px-3 py-2 rounded flex items-center justify-between">
              <span>Payment</span>
              <ChevronDown className="w-3 h-3 text-gray-400" />
            </button>
            <button className="bg-[#2B3139] p-2 rounded">
              <Filter className="w-4 h-4 text-[#F0B90B]" />
            </button>
          </div>
        </div>

        <div className="flex-1 overflow-y-auto">
          {merchants.map((merchant) => (
            <div
              key={merchant.id}
              className="bg-[#181A20] border-[#2B3139] px-4 py-3"
            >
              <div className="flex items-start justify-between mb-2">
                <div className="flex flex-col gap-1">
                  <div className="flex items-center gap-2">
                    <div className="w-6 h-6 rounded-full overflow-hidden bg-[#2B3139]">
                      <img src={merchant.avatar} alt={merchant.username} className="w-full h-full object-cover" />
                    </div>
                    <span className="text-sm font-medium">{merchant.username}</span>
                    {merchant.verified && (
                      <>
                        <Shield className="w-3.5 h-3.5 text-[#F0B90B]" fill="#F0B90B" />
                        <CheckCircle className="w-3.5 h-3.5 text-[#0ECB81]" fill="#0ECB81" />
                      </>
                    )}
                  </div>
                  <div className="flex items-center gap-3 text-gray-400 ml-8">
                    <span className="text-gray-400">{merchant.trades} trades</span>
                    <span className="text-gray-400">|</span>
                    <span className="text-gray-400">Completion {merchant.completion.toFixed(2)}%</span>
                  </div>
                </div>
              </div>

              <div className="flex items-center gap-2 mb-3 text-gray-400 ml-8">
                <Clock className="w-3 h-3" />
                <span>{merchant.timeLimit} min</span>
              </div>

              <div className="flex items-end justify-between mb-2">
                <div>
                  <div className="font-bold text-2xl mb-0.5">
                    $ {merchant.price.toFixed(3)}
                    <span className="text-xs font-normal ml-1">/USDT</span>
                  </div>
                  <div className="text-[10px] mb-1">
                    Limit {merchant.minLimit} - {merchant.maxLimit.toLocaleString()} USD
                  </div>
                  <div className="text-[10px]">
                    Available {merchant.available.toFixed(2)} USDT
                  </div>
                </div>

                <div className="text-right">
                  <div className="text-xs mb-2 flex items-center gap-1 justify-end">
                    <span>{merchant.paymentMethod}</span>
                  </div>
                  <button
                    onClick={() => handleMerchantClick(merchant)}
                    className="bg-[#0ECB81] hover:bg-[#0ECB81]/90 font-bold px-6 py-1.5 rounded text-sm transition-all"
                  >
                    Buy
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {showBuySheet && selectedMerchant && (
          <div className="absolute inset-0 bg-black/60 z-20 flex items-end">
            <div className="bg-[#181A20] w-full rounded-t-3xl animate-slide-up">
              <div className="w-12 h-1 bg-[#474D57] rounded-full mx-auto mt-2 mb-4"></div>

              <div className="px-4 pt-2 pb-24">
                <h3 className="text-lg font-bold mb-4">I Want to Buy</h3>

                <div className="bg-[#2B3139] rounded-lg px-4 py-3 mb-4 flex items-center justify-between">
                  <input
                    type="number"
                    placeholder="Enter total amount"
                    value={buyAmount}
                    onChange={(e) => setBuyAmount(e.target.value)}
                    className="bg-transparent text-base flex-1 outline-none placeholder-[#5E6673]"
                  />
                  <span className="text-white font-medium">USD</span>
                </div>

                <div className="grid grid-cols-4 gap-2 mb-6">
                  <button
                    onClick={() => handleQuickAmount('20')}
                    className="bg-[#2B3139] hover:bg-[#343C45] py-3 rounded-lg text-sm font-medium transition-all"
                  >
                    $20
                  </button>
                  <button
                    onClick={() => handleQuickAmount('100')}
                    className="bg-[#2B3139] hover:bg-[#343C45] py-3 rounded-lg text-sm font-medium transition-all"
                  >
                    $100
                  </button>
                  <button
                    onClick={() => handleQuickAmount('500')}
                    className="bg-[#2B3139] hover:bg-[#343C45] py-3 rounded-lg text-sm font-medium transition-all"
                  >
                    $500
                  </button>
                  <button
                    onClick={() => handleQuickAmount('1000')}
                    className="bg-[#2B3139] hover:bg-[#343C45] py-3 rounded-lg text-sm font-medium transition-all"
                  >
                    $1K
                  </button>
                </div>

                <div className="flex items-center gap-3">
                  <button
                    onClick={() => {
                      setBuyAmount('');
                      setShowBuySheet(false);
                      setSelectedMerchant(null);
                    }}
                    className="flex-1 bg-[#2B3139] hover:bg-[#343C45] text-white font-bold py-3.5 rounded-lg transition-all"
                  >
                    Reset
                  </button>
                  <button
                    onClick={() => {
                      setShowBuySheet(false);
                      setSelectedMerchant(null);
                      setBuyAmount('');
                    }}
                    className="flex-1 bg-[#F0B90B] hover:bg-[#F0B90B] text-black font-bold py-3.5 rounded-lg transition-all"
                  >
                    Confirm
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>

      <style>{`
        @keyframes slide-up {
          from {
            transform: translateY(100%);
          }
          to {
            transform: translateY(0);
          }
        }
        .animate-slide-up {
          animation: slide-up 0.3s ease-out;
        }
      `}</style>
    </div>
  );
}
