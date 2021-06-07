import { get, set } from 'lodash'

// TODO: refactor to do the loop internally, as opposed to requiring developer to run loop
// TODO: refactor to method that takes URL or query-string

/**
 * Converts a rails GET query string segment into a deeply-nested javascript object.
 * Typically, this function should be used in closure that loops over an object
 * containing URL parameters.
 *
 * Example:
 *
 * const outputContainer = {}
 * const key = 'companies[types][]'
 * const val = '2'
 *
 * railsFormParamsToObject(outputContainer, key, val)
 *
 * console.log(outputContainer)
 * => {
 *   companies: {
 *     types: ['2']
 *   }
 * }
 *
 * const key2 = 'companies[types][]'
 * const val2 = '3'
 *
 * railsFormParamsToObject(outputContainer, key2, val2)
 *
 * console.log(outputContainer)
 * => {
 *   companies: {
 *     types: ['2', '3']
 *   }
 * }
 *
 * In current state, use by looping through a set of query parameters.
 *
 * E.g.,
 *
 * const url = new URL('https://app.rocketcyber.com/cool_query?param1=1&param2=2&array_param[]=array1&parray_param[]=array2')
 * const extractedParams = {}
 *
 * for (const [key, val] of url.searchParams) {
 *   railsFormParamsToObject(extractedParams, key, val)
 * }
 *
 * => {
 *   param1: '1',
 *   param2: '2',
 *   array_param: [
 *     'array1',
 *     'array2'
 *   ]
 * }
 */
export const railsFormParamsToObject = (target, key, val) => {
  const valueNesting = key.match(/[a-zA-Z_-]*[^[\]]/g)
  if (!valueNesting) {
    target[key] = val
  } else {
    if (key.endsWith('[]')) {
      let currentValue = get(target, valueNesting)
      if (!currentValue) {
        const arrayValue = [].concat([val])
        set(target, valueNesting, arrayValue)
      } else {
        set(target, valueNesting, get(target, valueNesting).concat([val]))
      }
    } else {
      set(target, valueNesting, val)
    }
  }
}
