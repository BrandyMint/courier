# -*- coding: utf-8 -*-
require 'spec_helper'

describe Courier::Message do

  it { should belong_to(:owner) }

  it { should validate_presence_of(:owner) }
  it { should validate_presence_of(:service) }
  it { should validate_presence_of(:template2) }
end
