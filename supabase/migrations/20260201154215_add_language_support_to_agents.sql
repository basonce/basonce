/*
  # Add Language Support to Support Agents

  1. Changes
    - Add `language_code` column to support_agents table
    - Add `flag_emoji` column to support_agents table for country flags
    - Update all agents with appropriate language codes based on their country
    - Agents will respond in their native language for better user experience

  2. Language Codes
    - tr: Turkish (Turkey, Azerbaijan, Uzbekistan, Kazakhstan)
    - en: English (UK, US, Canada, Australia, Ireland, Singapore, Nigeria, Ghana, Kenya, South Africa)
    - de: German (Germany, Austria)
    - fr: French (France, Belgium, Switzerland)
    - es: Spanish (Spain, Mexico, Argentina, Colombia, Chile)
    - it: Italian (Italy)
    - ru: Russian (Russia, Ukraine, Belarus)
    - zh: Chinese (China, Taiwan, Hong Kong)
    - ja: Japanese (Japan)
    - ko: Korean (Korea)
    - ar: Arabic (Saudi Arabia, UAE, Egypt, Lebanon, Morocco, Tunisia, Jordan)
    - pt: Portuguese (Brazil, Portugal)
    - hi: Hindi (India)
    - id: Indonesian (Indonesia)
    - th: Thai (Thailand)
    - vi: Vietnamese (Vietnam)
    - pl: Polish (Poland)
    - nl: Dutch (Netherlands)
    - sv: Swedish (Sweden)
    - el: Greek (Greece)
    - cs: Czech (Czech Republic)
*/

-- Add language_code and flag_emoji columns
ALTER TABLE support_agents ADD COLUMN IF NOT EXISTS language_code text NOT NULL DEFAULT 'en';
ALTER TABLE support_agents ADD COLUMN IF NOT EXISTS flag_emoji text NOT NULL DEFAULT '🌍';

-- Update Turkish World countries
UPDATE support_agents SET language_code = 'tr', flag_emoji = '🇹🇷' WHERE country_code = 'TR';
UPDATE support_agents SET language_code = 'tr', flag_emoji = '🇦🇿' WHERE country_code = 'AZ';
UPDATE support_agents SET language_code = 'tr', flag_emoji = '🇺🇿' WHERE country_code = 'UZ';
UPDATE support_agents SET language_code = 'tr', flag_emoji = '🇰🇿' WHERE country_code = 'KZ';

-- Update English-speaking countries
UPDATE support_agents SET language_code = 'en', flag_emoji = '🇬🇧' WHERE country_code = 'GB';
UPDATE support_agents SET language_code = 'en', flag_emoji = '🇺🇸' WHERE country_code = 'US';
UPDATE support_agents SET language_code = 'en', flag_emoji = '🇨🇦' WHERE country_code = 'CA';
UPDATE support_agents SET language_code = 'en', flag_emoji = '🇦🇺' WHERE country_code = 'AU';
UPDATE support_agents SET language_code = 'en', flag_emoji = '🇮🇪' WHERE country_code = 'IE';
UPDATE support_agents SET language_code = 'en', flag_emoji = '🇸🇬' WHERE country_code = 'SG';
UPDATE support_agents SET language_code = 'en', flag_emoji = '🇳🇬' WHERE country_code = 'NG';
UPDATE support_agents SET language_code = 'en', flag_emoji = '🇬🇭' WHERE country_code = 'GH';
UPDATE support_agents SET language_code = 'en', flag_emoji = '🇰🇪' WHERE country_code = 'KE';
UPDATE support_agents SET language_code = 'en', flag_emoji = '🇿🇦' WHERE country_code = 'ZA';

-- Update German-speaking countries
UPDATE support_agents SET language_code = 'de', flag_emoji = '🇩🇪' WHERE country_code = 'DE';
UPDATE support_agents SET language_code = 'de', flag_emoji = '🇦🇹' WHERE country_code = 'AT';

-- Update French-speaking countries
UPDATE support_agents SET language_code = 'fr', flag_emoji = '🇫🇷' WHERE country_code = 'FR';
UPDATE support_agents SET language_code = 'fr', flag_emoji = '🇧🇪' WHERE country_code = 'BE';
UPDATE support_agents SET language_code = 'fr', flag_emoji = '🇨🇭' WHERE country_code = 'CH';

