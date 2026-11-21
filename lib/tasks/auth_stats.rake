# frozen_string_literal: true

# TEMPORARY: prints aggregate account counts (no personal data) so we can
# plan password resets. Runs in the PR preview against its copy of the
# production database. Not meant to be merged.
namespace :users do
  desc 'Print aggregate counts of how accounts can log in'
  task auth_stats: :environment do
    kind = <<~SQL.squish
      CASE WHEN crypted_password IS NULL OR crypted_password = '' THEN 'none'
           WHEN crypted_password LIKE '$P$%' THEN 'phpass'
           WHEN crypted_password LIKE '$H$%' THEN 'phpass-H'
           WHEN length(crypted_password) = 128 THEN 'sha512'
           ELSE 'scrypt/other' END
    SQL
    email = "CASE WHEN email IS NULL OR email = '' THEN 'no' ELSE 'yes' END"
    recent = "CASE WHEN last_request_at > now() - interval '2 years' " \
             "THEN 'active<2y' ELSE 'older' END"
    fb = "CASE WHEN fbid IS NULL OR fbid = '' THEN 'no' ELSE 'yes' END"

    sql = "SELECT #{kind} AS pw, #{email} AS email, #{fb} AS fb, " \
          "#{recent} AS recent, count(*) FROM users GROUP BY 1, 2, 3, 4 " \
          'ORDER BY 1, 2, 3, 4'
    puts '[auth_stats] pw | email | fb | recent | count'
    ActiveRecord::Base.connection.select_rows(sql).each do |row|
      puts "[auth_stats] #{row.join(' | ')}"
    end

    admins = ['michael.james', 'marty', 'Mentok', 'earley', 'eearley',
              'E. Earley', 'Brian Trapper', 'Ross McLochness', 'Matt', 'Sara']
    admins.each do |login|
      row = ActiveRecord::Base.connection.select_rows(
        User.sanitize_sql(["SELECT #{kind}, #{email} FROM users " \
                           'WHERE login = ?', login])
      ).first
      puts "[auth_stats] admin #{login}: pw=#{row&.first || 'missing'} " \
           "email=#{row&.last || '-'}"
    end
  end
end
