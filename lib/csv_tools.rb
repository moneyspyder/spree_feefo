# encoding: UTF-8
module CsvTools

  def csv_line_from_hash(keys, hash)
    csv_line(csv_parts_from_hash(keys, hash))
  end

  def csv_parts_from_hash(keys, hash)
    keys.collect{|key| hash[key]}
  end

  def csv_escape(s)
    s = s.to_s
    if s.nil?
      ''
    elsif s == ''
      '""'
    elsif s =~ /\A[0-9a-z@\.\-]+\Z/i
      s
    else
      "\"#{s.gsub('"', '""')}\""
    end
  end

  def csv_line(*parts)
    parts.flatten!
    #parts.compact! if parts
    parts.map { |part| csv_escape(part) }.join(',')
  end

  def tab_line(*parts)
    parts.flatten!
    #parts.compact! if parts
    parts.map { |part| csv_escape(part) }.join("\t")
  end

  def csv_line_piped(*parts)
    parts.flatten!
    #parts.compact! if parts
    parts.map { |part| csv_escape(part) }.join('|')
  end

  def csv(rows)
    raw(rows.map { |row| csv_line(*yield(row)) }.join("\r\n"))
  end

  def csv_date(datetime)
    datetime.strftime('%d/%m/%Y') if datetime
  end

  def csv_time(datetime)
    datetime.strftime("%H:%M") if datetime
  end

  def csv_datetime(datetime)
    datetime.strftime('%d/%m/%Y %H:%M') if datetime
  end

  def csv_pound(money)
    raise "Money isn't GBP" unless money.currency == Currency.GBP

    #"\xA3#{money.amount_in_decimal}"
    "#{money.amount_in_decimal}"
  end

  def csv_money_with_currency(money)
    # TODO why isn't this just money.to_s?
    if money.currency == Currency.GBP
      #"\xA3#{money.amount_in_decimal}"
      "#{money.amount_in_decimal}"
    elsif money.currency == Currency.EUR
      #"\x80#{money.amount_in_decimal}"
      "#{money.amount_in_decimal}"
    elsif money.currency == Currency.AUD
      #"\x24#{money.amount_in_decimal}"
      "#{money.amount_in_decimal}"
    elsif money.currency == Currency.USD
      #"\x24#{money.amount_in_decimal}"
      "#{money.amount_in_decimal}"
    end
  end

  def csv_percent(ratio)
    "#{ratio * 100.0}%"
  end

  def csv_order_status(status)
    OrderStatus.status_to_word(status)
  end

  def csv_order_method(method)
    case method
    when Order::INTERNET
      'Internet'
    when Order::TELEPHONE
      'Telephone'
    when Order::MAIL
      'Mail'
    when Order::HISTORICAL
      'Historical'
    when Order::STORE
      'Store'
    end
  end
end
