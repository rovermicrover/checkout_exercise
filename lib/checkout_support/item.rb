module CheckoutSupport
  class Item

    attr_reader :id, :price, :name

    def initialize options={}
      @id = options[:id].to_s
      @price = options[:price]
      @name = options[:name].to_s
    end

    # Overide == and hash to allow for items to be easy look up hash keys
    def ==(other)
      self.class === other and
        other.id == @id
    end

    alias_method :eql?, :==

    def hash
      Digest::SHA1.hexdigest(@id + self.class.name).to_i(16)
    end

  end
end