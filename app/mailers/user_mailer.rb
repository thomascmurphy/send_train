class UserMailer < ApplicationMailer

  def comment_email(subject, body, from_email)
    mail(to: "thomas.c.murphy@gmail.com", subject: subject, body: body, from: from_email)
  end
end
