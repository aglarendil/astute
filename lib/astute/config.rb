#    Copyright 2013 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.


require 'symboltable'
require 'singleton'

module Astute
  class ConfigError < StandardError; end
  class UnknownOptionError < ConfigError
    attr_reader :name

    def initialize(name)
      super("Unknown config option #{name}")
      @name = name
    end
  end

  class MyConfig
    include Singleton
    attr_reader :configtable

    def initialize
      @configtable = SymbolTable.new
    end
  end

  class ParseError < ConfigError
    attr_reader :line

    def initialize(message, line)
      super(message)
      @line = line
    end
  end

  def self.config
    config = MyConfig.instance.configtable
    config.update(default_config) if config.empty?
    return config
  end

  def self.default_config
    conf = {}
    conf[:PUPPET_TIMEOUT] = 60*60         # maximum time it waits for the whole deployment
    conf[:PUPPET_DEPLOY_INTERVAL] = 2     # sleep for ## sec, then check puppet status again
    conf[:PUPPET_FADE_TIMEOUT] = 60       # how long it can take for puppet to exit after dumping to last_run_summary
    conf[:MC_RETRIES] = 5                 # MClient tries to call mcagent before failure
    conf[:MC_RETRY_INTERVAL] = 1          # MClient sleeps for ## sec between retries
    conf[:PUPPET_FADE_INTERVAL] = 1       # retry every ## seconds to check puppet state if it was running
    conf[:PROVISIONING_TIMEOUT] = 90 * 60 # timeout for booting target OS in provision
    conf[:REBOOT_TIMEOUT] = 120           # how long it can take for node to reboot 
    return conf
  end
end
