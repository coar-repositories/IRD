# frozen_string_literal: true
require 'csv'

def seed_roles
  CSV.foreach(('./data/seed_data/roles.csv'), headers: true) do |row|
    Role.create!(
      id: row['id'],
      name: row['name'],
      description: row['description']
    )
  end
end

def seed_users
  CSV.foreach(('./data/seed_data/users.csv'), headers: true) do |row|
    user = User.create!(
      id: row['id'],
      email: row['email'],
      fore_name: row['fore_name'],
      last_name: row['last_name'],
      verified: (row['verified'] == 'true'),
    )
    if row['roles']
      roles = row['roles'].split('|')
      roles.each do |role|
        user.roles << Role.find(role)
      end
    end
  end
end

def seed_countries
  CSV.foreach(('./data/seed_data/countries.csv'), headers: true) do |row|
    Country.create!(
      id: row['code'],
      name: row['name'],
      continent: Country.continents[row['continent'].to_sym],
      latitude: row['latitude'],
      longitude: row['longitude']
    )
  end
end

def seed_annotations
  CSV.foreach(('./data/seed_data/annotations.csv'), headers: true) do |row|
    Annotation.create!(
      id: row['id'],
      name: row['name'],
      description: row['description'],
      restricted: row['restricted']=='1'
    )
  end
end

def seed_rps
  CSV.foreach(('./data/seed_data/rps.csv'), headers: true) do |row|
    alias_array = []
    alias_array = row['aliases'].split("|") unless row['aliases'].nil?
    Organisation.create!(
      id: row['id'],
      name: row['name'],
      aliases: alias_array,
      website: row['website'],
      short_name: row['short_name'],
      rp: true,
      ror: row['ror'],
      country: Country.find(row['country_id']),
      location: row['location'],
      latitude: row['latitude'],
      longitude: row['longitude']
    )
  end
end

def seed_all_lookup_tables
  seed_roles
  seed_users
  seed_countries
  seed_annotations
  seed_rps
end