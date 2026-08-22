password = "DemoPass123!"

# ============================================================
# ServiceConnect Final Demo Seed Data
# ============================================================

# ------------------------------------------------------------
# Admin
# ------------------------------------------------------------

admin = User.find_or_initialize_by(email: "admin@serviceconnect.test")
admin.assign_attributes(
  first_name: "Ayesha",
  last_name: "Admin",
  phone_number: "03000000000",
  role: :admin,
  status: :active,
  password: password,
  password_confirmation: password
)
admin.save!

# ------------------------------------------------------------
# Service Categories
# ------------------------------------------------------------

category_names = %w[
  Electrical
  Plumbing
  Cleaning
  Painting
  Carpentry
]

categories = category_names.index_with do |name|
  ServiceCategory.find_or_create_by!(name: name) do |category|
    category.description = "Professional #{name.downcase} services"
    category.active = true
  end
end

categories.each_value do |category|
  category.update!(active: true)
end

# ------------------------------------------------------------
# Customers
# ------------------------------------------------------------

customers = 5.times.map do |index|
  user = User.find_or_initialize_by(
    email: "customer#{index + 1}@serviceconnect.test"
  )

  user.assign_attributes(
    first_name: "Customer",
    last_name: (index + 1).to_s,
    phone_number: "030000000#{index + 1}",
    role: :customer,
    status: :active,
    password: password,
    password_confirmation: password
  )

  user.save!

  user.customer_profile || user.create_customer_profile!

  address = user.addresses.find_or_initialize_by(label: "Home")
  address.assign_attributes(
    street: "#{index + 1} Main Street",
    city: "Karachi",
    postal_code: "75000",
    is_default: true
  )
  address.save!

  user
end

# ------------------------------------------------------------
# Preserve the real Abdullah account
# ------------------------------------------------------------

abdullah = User.find_by(email: "abdullah@example.com")

if abdullah
  abdullah.update!(
    first_name: "Abdullah",
    last_name: "Johar",
    status: :active
  )

  abdullah.customer_profile || abdullah.create_customer_profile!

  address = abdullah.addresses.find_or_initialize_by(label: "Home")
  address.assign_attributes(
    street: "Johar Town",
    city: "Lahore",
    postal_code: "54000",
    is_default: true
  )
  address.save!
end

# ------------------------------------------------------------
# Provider data
#
# 25 marketplace providers:
# 5 Electrical
# 5 Plumbing
# 5 Cleaning
# 5 Painting
# 5 Carpentry
#
# Ali Electrical Services is preserved.
# ------------------------------------------------------------

