import { X, ChevronDown, ChevronUp, Zap, Clock, DollarSign, Lock, TrendingUp, Award, AlertCircle, Shield, Cpu, Settings, Sparkles, Target, Info, Search } from 'lucide-react';
import { useState, useMemo } from 'react';

interface FAQModalProps {
  isOpen: boolean;
  onClose: () => void;
  isDemoMode?: boolean;
}

interface FAQItem {
  question: string;
  answer: string;
  icon: any;
  category: 'demo' | 'mining' | 'earnings' | 'equipment' | 'security' | 'technical' | 'advanced';
}

const faqData: FAQItem[] = [
    {
      question: 'What is Demo Mining Mode?',
      answer: 'Demo Mining is a FREE 15-minute trial experience that allows you to experience our mining system without registration. You\'ll earn real-time USDT rewards during the demo period. When you register after the demo, your demo earnings will be credited to your account, and you\'ll receive a FREE CPU Miner Pro to continue earning. Demo mode automatically prompts registration when the timer ends or when you click COLLECT.',
      icon: Sparkles,
      category: 'demo'
    },
    {
      question: 'How Does the Mining System Work?',
      answer: 'Mining simulates cryptocurrency mining operations. You purchase equipment (CPU Miner, GPU Miner, ASIC Miner, etc.), press START, and the equipment begins generating USDT automatically based on its hash rate and daily earning capacity. Each piece of equipment operates independently with its own timer, earning rate, and withdrawal limit. The system calculates earnings in real-time and displays them in your Session Earnings until you collect them.',
      icon: Zap,
      category: 'mining'
    },
    {
      question: 'How Are My Earnings Calculated?',
      answer: 'Each equipment has a fixed daily earning rate that\'s divided into hourly calculations. For example:\n\n• CPU Miner: $1.2/day = $0.05/hour\n• GPU Miner: $4.8/day = $0.20/hour\n• ASIC Miner: $12/day = $0.50/hour\n\nEarnings accumulate continuously while your equipment is running. The "Session Earned" shows current session earnings, while "Total Earned" displays your cumulative lifetime earnings from all mining activities.',
      icon: DollarSign,
      category: 'earnings'
    },
    {
      question: 'What is EQ Token? How Does It Work?',
      answer: 'EQ (EarnQuest Token) is a bonus display metric on our platform. When you mine, you earn USDT as your primary currency. EQ is calculated based on your USDT balance and is displayed for visual representation only. EQ cannot be swapped or withdrawn - it\'s purely a showcase metric. Your actual, withdrawable earnings are always in USDT. Think of EQ as a loyalty points display that reflects your platform activity.',
      icon: Award,
      category: 'earnings'
    },
    {
      question: 'How Do I Collect My Mining Earnings?',
      answer: 'When mining, your USDT is temporarily stored in "Session Earnings" (locked state). To use this money, you must click the "COLLECT" button. After collection:\n\n1. Your Session Earnings are transferred to "Available Balance"\n2. Available Balance can be used for:\n   • Purchasing new equipment in the Shop\n   • Swapping to other cryptocurrencies\n   • Withdrawing to external wallets\n   • Trading on Spot/Futures markets\n\nNote: Session Earnings remain locked and unusable until collected.',
      icon: DollarSign,
      category: 'earnings'
    },
    {
      question: 'What Does the Mining Timer Mean?',
      answer: 'Each piece of equipment has a predefined operation duration:\n\n• CPU Miner: 3 hours\n• GPU Miner: 6 hours\n• ASIC Miner: 12 hours\n• Industrial Rigs: 24+ hours\n\nThe timer counts down while your equipment is active. When it reaches 0:00, the equipment automatically stops, and you can collect your earnings. After collecting, you can restart the equipment for another mining session. The timer ensures fair earning distribution and prevents infinite mining cycles.',
      icon: Clock,
      category: 'mining'
    },
    {
      question: 'What is Withdrawal Limit? Why Does It Exist?',
      answer: 'Each equipment tier has a minimum withdrawal threshold. This is the minimum total balance required to withdraw funds:\n\n• CPU Miner: $100 limit\n• GPU Miner: $50 limit\n• ASIC Miner: $25 limit\n• Industrial Miners: $10-15 limit\n\nThe withdrawal limit is calculated based on your highest-tier equipment owned. Your total balance (Available + Session Earnings) must exceed this limit to withdraw. This mechanism encourages equipment upgrades and platform engagement. Higher-tier equipment = lower withdrawal limits + higher earnings.',
      icon: Lock,
      category: 'security'
    },
    {
      question: 'What Are Locked Earnings? How Do I Unlock Them?',
      answer: 'Some equipment (particularly starter tiers like CPU Miner) may have single-use restrictions. When you use the equipment once and the timer expires, the equipment becomes locked. Your earnings are visible but cannot be collected until you upgrade to the next tier.\n\nFor example:\n• CPU Miner (free) → locks after first use\n• Must purchase CPU Miner Pro to unlock earnings\n• This is part of our progressive upgrade system\n\nThis "trap mechanism" encourages users to upgrade equipment for better earning potential and lower withdrawal limits.',
      icon: Lock,
      category: 'equipment'
    },
    {
      question: 'How Do I Upgrade My Equipment?',
      answer: 'Navigate to the "Shop" tab to browse and purchase new mining equipment. Each tier offers different specifications:\n\n**Entry Level:**\n• CPU Miner: FREE (demo), $1.2/day, 3h duration, $100 limit\n• CPU Miner Pro: $35, $1.2/day, 3h, unlocks earnings\n\n**Mid Tier:**\n• GPU Miner: $50, $4.8/day, 6h, $50 limit\n• GPU Miner Pro: $120, $6/day, 8h, $40 limit\n\n**Advanced Tier:**\n• ASIC Miner: $200, $12/day, 12h, $25 limit\n• ASIC Pro: $450, $18/day, 18h, $20 limit\n\n**Professional Tier:**\n• Mining Farm: $1,000+, $30-50/day, 24h, $10-15 limit\n\nHigher tiers = more earnings + longer runtime + lower withdrawal limits.',
      icon: TrendingUp,
      category: 'equipment'
    },
    {
      question: 'Can I Run Multiple Equipment Simultaneously?',
      answer: 'Yes! You can operate multiple pieces of equipment at the same time. Each equipment operates independently:\n\n• Separate timers for each device\n• Independent earning calculations\n• Individual Session Earnings tracking\n• Combined hourly rate display\n\nExample:\n• CPU Miner ($0.05/h) + GPU Miner ($0.20/h) + ASIC Miner ($0.50/h) = $0.75/hour total\n\nThis allows you to maximize earnings by diversifying your mining portfolio. However, each equipment still has its own timer and must be collected separately when finished.',
      icon: Zap,
      category: 'equipment'
    },
    {
      question: 'What\'s the Difference Between Available Balance and Session Earnings?',
      answer: '**Available Balance:**\n• Funds you can immediately use\n• Can be spent on equipment in Shop\n• Can be swapped to other cryptocurrencies\n• Can be withdrawn to external wallets\n• Can be used for Spot/Futures trading\n• Visible in your wallet\n\n**Session Earnings:**\n• USDT earned during current mining session\n• Locked and cannot be used until collected\n• Displayed in mining interface only\n• Must press COLLECT to transfer to Available Balance\n• Acts as a temporary holding state\n\nAlways collect your Session Earnings before starting new equipment to ensure your balance is available for use.',
      icon: DollarSign,
      category: 'earnings'
    },
    {
      question: 'How Do I Transition From Demo Mode to Real Mode?',
      answer: 'Demo mode offers a 15-minute trial experience. Transition happens automatically when:\n\n1. **Demo timer expires** (15 minutes)\n2. **You click COLLECT** (triggers registration prompt)\n\n**What happens after registration:**\n\n✓ Demo earnings are credited to your account\n✓ You receive a FREE CPU Miner Pro ($35 value)\n✓ Unlimited mining time (no more 15-minute restriction)\n✓ Full access to Shop, Swap, Withdrawal features\n✓ Access to Trading (Spot & Futures)\n✓ Support tickets and live chat\n✓ Referral system and rewards\n\nYour demo progress is saved, so you never lose your initial earnings!',
      icon: Award,
      category: 'demo'
    },
    {
      question: 'Is Mining Safe? Can I Lose My Money?',
      answer: 'Mining is completely safe with zero risk of losing your funds. Here\'s why:\n\n**Security Measures:**\n• No risk of equipment "breaking" or failing\n• Your earnings are always saved and tracked\n• Cannot lose USDT balance through mining\n• All transactions are recorded in blockchain history\n• Withdrawal limits protect against unauthorized access\n\n**What You CAN\'T Lose:**\n• Your USDT balance\n• Your equipment (once purchased)\n• Your accumulated earnings\n\n**System Mechanics:**\n• Withdrawal limits and upgrade requirements are strategic game mechanics\n• They encourage engagement but don\'t cause fund loss\n• You always have full visibility of your earnings\n• Withdrawal requests are processed securely\n\nMining is designed to be a progressive earning system, not a gambling mechanism.',
      icon: Shield,
      category: 'security'
    },
    {
      question: 'What is Test Mode? How Long Does It Last?',
      answer: 'Test Mode is an accelerated demonstration feature for first-time users. When you receive your first CPU Miner (either in demo or after registration), it may operate in test mode.\n\n**Test Mode Features:**\n• Timer runs faster than real-time (3 hours → 5-10 minutes)\n• Allows you to experience a complete mining cycle quickly\n• Earnings are calculated the same as regular mode\n• Helps you understand: START → WAIT → COLLECT process\n\n**When Test Mode Ends:**\n• After your first equipment cycle completes\n• All subsequent equipment runs in real-time\n• Your account transitions to standard mining operations\n\nTest mode is a one-time learning feature to help you understand the system without waiting hours for your first experience.',
      icon: Zap,
      category: 'demo'
    },
    {
      question: 'How is Hourly Rate Calculated?',
      answer: 'Hourly Rate is the combined earning rate of all your active mining equipment. Calculation formula:\n\n**Single Equipment:**\nDaily Rate ÷ 24 hours = Hourly Rate\n\n**Examples:**\n• CPU Miner: $1.2/day ÷ 24 = $0.05/hour\n• GPU Miner: $4.8/day ÷ 24 = $0.20/hour\n• ASIC Miner: $12/day ÷ 24 = $0.50/hour\n\n**Multiple Equipment:**\nSum of all active equipment hourly rates\n\n• Example: If you run CPU + GPU + ASIC simultaneously:\n  $0.05 + $0.20 + $0.50 = $0.75/hour total\n\nYour displayed "Hourly Rate" updates automatically when you start or stop equipment, giving you real-time earning visibility.',
      icon: TrendingUp,
      category: 'earnings'
    },
    {
      question: 'What Happens If My Session Timer Expires But I Don\'t Collect?',
      answer: 'If your mining timer reaches 0:00 and you don\'t immediately collect:\n\n**Your Earnings Are Safe:**\n• Session Earnings remain in locked state\n• No expiration or loss of funds\n• Earnings accumulate and wait for you\n• You can collect anytime after timer expires\n\n**Equipment Status:**\n• Equipment stops generating new earnings\n• Equipment remains in "finished" state\n• Cannot restart until you collect\n• No penalties for delayed collection\n\n**Best Practice:**\nCollect earnings promptly to restart your equipment and continue earning. However, there\'s no rush - your funds are permanently saved.',
      icon: Clock,
      category: 'mining'
    },
    {
      question: 'Can I Pause or Stop Mining Mid-Session?',
      answer: 'Currently, you cannot pause an active mining session. Once you press START:\n\n• Equipment runs until timer reaches 0:00\n• Earnings accumulate continuously\n• No manual stop button available\n• Must wait for session completion\n\n**Why No Pause Feature?**\n• Ensures fair earning calculations\n• Prevents manipulation of earning rates\n• Maintains system integrity\n• Simplifies user experience\n\n**Workaround:**\nIf you need to stop earning, simply don\'t start new equipment after collecting. Your current session will complete, and earnings are safe.',
      icon: Settings,
      category: 'technical'
    },
    {
      question: 'What Determines Equipment Pricing in the Shop?',
      answer: 'Equipment prices are based on several factors:\n\n**1. Daily Earning Potential**\n• Higher earnings = higher price\n• ROI period typically 30-90 days\n\n**2. Withdrawal Limit Reduction**\n• Lower limit = more valuable\n• Industrial equipment ($1000+) has $10 limit vs CPU\'s $100\n\n**3. Session Duration**\n• Longer runtime = better efficiency\n• 24-hour equipment means fewer restarts\n\n**4. Strategic Value**\n• Some equipment unlocks higher tiers\n• Certain purchases unlock exclusive features\n\n**Pricing Philosophy:**\nEach equipment is priced to offer positive ROI while encouraging progressive upgrades. The more you invest, the faster you earn and the easier withdrawals become.',
      icon: Target,
      category: 'equipment'
    },
    {
      question: 'How Do I Know Which Equipment to Buy First?',
      answer: 'Equipment purchase strategy depends on your goals:\n\n**For Fastest ROI:**\n• CPU Miner Pro → GPU Miner → ASIC Miner\n• Lowest investment, steady progression\n\n**For Fastest Withdrawal Access:**\n• Save for ASIC Miner ($200) directly\n• Gets you to $25 withdrawal limit quickly\n• Higher daily earnings ($12/day)\n\n**For Maximum Long-Term Earnings:**\n• Invest in Industrial/Farm equipment early\n• $1,000+ investment\n• $30-50/day earnings\n• $10-15 withdrawal limit\n\n**Beginner Recommendation:**\nStart with CPU Miner Pro ($35) to unlock your demo earnings, then save for GPU Miner ($50). This path offers the best learning curve and reasonable ROI.',
      icon: Cpu,
      category: 'advanced'
    },
    {
      question: 'What is the Total Earned Counter? Is It Accurate?',
      answer: 'The "Total Earned" counter tracks your lifetime mining earnings across all equipment and sessions.\n\n**What It Includes:**\n• All USDT earned from mining operations\n• Demo mode earnings (after registration)\n• Earnings from all equipment types\n• Historical earnings from previous sessions\n\n**What It Doesn\'t Include:**\n• Trading profits (Spot/Futures)\n• Deposits from external wallets\n• Swap transactions\n• Referral bonuses\n\n**Accuracy:**\n• Updated in real-time during mining\n• Calculated to 6 decimal places\n• Permanently stored in database\n• Cannot be manipulated or reset\n\nThis counter helps you track your mining performance and calculate your actual ROI on equipment purchases.',
      icon: Info,
      category: 'earnings'
    },
    {
      question: 'Why Do Some Equipment Have "Locked" Status in Shop?',
      answer: 'Certain high-tier equipment may be locked until you meet specific requirements:\n\n**Common Lock Reasons:**\n\n1. **Tier Prerequisites:**\n   • Must own previous tier equipment\n   • Example: Need GPU Miner to unlock GPU Miner Pro\n\n2. **Balance Requirements:**\n   • Must have minimum balance to prove seriousness\n   • Prevents new users from accessing equipment they can\'t afford to operate\n\n3. **Account Level:**\n   • Mining experience requirements\n   • Total earnings thresholds\n\n4. **Exclusive Equipment:**\n   • VIP-only equipment\n   • Special event equipment\n\n**How to Unlock:**\nHover over locked equipment to see unlock requirements. Progress through mining tiers naturally, and equipment unlocks automatically as you meet criteria.',
      icon: Lock,
      category: 'equipment'
    },
    {
      question: 'Can I Sell or Transfer My Equipment?',
      answer: 'Currently, equipment cannot be sold, transferred, or traded:\n\n**Why Equipment is Permanent:**\n• Once purchased, equipment is bound to your account\n• Prevents exploitation and secondary markets\n• Ensures fair earning distribution\n• Simplifies system mechanics\n\n**What You CAN Do:**\n• Own equipment indefinitely\n• Run equipment unlimited times\n• Collect earnings whenever you want\n• Upgrade to higher tiers anytime\n\n**Planning Advice:**\nPurchase equipment strategically. While you can\'t sell equipment, you CAN always buy higher tiers. Every equipment purchase is permanent progress toward better earnings and lower withdrawal limits.',
      icon: Shield,
      category: 'advanced'
    },
    {
      question: 'What Happens to My Equipment When I Withdraw Funds?',
      answer: 'Withdrawing USDT from your account does NOT affect your equipment:\n\n**Equipment Status After Withdrawal:**\n• All equipment remains in your account\n• Can continue mining immediately\n• Equipment specifications unchanged\n• No penalties or restrictions\n\n**What IS Affected:**\n• Your Available Balance decreases by withdrawal amount\n• You may need to mine more to reach withdrawal limit again\n• Session Earnings remain untouched (locked state)\n\n**Best Practice:**\nCollect all Session Earnings BEFORE withdrawing to maximize your withdrawal amount. Your equipment is a permanent asset that continues generating earnings regardless of withdrawals.',
      icon: DollarSign,
      category: 'security'
    },
    {
      question: 'How Often Can I Withdraw My Earnings?',
      answer: 'You can withdraw funds whenever you meet the withdrawal limit requirement:\n\n**Withdrawal Frequency:**\n• No daily/weekly limits\n• No cooldown periods\n• No maximum withdrawal amount restrictions\n• Process funds as often as you want\n\n**Requirements Per Withdrawal:**\n• Total balance ≥ your equipment withdrawal limit\n• Sufficient balance to cover network fees\n• Completed KYC verification (if required for large amounts)\n\n**Processing Times:**\n• Typically within 24-48 hours\n• May vary based on network congestion\n• Blockchain confirmation required\n\n**Pro Tip:**\nLet earnings accumulate to larger amounts before withdrawing. This minimizes network fees and maximizes your net withdrawal amount.',
      icon: Clock,
      category: 'security'
    },
    {
      question: 'What is Hash Rate? How Does It Affect My Earnings?',
      answer: 'Hash Rate is a visual metric representing your mining equipment\'s processing power:\n\n**Understanding Hash Rate:**\n• Displayed in H/s (hashes per second)\n• Higher hash rate = more "powerful" equipment\n• Purely cosmetic metric for immersion\n\n**Important Note:**\nHash rate does NOT directly affect your earnings. Your earnings are determined by:\n\n1. **Equipment Daily Rate** (e.g., $1.2/day)\n2. **Session Duration** (how long equipment runs)\n3. **Number of Active Equipment** (running simultaneously)\n\n**Why Show Hash Rate?**\n• Provides realistic mining simulation feel\n• Helps users understand equipment "power"\n• Makes the experience more engaging\n• Industry-standard metric for comparison\n\nFocus on daily earning rates and withdrawal limits when choosing equipment, not hash rate numbers.',
      icon: Cpu,
      category: 'technical'
    },
    {
      question: 'Does Equipment "Degrade" or Require Maintenance?',
      answer: 'No! All equipment is maintenance-free and never degrades:\n\n**Equipment Characteristics:**\n• Infinite usage with no performance loss\n• Same earning rate every session\n• No repair costs or maintenance fees\n• No depreciation over time\n\n**What This Means:**\n• CPU Miner bought today earns $1.2/day forever\n• Equipment purchased = permanent passive income tool\n• No hidden costs or surprise expenses\n\n**Comparison to Real Mining:**\nUnlike real-world mining hardware that degrades, consumes electricity, and requires cooling/maintenance, our system eliminates these complexities. You pay once, earn forever.',
      icon: Shield,
      category: 'technical'
    },
    {
      question: 'Can I Mine While Using Other Platform Features?',
      answer: 'Yes! Mining operates completely independently from other features:\n\n**Simultaneous Activities:**\n• Mine while trading Spot markets\n• Mine while trading Futures positions\n• Mine while browsing Markets\n• Mine while chatting in Live Rooms\n• Mine while checking Support tickets\n\n**Background Operation:**\n• Mining continues even if you navigate away\n• Timer counts down regardless of your activity\n• Earnings accumulate automatically\n• Can check progress anytime in Mining tab\n\n**Mobile/Desktop:**\n• Mining continues even if you close the browser (server-side)\n• Log back in anytime to collect earnings\n• No need to keep browser/app open\n\nMining is a true passive earning system that works 24/7 in the background.',
      icon: Zap,
      category: 'technical'
    },
    {
      question: 'What Should I Do If My Session Earnings Don\'t Match Expected Amount?',
      answer: 'If your earnings seem incorrect, verify these factors:\n\n**1. Check Timer Progress:**\n• Earnings are proportional to time elapsed\n• If timer shows 1:30 remaining out of 3:00, you\'re at 50% earnings\n\n**2. Verify Equipment Specs:**\n• Confirm daily rate (e.g., $1.2/day = $0.05/hour)\n• Check if you\'re running correct equipment\n\n**3. Multiple Equipment:**\n• Session Earnings may combine multiple devices\n• Check "Active Devices" section to see all running equipment\n\n**4. Collection Status:**\n• Previous earnings may already be collected\n• Check Available Balance for collected amounts\n\n**5. Network Issues:**\n• Refresh page to sync latest data\n• Check internet connection stability\n\n**Still Incorrect?**\nContact Support with your User ID, equipment name, and session start time. Our team can audit your mining history and resolve discrepancies.',
      icon: AlertCircle,
      category: 'technical'
    },
    {
      question: 'How Does the Mining Discover Feature Work?',
      answer: 'Mining Discover shows real-time mining activity from other users:\n\n**What You See:**\n• Random users currently mining\n• Their equipment types\n• Their session earnings (approximate)\n• Their hourly rates\n• Total active miners globally\n\n**Purpose:**\n• Demonstrates platform activity\n• Provides earning benchmarks\n• Shows what\'s possible with different equipment\n• Creates community engagement\n\n**Privacy:**\n• Only first names and avatars shown\n• Exact earnings are approximations\n• No personal information revealed\n• Cannot interact directly with listed users\n\n**Use Case:**\nUse Discover to see what high-tier equipment owners are earning, helping you decide on your next equipment upgrade.',
      icon: Sparkles,
      category: 'demo'
    },
    {
      question: 'What Are Mining Games? How Do I Participate?',
      answer: 'Mining Games (if available) are special events that offer bonus earnings:\n\n**Game Types:**\n• Lucky Spin: Spin for bonus USDT or equipment discounts\n• Mining Challenges: Complete tasks for rewards\n• Leaderboards: Top miners get exclusive prizes\n• Limited-Time Events: Special earning multipliers\n\n**How to Access:**\n• Navigate to "Games" tab in Mining section\n• Complete requirements (may need minimum balance or equipment)\n• Participate during event active periods\n\n**Rewards:**\n• Bonus USDT added directly to balance\n• Equipment purchase discounts\n• Free equipment upgrades\n• Exclusive badges or achievements\n\n**Frequency:**\nGames rotate regularly. Check the Games tab frequently for new opportunities to maximize earnings beyond standard mining.',
      icon: Award,
      category: 'advanced'
    },
    {
      question: 'What is the Support System? How Can I Get Help?',
      answer: 'Our 24/7 support system offers multiple channels:\n\n**Support Options:**\n\n1. **FAQ (This Page):**\n   • Instant answers to common questions\n   • Searchable and categorized\n   • Updated regularly\n\n2. **Live Chat (Support Tab):**\n   • Real-time chat with support agents\n   • Available 24/7 in multiple languages\n   • Average response time: <5 minutes\n\n3. **Support Tickets:**\n   • For complex issues requiring investigation\n   • Upload screenshots/evidence\n   • Tracked with ticket ID\n   • Email notifications on updates\n\n4. **Mining Chat:**\n   • Community discussion\n   • Learn from other miners\n   • Share experiences and tips\n\n**When to Contact Support:**\n• Technical issues with mining\n• Withdrawal problems\n• Account questions\n• Suspicious activity\n• Feature requests\n\nOur multilingual support team is trained to help with any platform issue!',
      icon: AlertCircle,
      category: 'demo'
    }
];

