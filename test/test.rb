
%w{

  t_misc
  t_auth

  ft_auth

  st_service
  st_errors
  st_expressions
  st_participants
  st_history

  st_processes
  st_workitems

}.each do |t|
  require File.join(File.dirname(__FILE__), t)
end

