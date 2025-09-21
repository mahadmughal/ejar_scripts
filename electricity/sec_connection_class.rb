#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_646_sec_connection_class: :environment do
    response, call_id = App::Services::Sec::Connection.new(
              name: :premise_check,
              params: {premiseID: "30015713875"}
            ).call
    pp response
    pp call_id
  end
end; 0