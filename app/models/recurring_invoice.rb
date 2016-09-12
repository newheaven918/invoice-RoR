class RecurringInvoice < Common

  # make this object a publisher
  include Wisper::Publisher

  # Relations
  has_many :invoices

  # Validation
  validates :series, presence: true
  validates :name, presence: true
  validates :starting_date, presence: true
  validates :period_type, presence: true
  validates :period, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validate :valid_date_range

  PERIOD_TYPES = [
    ["Daily", "day"],
    ["Monthly", "month"],
    ["Yearly", "year"]
  ].freeze

  def to_s
    "#{name}"
  end

  def next_invoice_date
    self.invoices.length > 0 ? self.invoices.last.issue_date + period.send(period_type) : starting_date
  end

  def generate_pending_invoices
    # how many invoices are generated by now
    occurrences = Invoice.belonging_to(id).count
    next_date = next_invoice_date()

    generated_invoices = []

    while next_date <= [Date.current, finishing_date.blank? ? Date.current + 1 : finishing_date].min and
        (max_occurrences.nil? or occurrences < max_occurrences) do
      inv = self.becomes(Invoice).deep_clone include: { items: :taxes}, except: [:period, :period_type, :starting_date, :finishing_date, :max_occurrences]

      inv.recurring_invoice_id = self.id
      inv.status = 'Open'
      inv.issue_date = next_date
      inv.due_date = Date.current + days_to_due.days if days_to_due
      inv.meta_attributes = meta_attributes

      inv.items.each do |item|
        item.description.sub! "$(issue_date)", inv.issue_date.strftime('%Y-%m-%d')
        item.description.sub! "$(issue_date - period)", (inv.issue_date - period.send(period_type)).strftime('%Y-%m-%d')
        item.description.sub! "$(issue_date + period)", (inv.issue_date + period.send(period_type)).strftime('%Y-%m-%d')
       end

      broadcast(:invoice_generation, inv)
      next_date += period.send period_type
      occurrences += 1
      generated_invoices.append inv
      if inv.save
        inv.send_email if self.sent_by_email  # If recurring is set to send emails
      end
    end

    save
    generated_invoices
  end

  def self.with_pending_invoices
    # candidates to have pending invoices
    candidates = where(:enabled => true)
    pendings = []
    candidates.each do |actual|

      # get the finishing date from either max_occurrences or finishing_date
      ending_date = Date.new 2999
      if actual.max_occurrences?
        if Invoice.belonging_to(actual.id).count >= actual.max_occurrences
          next
        end
        ending_date = actual.starting_date +
          (actual.period * actual.max_occurrences).send(actual.period_type)
      end
      if actual.finishing_date? and actual.finishing_date < ending_date
        ending_date = actual.finishing_date
      end

      # get the next invoice issuing date
      next_date = actual.invoices.length > 0 ? \
          actual.invoices.last.created_at + actual.period.send(actual.period_type) \
          : actual.starting_date

      # is it within range?
      if next_date > Date.current or !next_date.in? (actual.starting_date...ending_date)
        next
      end

      pendings.append actual
    end
    pendings
  end

  def test
    broadcast(:invoice_generation, Invoice.first)
  end


  private

  def valid_date_range
    return if starting_date.blank? || finishing_date.blank?

    if starting_date > finishing_date
      errors.add(:finishing_time, "Finishing Date must be after Starting Date")
    end
  end

end
