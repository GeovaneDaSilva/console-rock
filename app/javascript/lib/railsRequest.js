import { objectToRailsURLFormQueryString } from './objectToRailsURLFormQueryString'
import { getCSRFHeader } from './getCSRFHeader'
import { BasicError } from './errors/BasicError'
import { validateResponse } from './validations/validateResponse'
import { DeveloperError } from './errors/DeveloperError'

class RailsRequestError extends BasicError {
  constructor(causedBy, message = 'A rails request error has occurred.') {
    super(message)
    this.causedBy = causedBy
    this.useCausedByStack()
  }
}

class RailsRequestResponse {
  constructor(body, response, options = null) {
    this.body = body
    this.response = response
    this.options = options
  }
}

const unwrapBody = async (response) => {
  switch(response.status) {
  case 204: {
    return null
  }
  default: {
    return await response.json()
  }
  }
}

export const railsRequest = async (url, { method, body, onError, onSuccess }) => {
  const headers = new Headers()
  const { csrfHeaderName, csrfHeaderValue } = getCSRFHeader()

  const onSuccessFunction = (...args) => {
    if (onSuccess && typeof onSuccess === 'function') {
      return onSuccess(...args)
    }
    return undefined
  }

  const onErrorFunction = (...args) => {
    if (onError && typeof onError === 'function') {
      return onError(...args)
    }
    return undefined
  }

  let parsedURL = url

  const options = {
    headers,
    method: method.toUpperCase(),
    mode: 'same-origin',
    cache: 'no-cache',
    credentials: 'same-origin',
    referrerPolicy: 'same-origin',
  }

  if (body) {
    if (options.method !== 'GET' && options.method !== 'HEAD') {
      headers.append('X-CSRF-Token', csrfHeaderValue)
      headers.append('Content-Type', 'application/json')
      options.body = JSON.stringify(body)
    } else {
      headers.append(csrfHeaderName, csrfHeaderValue)
      const queryString = objectToRailsURLFormQueryString(body)
      parsedURL = `${parsedURL}?${queryString}`
    }
  }

  let response = undefined
  let receivedBody = undefined

  try {
    response = await fetch(parsedURL, options)
  } catch (error) {
    const wrappedError = new RailsRequestError(error)
    onErrorFunction(wrappedError)
    throw wrappedError
  }

  try {
    validateResponse(response)
  } catch (error) {
    // NOTE: validateResponse returns a well-formatted error, pass directly to UI components
    onErrorFunction(error)
    throw error
  }

  try {
    receivedBody = await unwrapBody(response)
  } catch (error) {
    throw new DeveloperError('There was an error unwrapping the response body', error)
  }

  onSuccessFunction()
  return new RailsRequestResponse(receivedBody, response, options)
}
