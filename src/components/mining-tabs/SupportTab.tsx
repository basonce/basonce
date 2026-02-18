import { useState, useEffect } from 'react';
import { Globe, Send, X } from 'lucide-react';
import { supabase } from '../../lib/supabase';

interface SupportAgent {
  id: string;
  name: string;
  avatar_url: string;
  specialty: string;
  language: string;
  status: string;
  response_time: string;
  rating: number;
}

interface Message {
  id: string;
  text: string;
  isAgent: boolean;
  timestamp: Date;
}

interface RegionStats {
  name: string;
  count: number;
}

export default function SupportTab() {
  const [agents, setAgents] = useState<SupportAgent[]>([]);
  const [selectedAgent, setSelectedAgent] = useState<SupportAgent | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [messageInput, setMessageInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const [customerId, setCustomerId] = useState('');
  const [email, setEmail] = useState('');
  const [showStartModal, setShowStartModal] = useState(false);
  const [liveAgentCount, setLiveAgentCount] = useState(420);
  const [liveRegionCounts, setLiveRegionCounts] = useState<Record<string, number>>({
    'Turkish World': 45,
    'Europe': 95,
    'Arab World': 52,
    'Asia': 88,
    'Americas': 78,
    'Africa': 35,
    'Oceania': 27
  });

  const regionStats: RegionStats[] = Object.entries(liveRegionCounts).map(([name, count]) => ({
    name,
    count
  }));

  const totalAgents = liveAgentCount;

  useEffect(() => {
    loadSupportAgents();
    loadUserInfo();

    const interval = setInterval(() => {
      setLiveAgentCount(prev => {
        const change = Math.random() > 0.5 ? 1 : -1;
        const newCount = prev + change;
        return Math.max(410, Math.min(432, newCount));
      });

      setLiveRegionCounts(prev => {
        const regions = Object.keys(prev);
        const updatedCounts = { ...prev };

        regions.forEach(region => {
          const change = Math.random() > 0.5 ? 1 : -1;
          const currentCount = prev[region] || 0;

          if (region === 'Turkish World') {
            updatedCounts[region] = Math.max(42, Math.min(48, currentCount + change));
          } else if (region === 'Europe') {
            updatedCounts[region] = Math.max(92, Math.min(98, currentCount + change));
          } else if (region === 'Arab World') {
            updatedCounts[region] = Math.max(48, Math.min(56, currentCount + change));
          } else if (region === 'Asia') {
            updatedCounts[region] = Math.max(84, Math.min(92, currentCount + change));
          } else if (region === 'Americas') {
            updatedCounts[region] = Math.max(74, Math.min(82, currentCount + change));
          } else if (region === 'Africa') {
            updatedCounts[region] = Math.max(32, Math.min(38, currentCount + change));
          } else if (region === 'Oceania') {
            updatedCounts[region] = Math.max(24, Math.min(30, currentCount + change));
          }
        });

        return updatedCounts;
      });
    }, 2500 + Math.random() * 1500);

    return () => clearInterval(interval);
  }, []);

  const loadUserInfo = async () => {
    const { data: { user } } = await supabase.auth.getUser();
    if (user) {
      const { data: profile } = await supabase
        .from('user_profiles')
        .select('user_id, email')
        .eq('user_id', user.id)
        .single();

      if (profile) {
        setCustomerId(profile.user_id.toString());
        setEmail(user.email || '');
      }
    }
  };

  const loadSupportAgents = async () => {
    // Load mining-focused support agents
    const { data } = await supabase
      .from('support_agents')
      .select('*')
      .in('specialty', ['Mining', 'Technical Support', 'General Support'])
      .eq('status', 'online')
      .limit(6);

    if (data) setAgents(data);
  };

  const startChat = (agent: SupportAgent) => {
    setSelectedAgent(agent);
    setMessages([
      {
        id: '1',
        text: `Hello! I'm ${agent.name}, your mining support specialist. How can I help you today?`,
        isAgent: true,
        timestamp: new Date()
      }
    ]);
  };

  const sendMessage = () => {
    if (!messageInput.trim() || !selectedAgent) return;

    // Add user message
    const userMessage: Message = {
      id: Date.now().toString(),
      text: messageInput,
      isAgent: false,
      timestamp: new Date()
    };

    setMessages(prev => [...prev, userMessage]);
    setMessageInput('');
    setIsTyping(true);

    // Simulate agent response
    setTimeout(() => {
      const responses = [
        "I understand your concern. Let me help you with that right away.",
        "That's a great question! Mining equipment earnings depend on several factors.",
        "You can increase your mining efficiency by upgrading to higher-tier equipment.",
        "EQ tokens are earned based on your equipment's hashrate and mining duration.",
        "For withdrawal questions, you can convert your EQ to USDT anytime in the Swap section.",
        "Mining operates 24/7 once you start. You can check your progress anytime.",
        "Premium equipment offers significantly higher returns on investment.",
        "Your mining data is stored securely and can be accessed from any device."
      ];

      const agentMessage: Message = {
        id: (Date.now() + 1).toString(),
        text: responses[Math.floor(Math.random() * responses.length)],
        isAgent: true,
        timestamp: new Date()
      };

      setMessages(prev => [...prev, agentMessage]);
      setIsTyping(false);
    }, 2000);
  };

  if (selectedAgent) {
    return (
      <div className="min-h-screen bg-[#0a0e1a] pb-24 flex flex-col">
        {/* Chat Header - Golden Theme */}
        <div className="bg-gradient-to-br from-[#1a1f2e] to-[#0a0e1a] border-b border-[#F0B90B]/30 px-4 py-4">
          <div className="flex items-center gap-3">
            <button
              onClick={() => setSelectedAgent(null)}
              className="text-gray-400 hover:text-[#F0B90B]"
            >
              <X className="w-6 h-6" />
            </button>
            <img
              src={selectedAgent.avatar_url}
              alt={selectedAgent.name}
              className="w-12 h-12 rounded-full border-2 border-[#F0B90B]"
              onError={(e) => {
                const target = e.target as HTMLImageElement;
                target.src = `https://api.dicebear.com/7.x/avataaars/svg?seed=${selectedAgent.name}`;
              }}
            />
            <div className="flex-1">
              <div className="text-white font-bold">{selectedAgent.name}</div>
              <div className="flex items-center gap-2 text-xs">
                <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                <span className="text-green-400">Online</span>
                <span className="text-gray-500">•</span>
                <span className="text-[#F0B90B]">{selectedAgent.specialty}</span>
              </div>
            </div>
          </div>
        </div>

        {/* Messages */}
        <div className="flex-1 overflow-y-auto px-4 py-6 space-y-4">
          {messages.map((message) => (
            <div
              key={message.id}
              className={`flex ${message.isAgent ? 'justify-start' : 'justify-end'}`}
            >
              <div className={`max-w-[80%] ${message.isAgent ? 'order-2' : 'order-1'}`}>
                <div
                  className={`rounded-2xl px-4 py-3 ${
                    message.isAgent
                      ? 'bg-[#1a1f2e] border border-[#2B3139]'
                      : 'bg-gradient-to-r from-[#F0B90B] to-[#D4A00A]'
                  }`}
                >
                  <p className={`text-sm ${message.isAgent ? 'text-white' : 'text-black'} font-medium`}>
                    {message.text}
                  </p>
                </div>
                <div className="text-xs text-gray-500 mt-1 px-2">
                  {message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                </div>
              </div>
              {message.isAgent && (
                <img
                  src={selectedAgent.avatar_url}
                  alt={selectedAgent.name}
                  className="w-8 h-8 rounded-full order-1 mr-2"
                  onError={(e) => {
                    const target = e.target as HTMLImageElement;
                    target.src = `https://api.dicebear.com/7.x/avataaars/svg?seed=${selectedAgent.name}`;
                  }}
                />
              )}
            </div>
          ))}

          {isTyping && (
            <div className="flex items-center gap-2">
              <img
                src={selectedAgent.avatar_url}
                alt={selectedAgent.name}
                className="w-8 h-8 rounded-full"
              />
              <div className="bg-[#1a1f2e] rounded-2xl px-4 py-3 border border-[#2B3139]">
                <div className="flex gap-1">
                  <div className="w-2 h-2 bg-[#F0B90B] rounded-full animate-bounce"></div>
                  <div className="w-2 h-2 bg-[#F0B90B] rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                  <div className="w-2 h-2 bg-[#F0B90B] rounded-full animate-bounce" style={{ animationDelay: '0.4s' }}></div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Input */}
        <div className="bg-[#1a1f2e] border-t border-[#2B3139] px-4 py-4">
          <div className="flex gap-2">
            <input
              type="text"
              value={messageInput}
              onChange={(e) => setMessageInput(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
              placeholder="Type your message..."
              className="flex-1 bg-[#0a0e1a] text-white rounded-xl px-4 py-3 border border-[#2B3139] focus:border-[#F0B90B] outline-none"
            />
            <button
              onClick={sendMessage}
              disabled={!messageInput.trim()}
              className="bg-gradient-to-r from-[#F0B90B] to-[#D4A00A] hover:from-[#D4A00A] hover:to-[#F0B90B] text-black font-bold px-6 py-3 rounded-xl disabled:opacity-50 transition-all"
            >
              <Send className="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#0a0e1a] pb-24">
      {/* Start Support Chat Button - Golden Theme */}
      <div className="max-w-md mx-auto px-4 pt-6 pb-4">
        <button
          onClick={() => setShowStartModal(!showStartModal)}
          className="w-full bg-gradient-to-r from-[#1A1B23] to-[#14151B] border border-[#F0B90B]/30 rounded-xl p-4 hover:border-[#F0B90B] transition-all"
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-2.5 h-2.5 bg-[#F0B90B] rounded-full animate-pulse"></div>
              <span className="text-white text-lg font-black">Start Support Chat</span>
            </div>
            <X className={`w-6 h-6 text-gray-400 transition-transform ${showStartModal ? 'rotate-0' : 'rotate-45'}`} />
          </div>
        </button>
      </div>

      {/* Support Modal */}
      {showStartModal && (
        <div className="max-w-md mx-auto px-4">
          <div className="bg-[#14151B] border border-[#2B3139] rounded-xl overflow-hidden">
            {/* Globe Icon */}
            <div className="flex justify-center pt-8 pb-4">
              <div className="w-24 h-24 bg-gradient-to-br from-[#F0B90B]/20 to-[#F0B90B]/5 rounded-full flex items-center justify-center border-2 border-[#F0B90B]/30">
                <Globe className="w-12 h-12 text-[#F0B90B]" />
              </div>
            </div>

            {/* Global Support Network */}
            <div className="text-center px-6 pb-6">
              <h2 className="text-2xl font-black text-white mb-3 tracking-wide">Global Support Network</h2>

              {/* Agents Online */}
              <div className="flex items-center justify-center gap-2 mb-2">
                <div className="w-2.5 h-2.5 bg-green-500 rounded-full animate-pulse"></div>
                <span className="text-xl font-black text-white">{totalAgents}+ Agents Online</span>
              </div>

              <div className="inline-flex items-center justify-center gap-2 bg-[#F0B90B]/20 border border-[#F0B90B] px-4 py-1.5 rounded-full mb-6">
                <span className="text-[#F0B90B] font-black text-sm tracking-wider">24/7 PROFESSIONAL SUPPORT</span>
              </div>

              {/* Regional Stats - 2 Columns */}
              <div className="grid grid-cols-2 gap-3 mb-6">
                {regionStats.map((region, idx) => (
                  <div
                    key={idx}
                    className="bg-[#1A1B23] border border-[#2B3139] rounded-lg p-3 hover:border-[#F0B90B]/30 transition-all cursor-pointer"
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                        <span className="text-white text-sm font-medium truncate">{region.name}</span>
                      </div>
                      <span className="text-white text-lg font-bold">{region.count}</span>
                    </div>
                  </div>
                ))}
              </div>

              {/* Live Status */}
              <div className="flex items-center justify-center gap-2 text-sm mb-6">
                <div className="flex items-center gap-1">
                  <div className="w-1.5 h-1.5 bg-green-500 rounded-full animate-ping"></div>
                  <span className="text-green-400 font-bold">Live</span>
                </div>
                <span className="text-gray-400">•</span>
                <span className="text-gray-400">Response: 45s</span>
              </div>

              {/* Customer ID Input */}
              <div className="mb-4">
                <label className="block text-gray-400 text-sm text-left mb-2">Customer ID</label>
                <input
                  type="text"
                  value={customerId}
                  onChange={(e) => setCustomerId(e.target.value)}
                  placeholder="e.g. 100007"
                  className="w-full bg-[#1A1B23] border border-[#2B3139] rounded-lg px-4 py-3 text-white placeholder-gray-600 focus:border-[#F0B90B] outline-none transition-all"
                />
              </div>

              {/* Email Address Input */}
              <div className="mb-6">
                <label className="block text-gray-400 text-sm text-left mb-2">Email Address</label>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="your@email.com"
                  className="w-full bg-[#1A1B23] border border-[#2B3139] rounded-lg px-4 py-3 text-white placeholder-gray-600 focus:border-[#F0B90B] outline-none transition-all"
                />
              </div>

              {/* Connect Button */}
              <button
                onClick={() => {
                  if (!customerId || !email) {
                    alert('Please enter your Customer ID and Email Address');
                    return;
                  }
                  if (agents.length > 0) {
                    startChat(agents[0]);
                  }
                }}
                className="w-full bg-gradient-to-r from-[#F0B90B] to-[#D4A00A] hover:from-[#D4A00A] hover:to-[#F0B90B] text-black font-bold py-4 rounded-lg transition-all shadow-lg shadow-[#F0B90B]/20"
              >
                Connect to Agent
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
