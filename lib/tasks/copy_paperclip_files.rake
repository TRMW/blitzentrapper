namespace :users do
  task migrate_to_active_storage: :environment do
    User.where.not(avatar_file_name: nil).find_each do |user|
  # This step helps us catch any attachments we might have uploaded that
      # don't have an explicit file extension in the filename
      image_file_name = user.avatar_file_name
      ext = File.extname(image_file_name)

      # this url pattern can be changed to reflect whatever service you use
      avatar_url = "https://s3.amazonaws.com/#{ENV['AWS_BUCKET']}/avatars/#{user.slug}/original#{ext}"
      puts avatar_url
      user.avatar.attach(io: open(avatar_url), filename: user.avatar_file_name)
    end
  end
end

namespace :records do
  task migrate_to_active_storage: :environment do
    Record.where.not(cover_file_name: nil).find_each do |record|
  # This step helps us catch any attachments we might have uploaded that
      # don't have an explicit file extension in the filename
      image_file_name = record.cover_file_name
      ext = File.extname(image_file_name)

      # this url pattern can be changed to reflect whatever service you use
      cover_url = "https://s3.amazonaws.com/#{ENV['AWS_BUCKET']}/covers/#{record.slug}/original#{ext}"
      puts cover_url
      record.cover.attach(io: open(cover_url), filename: record.cover_file_name)
    end
  end
end

namespace :videos do
  task migrate_to_active_storage: :environment do
    Video.where.not(clip_file_name: nil).find_each do |video|
  # This step helps us catch any attachments we might have uploaded that
      # don't have an explicit file extension in the filename
      image_file_name = video.clip_file_name
      ext = File.extname(image_file_name)

      # this url pattern can be changed to reflect whatever service you use
      clip_url = "https://s3.amazonaws.com/#{ENV['AWS_BUCKET']}/videos/#{video.id}/original#{ext}"
      puts clip_url
      video.clip.attach(io: open(clip_url), filename: video.clip_file_name)
    end
  end
end
