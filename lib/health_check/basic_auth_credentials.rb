module HealthCheck
  # A value class for basic auth credentials, with a user name and a password.
  #
  # Because this is a Struct, the object can be passed into a Net::HTTP::Get
  # request's #basic_auth method with the splat operator.
  BasicAuthCredentials = Struct.new(:user, :password) do
    def self.call(value)
      error = "Credentials must be of the form 'user:password'"
      raise ArgumentError, error unless value && value.include?(":")

      new(*value.split(":", 2)).freeze
    end
  end
end