const categories = {
  demo: { name: 'Demo & Getting Started', color: 'blue' },
  mining: { name: 'Mining Basics', color: 'yellow' },
  earnings: { name: 'Earnings & Balance', color: 'green' },
  equipment: { name: 'Equipment & Shop', color: 'purple' },
  security: { name: 'Security & Withdrawals', color: 'red' },
  technical: { name: 'Technical Details', color: 'cyan' },
  advanced: { name: 'Advanced Strategies', color: 'orange' }
};

export default function MiningFAQModal({ isOpen, onClose, isDemoMode }: FAQModalProps) {
  const [expandedIndex, setExpandedIndex] = useState<number | null>(0);
  const [searchQuery, setSearchQuery] = useState('');

  const toggleExpand = (index: number) => {
    setExpandedIndex(expandedIndex === index ? null : index);
  };

  const filteredFAQs = useMemo(() => {
    if (!searchQuery.trim()) return faqData;

    const query = searchQuery.toLowerCase();
    return faqData.filter(faq =>
      faq.question.toLowerCase().includes(query) ||
      faq.answer.toLowerCase().includes(query) ||
      categories[faq.category].name.toLowerCase().includes(query)
    );
  }, [searchQuery]);

  if (!isOpen) return null;

  return (
    <div
      className="fixed inset-0 bg-black/95 flex items-center justify-center z-[99999] p-4 animate-fadeIn backdrop-blur-sm"
      onClick={onClose}
      style={{ isolation: 'isolate' }}
    >
      <div
        className="bg-[#1A1B23] rounded-2xl max-w-3xl w-full border-4 border-[#F0B90B] shadow-[0_0_50px_rgba(240,185,11,0.5)] max-h-[90vh] flex flex-col animate-scaleIn"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="bg-gradient-to-r from-[#1A1B23] to-[#2B3139] border-b-2 border-[#F0B90B]/50 p-6 rounded-t-2xl flex-shrink-0">
          <div className="flex items-center justify-between">
            <div className="flex-1">
              <h2 className="text-2xl font-bold text-white flex items-center gap-2">
                <Zap className="w-7 h-7 text-[#F0B90B]" />
                Mining - Frequently Asked Questions
              </h2>
              <p className="text-gray-300 mt-1">
                {isDemoMode ? 'Everything you need to know about Demo Mining' : 'Complete guide to our mining system'}
              </p>
            </div>
            <button
              onClick={onClose}
              className="ml-4 p-2 bg-red-500/20 hover:bg-red-500/40 rounded-lg text-red-400 hover:text-red-300 transition-colors flex-shrink-0"
              aria-label="Close FAQ"
            >
              <X className="w-6 h-6" />
            </button>
          </div>

          <div className="relative mt-4">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Search questions, answers, or categories..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-[#0D0E12] border border-[#2B3139] rounded-lg pl-10 pr-4 py-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-[#F0B90B]/50 transition-colors"
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery('')}
                className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-white transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            )}
          </div>
        </div>

        <div className="px-6 py-4 space-y-3 overflow-y-auto flex-1 bg-[#0D0E12]">
          {filteredFAQs.length === 0 ? (
            <div className="text-center py-12">
              <AlertCircle className="w-12 h-12 text-gray-500 mx-auto mb-3" />
              <p className="text-gray-300">No results found for "{searchQuery}"</p>
              <p className="text-sm text-gray-400 mt-1">Try different keywords or browse all questions</p>
            </div>
          ) : (
            filteredFAQs.map((faq, index) => {
            const Icon = faq.icon;
            const isExpanded = expandedIndex === index;
            const categoryInfo = categories[faq.category];

            return (
              <div
                key={index}
                className="bg-[#1A1B23] border border-[#2B3139] rounded-xl overflow-hidden hover:border-[#F0B90B]/30 transition-all"
              >
                <button
                  onClick={() => toggleExpand(index)}
                  className="w-full p-4 flex items-center justify-between text-left"
                >
                  <div className="flex items-center gap-3 flex-1">
                    <div className={
                      faq.category === 'demo' ? 'p-2 rounded-lg bg-blue-500/10' :
                      faq.category === 'mining' ? 'p-2 rounded-lg bg-yellow-500/10' :
                      faq.category === 'earnings' ? 'p-2 rounded-lg bg-green-500/10' :
                      faq.category === 'equipment' ? 'p-2 rounded-lg bg-purple-500/10' :
                      faq.category === 'security' ? 'p-2 rounded-lg bg-red-500/10' :
                      faq.category === 'technical' ? 'p-2 rounded-lg bg-cyan-500/10' :
                      'p-2 rounded-lg bg-orange-500/10'
                    }>
                      <Icon className={
                        faq.category === 'demo' ? 'w-5 h-5 text-blue-400' :
                        faq.category === 'mining' ? 'w-5 h-5 text-yellow-400' :
                        faq.category === 'earnings' ? 'w-5 h-5 text-green-400' :
                        faq.category === 'equipment' ? 'w-5 h-5 text-purple-400' :
                        faq.category === 'security' ? 'w-5 h-5 text-red-400' :
                        faq.category === 'technical' ? 'w-5 h-5 text-cyan-400' :
                        'w-5 h-5 text-orange-400'
                      } />
                    </div>
                    <div className="flex-1">
                      <h3 className="font-bold text-white">{faq.question}</h3>
                      <div className={
                        faq.category === 'demo' ? 'text-xs text-blue-400 mt-0.5' :
                        faq.category === 'mining' ? 'text-xs text-yellow-400 mt-0.5' :
                        faq.category === 'earnings' ? 'text-xs text-green-400 mt-0.5' :
                        faq.category === 'equipment' ? 'text-xs text-purple-400 mt-0.5' :
                        faq.category === 'security' ? 'text-xs text-red-400 mt-0.5' :
                        faq.category === 'technical' ? 'text-xs text-cyan-400 mt-0.5' :
                        'text-xs text-orange-400 mt-0.5'
                      }>
                        {categoryInfo.name}
                      </div>
                    </div>
                  </div>
                  {isExpanded ? (
                    <ChevronUp className="w-5 h-5 text-gray-400" />
                  ) : (
                    <ChevronDown className="w-5 h-5 text-gray-400" />
                  )}
                </button>

                {isExpanded && (
                  <div className="px-4 pb-4 pt-0">
                    <div className="bg-[#0D0E12] rounded-lg p-4 border-l-4 border-[#F0B90B]">
                      <p className="text-gray-300 leading-relaxed whitespace-pre-line">
                        {faq.answer}
                      </p>
                    </div>
                  </div>
                )}
              </div>
            );
          })
        )}
        </div>

        <div className="bg-[#0D0E12] p-6 rounded-b-2xl flex-shrink-0">
          <div className="flex items-start gap-3">
            <AlertCircle className="w-5 h-5 text-[#F0B90B] flex-shrink-0 mt-0.5" />
            <div>
              <h4 className="font-bold text-white mb-1">Still have questions?</h4>
              <p className="text-sm text-gray-300">
                Visit the Support tab for live chat assistance or create a support ticket.
                Our team is available 24/7 to help you!
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
