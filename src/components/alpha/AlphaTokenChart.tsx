import { useEffect, useRef, useState } from 'react';
import { createChart, ColorType, CandlestickSeries, HistogramSeries } from 'lightweight-charts';
import type { AlphaPricePoint } from '../../types/alpha';

interface Props {
  priceHistory: AlphaPricePoint[];
  currentPrice: number;
  priceChange: number;
}

export default function AlphaTokenChart({ priceHistory, currentPrice, priceChange }: Props) {
  const containerRef = useRef<HTMLDivElement>(null);
  const chartRef = useRef<ReturnType<typeof createChart> | null>(null);
  const [timeframe, setTimeframe] = useState('1H');
  const [priceFlash, setPriceFlash] = useState(false);
  const prevPriceRef = useRef(currentPrice);

  useEffect(() => {
    if (prevPriceRef.current !== currentPrice) {
      setPriceFlash(true);
      const t = setTimeout(() => setPriceFlash(false), 600);
      prevPriceRef.current = currentPrice;
      return () => clearTimeout(t);
    }
  }, [currentPrice]);

  useEffect(() => {
    if (!containerRef.current || priceHistory.length === 0) return;

    if (chartRef.current) {
      chartRef.current.remove();
    }

    const chart = createChart(containerRef.current, {
      layout: {
        background: { type: ColorType.Solid, color: 'transparent' },
        textColor: '#848E9C',
        fontSize: 10,
      },
      grid: {
        vertLines: { color: 'rgba(43, 49, 57, 0.3)' },
        horzLines: { color: 'rgba(43, 49, 57, 0.3)' },
      },
      crosshair: {
        mode: 0,
        vertLine: { color: '#F0B90B', width: 1, style: 2, labelBackgroundColor: '#F0B90B' },
        horzLine: { color: '#F0B90B', width: 1, style: 2, labelBackgroundColor: '#F0B90B' },
      },
      rightPriceScale: {
        borderColor: 'rgba(43, 49, 57, 0.5)',
        scaleMargins: { top: 0.1, bottom: 0.25 },
      },
      timeScale: {
        borderColor: 'rgba(43, 49, 57, 0.5)',
        timeVisible: true,
        secondsVisible: false,
      },
      handleScroll: { vertTouchDrag: false },
      width: containerRef.current.clientWidth,
      height: 280,
    });

    chartRef.current = chart;

    const candleSeries = chart.addSeries(CandlestickSeries, {
      upColor: '#0ECB81',
      downColor: '#F6465D',
      borderUpColor: '#0ECB81',
      borderDownColor: '#F6465D',
      wickUpColor: '#0ECB81',
      wickDownColor: '#F6465D',
    });

    const volumeSeries = chart.addSeries(HistogramSeries, {
      priceFormat: { type: 'volume' },
      priceScaleId: '',
    });

    volumeSeries.priceScale().applyOptions({
      scaleMargins: { top: 0.85, bottom: 0 },
    });

    const candleData = priceHistory.map(p => ({
      time: (new Date(p.timestamp).getTime() / 1000) as number,
      open: Number(p.open_price),
      high: Number(p.high_price),
      low: Number(p.low_price),
      close: Number(p.close_price),
    }));

    const volumeData = priceHistory.map(p => ({
      time: (new Date(p.timestamp).getTime() / 1000) as number,
      value: Number(p.volume),
      color: Number(p.close_price) >= Number(p.open_price) ? 'rgba(14, 203, 129, 0.3)' : 'rgba(246, 70, 93, 0.3)',
    }));

    candleSeries.setData(candleData as Parameters<typeof candleSeries.setData>[0]);
    volumeSeries.setData(volumeData as Parameters<typeof volumeSeries.setData>[0]);

    chart.timeScale().fitContent();

    const handleResize = () => {
      if (containerRef.current) {
        chart.applyOptions({ width: containerRef.current.clientWidth });
      }
    };

    window.addEventListener('resize', handleResize);
    return () => {
      window.removeEventListener('resize', handleResize);
      chart.remove();
      chartRef.current = null;
    };
  }, [priceHistory, timeframe]);

  const TF = ['1M', '5M', '15M', '1H', '4H', '1D'];

  return (
    <div className="bg-[#181A20] rounded-xl border border-[#2B3139]/50 overflow-hidden">
      <div className="flex items-center justify-between px-3 py-2 border-b border-[#2B3139]/50">
        <div className="flex items-center gap-3">
          <span className={`text-white font-bold text-lg transition-all duration-300 ${priceFlash ? 'scale-105' : 'scale-100'}`}>
            ${currentPrice < 0.01 ? currentPrice.toFixed(8) : currentPrice.toFixed(4)}
          </span>
          <span className={`text-xs font-bold px-1.5 py-0.5 rounded ${priceChange >= 0 ? 'text-[#0ECB81] bg-[#0ECB81]/10' : 'text-[#F6465D] bg-[#F6465D]/10'}`}>
            {priceChange >= 0 ? '+' : ''}{priceChange.toFixed(2)}%
          </span>
        </div>
        <div className="flex items-center gap-0.5">
          {TF.map(tf => (
            <button
              key={tf}
              onClick={() => setTimeframe(tf)}
              className={`px-2 py-1 rounded text-[10px] font-bold transition-all ${
                timeframe === tf ? 'bg-[#F0B90B] text-[#0B0E11]' : 'text-gray-500 hover:text-gray-300'
              }`}
            >
              {tf}
            </button>
          ))}
        </div>
      </div>
      <div ref={containerRef} className="w-full" style={{ minHeight: 280 }}>
        {priceHistory.length === 0 && (
          <div className="flex items-center justify-center h-[280px]">
            <div className="text-center">
              <div className="w-8 h-8 border-2 border-[#F0B90B] border-t-transparent rounded-full animate-spin mx-auto mb-2" />
              <span className="text-gray-500 text-xs">Loading chart data...</span>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
