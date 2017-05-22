module CheckoutSupport
  class Deal

    attr_reader :id

    @@deal_lookup = Hash.new { |h, k| h[k] = Set.new }

    # Pass any deal spefic information as options
    # they will be passed along to deal type on applicaiton.
    def initialize options={}
      @id = options[:id]

      @prerequisite_item = options[:prerequisite_product]

      @deal_type = options[:deal_type]
      @options = options

      append_self
    end

    def apply products
      @deal_type.apply(products, @options)
    end

    def self.lookup_deals item
      @@deal_lookup[item]
    end

    def ==(other)
      self.class === other and
        other.id == @id
    end

    alias_method :eql?, :==

    def hash
      Digest::SHA1.hexdigest(@id + self.class.name).to_i(16)
    end

    private

    def append_self
      @@deal_lookup[@prerequisite_item].add(self)
    end

  end
end