import { useState, useEffect, useRef } from 'react';
import { MessageSquare, Send, ArrowLeft, Trash2, RefreshCw, AlertCircle, Globe } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { getCountryFlag } from '../lib/geolocation';

interface Agent {
  id: string;
  name: string;
  country_code: string;
  avatar_url: string;
}

interface SupportTicket {
  id: string;
  customer_id: string;
  email: string;
  status: 'open' | 'in_progress' | 'closed';
  created_at: string;
  updated_at: string;
  unread_count?: number;
  customer_country?: string;
  support_agents?: Agent;
}

interface SupportMessage {
  id: string;
  ticket_id: string;
  sender_type: 'customer' | 'admin';
  sender_name: string;
  message: string;
  created_at: string;
  read: boolean;
  original_message?: string;
  original_language?: string;
}

const LANGUAGE_FLAGS: Record<string, string> = {
  'tr': '🇹🇷',
  'en': '🇬🇧',
  'es': '🇪🇸',
  'de': '🇩🇪',
  'fr': '🇫🇷',
  'it': '🇮🇹',
  'pt': '🇵🇹',
  'ru': '🇷🇺',
  'ja': '🇯🇵',
  'zh': '🇨🇳',
  'ar': '🇸🇦',
  'hi': '🇮🇳',
  'ko': '🇰🇷',
  'unknown': '🌐',
};

const LANGUAGE_NAMES: Record<string, string> = {
  'tr': 'Türkçe',
  'en': 'English',
  'es': 'Español',
  'de': 'Deutsch',
  'fr': 'Français',
  'it': 'Italiano',
  'nl': 'Nederlands',
  'pt': 'Português',
  'ru': 'Русский',
  'pl': 'Polski',
  'cs': 'Čeština',
  'ro': 'Română',
  'el': 'Ελληνικά',
  'sv': 'Svenska',
  'no': 'Norsk',
  'da': 'Dansk',
  'fi': 'Suomi',
  'hu': 'Magyar',
  'bg': 'Български',
  'hr': 'Hrvatski',
  'sk': 'Slovenčina',
  'sl': 'Slovenščina',
  'lt': 'Lietuvių',
  'lv': 'Latviešu',
  'et': 'Eesti',
  'ja': '日本語',
  'zh': '中文',
  'ko': '한국어',
  'ar': 'العربية',
  'he': 'עברית',
  'fa': 'فارسی',
  'hi': 'हिन्दी',
  'bn': 'বাংলা',
  'ur': 'اردو',
  'ta': 'தமிழ்',
  'te': 'తెలుగు',
  'mr': 'मराठी',
  'gu': 'ગુજરાતી',
  'kn': 'ಕನ್ನಡ',
  'ml': 'മലയാളം',
  'pa': 'ਪੰਜਾਬੀ',
  'th': 'ไทย',
  'vi': 'Tiếng Việt',
  'id': 'Bahasa Indonesia',
  'ms': 'Bahasa Melayu',
  'tl': 'Tagalog',
  'uk': 'Українська',
  'sr': 'Српски',
  'sq': 'Shqip',
  'mk': 'Македонски',
  'bs': 'Bosanski',
  'is': 'Íslenska',
  'ga': 'Gaeilge',
  'cy': 'Cymraeg',
  'mt': 'Malti',
  'ca': 'Català',
  'eu': 'Euskara',
  'gl': 'Galego',
  'af': 'Afrikaans',
  'sw': 'Kiswahili',
  'az': 'Azərbaycan',
  'ka': 'ქართული',
  'hy': 'Հայերեն',
  'kk': 'Қазақша',
  'uz': "O'zbek",
  'tk': 'Türkmen',
  'ky': 'Кыргызча',
  'tg': 'Тоҷикӣ',
  'mn': 'Монгол',
  'be': 'Беларуская',
  'unknown': 'Unknown',
};

