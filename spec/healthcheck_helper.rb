require 'health_check/logging_config'
require 'spec_helper'

# Silence log output
Logging.logger.root.appenders = nil