provider_definitions = [
  # Electrical
  {
    first_name: "Ali",
    email: "provider@example.com",
    phone: "03100000000",
    business_name: "Ali Electrical Services",
    category: "Electrical",
    experience: 6,
    hourly_rate: 1800
  },
  {
    first_name: "Danish",
    email: "provider1@serviceconnect.test",
    phone: "03100000001",
    business_name: "Danish Electrical Services",
    category: "Electrical",
    experience: 5,
    hourly_rate: 1700
  },
  {
    first_name: "Waqas",
    email: "provider2@serviceconnect.test",
    phone: "03100000002",
    business_name: "Waqas Electrical Services",
    category: "Electrical",
    experience: 7,
    hourly_rate: 1900
  },
  {
    first_name: "Saif",
    email: "provider3@serviceconnect.test",
    phone: "03100000003",
    business_name: "Saif Electrical Services",
    category: "Electrical",
    experience: 4,
    hourly_rate: 1650
  },
  {
    first_name: "Farhan",
    email: "provider4@serviceconnect.test",
    phone: "03100000004",
    business_name: "Farhan Electrical Services",
    category: "Electrical",
    experience: 8,
    hourly_rate: 2000
  },

  # Plumbing
  {
    first_name: "Ahmed",
    email: "provider5@serviceconnect.test",
    phone: "03100000005",
    business_name: "Ahmed Plumbing Services",
    category: "Plumbing",
    experience: 6,
    hourly_rate: 1600
  },
  {
    first_name: "Usman",
    email: "provider6@serviceconnect.test",
    phone: "03100000006",
    business_name: "Usman Plumbing Services",
    category: "Plumbing",
    experience: 5,
    hourly_rate: 1550
  },
  {
    first_name: "Bilal",
    email: "provider7@serviceconnect.test",
    phone: "03100000007",
    business_name: "Bilal Plumbing Services",
    category: "Plumbing",
    experience: 9,
    hourly_rate: 1850
  },
  {
    first_name: "Hassan",
    email: "provider8@serviceconnect.test",
    phone: "03100000008",
    business_name: "Hassan Plumbing Services",
    category: "Plumbing",
    experience: 4,
    hourly_rate: 1500
  },
  {
    first_name: "Fahad",
    email: "provider9@serviceconnect.test",
    phone: "03100000009",
    business_name: "Fahad Plumbing Services",
    category: "Plumbing",
    experience: 7,
    hourly_rate: 1750
  },

  # Cleaning
  {
    first_name: "Saad",
    email: "provider10@serviceconnect.test",
    phone: "03100000010",
    business_name: "Saad Cleaning Services",
    category: "Cleaning",
    experience: 5,
    hourly_rate: 1300
  },
  {
    first_name: "Omar",
    email: "provider11@serviceconnect.test",
    phone: "03100000011",
    business_name: "Omar Cleaning Services",
    category: "Cleaning",
    experience: 6,
    hourly_rate: 1400
  },
  {
    first_name: "Adnan",
    email: "provider12@serviceconnect.test",
    phone: "03100000012",
    business_name: "Adnan Cleaning Services",
    category: "Cleaning",
    experience: 4,
    hourly_rate: 1250
  },
  {
    first_name: "Rayan",
    email: "provider13@serviceconnect.test",
    phone: "03100000013",
    business_name: "Rayan Cleaning Services",
    category: "Cleaning",
    experience: 8,
    hourly_rate: 1500
  },
  {
    first_name: "Kashif",
    email: "provider14@serviceconnect.test",
    phone: "03100000014",
    business_name: "Kashif Cleaning Services",
    category: "Cleaning",
    experience: 7,
    hourly_rate: 1450
  },

  # Painting
  {
    first_name: "Arslan",
    email: "provider15@serviceconnect.test",
    phone: "03100000015",
    business_name: "Arslan Painting Services",
    category: "Painting",
    experience: 6,
    hourly_rate: 1500
  },
  {
    first_name: "Haris",
    email: "provider16@serviceconnect.test",
    phone: "03100000016",
    business_name: "Haris Painting Services",
    category: "Painting",
    experience: 5,
    hourly_rate: 1450
  },
  {
    first_name: "Sameer",
    email: "provider17@serviceconnect.test",
    phone: "03100000017",
    business_name: "Sameer Painting Services",
    category: "Painting",
    experience: 8,
    hourly_rate: 1700
  },
  {
    first_name: "Shahzaib",
    email: "provider18@serviceconnect.test",
    phone: "03100000018",
    business_name: "Shahzaib Painting Services",
    category: "Painting",
    experience: 4,
    hourly_rate: 1400
  },
  {
    first_name: "Yasir",
    email: "provider19@serviceconnect.test",
    phone: "03100000019",
    business_name: "Yasir Painting Services",
    category: "Painting",
    experience: 7,
    hourly_rate: 1600
  },

  # Carpentry
  {
    first_name: "Aamir",
    email: "provider20@serviceconnect.test",
    phone: "03100000020",
    business_name: "Aamir Carpentry Services",
    category: "Carpentry",
    experience: 6,
    hourly_rate: 1700
  },
  {
    first_name: "Noman",
    email: "provider21@serviceconnect.test",
    phone: "03100000021",
    business_name: "Noman Carpentry Services",
    category: "Carpentry",
    experience: 5,
    hourly_rate: 1600
  },
  {
    first_name: "Faisal",
    email: "provider22@serviceconnect.test",
    phone: "03100000022",
    business_name: "Faisal Carpentry Services",
    category: "Carpentry",
    experience: 8,
    hourly_rate: 1900
  },
  {
    first_name: "Salman",
    email: "provider23@serviceconnect.test",
    phone: "03100000023",
    business_name: "Salman Carpentry Services",
    category: "Carpentry",
    experience: 4,
    hourly_rate: 1550
  },
  {
    first_name: "Mustafa",
    email: "provider24@serviceconnect.test",
    phone: "03100000024",
    business_name: "Mustafa Carpentry Services",
    category: "Carpentry",
    experience: 9,
    hourly_rate: 2000
  }
]

providers = provider_definitions.map do |data|
  user = User.find_or_initialize_by(email: data[:email])

  user.assign_attributes(
    first_name: data[:first_name],
    last_name: user.last_name.presence || "Provider",
    phone_number: data[:phone],
    role: :provider,
    status: :active,
    password: password,
    password_confirmation: password
  )

  user.save!

  profile = user.provider_profile ||
            user.create_provider_profile!(
              business_name: data[:business_name],
              experience_years: data[:experience],
              hourly_rate: data[:hourly_rate]
            )

  profile.update!(
    business_name: data[:business_name],
    experience_years: data[:experience],
    hourly_rate: data[:hourly_rate],
    approval_status: :approved
  )

  category = categories.fetch(data[:category])

  # Each marketplace provider has one primary service.
  profile.provider_services
         .where.not(service_category_id: category.id)
         .destroy_all

  service = profile.provider_services.find_or_initialize_by(
    service_category: category
  )

  service.assign_attributes(
    description: "#{data[:category]} service provided by #{data[:first_name]}",
    base_price: data[:hourly_rate],
    duration_minutes: 60,
    active: true
  )

  service.save!

  # Monday through Sunday.
  (0..6).each do |day|
    availability = profile.availabilities.find_or_initialize_by(
      day_of_week: day
    )

    availability.assign_attributes(
      start_time: "09:00",
      end_time: "17:00",
      active: true
    )

    availability.save!
  end

  profile
