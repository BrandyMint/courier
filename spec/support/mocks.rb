def mock_template *args
  mock_model Courier::Template::Base, *args
end

def mock_sets *args
  mock_model Courier::OwnerSet, *args
end

def mock_service *args
  mock_model Courier::Service::Base, *args
end
