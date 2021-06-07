import { BasicError } from './BasicError'
import { getReasonPhrase } from 'http-status-codes'

/**
 * Indicates that an error happened while the app was communicating with a server.
 *
 * This error should typically be wrapped with a more semantic error when it is
 * used in the app, as it does not necessarily carry any useful information
 * for the client.
 */
export class ResponseError extends BasicError {
  constructor(response, msg = 'Frontend request failed') {
    super(msg)
    this.response = response
    this.status = response.status
    this.reason = getReasonPhrase(response.status)
  }
}
