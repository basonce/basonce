import { useState, useEffect, useRef } from 'react';
import { X, Send, Check, CheckCheck, Globe } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { detectUserCountry } from '../lib/geolocation';
import { assignBestAgent, getAgentStats, type Agent } from '../lib/agent-assignment';
import { getAgentGreeting } from '../lib/agent-greetings';

interface SupportMessage {
  id: string;
  sender_type: 'customer' | 'admin';
  sender_name: string;
  message: string;
  created_at: string;
  read: boolean;
  original_message?: string;
  original_language?: string;
}

interface SupportModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function SupportModal({ isOpen, onClose }: SupportModalProps) {
  const [step, setStep] = useState<'form' | 'chat'>('form');
  const [customerId, setCustomerId] = useState('');
  const [email, setEmail] = useState('');
  const [ticketId, setTicketId] = useState<string | null>(null);
  const [messages, setMessages] = useState<SupportMessage[]>([]);
  const [newMessage, setNewMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [assignedAgent, setAssignedAgent] = useState<Agent | null>(null);
  const [isAgentTyping, setIsAgentTyping] = useState(false);
  const [agentStats, setAgentStats] = useState<{ total: number; byRegion: Record<string, number> }>({ total: 0, byRegion: {} });
  const [liveAgentCount, setLiveAgentCount] = useState(420);
  const [liveRegionCounts, setLiveRegionCounts] = useState<Record<string, number>>({});
  const [customerLanguage, setCustomerLanguage] = useState<string>('en');
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (isOpen) {
      getAgentStats().then(stats => {
        setAgentStats(stats);
        const initialRegionCounts: Record<string, number> = {
          'Turkish World': 45,
          'Europe': 95,
          'Arab World': 52,
          'Asia': 88,
          'Americas': 78,
          'Africa': 35,
          'Oceania': 27
        };
        setLiveRegionCounts(initialRegionCounts);
      });
    }
  }, [isOpen]);

  useEffect(() => {
    if (!isOpen) return;

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
  }, [isOpen]);

  useEffect(() => {
    if (!isOpen) {
      setStep('form');
      setCustomerId('');
      setEmail('');
      setTicketId(null);
      setMessages([]);
      setNewMessage('');
      setAssignedAgent(null);
      setIsAgentTyping(false);
    }
  }, [isOpen]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  useEffect(() => {
    if (step === 'chat' && inputRef.current) {
      setTimeout(() => {
        inputRef.current?.focus();
      }, 500);
    }
  }, [step]);

  useEffect(() => {
    if (!ticketId) return;

    const channel = supabase
      .channel(`support_ticket_${ticketId}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'support_messages',
          filter: `ticket_id=eq.${ticketId}`,
        },
        async (payload) => {
          const newMsg = payload.new as SupportMessage;

          if (newMsg.sender_type === 'admin') {
            setIsAgentTyping(false);

            if (newMsg.original_message && newMsg.original_language === 'tr' && customerLanguage !== 'tr') {
              const translated = await translateMessage(
                newMsg.original_message,
                'tr',
                customerLanguage
              );
              newMsg.message = translated.translatedText;
            }
          }

          setMessages((prev) => [...prev, newMsg]);
        }
      )
      .subscribe();

    const typingChannel = supabase
      .channel(`ticket_${ticketId}_typing`)
      .on('broadcast', { event: 'admin_typing' }, (payload) => {
        if (payload.payload.ticketId === ticketId) {
          setIsAgentTyping(payload.payload.isTyping);
        }
      })
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
      supabase.removeChannel(typingChannel);
    };
  }, [ticketId, customerLanguage]);

  useEffect(() => {
    if (messages.length > 0 && messages[messages.length - 1].sender_type === 'customer') {
      setIsAgentTyping(true);
      const timer = setTimeout(() => {
        setIsAgentTyping(false);
      }, 5000);
      return () => clearTimeout(timer);
    }
  }, [messages]);

  const handleStartChat = async () => {
    if (!customerId.trim() || !email.trim()) return;

    setIsLoading(true);
    try {
      const { data: verifyResult, error: verifyError } = await supabase
        .rpc('verify_support_user', {
          p_customer_id: customerId.trim(),
          p_email: email.trim()
        });

      if (verifyError) {
        console.error('Verification error:', verifyError);
        alert('Error verifying credentials. Please try again.');
        setIsLoading(false);
        return;
      }

      if (!verifyResult || verifyResult.length === 0) {
        alert('Invalid credentials. Customer ID/Username and Email do not match any registered account.');
        setIsLoading(false);
        return;
      }

      const userId = verifyResult[0].user_id;

      const countryInfo = await detectUserCountry();

      const languageMap: Record<string, string> = {
        'TR': 'Turkish',
        'ES': 'Spanish',
        'MX': 'Spanish',
        'DE': 'German',
        'IT': 'Italian',
        'FR': 'French',
        'CN': 'Chinese',
        'JP': 'Japanese',
        'KR': 'Korean',
        'SA': 'Arabic',
        'AE': 'Arabic',
        'PL': 'Polish',
        'IN': 'Hindi'
      };

      const userLanguage = languageMap[countryInfo.country_code] || 'English';

      const agent = await assignBestAgent({
        countryCode: countryInfo.country_code,
        language: userLanguage,
        specialty: 'account'
      });

      const { data: ticket, error } = await supabase
        .from('support_tickets')
        .insert({
          customer_id: userId,
          email: email.trim(),
          status: 'open',
          customer_country: countryInfo.country_code,
          assigned_agent_id: agent?.id || null,
        })
        .select()
        .single();

      if (error) throw error;

      setTicketId(ticket.id);
      setAssignedAgent(agent);

      const { data: messagesData } = await supabase
        .from('support_messages')
        .select('*')
        .eq('ticket_id', ticket.id)
        .order('created_at', { ascending: true });

      const browserLang = navigator.language.split('-')[0].toLowerCase();
      console.log('Browser language detected:', browserLang);

      const supportedLangs = ['tr', 'en', 'es', 'de', 'fr', 'it', 'nl', 'pt', 'ru', 'pl', 'zh', 'ja', 'ko', 'ar', 'hi', 'sv', 'no', 'da', 'fi', 'el', 'cs', 'hu', 'ro', 'bg', 'uk', 'az', 'ka', 'th', 'vi', 'id', 'tl', 'ms'];

      const customerLangCode = countryInfo.country_code.toLowerCase();
      const countryToLang: Record<string, string> = {
        'tr': 'tr',
        'us': 'en', 'gb': 'en', 'uk': 'en', 'au': 'en', 'ca': 'en', 'nz': 'en',
        'es': 'es', 'mx': 'es', 'ar': 'es', 'co': 'es', 've': 'es',
        'de': 'de', 'at': 'de', 'ch': 'de',
        'fr': 'fr', 'be': 'fr',
        'it': 'it',
        'nl': 'nl',
        'pt': 'pt', 'br': 'pt',
        'ru': 'ru',
        'pl': 'pl',
        'cn': 'zh', 'tw': 'zh',
        'jp': 'ja',
        'kr': 'ko',
        'sa': 'ar', 'ae': 'ar', 'eg': 'ar', 'iq': 'ar', 'jo': 'ar',
        'in': 'hi',
        'se': 'sv',
        'no': 'no',
        'dk': 'da',
        'fi': 'fi',
        'gr': 'el',
        'cz': 'cs',
        'hu': 'hu',
        'ro': 'ro',
        'bg': 'bg',
        'ua': 'uk',
        'az': 'az',
        'ka': 'ka',
        'th': 'th',
        'vn': 'vi',
        'id': 'id',
        'ph': 'tl',
        'my': 'ms'
      };

      let customerLang = 'en';
      if (supportedLangs.includes(browserLang)) {
        customerLang = browserLang;
      } else if (countryToLang[customerLangCode]) {
        customerLang = countryToLang[customerLangCode];
      }
      console.log('Customer browser lang:', browserLang, '| country:', countryInfo.country_code, '-> final language:', customerLang);

      setCustomerLanguage(customerLang);

      const translatedMessages = await Promise.all(
        (messagesData || []).map(async (msg: SupportMessage) => {
          if (msg.sender_type === 'admin' && msg.original_message && msg.original_language === 'tr' && customerLang !== 'tr') {
            const translated = await translateMessage(msg.original_message, 'tr', customerLang);
            return { ...msg, message: translated.translatedText };
          }
          return msg;
        })
      );

      setMessages(translatedMessages);
      setStep('chat');
    } catch (error) {
      console.error('Error creating ticket:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const translateMessage = async (text: string, sourceLang: string, targetLang: string) => {
    try {
      const apiUrl = `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/translate-message`;

      const response = await fetch(apiUrl, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          text,
          sourceLang,
          targetLang,
        }),
      });

      if (!response.ok) {
        throw new Error('Translation failed');
      }

      return await response.json();
    } catch (error) {
      console.error('Translation error:', error);
      return { translatedText: text, detectedLanguage: sourceLang };
    }
  };

  const handleSendMessage = async () => {
    if (!newMessage.trim() || !ticketId || !assignedAgent) return;

    const messageText = newMessage.trim();
    const isFirstMessage = messages.length === 0;
    setNewMessage('');

    try {
      const translation = await translateMessage(messageText, customerLanguage, 'tr');
      const translatedToTurkish = translation.translatedText;

      console.log('Customer message:', messageText);
      console.log('Customer language:', customerLanguage);
      console.log('Translated to Turkish:', translatedToTurkish);

      const { error } = await supabase.from('support_messages').insert({
        ticket_id: ticketId,
        sender_type: 'customer',
        sender_name: customerId,
        message: translatedToTurkish,
        original_message: messageText,
        original_language: customerLanguage,
      });

      if (error) throw error;

      if (isFirstMessage) {
        setIsAgentTyping(true);

        setTimeout(async () => {
          const greetingMessage = getAgentGreeting(assignedAgent);
          const greetingTranslated = await translateMessage(greetingMessage, 'tr', customerLanguage);

          await supabase.from('support_messages').insert({
            ticket_id: ticketId,
            sender_type: 'admin',
            sender_name: assignedAgent.name,
            message: greetingTranslated.translatedText,
            original_message: greetingMessage,
            original_language: 'tr',
          });

          setIsAgentTyping(false);
        }, 2000 + Math.random() * 2000);
      }
    } catch (error) {
      console.error('Error sending message:', error);
      setNewMessage(messageText);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/50 flex items-end sm:items-center justify-center z-50 sm:p-4">
      <div className="bg-[#181A20] sm:rounded-lg w-full h-[100dvh] sm:h-auto flex flex-col overflow-hidden sm:max-h-[90vh] sm:max-w-lg">
        <div className="flex items-center justify-between border-b border-[#2B3139] p-4">
          {step === 'chat' && assignedAgent ? (
            <div className="flex items-center gap-3">
              <img
                src={assignedAgent.avatar_url}
                alt={assignedAgent.name}
                className="w-10 h-10 rounded-full object-cover border-[#F0B90B]"
                onError={(e) => {
                  console.error('Failed to load avatar:', assignedAgent.avatar_url);
                  e.currentTarget.src = 'https://ui-avatars.com/api/?name=' + encodeURIComponent(assignedAgent.name) + '&background=F0B90B&color=181A20&size=128&bold=true';
                }}
              />
              <div className="flex-1">
                <div className="flex items-center gap-2">
                  <h3 className="font-semibold text-sm">
                    {assignedAgent.name}
                  </h3>
                  <span className="text-xl">{assignedAgent.flag_emoji || assignedAgent.flag}</span>
                  <span className="px-2 py-0.5 bg-opacity-20 font-bold text-xs rounded">
                    {assignedAgent.country_code}
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <div className="flex items-center gap-1.5">
                    <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                    <span className="text-green-400 font-medium">Online</span>
                  </div>
                  <span className="text-gray-500">•</span>
                  <span className="text-gray-300">{assignedAgent.region}</span>
                </div>
              </div>
            </div>
          ) : (
            <div className="flex items-center gap-3">
              <div className="flex items-center gap-2">
                <div className="w-2.5 h-2.5 bg-[#F0B90B] rounded-full animate-pulse"></div>
                <h3 className="text-white font-black text-lg tracking-wide">
                  {step === 'form' ? 'SUPPORT' : 'LIVE SUPPORT'}
                </h3>
              </div>
              <div className="flex items-center gap-1 bg-[#F0B90B]/20 border border-[#F0B90B] px-3 py-1 rounded-full">
                <span className="text-[#F0B90B] font-black text-xs tracking-wider">24/7</span>
              </div>
            </div>
          )}
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-white transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {step === 'form' ? (
          <div className="overflow-y-auto p-6 space-y-6">
            <div className="text-center space-y-4">
              <div className="bg-opacity-10 rounded-full flex items-center justify-center mx-auto animate-pulse w-16 h-16">
                <Globe className="text-[#F0B90B] w-8 h-8" />
              </div>
              <div>
                <h3 className="font-black text-2xl mb-3 tracking-wide">Global Support Network</h3>
                <div className="flex items-center justify-center mb-2 gap-2">
                  <div className="bg-green-500 rounded-full animate-pulse w-2.5 h-2.5"></div>
                  <p className="font-black text-xl">
                    {liveAgentCount}+ Agents Online
                  </p>
                </div>
                <div className="inline-flex items-center justify-center gap-2 bg-[#F0B90B]/20 border border-[#F0B90B] px-4 py-1.5 rounded-full">
                  <span className="text-[#F0B90B] font-black text-sm tracking-wider">24/7 PROFESSIONAL SUPPORT</span>
                </div>
              </div>
              <div className="grid grid-cols-2 max-w-md mx-auto gap-2">
                {Object.entries(liveRegionCounts).map(([region, count]) => (
                  <div key={region} className="flex items-center justify-between bg-[#2B3139] rounded-lg px-3 py-2">
                    <div className="flex items-center gap-2">
                      <div className="bg-green-500 rounded-full animate-pulse w-2 h-2"></div>
                      <span className="font-medium truncate text-xs">{region}</span>
                    </div>
                    <span className="font-bold text-sm">{count}</span>
                  </div>
                ))}
              </div>
              <div className="flex items-center justify-center gap-2 pt-2">
                <div className="flex items-center gap-1">
                  <div className="w-1.5 h-1.5 bg-green-500 rounded-full animate-ping"></div>
                  <span className="font-medium text-xs">Live</span>
                </div>
                <span className="text-xs">•</span>
                <span className="text-xs">Response: 45s</span>
              </div>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-sm mb-2">
                  Customer ID
                </label>
                <input
                  type="text"
                  value={customerId}
                  onChange={(e) => setCustomerId(e.target.value)}
                  placeholder="e.g. 100007"
                  className="w-full bg-[#2B3139] rounded-lg focus:ring-[#F0B90B] text-base px-4 py-3"
                />
              </div>

              <div>
                <label className="block text-sm mb-2">
                  Email Address
                </label>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="your@email.com"
                  className="w-full bg-[#2B3139] rounded-lg focus:ring-[#F0B90B] text-base px-4 py-3"
                />
              </div>

              <button
                onClick={handleStartChat}
                disabled={isLoading || !customerId.trim() || !email.trim()}
                className="w-full bg-[#F0B90B] hover:bg-[#F0B90B] font-semibold rounded-lg transition-colors disabled:cursor-not-allowed text-base py-3"
              >
                {isLoading ? 'Starting...' : 'Start Chat'}
              </button>
            </div>

            <div className="border-[#2B3139] pt-4">
              <p className="text-xs">
                By continuing, you agree to our Terms of Service and Privacy Policy
              </p>
            </div>
          </div>
        ) : (
          <>
            <div className="flex-1 overflow-y-auto p-4 space-y-3 min-h-0">
              {messages.length === 0 ? (
                <div className="flex items-center justify-center h-full">
                  <div className="text-center space-y-2">
                    <p className="text-gray-400">No messages yet</p>
                    <p className="text-gray-500 text-sm">
                      Send a message to start the conversation
                    </p>
                  </div>
                </div>
              ) : (
                <>
                  {messages.map((msg) => (
                    <div
                      key={msg.id}
                      className={`flex ${ msg.sender_type === 'customer' ? 'justify-end' : 'justify-start' }`}
                    >
                      <div
                        className={`max-w-[70%] rounded-lg p-3 ${ msg.sender_type === 'customer' ? 'bg-[#F0B90B] text-[#181A20]' : 'bg-[#2B3139] text-white' }`}
                      >
                        <div className="flex items-center gap-2 mb-1">
                          <span className="text-xs font-semibold">
                            {msg.sender_type === 'customer' ? 'You' : assignedAgent?.name || 'Support Team'}
                          </span>
                          <span className="text-xs opacity-60">
                            {new Date(msg.created_at).toLocaleTimeString('en-US', {
                              hour: '2-digit',
                              minute: '2-digit',
                            })}
                          </span>
                        </div>
                        <p className="text-sm break-words">{msg.message}</p>
                        {msg.sender_type === 'customer' && (
                          <div className="flex justify-end mt-1">
                            {msg.read ? (
                              <CheckCheck className="w-3 h-3 opacity-60" />
                            ) : (
                              <Check className="w-3 h-3 opacity-60" />
                            )}
                          </div>
                        )}
                      </div>
                    </div>
                  ))}
                  {isAgentTyping && (
                    <div className="flex justify-start">
                      <div className="bg-[#2B3139] text-white rounded-lg p-3 max-w-[70%]">
                        <div className="flex items-center gap-2 mb-1">
                          <span className="text-xs font-semibold">
                            {assignedAgent?.name || 'Support Team'}
                          </span>
                        </div>
                        <div className="flex items-center gap-1">
                          <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                          <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                          <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.4s' }}></div>
                        </div>
                      </div>
                    </div>
                  )}
                </>
              )}
              <div ref={messagesEndRef} />
            </div>

            <div className="flex-shrink-0 bg-[#181A20] border-t border-[#2B3139] p-4 pb-6 safe-area-bottom">
              <div className="flex gap-2">
                <input
                  ref={inputRef}
                  type="text"
                  value={newMessage}
                  onChange={(e) => setNewMessage(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && !e.shiftKey && handleSendMessage()}
                  placeholder="Type your message..."
                  className="flex-1 bg-[#2B3139] text-white placeholder-gray-500 px-4 py-3 rounded-lg focus:ring-2 focus:ring-[#F0B90B] focus:outline-none text-base"
                  autoComplete="off"
                  inputMode="text"
                />
                <button
                  onClick={handleSendMessage}
                  disabled={!newMessage.trim()}
                  className="bg-[#F0B90B] hover:bg-[#F0B90B] text-[#181A20] p-3 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex-shrink-0"
                >
                  <Send className="w-5 h-5" />
                </button>
              </div>
              {ticketId && (
                <p className="text-xs text-gray-500 mt-2">
                  Ticket ID: {ticketId.slice(0, 8).toUpperCase()}
                </p>
              )}
            </div>
          </>
        )}
      </div>
    </div>
  );
}
