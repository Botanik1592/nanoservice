require 'rails_helper'

RSpec.describe Message, type: :model do
  it { should validate_presence_of :body }
  it { should validate_presence_of :sender }
  it { should validate_presence_of :service }
  it { should validate_presence_of :reciever }
  it { should validate_length_of(:body).is_at_least(1) }
end
