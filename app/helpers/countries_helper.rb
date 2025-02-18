module CountriesHelper
  def country_code_for_name(name)
    Country.find_by_name(name).id
  end
end
