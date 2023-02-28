class EventSerializer < ActiveModel::Serializer
    attributes :id, :name, :description, :start_at, :end_at, :duration
  
    has_many :users
    belongs_to :client, class_name: "User", foreign_key: "client_id", serializer: UserSerializer
    belongs_to :space
  end