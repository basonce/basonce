import { supabase } from './supabase';

export interface Agent {
  id: string;
  name: string;
  country_code: string;
  country_name: string;
  avatar_url: string;
  status: string;
  languages: string[];
  specialty: string;
  flag: string;
  flag_emoji?: string;
  language_code?: string;
  timezone: string;
  region: string;
  active_tickets: number;
}

interface AssignmentOptions {
  countryCode?: string;
  language?: string;
  specialty?: 'trading' | 'deposits' | 'technical' | 'account';
}

export async function assignBestAgent(options: AssignmentOptions = {}): Promise<Agent | null> {
  try {
    const { countryCode, language = 'English', specialty } = options;

    if (countryCode) {
      const { data: sameCountryAgents } = await supabase
        .from('support_agents')
        .select('*')
        .eq('status', 'online')
        .eq('country_code', countryCode.toUpperCase())
        .order('active_tickets', { ascending: true })
        .limit(10);

      if (sameCountryAgents && sameCountryAgents.length > 0) {
        const languageFilteredAgents = sameCountryAgents.filter(agent =>
          agent.languages.some((lang: string) =>
            lang.toLowerCase().includes(language.toLowerCase())
          )
        );

        let filteredAgents = languageFilteredAgents.length > 0 ? languageFilteredAgents : sameCountryAgents;

        if (specialty) {
          const specialtyFiltered = filteredAgents.filter(a => a.specialty === specialty);
          if (specialtyFiltered.length > 0) {
            filteredAgents = specialtyFiltered;
          }
        }

        filteredAgents.sort((a, b) => a.active_tickets - b.active_tickets);
        return filteredAgents[0] as Agent;
      }
    }

    const { data: allAgents } = await supabase
      .from('support_agents')
      .select('*')
      .eq('status', 'online')
      .order('active_tickets', { ascending: true })
      .limit(50);

    if (allAgents && allAgents.length > 0) {
      const languageAgents = allAgents.filter(agent =>
        agent.languages.some((lang: string) =>
          lang.toLowerCase().includes(language.toLowerCase())
        )
      );

      if (languageAgents.length > 0) {
        let filteredAgents = languageAgents;

        if (specialty) {
          const specialtyFiltered = languageAgents.filter(a => a.specialty === specialty);
          if (specialtyFiltered.length > 0) {
            filteredAgents = specialtyFiltered;
          }
        }

        filteredAgents.sort((a, b) => a.active_tickets - b.active_tickets);
        return filteredAgents[0] as Agent;
      }
    }

    const { data: fallbackAgents } = await supabase
      .from('support_agents')
      .select('*')
      .eq('status', 'online')
      .order('active_tickets', { ascending: true })
      .limit(10);

    if (!fallbackAgents || fallbackAgents.length === 0) return null;

    return fallbackAgents[0] as Agent;
  } catch (error) {
    console.error('Error assigning agent:', error);
    return null;
  }
}

export async function assignAgentByCountry(countryCode: string): Promise<Agent | null> {
  return assignBestAgent({ countryCode });
}

export async function getAgentsByRegion(region: string): Promise<Agent[]> {
  try {
    const { data, error } = await supabase
      .from('support_agents')
      .select('*')
      .eq('region', region)
      .eq('status', 'online')
      .order('name', { ascending: true });

    if (error) throw error;
    return (data || []) as Agent[];
  } catch (error) {
    console.error('Error fetching agents by region:', error);
    return [];
  }
}

export async function getAllAgents(): Promise<Agent[]> {
  try {
    const { data, error } = await supabase
      .from('support_agents')
      .select('*')
      .eq('status', 'online')
      .order('country_name', { ascending: true });

    if (error) throw error;
    return (data || []) as Agent[];
  } catch (error) {
    console.error('Error fetching all agents:', error);
    return [];
  }
}

export async function getAgentStats() {
  try {
    const { data, error } = await supabase
      .from('support_agents')
      .select('country_code, region, status')
      .eq('status', 'online');

    if (error) throw error;

    const stats = {
      total: data?.length || 0,
      byRegion: {} as Record<string, number>,
      byCountry: {} as Record<string, number>
    };

    data?.forEach(agent => {
      stats.byRegion[agent.region] = (stats.byRegion[agent.region] || 0) + 1;
      stats.byCountry[agent.country_code] = (stats.byCountry[agent.country_code] || 0) + 1;
    });

    return stats;
  } catch (error) {
    console.error('Error fetching agent stats:', error);
    return { total: 0, byRegion: {}, byCountry: {} };
  }
}