-- Update Spanish-speaking countries
UPDATE support_agents SET language_code = 'es', flag_emoji = '🇪🇸' WHERE country_code = 'ES';
UPDATE support_agents SET language_code = 'es', flag_emoji = '🇲🇽' WHERE country_code = 'MX';
UPDATE support_agents SET language_code = 'es', flag_emoji = '🇦🇷' WHERE country_code = 'AR';
UPDATE support_agents SET language_code = 'es', flag_emoji = '🇨🇴' WHERE country_code = 'CO';
UPDATE support_agents SET language_code = 'es', flag_emoji = '🇨🇱' WHERE country_code = 'CL';

-- Update Italian-speaking countries
UPDATE support_agents SET language_code = 'it', flag_emoji = '🇮🇹' WHERE country_code = 'IT';

-- Update Russian-speaking countries
UPDATE support_agents SET language_code = 'ru', flag_emoji = '🇷🇺' WHERE country_code = 'RU';
UPDATE support_agents SET language_code = 'ru', flag_emoji = '🇺🇦' WHERE country_code = 'UA';
UPDATE support_agents SET language_code = 'ru', flag_emoji = '🇧🇾' WHERE country_code = 'BY';

-- Update Chinese-speaking countries
UPDATE support_agents SET language_code = 'zh', flag_emoji = '🇨🇳' WHERE country_code = 'CN';
UPDATE support_agents SET language_code = 'zh', flag_emoji = '🇹🇼' WHERE country_code = 'TW';
UPDATE support_agents SET language_code = 'zh', flag_emoji = '🇭🇰' WHERE country_code = 'HK';

-- Update Japanese
UPDATE support_agents SET language_code = 'ja', flag_emoji = '🇯🇵' WHERE country_code = 'JP';

-- Update Korean
UPDATE support_agents SET language_code = 'ko', flag_emoji = '🇰🇷' WHERE country_code = 'KR';

-- Update Arabic-speaking countries
UPDATE support_agents SET language_code = 'ar', flag_emoji = '🇸🇦' WHERE country_code = 'SA';
UPDATE support_agents SET language_code = 'ar', flag_emoji = '🇦🇪' WHERE country_code = 'AE';
UPDATE support_agents SET language_code = 'ar', flag_emoji = '🇪🇬' WHERE country_code = 'EG';
UPDATE support_agents SET language_code = 'ar', flag_emoji = '🇱🇧' WHERE country_code = 'LB';
UPDATE support_agents SET language_code = 'ar', flag_emoji = '🇲🇦' WHERE country_code = 'MA';
UPDATE support_agents SET language_code = 'ar', flag_emoji = '🇹🇳' WHERE country_code = 'TN';
UPDATE support_agents SET language_code = 'ar', flag_emoji = '🇯🇴' WHERE country_code = 'JO';

-- Update Portuguese-speaking countries
UPDATE support_agents SET language_code = 'pt', flag_emoji = '🇧🇷' WHERE country_code = 'BR';
UPDATE support_agents SET language_code = 'pt', flag_emoji = '🇵🇹' WHERE country_code = 'PT';

-- Update Hindi-speaking countries
UPDATE support_agents SET language_code = 'hi', flag_emoji = '🇮🇳' WHERE country_code = 'IN';

-- Update Indonesian
UPDATE support_agents SET language_code = 'id', flag_emoji = '🇮🇩' WHERE country_code = 'ID';

-- Update Thai
UPDATE support_agents SET language_code = 'th', flag_emoji = '🇹🇭' WHERE country_code = 'TH';

-- Update Vietnamese
UPDATE support_agents SET language_code = 'vi', flag_emoji = '🇻🇳' WHERE country_code = 'VN';

-- Update Polish
UPDATE support_agents SET language_code = 'pl', flag_emoji = '🇵🇱' WHERE country_code = 'PL';

-- Update Dutch
UPDATE support_agents SET language_code = 'nl', flag_emoji = '🇳🇱' WHERE country_code = 'NL';

-- Update Swedish
UPDATE support_agents SET language_code = 'sv', flag_emoji = '🇸🇪' WHERE country_code = 'SE';

-- Update Greek
UPDATE support_agents SET language_code = 'el', flag_emoji = '🇬🇷' WHERE country_code = 'GR';

-- Update Czech
UPDATE support_agents SET language_code = 'cs', flag_emoji = '🇨🇿' WHERE country_code = 'CZ';

-- Update Pakistan and Bangladesh (English as common language)
UPDATE support_agents SET language_code = 'en', flag_emoji = '🇵🇰' WHERE country_code = 'PK';
UPDATE support_agents SET language_code = 'en', flag_emoji = '🇧🇩' WHERE country_code = 'BD';
