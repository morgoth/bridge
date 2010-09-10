module Claim::States
  extend ActiveSupport::Concern

  included do
    state_machine do
      event :propose do
        transition nil => :previous_accepted, :if => :previous_user_dummy?
        transition nil => :next_accepted, :if => :next_user_dummy?
        transition nil => :proposed, :if => :user_declarer?
      end
      event :accept do
        transition :proposed => :previous_accepted, :if => :user_previous?
        transition :proposed => :next_accepted, :if => :user_next?
        transition :previous_accepted => :accepted, :if => :user_next?
        transition :next_accepted => :accepted, :if => :user_previous?
      end
      event :reject do
        transition [:proposed, :previous_accepted, :next_accepted] => :rejected, :if => :playing_user?
      end
    end
  end
end
