import { isObject } from 'lodash'

/**
 * Takes a deeply-nested object (previously constructed from a rails form object)
 * and returns a string that corresponds to the query on a rails GET request. All
 * components are URI encoded
 *
 * Example:
 *
 * const object = {
 *   companies: {
 *     limit: 1,
 *     types: [1, 2]
 *   },
 *   customers: {
 *    limit: 10,
 *    q: 'CoolCompany LLC'
 *   }
 * }
 *
 * objectToRailsURLFormQuery(object)

 * => (Human-readable result) = 'companies[limit]=1&companies[types][]=1&companies[types][]=2&customers[limit]=10&customers[q]=CoolCompany%20LLC'
 * => (actual result) = "companies%5Blimit%5D%3D1%26companies%5Btypes%5D%5B%5D%3D1%26companies%5Btypes%5D%5B%5D%3D2%26customers%5Blimit%5D%3D10%26customers%5Bq%5D%3DCoolCompany%2520LLC"
 */
export const objectToRailsURLFormQueryString = (formObject, base = false, target = {}) => {
  const rootKeys = Object.keys(formObject)
  rootKeys.forEach(key => {
    let updatedKey = ''
    if (!base) {
      updatedKey = key
    } else {
      updatedKey = `${base}[${key}]`
    }

    const val = formObject[key]

    if (!isObject(val)) {
      target[updatedKey] = val
    } else {
      objectToRailsURLFormQueryString(val, updatedKey, target)
    }
  })

  /**
   * normalizes array form values by replacing number-based object keys with an empty array
   * @param {String} str
   * @returns String
   */
  const arrayKeyReplacer = (str) => {
    return str.replace(/\[(\d+)\]/g, '[]')
  }

  const obj = Object.keys(target)
    .map(
      key => [
        encodeURIComponent(arrayKeyReplacer(key)),
        encodeURIComponent(target[key])
      ].join('=')
    )
    .join('&')
  return obj
}
