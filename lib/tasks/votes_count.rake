namespace :votes_count_refresh do
  desc "Reset and update votes_count column manually"
  task reset_and_update: :environment do
    Proposal.reset_column_information
    Proposal.all.each do |p|
      Proposal.reset_counters(p.id, :votes)
    end
    puts "Proposal vote counts have been reset and refreshed"
  end
end