export default function SupportTicketsPanel() {
  const [tickets, setTickets] = useState<SupportTicket[]>([]);
  const [selectedTicket, setSelectedTicket] = useState<SupportTicket | null>(null);
  const [messages, setMessages] = useState<SupportMessage[]>([]);
  const [newMessage, setNewMessage] = useState('');
  const [filterStatus, setFilterStatus] = useState<'all' | 'open' | 'closed'>('open');
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const [showOriginal, setShowOriginal] = useState<Record<string, boolean>>({});
  const [translating, setTranslating] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const typingTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  const ADMIN_LANGUAGE = 'tr';

  const playNotificationSound = () => {
    try {
      const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
      const oscillator = audioContext.createOscillator();
      const gainNode = audioContext.createGain();

      oscillator.connect(gainNode);
      gainNode.connect(audioContext.destination);

      oscillator.frequency.value = 800;
      oscillator.type = 'sine';

      gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
      gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.5);

      oscillator.start(audioContext.currentTime);
      oscillator.stop(audioContext.currentTime + 0.5);
    } catch (error) {
      console.error('Bildirim sesi çalınamadı:', error);
    }
  };

  useEffect(() => {
    fetchTickets();

    const channel = supabase
      .channel('admin_support_tickets')
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'support_messages' }, (payload) => {
        const newMsg = payload.new as SupportMessage;
        if (newMsg.sender_type === 'customer') {
          playNotificationSound();
        }
        fetchTickets();
      })
      .on('postgres_changes', { event: '*', schema: 'public', table: 'support_tickets' }, () => {
        fetchTickets();
      })
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [filterStatus]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  useEffect(() => {
    if (!selectedTicket) return;

    const channel = supabase
      .channel(`admin_ticket_${selectedTicket.id}`)
      .on('postgres_changes', {
        event: 'INSERT',
        schema: 'public',
        table: 'support_messages',
        filter: `ticket_id=eq.${selectedTicket.id}`,
      }, async (payload) => {
        const newMsg = payload.new as SupportMessage;

        if (newMsg.sender_type === 'customer') {
          playNotificationSound();

          if (newMsg.original_language && newMsg.original_language !== ADMIN_LANGUAGE) {
            const translated = await translateMessage(newMsg.original_message || newMsg.message, newMsg.original_language, ADMIN_LANGUAGE);

            if (!translated.translatedText.includes('PLEASE SELECT TWO DISTINCT LANGUAGES') &&
                !translated.translatedText.includes('ERROR')) {
              newMsg.message = translated.translatedText;
            } else {
              newMsg.message = newMsg.original_message || newMsg.message;
            }
          }
        } else if (newMsg.sender_type === 'admin' && newMsg.original_message) {
          newMsg.message = newMsg.original_message;
        }

        setMessages((prev) => [...prev, newMsg]);
      })
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [selectedTicket]);

  const translateMessage = async (text: string, sourceLang: string, targetLang: string) => {
    return { translatedText: text, detectedLanguage: sourceLang };
  };

  const fetchTickets = async () => {
    setLoading(true);
    try {
      let query = supabase
        .from('support_tickets')
        .select(`
          *,
          support_agents (
            id,
            name,
            country_code,
            avatar_url
          )
        `)
        .order('updated_at', { ascending: false });

      if (filterStatus !== 'all') {
        query = query.eq('status', filterStatus);
      }

      const { data, error } = await query;
      if (error) throw error;

      const ticketsWithUnread = await Promise.all(
        (data || []).map(async (ticket) => {
          const { count } = await supabase
            .from('support_messages')
            .select('*', { count: 'exact', head: true })
            .eq('ticket_id', ticket.id)
            .eq('sender_type', 'customer')
            .eq('read', false);

          return { ...ticket, unread_count: count || 0 };
        })
      );

      setTickets(ticketsWithUnread);
    } catch (error) {
      console.error('Error fetching tickets:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchMessages = async (ticketId: string) => {
    try {
      const { data, error } = await supabase
        .from('support_messages')
        .select('*')
        .eq('ticket_id', ticketId)
        .order('created_at', { ascending: true });

      if (error) throw error;

      const translatedMessages = await Promise.all(
        (data || []).map(async (msg) => {
          if (msg.sender_type === 'customer' && msg.original_language && msg.original_language !== ADMIN_LANGUAGE) {
            const translated = await translateMessage(
              msg.original_message || msg.message,
              msg.original_language,
              ADMIN_LANGUAGE
            );

            if (!translated.translatedText.includes('PLEASE SELECT TWO DISTINCT LANGUAGES') &&
                !translated.translatedText.includes('ERROR')) {
              return { ...msg, message: translated.translatedText };
            }
            return { ...msg, message: msg.original_message || msg.message };
          } else if (msg.sender_type === 'admin' && msg.original_message) {
            return { ...msg, message: msg.original_message };
          }
          return msg;
        })
      );

      setMessages(translatedMessages);

      await supabase
        .from('support_messages')
        .update({ read: true })
        .eq('ticket_id', ticketId)
        .eq('sender_type', 'customer')
        .eq('read', false);

      setTickets((prev) =>
        prev.map((t) =>
          t.id === ticketId ? { ...t, unread_count: 0 } : t
        )
      );
    } catch (error) {
      console.error('Error fetching messages:', error);
    }
  };

  const handleSelectTicket = async (ticket: SupportTicket) => {
    setSelectedTicket(ticket);
    fetchMessages(ticket.id);

    const customerLang = await detectCustomerLanguage(ticket.id);
    if (customerLang) {
      setDetectedCustomerLang(customerLang);
      setAdminReplyLanguage(customerLang);
    }
  };

  const broadcastTypingStatus = async (isTyping: boolean) => {
    if (!selectedTicket) return;

    try {
      const channel = supabase.channel(`ticket_${selectedTicket.id}_typing`);
      await channel.send({
        type: 'broadcast',
        event: 'admin_typing',
        payload: { isTyping, ticketId: selectedTicket.id }
      });
    } catch (error) {
      console.error('Error broadcasting typing status:', error);
    }
  };

  const handleMessageInput = (value: string) => {
    setNewMessage(value);

    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current);
    }

    if (value.trim()) {
      broadcastTypingStatus(true);

      typingTimeoutRef.current = setTimeout(() => {
        broadcastTypingStatus(false);
      }, 3000);
    } else {
      broadcastTypingStatus(false);
    }
  };

  const handleSendMessage = async () => {
    if (!newMessage.trim() || !selectedTicket || sending) return;

    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current);
    }
    broadcastTypingStatus(false);

    setSending(true);
    setTranslating(true);

    try {
      const customerLanguage = await detectCustomerLanguage(selectedTicket.id);
      const originalText = newMessage.trim();
      let messageToSend = originalText;

      if (customerLanguage && customerLanguage !== ADMIN_LANGUAGE) {
        const translation = await translateMessage(originalText, ADMIN_LANGUAGE, customerLanguage);

        if (translation.translatedText.includes('PLEASE SELECT TWO DISTINCT LANGUAGES') ||
            translation.translatedText.includes('ERROR') ||
            translation.translatedText === originalText && originalText.length > 10) {
          messageToSend = originalText;
        } else {
          messageToSend = translation.translatedText;
        }
      }

      const { error } = await supabase.from('support_messages').insert({
        ticket_id: selectedTicket.id,
        sender_type: 'admin',
        sender_name: 'Admin',
        message: messageToSend,
        original_message: originalText,
        original_language: ADMIN_LANGUAGE,
        read: true,
      });

      if (error) throw error;

      setNewMessage('');

      if (selectedTicket.status === 'open') {
        await supabase
          .from('support_tickets')
          .update({ status: 'in_progress', updated_at: new Date().toISOString() })
          .eq('id', selectedTicket.id);
      }

      await fetchMessages(selectedTicket.id);
      await fetchTickets();
    } catch (error) {
      console.error('Error sending message:', error);
    } finally {
      setSending(false);
      setTranslating(false);
    }
  };

  const detectCustomerLanguage = async (ticketId: string): Promise<string | null> => {
    try {
      const { data } = await supabase
        .from('support_messages')
        .select('original_language')
        .eq('ticket_id', ticketId)
        .eq('sender_type', 'customer')
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle();

      console.log('Detected customer language:', data?.original_language);
      return data?.original_language || 'en';
    } catch (error) {
      console.error('Error detecting language:', error);
      return 'en';
    }
  };

  const handleDeleteTicket = async (ticketId: string) => {
    if (!confirm('Bu ticketı ve tüm mesajlarını silmek istediğinize emin misiniz?')) return;

    try {
      if (selectedTicket?.id === ticketId) {
        setSelectedTicket(null);
        setMessages([]);
      }

      const { error: messagesError } = await supabase
        .from('support_messages')
        .delete()
        .eq('ticket_id', ticketId);

      if (messagesError) {
        console.error('Error deleting messages:', messagesError);
        throw messagesError;
      }

      const { error: ticketError } = await supabase
        .from('support_tickets')
        .delete()
        .eq('id', ticketId);

      if (ticketError) {
        console.error('Error deleting ticket:', ticketError);
        throw ticketError;
      }

      setTickets((prev) => prev.filter((t) => t.id !== ticketId));
    } catch (error) {
      console.error('Error deleting ticket:', error);
      alert('Ticket silinirken hata oluştu: ' + (error as Error).message);
    }
  };

  const handleCloseTicket = async (ticketId: string) => {
    try {
      await supabase
        .from('support_tickets')
        .update({ status: 'closed', updated_at: new Date().toISOString() })
        .eq('id', ticketId);

      await fetchTickets();
      if (selectedTicket?.id === ticketId) {
        setSelectedTicket((prev) => prev ? { ...prev, status: 'closed' } : null);
      }
    } catch (error) {
      console.error('Error closing ticket:', error);
    }
  };

  const toggleOriginalMessage = (messageId: string) => {
    setShowOriginal((prev) => ({
      ...prev,
      [messageId]: !prev[messageId],
    }));
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const days = Math.floor(hours / 24);

    if (days > 0) return `${days}d ago`;
    if (hours > 0) return `${hours}h ago`;
    return 'Now';
  };

  const getShortId = (id: string) => {
    return id.substring(0, 8).toUpperCase();
  };

  if (selectedTicket) {
    return (
      <div className="flex flex-col h-[calc(100vh-200px)] bg-[#0B0E11]">
        <div className="bg-[#1E2329] border-b border-gray-700 p-4 flex items-center gap-3">
          <button
            onClick={() => setSelectedTicket(null)}
            className="text-gray-400 hover:text-white transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>

          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-1">
              {selectedTicket.customer_country && (
                <span className="text-lg">{getCountryFlag(selectedTicket.customer_country)}</span>
              )}
              <p className="text-white font-medium truncate">{selectedTicket.email}</p>
            </div>
            <div className="flex items-center gap-2">
              <p className="text-xs text-gray-400">ID: {getShortId(selectedTicket.id)}</p>
            </div>
          </div>

          <div className="flex gap-2">
            {selectedTicket.status !== 'closed' && (
              <button
                onClick={() => handleCloseTicket(selectedTicket.id)}
                className="px-3 py-1.5 bg-green-600 hover:bg-green-700 text-white text-xs font-medium rounded-lg transition-colors"
              >
                Close
              </button>
            )}
            <button
              onClick={() => handleDeleteTicket(selectedTicket.id)}
              className="p-2 bg-red-500/20 hover:bg-red-500/30 text-red-400 rounded-lg transition-colors"
            >
              <Trash2 className="w-4 h-4" />
            </button>
          </div>
        </div>

        <div className="flex-1 overflow-y-auto p-4 space-y-3">
          {messages.map((msg) => {
            const isOriginalShown = showOriginal[msg.id];
            const displayText = isOriginalShown && msg.original_message ? msg.original_message : msg.message;
            const hasTranslation = msg.original_message && msg.original_message !== msg.message;

            return (
              <div
                key={msg.id}
                className={`flex ${msg.sender_type === 'admin' ? 'justify-end' : 'justify-start'}`}
              >
                <div className="max-w-[85%]">
                  <div
                    className={`rounded-2xl px-4 py-3 ${
                      msg.sender_type === 'admin'
                        ? 'bg-[#F0B90B] text-black'
                        : 'bg-[#2B3139] text-white'
                    }`}
                  >
                    {hasTranslation && (
                      <div className="flex items-center gap-2 mb-2 pb-2 border-b border-black/10">
                        <Globe className="w-3 h-3" />
                        <span className="text-xs opacity-70">
                          {isOriginalShown ? LANGUAGE_FLAGS[msg.original_language || 'unknown'] : '🇹🇷'} {isOriginalShown ? LANGUAGE_NAMES[msg.original_language || 'unknown'] : 'Türkçe Çeviri'}
                        </span>
                        <button
                          onClick={() => toggleOriginalMessage(msg.id)}
                          className={`ml-auto text-xs font-medium underline ${
                            msg.sender_type === 'admin' ? 'text-black/70 hover:text-black' : 'text-white/70 hover:text-white'
                          }`}
                        >
                          {isOriginalShown ? 'Çeviriyi Göster' : 'Orijinali Göster'}
                        </button>
                      </div>
                    )}
                    <p className="text-sm break-words">{displayText}</p>
                    <p
                      className={`text-xs mt-1 ${
                        msg.sender_type === 'admin' ? 'text-black/60' : 'text-gray-400'
                      }`}
                    >
                      {formatDate(msg.created_at)}
                    </p>
                  </div>
                </div>
              </div>
            );
          })}
          <div ref={messagesEndRef} />
        </div>

        {selectedTicket.status !== 'closed' && (
          <div className="bg-[#1E2329] border-t border-gray-700 p-4">
            <div className="flex gap-2">
              <input
                type="text"
                value={newMessage}
                onChange={(e) => handleMessageInput(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && !e.shiftKey && handleSendMessage()}
                placeholder="Türkçe mesajınızı yazın..."
                className="flex-1 bg-[#2B3139] text-white px-4 py-3 rounded-xl border border-gray-600 focus:border-[#F0B90B] focus:outline-none"
                disabled={sending}
              />
              <button
                onClick={handleSendMessage}
                disabled={!newMessage.trim() || sending}
                className="bg-[#F0B90B] hover:bg-[#F0B90B]/90 text-black p-3 rounded-xl transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Send className="w-5 h-5" />
              </button>
            </div>
          </div>
        )}
      </div>
    );
  }

  return (
    <div className="bg-[#0B0E11] min-h-[calc(100vh-200px)]">
      <div className="bg-[#1E2329] border-b border-gray-700 p-4">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <MessageSquare className="w-5 h-5 text-[#F0B90B]" />
            <h3 className="text-white font-bold text-lg">Support Tickets</h3>
            <Globe className="w-4 h-4 text-green-400" title="Otomatik Çeviri Aktif" />
          </div>
          <button
            onClick={fetchTickets}
            className="text-gray-400 hover:text-white transition-colors"
          >
            <RefreshCw className={`w-5 h-5 ${loading ? 'animate-spin' : ''}`} />
          </button>
        </div>

        <div className="flex gap-2">
          <button
            onClick={() => setFilterStatus('open')}
            className={`flex-1 py-2 px-4 rounded-lg font-medium text-sm transition-colors ${
              filterStatus === 'open'
                ? 'bg-[#F0B90B] text-black'
                : 'bg-[#2B3139] text-gray-400 hover:text-white'
            }`}
          >
            Open ({tickets.filter(t => t.status === 'open').length})
          </button>
          <button
            onClick={() => setFilterStatus('all')}
            className={`flex-1 py-2 px-4 rounded-lg font-medium text-sm transition-colors ${
              filterStatus === 'all'
                ? 'bg-[#F0B90B] text-black'
                : 'bg-[#2B3139] text-gray-400 hover:text-white'
            }`}
          >
            All ({tickets.length})
          </button>
          <button
            onClick={() => setFilterStatus('closed')}
            className={`flex-1 py-2 px-4 rounded-lg font-medium text-sm transition-colors ${
              filterStatus === 'closed'
                ? 'bg-[#F0B90B] text-black'
                : 'bg-[#2B3139] text-gray-400 hover:text-white'
            }`}
          >
            Closed ({tickets.filter(t => t.status === 'closed').length})
          </button>
        </div>
      </div>

      <div className="p-4 space-y-3">
        {loading ? (
          <div className="text-center py-12">
            <RefreshCw className="w-8 h-8 text-gray-400 animate-spin mx-auto" />
          </div>
        ) : tickets.length === 0 ? (
          <div className="text-center py-12">
            <AlertCircle className="w-12 h-12 text-gray-600 mx-auto mb-3" />
            <p className="text-gray-400">Ticket bulunamadı</p>
          </div>
        ) : (
          tickets.map((ticket) => (
            <div
              key={ticket.id}
              onClick={() => handleSelectTicket(ticket)}
              className="bg-[#1E2329] rounded-xl p-4 border border-gray-700 hover:border-[#F0B90B]/50 transition-all cursor-pointer active:scale-98"
            >
              <div className="flex items-start justify-between mb-2">
                <div className="flex items-center gap-2 flex-1 min-w-0">
                  {ticket.customer_country && (
                    <span className="text-lg">{getCountryFlag(ticket.customer_country)}</span>
                  )}
                  <div className="flex-1 min-w-0">
                    <p className="text-white font-medium truncate">{ticket.email}</p>
                    <p className="text-xs text-gray-500">ID: {getShortId(ticket.id)}</p>
                  </div>
                </div>

                {ticket.unread_count! > 0 && (
                  <span className="bg-red-500 text-white text-xs font-bold rounded-full w-6 h-6 flex items-center justify-center flex-shrink-0 ml-2">
                    {ticket.unread_count}
                  </span>
                )}
              </div>

              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <span
                    className={`px-2 py-1 rounded-md text-xs font-medium ${
                      ticket.status === 'open'
                        ? 'bg-blue-500/20 text-blue-400'
                        : ticket.status === 'in_progress'
                        ? 'bg-yellow-500/20 text-yellow-400'
                        : 'bg-gray-500/20 text-gray-400'
                    }`}
                  >
                    {ticket.status === 'open' ? 'Open' : ticket.status === 'in_progress' ? 'In Progress' : 'Closed'}
                  </span>

                  {ticket.support_agents && (
                    <div className="flex items-center gap-1">
                      <img
                        src={ticket.support_agents.avatar_url}
                        alt={ticket.support_agents.name}
                        className="w-5 h-5 rounded-full"
                      />
                      <span className="text-xs text-gray-400">{ticket.support_agents.name.split(' ')[0]}</span>
                    </div>
                  )}
                </div>

                <div className="flex items-center gap-2">
                  <span className="text-xs text-gray-500">{formatDate(ticket.updated_at)}</span>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      handleDeleteTicket(ticket.id);
                    }}
                    className="p-1.5 hover:bg-red-500/20 text-red-400 rounded-lg transition-colors"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
