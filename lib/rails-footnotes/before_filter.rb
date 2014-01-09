module Footnotes
  class BeforeFilter
    # Method called to start the notes
    # It's a before filter prepend in the controller
    def self.before(controller)
      silence_warnings do
        Footnotes::Filter.start!(controller)
      end
    end
  end
end
