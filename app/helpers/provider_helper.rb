# :nodoc
module ProviderHelper
  def provider_breadcrumbs(leaf, ancestors)
    links = provider_links(leaf, ancestors)

    breadcrumbs_tag(links)
  end

  def provider_links(leaf, ancestors)
    links = ancestors.order(:path).collect do |provider|
      link_to provider.name, provider_path(provider)
    end

    links << leaf.name
  end

  def states_for_country(country = "US")
    if country.is_a?(Array)
      all_states = []
      country.each do |one|
        all_states << ISO3166::Country.new(one)
                        &.states&.to_a
                        &.collect { |entry| ["#{entry[0]} - #{entry[1].name} (#{one})", entry[0]] }
      end
      all_states.reduce(:+)
    else
      ISO3166::Country.new(country)
                      .states.to_a
                      .collect { |entry| ["#{entry[0]} - #{entry[1].name}", entry[0]] }
    end
  end
end
