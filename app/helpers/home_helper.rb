# frozen_string_literal: true

# Helpers for the mostly static pages served by HomeController.
module HomeHelper
  # Where people write to claim old Facebook login accounts.
  CONTACT_EMAIL = "matt@blitzentrapper.net"

  def contact_email
    CONTACT_EMAIL
  end
end
