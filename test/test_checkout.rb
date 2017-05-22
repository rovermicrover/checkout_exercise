require 'awesome_print'
require 'simplecov'
SimpleCov.start do
  add_group "Library", "lib/"
end

require 'minitest/autorun'
require 'checkout'

class CheckoutTest < Minitest::Test

  # def initialize(name = nil)
  #   @test_name = name
  #   super(name) unless name.nil?
  # end

  def build_products
    @items = {}
    @items[:CH1] = CheckoutSupport::Product.new(id: "CH1", name: "Chai", price: BigDecimal.new("3.11"))
    @items[:AP1] = CheckoutSupport::Product.new(id: "AP1", name: "Apple", price: BigDecimal.new("6.00"))
    @items[:CF1] = CheckoutSupport::Product.new(id: "CF1", name: "Coffee", price: BigDecimal.new("11.23"))
    @items[:MK1] = CheckoutSupport::Product.new(id: "MK1", name: "Milk", price: BigDecimal.new("4.75"))
  end

  def build_deal_types
    @deal_types = {}
    @deal_types[:buy_get_free] = CheckoutSupport::DealType.new do |products, options|
      prerequisite_product = options[:prerequisite_product]
      prerequisite_count = options[:prerequisite_count]

      target_product = options[:target_product]
      target_count = options[:target_count]

      if (prerequisite_product == target_product)
        possible_discounts_applied = products[prerequisite_product] / (prerequisite_count + target_count)
      else
        possible_discounts_applied = products[prerequisite_product] / (prerequisite_count)
      end

      possible_discounts_applied = [options[:limit], products[target_product], possible_discounts_applied].compact.min

      (1..possible_discounts_applied).map{|i| CheckoutSupport::Discount.new(id: options[:id], price: -1 * target_product.price)}
    end
    @deal_types[:bulk] = CheckoutSupport::DealType.new do |products, options|
      prerequisite_product = options[:prerequisite_product]
      prerequisite_count = options[:prerequisite_count]
      discount = options[:discount]

      possible_discounts_applied = (products[prerequisite_product] >= prerequisite_count) ? products[prerequisite_product] : 0

      (1..possible_discounts_applied).map{|i| CheckoutSupport::Discount.new(id: options[:id], price: -1 * (prerequisite_product.price * discount))}
    end
  end

  def build_deals
    @deals = {}
    @deals[:BOGO] = CheckoutSupport::Deal.new(
      id: "BOGO", deal_type: @deal_types[:buy_get_free],
      prerequisite_product: @items[:CF1], prerequisite_count: 1,
      target_product: @items[:CF1], target_count: 1
    )
    @deals[:APPL] = CheckoutSupport::Deal.new(
      id: "APPL", deal_type: @deal_types[:bulk],
      prerequisite_product: @items[:AP1], prerequisite_count: 3,
      discount: BigDecimal.new("0.25")
    )
    @deals[:CHMK] = CheckoutSupport::Deal.new(
      id: "CHMK", deal_type: @deal_types[:buy_get_free],
      prerequisite_product: @items[:CH1], prerequisite_count: 1,
      target_product: @items[:MK1], target_count: 1,
      limit: 1
    )
  end

  def setup
    build_products
    build_deal_types
    build_deals
  end

  def test_given_test_case_1
    checkout = Checkout.new
    checkout.scan(@items[:CH1], @items[:AP1], @items[:CF1], @items[:MK1])
    assert_equal BigDecimal.new("20.34"), checkout.total
  end

  def test_given_test_case_2
    checkout = Checkout.new
    checkout.scan(@items[:MK1], @items[:AP1])
    assert_equal BigDecimal.new("10.75"), checkout.total
  end

  def test_given_test_case_3
    checkout = Checkout.new
    checkout.scan(@items[:CF1], @items[:CF1])
    assert_equal BigDecimal.new("11.23"), checkout.total
  end

  def test_given_test_case_4
    checkout = Checkout.new
    checkout.scan(@items[:AP1], @items[:AP1], @items[:CH1], @items[:AP1])
    assert_equal BigDecimal.new("16.61"), checkout.total
  end

  def test_that_discount_cache_counter_breaks_on_scan
    checkout = Checkout.new
    checkout.scan(@items[:AP1], @items[:AP1])
    assert_equal 0, checkout.discounts.length
    checkout.scan(@items[:AP1])
    assert_equal 3, checkout.discounts.length
  end

  def test_that_discount_cache_counter_breaks_on_remove
    checkout = Checkout.new
    checkout.scan(@items[:AP1], @items[:AP1], @items[:AP1])
    assert_equal 3, checkout.discounts.length
    checkout.remove(@items[:AP1])
    assert_equal 0, checkout.discounts.length
  end

  def test_that_discount_cache_works
    checkout = Checkout.new
    checkout.scan(@items[:AP1], @items[:AP1], @items[:AP1])
    # Use equal to ensure the very same array object is returned
    assert checkout.discounts.equal?(checkout.discounts)

    checkout2 = Checkout.new
    checkout2.scan(@items[:AP1], @items[:AP1], @items[:AP1])
    # Just to prove we haven't overridden equal?
    refute checkout2.discounts.equal?(checkout.discounts)
  end

  def test_that_public_products_methods_returns_the_correct_results
    checkout = Checkout.new
    checkout.scan(@items[:AP1], @items[:CH1], @items[:AP1], @items[:CF1], @items[:MK1])
    assert 5, checkout.products.length
  end

  def test_that_an_empty_checkout_does_not_cause_errors
    checkout = Checkout.new

    assert_equal 0, checkout.products.length
    assert_equal 0, checkout.discounts.length
    assert_equal 0, checkout.items.length
    assert_equal BigDecimal.new("0.00"), checkout.total
    # Make sure items can't be removed if there are none
    assert_nil checkout.remove(@items[:CH1]).first
    assert_equal 0, checkout.products.length
  end

  def test_that_you_cant_scan_non_products_to_a_checkout
    checkout = Checkout.new
    checkout.scan("Foobar")
    assert_equal 0, checkout.products.length
  end

  def test_that_two_items_with_same_id_are_equal_and_have_same_hash
    item1 = CheckoutSupport::Item.new(id: "Foo", price: BigDecimal.new("1.00"))
    item2 = CheckoutSupport::Item.new(id: "Foo", price: BigDecimal.new("2.00"))

    assert_equal item1, item2
    assert_equal item1.hash, item2.hash
  end

end