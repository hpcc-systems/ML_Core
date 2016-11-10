IMPORT $ AS Utils;
Fac := Utils.Fac;
/***
 * N Choose K - finds the number of combinations of K elements out
 * of a possible N.
 * Should eventually do this in a way to avoid the intermediates
 * (such as Fac(N)) exploding and causing precision loss.
 *@param N the number of items in the population.
 *@param K the number of items to choose
 *@return the number of combinations.
 */
EXPORT REAL8 NCK(INTEGER2 N, INTEGER2 K) := Fac(N)/(Fac(K)*Fac(N-k));
