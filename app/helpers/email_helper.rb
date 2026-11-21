# frozen_string_literal: true

require "base64"

# Keeps email addresses out of the page's HTML so scrapers can't harvest
# them. The address is stored reversed and Base64-encoded in a data
# attribute, and application.js turns it into a mailto link in the browser.
module EmailHelper
  NOSCRIPT_TEXT = "(turn on JavaScript to see this email address)"

  def protected_mail_to(email, subject: nil)
    encoded = Base64.strict_encode64(email.reverse)
    data = { email: encoded, subject: subject }.compact
    tag.span(class: "protected-email", data: data) do
      tag.noscript(NOSCRIPT_TEXT)
    end
  end
end
