require 'health_check/logging_config'
require 'health_check/cli'
require 'spec_helper'

# Silence log output
Logging.logger.root.appenders = nil
