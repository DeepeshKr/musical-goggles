class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name

  belongs_to :users
  belongs_to :events
end
