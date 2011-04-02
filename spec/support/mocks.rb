def mock_template *args
  mock Courier::Template::Base, *args
end

def mock_owner_setting *args
  mock_model Courier::OwnerSetting, *args
end

def mock_service *args
  mock Courier::Service::Base, *args
end

def mock_message *args
  mock_model Courier::Message, *args
end

def mock_owner *args
  mock_model User, *args
end
