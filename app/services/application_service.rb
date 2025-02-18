# frozen_string_literal: true

class ApplicationService
  Response = Struct.new(:success?, :payload, :error) do
    def failure?
      !success?
    end
  end

  def initialize(propagate = true)
    @propagate = propagate
  end

  def self.call(...)
    service = new(false)
    service.call(...)
  rescue StandardError => e
    service.failure(e)
  end

  def self.call!(...)
    new(true).call(...)
  end

  def success(payload = nil)
    Response.new(true, payload)
  end

  def failure(exception)
    raise exception if @propagate
    Response.new(false, nil, exception)
  end
end
