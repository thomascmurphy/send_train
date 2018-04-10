class UserMailer < ApplicationMailer

  def comment_email(subject, body, from_email)
    mail(to: "thomas.c.murphy+send_train@gmail.com", subject: subject, body: "body from: #{from_email}", from: "thomas.c.murphy+send_train@gmail.com")
  end

  def share_email(item_share)
    @item_share = item_share
    subject = "You've received a shared #{item_share.smart_item_type}"
    mail(to: item_share.recipient.email, from: "thomas.c.murphy+send_train@gmail.com")
  end
end
