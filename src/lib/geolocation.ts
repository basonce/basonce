interface GeolocationResult {
  country_code: string;
  country_name: string;
}

export async function detectUserCountry(): Promise<GeolocationResult> {
  try {
    const response = await fetch('https://ipapi.co/json/');
    const data = await response.json();

    return {
      country_code: data.country_code || 'US',
      country_name: data.country_name || 'United States'
    };
  } catch (error) {
    console.error('Error detecting country:', error);
    return {
      country_code: 'US',
      country_name: 'United States'
    };
  }
}

export function getCountryFlag(countryCode: string): string {
  const codePoints = countryCode
    .toUpperCase()
    .split('')
    .map(char => 127397 + char.charCodeAt(0));
  return String.fromCodePoint(...codePoints);
}
