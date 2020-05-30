# Cedis is an in-memory data store that
# mirrors the API of Redis.
#
# ======
#
# This was initially given to me as a coding challenge
# at a job interview. The requirements:
#
# - Must be able to set, get, and del keys.
# - Attempting to get a key which does not exist raises an error
# - Must be able to support transactions.
# - Transactions start with a #begin statement,
#   can be canceled with #abort,
#   and the operations in a transaction only complete
#   if every operation succeed.
# - Must also support nested transactions.
#
#
# cedis.set "name", "bob"
# cedis.get "name" # => "bob"
# cedis.transaction do
#   cedis.set "name", "alice"
#   cedis.set "age", cedis.get("name")
#   cedis.get "age" # => alice
#   cedis.get "fail" # => raises error
#   cedis.set ...
# end
# cedis.get "name" # => "bob
#
module Cedis
  VERSION = "0.1.0"

  class Store
    struct DeleteKey
    end

    @store = Hash(String, String).new
    @transactions = Array(Hash(String, String | DeleteKey)).new

    private def store
      store = @transactions.empty? ? @store : @transactions.last
    end

    def get(key)
      store[key]
    end

    def set(key, value)
      store[key] = value
    end

    def del(key)
      if @transactions.empty?
        store.delete key
      else
        store.as(Hash(String, String | DeleteKey))[key] = DeleteKey.new
      end
    end

    def transaction(&block)
      @transactions << Hash(String, String | DeleteKey).new
      yield
      merge_transactions(@transactions.pop)
    rescue e : KeyError
      @transactions.pop
    end

    private def merge_transactions(trans_store : Hash(String, DeleteKey))
      trans_store.each do |k, v|
        if v.is_a? DeleteKey
          store.delete k
        else
          store[k] = v
        end
      end
    end
  end
end
