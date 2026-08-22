class BookingMailer < ApplicationMailer
  def status_changed
    @booking = params[:booking]
    @event = params[:event]
    mail(to: params[:recipient].email, subject: "ServiceConnect booking #{@event.humanize}")
  end
end
