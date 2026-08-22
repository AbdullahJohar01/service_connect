module ApplicationHelper
  def pkr(amount)
    number_to_currency(amount, unit: "PKR ", format: "%u%n", precision: 0)
  end
end
