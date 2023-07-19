class CancellationReason < ApplicationRecord
  belongs_to :order

  DEFAULT_REASONS = {
    took_too_long: 'Trade took too long to complete',
    hasnt_completed_next_steps: "Other trader hasn't completed next steps",
    dont_want_to_trade: "Don't want to trade with other trader",
    dont_understand: "Don't understand OpenPeer",
  }
end
