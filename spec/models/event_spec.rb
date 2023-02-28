require 'rails_helper'

RSpec.describe Event, type: :model do
    let(:space) { Space.create(name: "Test Space") }
    let(:admin) { User.create(name: "Test Admin", role: "admin", email: "test@example.com", password: "password") }
    let(:user) { User.create(name: "Test User", role: "event_coordinator", email: "test1@example.com", password: "password") }
    let(:client) { User.create(name: "Test client", role: "client", email: "test3@example.com", password: "password") }
    let(:event) { Event.create(
        name: "Test Event", 
        start_at: Time.current, 
        end_at: Time.current + 1.hour, 
        space_id: space.id,
        client_id: client.id
        ) }
    let(:eventInvalid) { Event.create(
            name: "Test Invalid Event", 
            start_at: Time.current, 
            end_at: Time.current + 1.hour, 
            space_id: space.id,
            client_id: client.id
            ) }
            
    let(:event2) { Event.create(
                name: "Test Valid Event", 
                start_at: Time.current + 1.hour, 
                end_at: Time.current + 2.hour, 
                space_id: space.id,
                client_id: client.id
                ) }
    
    describe "validations" do
        it "is valid with valid attributes" do
          event.users << user
          expect(event).to be_valid
        end
    
        it "is not valid without a name" do
          event.name = nil
          expect(event).not_to be_valid
        end
    
        it "is not valid without a start_at" do
          event.start_at = nil
          expect(event).not_to be_valid
        end
    
        it "is not valid without a end_at" do
          event.end_at = nil
          expect(event).not_to be_valid
        end
    
        it "is not valid if start_at is after end_at" do
          event.start_at = Time.current + 1.hour
          event.end_at = Time.current
          expect(event).not_to be_valid
        end
    
        it "is not valid without a space" do
          event.space_id = nil
          expect(event).not_to be_valid
        end
      end
    
      describe "associations" do
        it "belongs to a space" do
          expect(event.space).to eq(space)
        end
    
        it "has and belongs to many users" do
          event.users << user
          event.users << admin
          expect(event.users).to include(user)
        end
      end

    
         

    context "when creating a new event" do
    
        it "is not valid if it overlaps with an existing event" do
            # Create an event that overlaps with event1
            expect(eventInvalid).not_to be_valid
            # expect(eventInvalid.errors[:base]).to include("Another event is already scheduled at this time and location.")
        end
    
        it "is valid if there is no overlap with an existing event" do
            event2.users << user
            # Create an event that does not overlap with event1
            expect(event2).to be_valid
        end
    end

end