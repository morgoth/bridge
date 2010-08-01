module OldTouch
  # File rails3.0.0.beta/activerecord/lib/active_record/timestamp.rb, line 29
  def touch(attribute = nil)
    current_time = current_time_from_proper_timezone

    if attribute
      write_attribute(attribute, current_time)
    else
      write_attribute('updated_at', current_time) if respond_to?(:updated_at)
      write_attribute('updated_on', current_time) if respond_to?(:updated_on)
    end

    save!
  end
end
