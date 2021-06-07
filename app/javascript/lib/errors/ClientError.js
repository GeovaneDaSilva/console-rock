import { BasicError } from './BasicError'

/**
 * This is a semantic error that indicates to the UI that the Client (not the
 * developer, nor a bad network state) was responsible for the error.
 *
 * When using this error, make sure to set a client message.
 *
 * Example:
 * const error = new ClientError('Incorrect credentials')
 *   .setAsRoot()
 *   .setCausedBy(responseErrorCausedByBadCredentials)
 *   .setClientMessage('It looks like there is something wrong with your credentials. Please check your credentials and try again.')
 *
 * Messaging containers that receive this error should use the ClientError#clientMessage
 * field to render a message for the client.
 */
export class ClientError extends BasicError {
  constructor(msg, causedBy) {
    super(msg)
    this.causedBy = causedBy
    this.scope = 'client'
  }

  setCausedBy(error) {
    this.causedBy = error
    this.useCausedByStack()
    return this
  }
}
