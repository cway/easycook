#encoding: utf-8
#author cway 2013-06-23

def authorize (params)
  if params[:name] != "admin"
    halt 403
  end
end
