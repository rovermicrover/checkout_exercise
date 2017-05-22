require 'bigdecimal'

require "checkout_support/version"
require "checkout_support/item"
require "checkout_support/product"
require "checkout_support/discount"
require "checkout_support/deal"
require "checkout_support/deal_type"

class Checkout

  def initialize
    # Store products as a hash. Where keys are product objects
    # and the values are the number of the corrisponding key
    @products = Hash.new(0)
    # Normally would use atmoic redis counters here
    @products_counter = 0
    # Start at -1 so if you call discounts on a new empty
    # checkout that discounts returns an empty array
    # instead of nil
    @discounts_counter = -1
  end

  # Public accessor that returns products as an array
  # Return more expected data structure, instead of
  # novel one.
  def products
    @products.map{|prouduct, num| (1..num).map{|i| prouduct}}.flatten
  end

  def discounts
    if @discounts_counter != @products_counter
      @discounts_counter = @products_counter
      @discounts = @products.keys.map do |product|
        CheckoutSupport::Deal.lookup_deals(product).map do |deal|
          deal.apply(@products)
        end.flatten
      end.flatten
    end
    @discounts
  end

  def items
    products + discounts
  end

  def scan *_products
    _products.map do |product|
      if product.is_a? CheckoutSupport::Product
        @products[product] += 1
        @products_counter += 1
        @products[product]
      else
        nil
      end
    end
  end

  def remove *_products
    _products.map do |product|
      if product.is_a?(CheckoutSupport::Product) && @products[product] > 0
        @products[product] -= 1
        @products_counter += 1
        @products[product]
      else
        nil
      end
    end
  end

  def total
    products_total + discount_total
  end

  private

  def products_total
    _total = 0
    @products.each do |product, num|
      _total = _total + product.price * num
    end
    _total
  end

  def discount_total
    _total = 0
    discounts.each do |discount|
      _total = _total + discount.price
    end
    _total
  end

end