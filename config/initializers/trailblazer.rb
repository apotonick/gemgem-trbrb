require "trailblazer/operation/dispatch"

Trailblazer::Operation.class_eval do
  include Trailblazer::Operation::Dispatch
end
