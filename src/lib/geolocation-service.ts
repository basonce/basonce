interface GeolocationData {
  ip: string;
  country_code: string;
  country_name: string;
  city: string;
  region: string;
  timezone: string;
}

class GeolocationService {
  private cache: Map<string, GeolocationData> = new Map();
  private readonly CACHE_DURATION = 1000 * 60 * 60 * 24; // 24 hours

  async getGeolocation(): Promise<Partial<GeolocationData>> {
    try {
      const cachedData = this.getCachedData();
      if (cachedData) {
        return cachedData;
      }

      const response = await fetch('https://ipapi.co/json/');
      if (!response.ok) {
        console.warn('Geolocation API failed, using fallback');
        return this.getFallbackData();
      }

      const data = await response.json();

      const geoData: GeolocationData = {
        ip: data.ip || 'unknown',
        country_code: data.country_code || 'XX',
        country_name: data.country_name || 'Unknown',
        city: data.city || 'Unknown',
        region: data.region || 'Unknown',
        timezone: data.timezone || 'UTC'
      };

      this.cacheData(geoData);
      return geoData;
    } catch (error) {
      console.error('Geolocation error:', error);
      return this.getFallbackData();
    }
  }

  private getCachedData(): GeolocationData | null {
    const cached = localStorage.getItem('geo_cache');
    if (!cached) return null;

    try {
      const { data, timestamp } = JSON.parse(cached);
      if (Date.now() - timestamp < this.CACHE_DURATION) {
        return data;
      }
      localStorage.removeItem('geo_cache');
    } catch {
      localStorage.removeItem('geo_cache');
    }
    return null;
  }

  private cacheData(data: GeolocationData): void {
    try {
      localStorage.setItem('geo_cache', JSON.stringify({
        data,
        timestamp: Date.now()
      }));
    } catch (error) {
      console.warn('Failed to cache geolocation data:', error);
    }
  }

  private getFallbackData(): Partial<GeolocationData> {
    return {
      ip: 'unknown',
      country_code: 'XX',
      country_name: 'Unknown',
      city: 'Unknown',
      region: 'Unknown',
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC'
    };
  }
}

export const geolocationService = new GeolocationService();
