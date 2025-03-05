# frozen_string_literal: true

def seed_cern
  Organisation.create!(
    id: '4ab4ad1a-0d3d-40ef-824c-cd20b3173e78',
    name: 'European Organization for Nuclear Research',
    aliases: ['CERN', 'Europäische Organisation für Kernforschung', 'Organisation européenne pour la recherche nucléaire'],
    website: 'https://home.web.cern.ch/',
    short_name: 'CERN',
    rp: false,
    ror: 'https://ror.org/01ggx4157',
    country: Country.find('CH'),
    location: 'Geneva, Switzerland'
  )
end

def seed_zenodo
  zenodo = System.create!(
    name: 'Zenodo',
    short_name: 'Zenodo',
    url: 'https://zenodo.org',
    record_source: 'ird',
    owner: Organisation.find('4ab4ad1a-0d3d-40ef-824c-cd20b3173e78'),
    rp: Organisation.default_rp_for_live_records,
    system_category: :repository,
    subcategory: :aggregating_repository,
    primary_subject: :multidisciplinary,
    oai_base_url: 'https://zenodo.org/oai2d',
    platform: Platform.find('invenio')
  )
  Repoid.create!(system_id: zenodo.id, identifier_scheme: :opendoar, identifier_value: '2659')
end
