module CheckoutSupport
  class DealType

    def initialize options={}, &block
      # Logic must be a block with the
      # first argument being an array of products
      # and the second must be an optional options hash
      # Must return an array of discounts, can be empty
      @logic = block
    end

    def apply products, options
      @logic.call(products, options)
    end

  end
end