# Cedis is an in-memory data store that
# mirrors the API of Redis.
# ======
# This was initially given to me as a coding challenge
# at a job interview. The requirements:
#
# Must be able to set, get, and del keys.
# Must be able to support transactions.
# Transactions start with a #begin statement,
#   can be canceled with #abort,
#   and the operations in a transaction only complete
#   if every operation succeed.
# Must also support nested transactions.
module Cedis
  VERSION = "0.1.0"

  class Store
    @store = Hash(String,String | Nil).new(nil)

    def get(key)
      @store[key]
    end

    def set(key, value)
      @store[key] = value
    end

    def del(key)
      @store.delete key
    end
  end

end
