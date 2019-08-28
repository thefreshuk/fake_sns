module FakeSNS
  ROOT_DIR = File.join(__dir__, '../..')
  ASYNC = ENV['RACK_ENV'] != 'test'
end