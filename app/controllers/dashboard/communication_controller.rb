class Dashboard::CommunicationController < ApplicationController
  force_ssl
  filter_access_to :all

  def index
    
    
  end
  
  
  def email_check
    
    if params[:subject].present? and params[:test_emails].present? and params[:body].present? 
      
      r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
      for email in params[:test_emails].scan(r).uniq
        @ready_for_final = true        
        if user = User.find_by_email(email)
          User.construct_and_send_generic_message(user, params)     
        end
      end
                  
    end
      
    render :action => 'index'    
        
  end
  
  
  def mass_email_go
    
    if params[:subject].present? and params[:body].present? 
      for user in User.all
        User.construct_and_send_generic_message(user, params)     
      end        
    end
      
    flash[:notice] = "Mass email sent"  
    redirect_to :action => 'index'    
    
  end


end