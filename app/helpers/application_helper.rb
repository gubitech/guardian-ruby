module ApplicationHelper
  def is_login_page?
    action_name == "login" && controller_name == "authentication"
  end
end
