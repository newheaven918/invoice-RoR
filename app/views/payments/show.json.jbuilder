json.extract! @payment, :id, :amount, :date, :notes, :created_at, :updated_at
json.invoice do
  json.id  @payment.invoice.id
  json.series_number @payment.invoice.to_s
  json.name @payment.invoice.name
end
