# Service that triggers destroy for Providers
class ProviderDestroyer
  def initialize(provider)
    @provider = provider
  end

  def call
    @provider.destroy!
  end
end
