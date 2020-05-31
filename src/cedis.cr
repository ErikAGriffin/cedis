# Cedis is an in-memory data store that
# mirrors the API of Redis.
#
# ======
#
# This was initially given to me as a coding challenge
# at a job interview. The requirements:
#
# - Must be able to set, get, and delete keys.
# - Attempting to get a key which does not exist raises an error
# - Must be able to support transactions.
# - Transactions start with a #begin statement,
#   can be canceled with #abort,
#   and the operations in a transaction only complete
#   if every operation succeed.
# - Must also support nested transactions.
# ...
# If get throws an error while in a transaction, actually
# it needs to look in the transaction above it if there
# is a value there.
# store.set "name", "alice"
# store.transaction do
#   store.set "test", store.get("name")
# end
# store.get "test" # => "alice"
# This needs to continue all the way up the transaction tree
# until it can be certain there is no actual value for that
# key.
#
# Further more getting a DeleteKey should throw an error
# that aborts the transaction
# store.set "name", "alice"
# store.transaction do
#   store.del "name"
#   store.set "test", store.get("name") # => throws error
# end
# store.get "name" # => "alice"
#
# And finally, if I wanted to build this more suited for a REPL,
# I think I could handle the throwing of errors in each individual
# method.  So that #get itself would hop out of the transaction
# in case of KeyError.  #begin would just add to the transactions
# stack and #abort would pop it off.
module Cedis
  VERSION = "0.1.0"

  class Store
    struct DeleteKey
    end
    class TransactionAborted < Exception
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
      puts e.message
      @transactions.pop
    rescue e : Exception
      puts "An error has occurred: #{e.message}"
      @transactions.pop
    end

    def abort_transaction
      unless @transactions.empty?
        raise TransactionAborted.new "Transaction Aborted"
      end
    end

    private def merge_transactions(trans_store : Hash(String, String | DeleteKey))
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
