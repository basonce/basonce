import { useState, useEffect } from 'react';
import { X, Copy, Check, AlertCircle, Share2, ArrowLeft } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { QRCodeSVG } from 'qrcode.react';
import CoinSelector from './CoinSelector';
import NetworkSelector from './NetworkSelector';

interface RealDepositModalProps {
  onClose: () => void;
  currency?: string;
  network?: string;
}

interface SelectedCoin {
  id: string;
  symbol: string;
  name: string;
  logo_url: string | null;
}

interface SelectedNetwork {
  id: string;
  network_name: string;
  network_code: string;
  chain_id: string | null;
  contract_address: string | null;
  min_deposit: number;
  confirmations_required: number;
  estimated_arrival_minutes: number;
  withdrawal_fee: number;
  is_mainnet: boolean;
}

export function RealDepositModal({ onClose, currency: initialCurrency, network: initialNetwork }: RealDepositModalProps) {
  const [step, setStep] = useState<'coin' | 'network' | 'address'>('coin');
  const [selectedCoin, setSelectedCoin] = useState<SelectedCoin | null>(null);
  const [selectedNetwork, setSelectedNetwork] = useState<SelectedNetwork | null>(null);
  const [depositAddress, setDepositAddress] = useState<string>('');
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState(false);
  const [error, setError] = useState<string>('');

  useEffect(() => {
    if (selectedCoin && selectedNetwork && step === 'address') {
      generateAddress();
    }
  }, [selectedCoin, selectedNetwork, step]);

  const generateAddress = async () => {
    try {
      setLoading(true);
      setError('');
      setDepositAddress('');
      const { data: { user } } = await supabase.auth.getUser();

      if (!user) {
        setError('Please login first');
        return;
      }

      const { data: wallets, error: walletsError } = await supabase
        .rpc('get_user_deposit_addresses', { user_id_param: user.id });

      if (walletsError) {
        console.error('Error fetching wallets:', walletsError);
        setError('Failed to load deposit address');
        return;
      }

      const targetNetwork = selectedNetwork?.network_code.toUpperCase();
      const wallet = wallets?.find((w: any) => w.network === targetNetwork);

      if (!wallet) {
        setError(`No ${targetNetwork} wallet assigned. Please contact support.`);
        return;
      }

      setDepositAddress(wallet.address);
      await updateCoinHistory();
    } catch (err) {
      setError('Failed to load deposit address');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const updateCoinHistory = async () => {
    if (!selectedCoin) return;

    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { data: existing } = await supabase
        .from('user_coin_history')
        .select('*')
        .eq('user_id', user.id)
        .eq('coin_id', selectedCoin.id)
        .maybeSingle();

      if (existing) {
        await supabase
          .from('user_coin_history')
          .update({
            last_used_at: new Date().toISOString(),
            usage_count: existing.usage_count + 1
          })
          .eq('id', existing.id);
      } else {
        await supabase
          .from('user_coin_history')
          .insert({
            user_id: user.id,
            coin_id: selectedCoin.id,
            last_used_at: new Date().toISOString(),
            usage_count: 1
          });
      }
    } catch (error) {
      console.error('Error updating coin history:', error);
    }
  };

  const handleCoinSelect = (coin: SelectedCoin) => {
    setSelectedCoin(coin);
    setStep('network');
  };

  const handleNetworkSelect = (network: SelectedNetwork) => {
    setSelectedNetwork(network);
    setStep('address');
  };

  const handleCopy = () => {
    navigator.clipboard.writeText(depositAddress);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleShare = async () => {
    const shareText = `${selectedCoin?.symbol} Deposit Address (${selectedNetwork?.network_code})\n\n${depositAddress}`;

    if (navigator.share) {
      try {
        await navigator.share({
          title: 'Deposit Address',
          text: shareText,
        });
      } catch (err) {
        handleCopy();
      }
    } else {
      handleCopy();
    }
  };

  const getCoinIcon = (symbol: string) => {
    const icons: Record<string, string> = {
      'USDT': '💵',
      'BTC': '₿',
      'ETH': 'Ξ',
      'BNB': '🔶',
      'TRX': '⚡',
      'USDC': '💲',
      'SOL': '◎',
      'MATIC': '🔷'
    };
    return icons[symbol] || '🪙';
  };

  if (step === 'coin') {
    return <CoinSelector onClose={onClose} onSelectCoin={handleCoinSelect} />;
  }

  if (step === 'network' && selectedCoin) {
    return (
      <NetworkSelector
        coinId={selectedCoin.id}
        coinSymbol={selectedCoin.symbol}
        coinName={selectedCoin.name}
        coinIconUrl={selectedCoin.logo_url}
        onClose={onClose}
        onSelectNetwork={handleNetworkSelect}
      />
    );
  }

  return (
    <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-[#1a1f2e] rounded-2xl w-full max-h-[90vh] overflow-hidden flex flex-col">
        <div className="flex items-center justify-between p-4 border-white/10">
          <button
            onClick={() => setStep('network')}
            className="p-2 hover:bg-white/5 rounded-lg transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-gray-400" />
          </button>
          <div className="flex items-center gap-2">
            {selectedCoin?.logo_url && (
              <div className="w-8 h-8 rounded-full overflow-hidden bg-white/10 p-1">
                <img
                  src={selectedCoin.logo_url}
                  alt={selectedCoin.symbol}
                  className="w-full h-full object-contain"
                />
              </div>
            )}
            <h2 className="font-semibold text-white">
              Deposit {selectedCoin?.symbol}
            </h2>
          </div>
          <button
            onClick={onClose}
            className="p-2 hover:bg-white/5 rounded-lg transition-colors"
          >
            <X className="w-5 h-5 text-gray-400" />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto p-4">
          {loading ? (
            <div className="flex items-center justify-center py-12">
              <div className="animate-spin rounded-full h-8 w-8 border-yellow-500"></div>
            </div>
          ) : error ? (
            <div className="bg-red-500/10 border border-red-500/20 rounded-xl p-4 mb-4">
              <div className="flex items-center gap-2 text-red-400">
                <AlertCircle className="w-5 h-5" />
                <span>{error}</span>
              </div>
            </div>
          ) : (
            <>
              {selectedNetwork?.is_mainnet && (
                <div className="bg-yellow-500/10 border border-yellow-500/20 rounded-xl p-4 mb-4">
                  <div className="flex items-start gap-2 text-sm">
                    <AlertCircle className="w-4 h-4 flex-shrink-0 mt-0.5" />
                    <div>
                      <div className="font-semibold mb-1">Your address has been updated to a TSS address</div>
                      <a href="#" className="text-yellow-500 hover:underline">Learn more</a>
                    </div>
                  </div>
                </div>
              )}

              <div className="bg-white p-6 rounded-2xl mb-4 flex justify-center relative">
                <QRCodeSVG
                  value={depositAddress}
                  size={240}
                  level="H"
                  includeMargin={true}
                />
                {selectedCoin?.logo_url && (
                  <div className="absolute top-1/2 left-1/2 -translate-y-1/2 w-16 h-16 bg-white rounded-full p-2 shadow-lg">
                    <img
                      src={selectedCoin.logo_url}
                      alt={selectedCoin.symbol}
                      className="w-full h-full object-contain"
                    />
                  </div>
                )}
              </div>

              <div className="bg-[#0f1419] rounded-xl p-4 mb-4">
                <div className="text-gray-400 mb-2">Network</div>
                <div className="flex items-center justify-between">
                  <div>
                    <div className="font-semibold text-lg">
                      {selectedNetwork?.network_code}
                    </div>
                    <div className="text-gray-400">
                      {selectedNetwork?.network_name}
                    </div>
                  </div>
                  <button className="p-2 hover:bg-white/5 rounded-lg transition-colors">
                    <Share2 className="w-5 h-5 text-gray-400" />
                  </button>
                </div>
                {selectedNetwork?.contract_address && (
                  <div className="mt-3 pt-3 border-white/10">
                    <div className="text-gray-400 mb-1">Contract Information</div>
                    <div className="text-gray-300 font-mono break-all">
                      {selectedNetwork.contract_address}
                    </div>
                  </div>
                )}
              </div>

              <div className="bg-[#0f1419] rounded-xl p-4 mb-4">
                <div className="text-gray-400 mb-2">Deposit Address</div>
                <div className="flex items-center gap-2">
                  <div className="flex-1 text-sm font-mono break-all">
                    {depositAddress}
                  </div>
                  <button
                    onClick={handleCopy}
                    className="p-2 hover:bg-white/5 rounded-lg transition-colors flex-shrink-0"
                  >
                    {copied ? (
                      <Check className="w-5 h-5 text-green-400" />
                    ) : (
                      <Copy className="w-5 h-5 text-gray-400" />
                    )}
                  </button>
                </div>
              </div>

              <button
                onClick={handleShare}
                className="w-full bg-yellow-500 hover:bg-yellow-600 text-black font-semibold py-4 rounded-xl transition-colors mb-4"
              >
                Save and Share Address
              </button>

              <div className="bg-blue-500/10 border border-blue-500/20 rounded-xl p-4">
                <div className="text-blue-300 space-y-2">
                  <div className="font-semibold flex items-center gap-2">
                    <AlertCircle className="w-4 h-4" />
                    Important Notes
                  </div>
                  <ul className="list-inside space-y-1 text-blue-200">
                    <li>
                      Only send {selectedCoin?.symbol} to this address on {selectedNetwork?.network_code}
                    </li>
                    <li>
                      Minimum deposit: {selectedNetwork?.min_deposit} {selectedCoin?.symbol}
                    </li>
                    <li>
                      {selectedNetwork?.confirmations_required} block confirmation(s) required
                    </li>
                    <li>
                      Estimated arrival: {selectedNetwork?.estimated_arrival_minutes} minute(s)
                    </li>
                    <li>
                      Sending to wrong network may result in loss of funds
                    </li>
                  </ul>
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}