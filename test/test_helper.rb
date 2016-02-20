require "minitest/autorun"

class Minitest::Test
  @@host = ENV['DB_HOST'] || "127.0.0.1"
end