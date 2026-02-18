import { useState, useEffect } from 'react';
import { X, Copy, Check, AlertCircle } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { CRYPTO_NETWORKS, generateDepositAddress, generateQRCodeUrl, Network } from '../lib/crypto-utils';

interface DepositModalProps {
  isOpen: boolean;
  onClose: () => void;
  coinSymbol: string;
  coinName: string;
}

export default function DepositModal({ isOpen, onClose, coinSymbol, coinName }: DepositModalProps) {
  const [selectedNetwork, setSelectedNetwork] = useState<Network | null>(null);
  const [depositAddress, setDepositAddress] = useState('');
  const [copied, setCopied] = useState(false);
  const [loading, setLoading] = useState(false);
  const [amount, setAmount] = useState('');
  const [txid, setTxid] = useState('');

  const networks = CRYPTO_NETWORKS[coinSymbol] || [];

  useEffect(() => {
    if (networks.length > 0 && !selectedNetwork) {
      setSelectedNetwork(networks[0]);
    }
  }, [networks, selectedNetwork]);

  useEffect(() => {
    if (selectedNetwork) {
      loadOrCreateDepositAddress();
    }
  }, [selectedNetwork]);

  const loadOrCreateDepositAddress = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user || !selectedNetwork) return;

      const { data: existingAddress } = await supabase
        .from('deposit_addresses')
        .select('address')
        .eq('user_id', user.id)
        .eq('coin_symbol', coinSymbol)
        .eq('network', selectedNetwork.id)
        .maybeSingle();

      if (existingAddress) {
        setDepositAddress(existingAddress.address);
      } else {
        const newAddress = generateDepositAddress(coinSymbol, selectedNetwork.id, user.id);
        await supabase.from('deposit_addresses').insert({
          user_id: user.id,
          coin_symbol: coinSymbol,
          network: selectedNetwork.id,
          address: newAddress
        });
        setDepositAddress(newAddress);
      }
    } catch (error) {
      console.error('Error loading deposit address:', error);
    }
  };

  const copyToClipboard = () => {
    navigator.clipboard.writeText(depositAddress);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleConfirmDeposit = async () => {
    if (!amount || parseFloat(amount) <= 0) {
      alert('Please enter a valid amount');
      return;
    }

    if (selectedNetwork && parseFloat(amount) < selectedNetwork.minDeposit) {
      alert(`Minimum deposit is ${selectedNetwork.minDeposit} ${coinSymbol}`);
      return;
    }

    setLoading(true);
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user || !selectedNetwork) return;

      await supabase.from('deposit_transactions').insert({
        user_id: user.id,
        coin_symbol: coinSymbol,
        network: selectedNetwork.id,
        amount: parseFloat(amount),
        address: depositAddress,
        txid: txid || null,
        status: 'pending'
      });

      alert('Deposit request submitted! Admin will confirm your transaction.');
      setAmount('');
      setTxid('');
      onClose();
    } catch (error) {
      console.error('Error submitting deposit:', error);
      alert('Failed to submit deposit request');
    } finally {
      setLoading(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4">
      <div className="bg-[#181A20] rounded-lg w-full max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between p-4 border-[#2B3139]">
          <h2 className="font-bold text-white">Deposit {coinName}</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-4">
          <div className="mb-4">
            <label className="text-gray-400 mb-2 block">Select Network</label>
            <div className="space-y-2">
              {networks.map((network) => (
                <button
                  key={network.id}
                  onClick={() => setSelectedNetwork(network)}
                  className={`w-full p-3 rounded-lg border transition-colors text-left ${ selectedNetwork?.id === network.id ? 'border-[#F0B90B] bg-[#F0B90B]/10' : 'border-[#2B3139] hover:border-[#474D57]' }`}
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <div className="text-white font-medium">{network.name}</div>
                      <div className="text-gray-400 mt-1">
                        Fee: {network.withdrawFee} {coinSymbol} • {network.estimatedTime}
                      </div>
                    </div>
                    {selectedNetwork?.id === network.id && (
                      <Check className="w-5 h-5 text-[#F0B90B]" />
                    )}
                  </div>
                </button>
              ))}
            </div>
          </div>

          {selectedNetwork && depositAddress && (
            <>
              <div className="bg-[#2B3139] rounded-lg p-4 mb-4">
                <div className="text-gray-400 mb-2">Deposit Address</div>
                <div className="flex items-center gap-2">
                  <input
                    type="text"
                    value={depositAddress}
                    readOnly
                    className="flex-1 bg-[#181A20] text-sm px-3 py-2 rounded border border-[#474D57] font-mono"
                  />
                  <button
                    onClick={copyToClipboard}
                    className="p-2 bg-[#F0B90B] hover:bg-[#F0B90B]/90 rounded transition-colors"
                  >
                    {copied ? (
                      <Check className="w-4 h-4 text-white" />
                    ) : (
                      <Copy className="w-4 h-4 text-white" />
                    )}
                  </button>
                </div>
              </div>

              <div className="flex justify-center mb-4">
                <div className="bg-white p-3 rounded-lg">
                  <img
                    src={generateQRCodeUrl(depositAddress)}
                    alt="QR Code"
                    className="w-48 h-48"
                  />
                </div>
              </div>

              <div className="bg-[#2B3139] rounded-lg p-4 mb-4">
                <div className="flex items-start gap-2">
                  <AlertCircle className="w-4 h-4 text-[#F0B90B] mt-0.5 flex-shrink-0" />
                  <div className="text-gray-400 space-y-1">
                    <div>• Send only {coinSymbol} to this address via {selectedNetwork.name}</div>
                    <div>• Minimum deposit: {selectedNetwork.minDeposit} {coinSymbol}</div>
                    <div>• Required confirmations: {selectedNetwork.confirmations}</div>
                    <div>• Estimated arrival time: {selectedNetwork.estimatedTime}</div>
                  </div>
                </div>
              </div>

              <div className="space-y-3">
                <div>
                  <label className="text-gray-400 mb-2 block">
                    Amount <span className="text-[#F6465D]">*</span>
                  </label>
                  <input
                    type="number"
                    value={amount}
                    onChange={(e) => setAmount(e.target.value)}
                    placeholder={`Min: ${selectedNetwork.minDeposit} ${coinSymbol}`}
                    className="w-full bg-[#2B3139] text-white px-4 py-3 rounded border border-[#474D57] focus:border-[#F0B90B] outline-none"
                  />
                </div>

                <div>
                  <label className="text-gray-400 mb-2 block">
                    Transaction ID (Optional)
                  </label>
                  <input
                    type="text"
                    value={txid}
                    onChange={(e) => setTxid(e.target.value)}
                    placeholder="Enter TxID if you already sent"
                    className="w-full bg-[#2B3139] text-white px-4 py-3 rounded border border-[#474D57] focus:border-[#F0B90B] outline-none"
                  />
                </div>

                <button
                  onClick={handleConfirmDeposit}
                  disabled={loading || !amount}
                  className="w-full bg-[#F0B90B] hover:bg-[#F0B90B]/90 disabled:cursor-not-allowed text-black font-bold py-3 rounded transition-colors"
                >
                  {loading ? 'Submitting...' : 'Confirm Deposit'}
                </button>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
