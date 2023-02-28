class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise  :database_authenticatable,
          :jwt_authenticatable,
          :registerable,
          jwt_revocation_strategy: JwtDenylist

  enum role: { admin: 0, event_coordinator: 1, client: 3 }
  has_and_belongs_to_many :events

  def generate_token
    self.auth_token = SecureRandom.hex
    save!
  end
end
