
# RXZSET

Source: [https://github.com/RedisLabsModules/redex](https://github.com/RedisLabsModules/redex).

Adds members to a Sorted Set, keeping it at `cap` cardinality. Removes top scoring members as needed to meet the limit.

**Reply:** Integer, the number of members added.

## `ZADDREVCAPPED zset cap score member [score member ...]`

> Time complexity: O(N\*LogM) where N is the number of elements added and M is the number of elements in the Sorted Set.

Adds members to a Sorted Set, keeping it at `cap` cardinality. Removes bottom scoring members as needed to meet the limit.

**Reply:** Integer, the number of members added.

## `MZRANK key ele [ele ...]`

> Time complexity: O(N\*LogM) where N is the number of elements passed as arguments to the command and M is the number of elements in the Sorted Set.

A variadic variant for `ZRANK`, returns the ranks of multiple members in a Sorted Set.

**Reply:** Array of Integers.

## `MZREVRANK key ele [ele ...]`

> Time complexity: O(N\*LogM) where N is the number of elements passed as arguments to the command and M is the number of elements in the Sorted Set.

A variadic variant for `ZREVRANK`, returns the reverse ranks of multiple members in a Sorted Set.

**Reply:** Array of Integers.

## `MZSCORE key ele [ele ...]`

> Time complexity: O(N\*LogM) where N is the number of elements passed as arguments to the command and M is the number of elements in the Sorted Set.

A variadic variant for `ZSCORE`, returns the scores of multiple members in a Sorted Set.

**Reply:** Array of Strings.

## `ZUNIONTOP K numkeys key [key ...] [WEIGHTS weight [weight ...]] [WITHSCORES]`

> Time complexity: O(numkeys\*log(N) + K\*log(numkeys)) where N is the number of elements in a Sorted Set.

Union multiple Sorted Sets and return the `K` elements with lowest scores. Refer to [`ZUNIONSTORE`](http://redis.io/commands/zunionstore)'s documentation for details on using the command.

**Reply:** Array reply, the top k elements (optionally with the score, in case the 'WITHSCORES' option is given).

## `ZUNIONREVTOP K numkeys key [key ...] [WEIGHTS weight [weight ...]] [WITHSCORES]`

> Time complexity: O(numkeys\*log(N) + K\*log(numkeys)) where N is the number of elements in a Sorted Set.

Union multiple Sorted Sets and return the `K` elements with highest scores. Refer to [`ZUNIONSTORE`](http://redis.io/commands/zunionstore)'s documentation for details on using the command.

**Reply:** Array reply, the top k elements (optionally with the score, in case the 'WITHSCORES' option is given).
