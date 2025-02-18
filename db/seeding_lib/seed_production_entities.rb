require 'csv'

def seed_platforms
  CSV.foreach(('./data/export_production_csv/platforms.csv'), headers: true) do |row|
    Platform.create!(
      id: row['id'],
      name: row['name'],
      url: row['url'],
      trusted: row['trusted']=='1',
      oai_support: row['oai_support']=='1',
      oai_suffix: row['oai_suffix'],
      matchers: row['matchers'],
      generator_patterns: row['generator_patterns'],
      match_order: row['match_order'].to_f
    )
  end
end

def seed_generators
  CSV.foreach(('./data/export_production_csv/generators.csv'), headers: true) do |row|
    Generator.create!(
      name: row['name'],
      platform: Platform.find(row['platform_id']),
      version: row['version']
    )
  end
end

def seed_organisations
  CSV.foreach(('./data/export_production_csv/organisations.csv'), headers: true) do |row|
    alias_array = []
    aliases_string = row['aliases'][1..-2]
    alias_array = aliases_string.split(",") unless aliases_string.nil?
    Organisation.create!(
      id: row['id'],
      name: row['name'],
      aliases: alias_array,
      website: row['website'],
      domain: row['domain'],
      short_name: row['short_name'],
      rp: (row['rp']=='true'),
      ror: row['ror'],
      country: Country.find(row['country_id']),
      location: row['location'],
      latitude: row['latitude'],
      longitude: row['longitude']
    )
  end
end

def seed_systems
  CSV.foreach(('./data/export_production_csv/systems.csv'), headers: true) do |row|
      alias_array = []
      aliases_string = row['aliases'][1..-2]
      alias_array = aliases_string.split(",") unless aliases_string.nil?
      System.create!(
        id: row['id'],
        name: row['name'],
        aliases: alias_array,
        short_name: row['short_name'],
        url: row['url'],
        description: row['description'],
        system_status: row['system_status'].to_i,
        oai_status: row['oai_status'].to_i,
        platform: Platform.find_by_id(row['platform_id']),
        platform_version: row['platform_version'],
        record_status: row['record_status'].to_i,
        record_source: row['record_source'],
        owner: Organisation.find_by_id(row['owner_id']),
        rp: Organisation.find_by_id(row['rp_id']),
        country: Country.find_by_id(row['country_id']),
        contact: row['contact'],
        random_id: row['random_id'],
        repo_ids: JSON.parse(row['repo_ids']),
        metadata: JSON.parse(row['metadata']),
        formats: JSON.parse(row['formats']),
        system_category: row['system_category'].to_i,
        subcategory: row['subcategory'].to_i,
        issues: JSON.parse(row['issues']),
        primary_subject: row['primary_subject'].to_i
      )
  end
end

def seed_all_production_entities
  seed_platforms
  seed_generators
  # seed_organisations
  # seed_systems
end