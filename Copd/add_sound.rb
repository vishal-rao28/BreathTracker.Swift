require 'rubygems'
require 'xcodeproj'
project_path = '../Copd.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

group = project.main_group.children.find { |g| g.display_name == 'Copd' || g.path == 'Copd' }
if group
  if group.files.any? { |f| f.path == 'alarm.wav' }
    puts 'already exists in group'
  else
    ref = group.new_reference('alarm.wav')
    target.resources_build_phase.add_file_reference(ref, true)
    project.save
    puts 'Successfully added alarm.wav to project target.'
  end
else
  puts 'Could not find Copd group'
end
