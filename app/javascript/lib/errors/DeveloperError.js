import { BasicError } from './BasicError'

/**
 * Used to indicate that an error was caused by the Developer, not the client.
 *
 * Should render a holding message for the client, such as: 'Oh no, something went
 * wrong! We have been notified. In the meantime, please try again in a few minutes'.
 *
 * These are meant to be prioritized in an error-tracking system if they happen in production.
 *
 * They can be used to indicate to another developer in development that they have
 * misused some feature in the application.
 *
 * e.g.,
 *
 * throw new DeveloperError('Server is unavailable')
 *   .setAsRoot()
 *   .setCausedBy(responseErrorFromUnavailableServer)
 *
 * DeveloperError uses the default clientMessage that is set by BasicError
 */
export class DeveloperError extends BasicError {
  constructor(msg) {
    super(msg)
    this.name = this.constructor.name
    this.scope = 'developer'
  }

  setCausedBy(error) {
    this.causedBy = error
    this.useCausedByStack()
    return this
  }
}
