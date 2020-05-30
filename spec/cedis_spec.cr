require "./spec_helper"

private def init_tests
  Cedis::Store.new
end

describe Cedis do
  describe Cedis::Store do
    describe "#get, #set, and #del" do
      it "can #set a value, then #get it" do
        store = init_tests
        store.set "foo", "bar"
        store.get("foo").should eq "bar"
      end

      it "#get raises an error if there is no value present" do
        store = init_tests
        expect_raises(KeyError) { store.get "foo" }
      end

      it "#del removes a key" do
        store = init_tests
        store.set "foo", "bar"
        store.del "foo"
        expect_raises(KeyError) { store.get "foo" }
      end
    end

    describe "#transaction and #abort" do
    end
  end
end
