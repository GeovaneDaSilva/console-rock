# Mass imports models into a specified active record class
class MassImport
  MassImportError = Class.new(StandardError)
  CouldNotImportAllModels = Class.new(MassImportError)
  # :nodoc
  class NoClassSpecifiedError < MassImportError
    def initialize(msg = "No klass was specified to import with. Please specify a klass.")
      super(msg)
    end
  end

  class << self
    def call(*args)
      new(*args).call
    end
  end

  def initialize(klass, models, run_callbacks: true, validate: true, raise_errors: false, **import_arguments)
    @models = models
    @klass = klass
    @import_arguments = import_arguments || {}
    @run_callbacks = run_callbacks
    @validate = validate
    @raise_errors = raise_errors

    @to_import = false
    @valid = []
    @invalid = []
    @result = false
    @errors = {}
  end

  attr_reader :errors

  def call
    raise NoClassSpecifiedError if @klass.blank?

    select_models_to_import
    execute_before_callbacks if @run_callbacks
    import
    extract_errors

    raise_errors! if @raise_errors

    self
  end

  def errors?
    errors.present?
  end

  private

  attr_reader :klass, :models, :invalid, :result

  def raise_errors!
    # TODO: implement a more advanced child of StandardError that takes care of
    # serializing errors like these appropriately
    raise CouldNotImportAllModels, log_details if errors?
  end

  def select_models_to_import
    if @validate
      validate_models
      @to_import = @valid
    else
      @to_import = models
    end
  end

  def validate_models
    models.each do |model|
      if model.valid?
        @valid << model
      else
        @invalid << model
      end
    end
  end

  def import
    @result = klass.import(@to_import, import_arguments)
  end

  def execute_before_callbacks
    @to_import.each do |model|
      model.run_callbacks(:save) { false }
      model.run_callbacks(:create) { false }
    end
  end

  def extract_errors
    errors[:invalid_models] = invalid if @invalid.size.positive?
    errors[:failed_insertions] = result.failed_instances if result.failed_instances.size.positive?
    log_error! if errors.present?
  end

  def log_error!
    Rails.logger.warn("#{error_header} : #{log_details.to_json}")
  end

  def error_header
    "#{self.class.name} failed to import some models."
  end

  def log_details
    model = models.first
    details = {
      message:      error_header,
      class_name:   self.class.name,
      model_sample: model.attributes,
      errors:       errors
    }
    details[:account] = { id: model.account.id } if model.respond_to?(:account)
    details
  end

  def import_arguments
    {
      validate:   false,
      batch_size: 1000
    }.merge(@import_arguments)
  end
end
