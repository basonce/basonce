const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || '';

export function getProxiedLogoUrl(logoUrl: string | null | undefined): string {
  if (!logoUrl) return '';

  if (logoUrl.startsWith('/') || logoUrl.startsWith('data:')) {
    return logoUrl;
  }

  if (logoUrl.includes('/functions/v1/logo-proxy')) {
    return logoUrl;
  }

  if (logoUrl.includes('coingecko.com') || logoUrl.includes('coinmarketcap.com')) {
    return `${SUPABASE_URL}/functions/v1/logo-proxy?url=${encodeURIComponent(logoUrl)}`;
  }

  return logoUrl;
}
