class Event < ApplicationRecord
    include ActionView::Helpers::DateHelper

    has_and_belongs_to_many :users
    belongs_to :client, class_name: "User", foreign_key: "client_id"
    belongs_to :space

    validates :client_id, presence: true
    validates :space_id, presence: true
    validates :name, presence: true
    validates :start_at, presence: true
    validates :end_at, presence: true
    validates :users, presence: true
    
    validate :no_conflicting_events

    validate :start_at_cannot_be_lower_than_ends_at  

    
    def as_json(options = {})
        super(options.merge(methods: [:duration]))
    end

    def duration
        "#{distance_of_time_in_words(start_at, end_at)}"
    end

    # def client

    # end

    private
    
    def start_at_cannot_be_lower_than_ends_at
        if start_at.present? && end_at.present? && start_at > end_at
          errors.add(:start_at, "can't be lower than ends_at datetime")
        end
      end

    def no_conflicting_events
        conflicting_events = Event.where(space_id: space_id)
            .where.not(id: id)
            .where('start_at <= ? AND end_at <= ?', start_at, end_at)
        if conflicting_events.any?
            errors.add(:base, "Another event is already scheduled at this time and location.")
        end
    end

end
