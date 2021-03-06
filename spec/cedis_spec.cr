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

    describe "#transaction and #abort_transaction" do
      it "can complete a #transaction" do
        store = init_tests
        store.set "name", "bob"
        store.set "age", "12"
        store.transaction do
          store.set "name", "alice"
          store.del "age"
        end
        store.get("name").should eq "alice"
        expect_raises(KeyError) { store.get "age" }
      end

      it "rolls back transaction if it did not complete successfully" do
        store = init_tests
        store.set "name", "bob"
        store.transaction do
          store.set "name", "alice"
          store.get "age"
        end
        store.get("name").should eq "bob"
      end

      it "can #abort a transaction" do
        store = init_tests
        store.set "name", "bob"
        store.transaction do
          store.set "name", "alice"
          store.abort_transaction
        end
        store.get("name").should eq "bob"
      end

      it "supports nested transactions" do
        store = init_tests
        store.set "name", "bob"
        store.transaction do
          store.set "name", "alice"
          store.set "age", "12"
          store.transaction do
            store.set "pizza", "yes"
            store.set "age", "13"
            store.transaction do
              store.del "name"
              store.set "pizza", "no"
            end
            store.get "fail"
          end
          store.transaction do
            store.set "sushi", "yes"
          end
        end
        store.get("name").should eq "alice"
        store.get("age").should eq "12"
        store.get("sushi").should eq "yes"
        expect_raises(KeyError) { store.get "pizza" }
      end
    end
  end
end