end

# ------------------------------------------------------------
# Separate edge-case provider
#
# Kept outside the 25 marketplace providers.
# Useful for demonstrating suspended/rejected authorization.
# ------------------------------------------------------------

edge_user = User.find_or_initialize_by(
  email: "suspended.provider@serviceconnect.test"
)

edge_user.assign_attributes(
  first_name: "Sami",
  last_name: "Suspended",
  phone_number: "03200000001",
  role: :provider,
  status: :suspended,
  password: password,
  password_confirmation: password
)

edge_user.save!

edge_profile = edge_user.provider_profile ||
               edge_user.create_provider_profile!(
                 business_name: "Sami Suspended Services",
                 experience_years: 3,
                 hourly_rate: 1400
               )

edge_profile.update!(
  business_name: "Sami Suspended Services",
  experience_years: 3,
  hourly_rate: 1400,
  approval_status: :rejected
)

# ------------------------------------------------------------
# Demo bookings
# ------------------------------------------------------------

statuses = %i[
  pending
  accepted
  confirmed
  in_progress
  completed
  cancelled
  rejected
]

20.times do |index|
  customer = customers[index % customers.length]
  provider = providers[index % providers.length]

  category = ServiceCategory.order(:id).to_a[index % 5]

  scheduled_at = (index + 2).days.from_now.change(
    hour: 9 + (index % 6),
    min: 0
  )

  booking = Booking.find_or_initialize_by(
    customer: customer,
    provider: provider,
    scheduled_at: scheduled_at
  )

  status = statuses[index % statuses.length]

  booking.assign_attributes(
    service_category: category,
    address: customer.addresses.first,
    estimated_duration: 60,
    customer_description: "Demo service request #{index + 1}",
    estimated_price: 1500 + (index % 5) * 250,
    status: status
  )

  booking.save!(validate: false)

  booking.update_columns(
    accepted_at: booking.accepted? || booking.confirmed? ||
                 booking.in_progress? || booking.completed? ?
                 Time.current : nil,
    started_at: booking.in_progress? || booking.completed? ?
                Time.current : nil,
    completed_at: booking.completed? ? Time.current : nil,
    cancelled_at: booking.cancelled? ? Time.current : nil
  )
end

# ------------------------------------------------------------
# Abdullah reviews
# ------------------------------------------------------------

if abdullah
  review_providers = providers.first(2)

  review_providers.each_with_index do |provider, index|
    category = ServiceCategory.order(:id).to_a[index]

    scheduled_at = (index + 2).days.ago.change(
      hour: 11,
      min: 0
    )

    booking = Booking.find_or_initialize_by(
      customer: abdullah,
      provider: provider,
      scheduled_at: scheduled_at
    )

    booking.assign_attributes(
      service_category: category,
      address: abdullah.addresses.first,
      estimated_duration: 60,
      customer_description: "Completed demo service for review",
      estimated_price: 1800 + index * 200,
      status: :completed,
      accepted_at: scheduled_at - 1.day,
      started_at: scheduled_at,
      completed_at: scheduled_at + 1.hour
    )

    booking.save!(validate: false)

    Review.find_or_create_by!(booking: booking) do |review|
      review.customer = abdullah
      review.provider = provider
      review.rating = 5
      review.comment = if index.zero?
                         "Excellent service. The provider was professional and completed the work successfully."
      else
                         "Very good service. The provider was punctual, professional and completed the job properly."
      end
    end
  end
end

# ------------------------------------------------------------
# Demo messages and notifications
# ------------------------------------------------------------

Booking.completed.limit(10).each do |booking|
  Message.find_or_create_by!(
    booking: booking,
    sender: booking.customer
  ) do |message|
    message.content = "Thank you for the professional service."
  end

  Notification.find_or_create_by!(
    booking: booking,
    user: booking.customer,
    notification_type: "booking_completed"
  ) do |notification|
    notification.message = "Your demo booking has been completed."
  end
end

# ------------------------------------------------------------
# Final seed summary
# ------------------------------------------------------------

puts
puts "=============================================="
puts "ServiceConnect demo data seeded successfully"
puts "=============================================="
puts "Categories: #{ServiceCategory.count}"
puts "Marketplace providers: #{providers.count}"
puts "Customers: #{User.where(role: :customer).count}"
puts "Bookings: #{Booking.count}"
puts "Reviews: #{Review.count}"
puts "Availability records: #{Availability.count}"
puts
puts "Demo password: #{password}"
puts "=============================================="
