require 'yaml'

class EventImporter
  def initialize(file_path)
    @file_path = file_path
  end

  def import
   events_errors =[]
   events_errors_log =[]
    events = YAML.load_file(@file_path)

    events.each do |event_data, other|

      other.each do |data|
        user = User.find_by(email: data['event_coordinators'][0]['email'])
        client = User.find_by(email: data['client']['email'])
        space = Space.find_or_create_by(name: data['space']['name'])

     
        begin

          event = Event.new(
            name: data['name'],
            start_at: data['starts'].to_datetime,
            end_at: data['ends'].to_datetime,
            client_id: client.id,
            space_id: space.id
          )
          event.users << user

          event.save!
        rescue Exception => exception

          events_errors.push(exception.message,)
          events_errors_log.push(exception.backtrace.inspect)
  
          ensure

         next
       end
        
      end

      p events_errors
      
    end
  end
end

