#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_3425_available_id_types: :environment do
    settings = App::Services::SettingService.new(EFrame::Iam.system_context).index

    puts "********* settings *********"
    pp settings

    available_id_types = settings.select{ |s| s.key == 'owner.id_types' }.first.value

    puts "********* available_id_types *********"
    pp available_id_types
  end
end