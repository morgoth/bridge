class ProcMailer < ActionMailer::Base
  default :to => 'system@test.lindsaar.net',
          'X-Proc-Method' => Proc.new { Time.now.to_i.to_s },
          :subject => Proc.new { give_a_greeting }

  def welcome
    mail
  end
  
  private
  
  def give_a_greeting
    "Thanks for signing up this afternoon"
  end
  
end
