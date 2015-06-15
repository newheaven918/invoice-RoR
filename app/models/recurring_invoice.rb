class RecurringInvoice < Common
  # Relations
  has_many :invoices

  # Validation
  validates :customer_name, :starting_date, presence: true
  validates :customer_email, \
    format: {
      with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i,
      message: "Only valid emails"
    }
  validate :valid_date_range
  validates :series, presence: true

  # Status
  PERIOD_TYPES = [
    ["Dayly", "days"],
    ["Monthly", "months"],
    ["Yearly", "years"]
  ].freeze

  STATUS = ['Inactive', 'Active']


  def to_s
    series_name = ""
    series_name = " (#{series.name})" if not series.name.empty?
    "#{customer_name}#{series_name}"
  end
  # returns all recurring_invoices with specified status
  scope :with_status, -> (status) {where status: status}

  def get_status
    if status
      STATUS[status]
    else
      # For nil case
      STATUS[0]
    end
  end

  private

  def valid_date_range
    return if starting_date.blank? || finishing_date.blank?

    if starting_date > finishing_date
      errors.add(:finishing_time, "Finishing Date must be after Starting Date")
    end
  end

end
