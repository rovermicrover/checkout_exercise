Products for a checkout are stored in a Hash where each key is a product and each
value is the number of said product. So a cart with two milks, an apple and a chai
would look like the following.

```ruby
{
  #<CheckoutSupport::Product:0x007f8b480e2f38 @id="AP1", @price=#<BigDecimal:7f8b480e2fb0,'0.6E1',9(18)>, @name="Apple"> => 2,
  #<CheckoutSupport::Product:0x007f8b480e2da8 @id="CF1", @price=#<BigDecimal:7f8b480e2e98,'0.1123E2',18(18)>, @name="Coffee"> => 1,
  #<CheckoutSupport::Product:0x007f8b480e2bc8 @id="MK1", @price=#<BigDecimal:7f8b480e2c40,'0.475E1',18(18)>, @name="Milk"> => 1
}
```

Discounts are only calculated when asked for via the discounts method. They are
calculated by looping through the list of distinct products and then attempting
to apply each deal where that product is a prerequisite.

Each deal types logic is passed in on initialize as a block to allow  for flexibility
in the system. The logic should only deal with products in the abstract. More specific
information should be passed in the options hash on initialize of a deal.