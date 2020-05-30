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

      it "#get returns nil if there is no value present" do
        store = init_tests
        store.get("foo").should be_nil
      end

      it "#del removes a key" do
        store = init_tests
        store.set "foo", "bar"
        store.del "foo"
        store.get("foo").should eq nil
      end

    end

  end

end
