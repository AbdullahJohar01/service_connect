password = "DemoPass123!"
admin = User.find_or_initialize_by(email: "admin@serviceconnect.test")
admin.assign_attributes(first_name: "Ayesha", last_name: "Admin", phone_number: "03000000000", role: :admin, status: :active, password: password, password_confirmation: password)
admin.save!

categories = %w[Plumbing Electrical Cleaning Painting Carpentry].map do |name|
  ServiceCategory.find_or_create_by!(name: name) { |category| category.description = "Professional #{name.downcase} services"; category.active = true }
end

customers = 5.times.map do |index|
  user = User.find_or_initialize_by(email: "customer#{index + 1}@serviceconnect.test")
  user.assign_attributes(first_name: "Customer", last_name: (index + 1).to_s, phone_number: "030000000#{index + 1}", role: :customer, status: :active, password: password, password_confirmation: password)
  user.save!; user.customer_profile || user.create_customer_profile!
  user.addresses.find_or_create_by!(label: "Home") { |address| address.street = "#{index + 1} Main Street"; address.city = "Karachi"; address.postal_code = "75000"; address.is_default = true }
  user
end

providers = 5.times.map do |index|
  user = User.find_or_initialize_by(email: "provider#{index + 1}@serviceconnect.test")
  user.assign_attributes(first_name: "Provider", last_name: (index + 1).to_s, phone_number: "031000000#{index + 1}", role: :provider, status: index == 3 ? :suspended : :active, password: password, password_confirmation: password)
  user.save!
  profile = user.provider_profile || user.create_provider_profile!(business_name: "Provider #{index + 1} Services", experience_years: index + 2, hourly_rate: 1200 + index * 100)
  profile.update!(approval_status: index == 3 ? :rejected : :approved)
  categories.each_with_index { |category, i| profile.provider_services.find_or_create_by!(service_category: category) { |service| service.description = "#{category.name} service"; service.base_price = 1500 + i * 250; service.duration_minutes = 60; service.active = true } }
  (0..6).each { |day| profile.availabilities.find_or_create_by!(day_of_week: day, start_time: "09:00", end_time: "17:00") }
  profile
end

statuses = %i[pending accepted confirmed in_progress completed cancelled rejected]
20.times do |index|
  customer = customers[index % customers.size]; provider = providers[index % 3]
  scheduled_at = (index + 2).days.from_now.change(hour: 9 + (index % 6), min: 0)
  booking = Booking.find_or_initialize_by(customer: customer, provider: provider, scheduled_at: scheduled_at)
  booking.assign_attributes(service_category: categories[index % categories.size], address: customer.addresses.first, estimated_duration: 60, customer_description: "Demo service request #{index + 1}", estimated_price: 1500, status: statuses[index % statuses.size])
  booking.save!(validate: false)
  booking.update_columns(accepted_at: booking.accepted? ? Time.current : nil, started_at: booking.in_progress? ? Time.current : nil, completed_at: booking.completed? ? Time.current : nil, cancelled_at: booking.cancelled? ? Time.current : nil)
end

Booking.completed.limit(3).each_with_index do |booking, index|
  Review.find_or_create_by!(booking: booking) { |review| review.customer = booking.customer; review.provider = booking.provider; review.rating = 4 + (index % 2); review.comment = "Excellent demo service." }
  Message.find_or_create_by!(booking: booking, sender: booking.customer, content: "Looking forward to the appointment.")
  Notification.find_or_create_by!(booking: booking, user: booking.customer, notification_type: "booking_completed") { |notification| notification.message = "Your demo booking is complete." }
end

puts "Seeded demo users. Password: #{password}"
