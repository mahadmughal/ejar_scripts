namespace :custom_tasks do
  desc "ES_2808_update_core_contract"
  task ES_2808_update_core_contract: :environment do
    Workers::UnitSecurityForms::UpdateCoreContract.perform_in(1.minute, '8caf4c99-9a89-4294-a1e5-0a5a13daff03')
  end
end
