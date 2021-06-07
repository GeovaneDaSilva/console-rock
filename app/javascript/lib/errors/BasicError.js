function causeTraverser(obj) {
  if (obj.isRoot) {
    return obj.stack
  }
  if (obj.causedBy) {
    return causeTraverser(obj.causedBy)
  }
  return obj.stack
}

/**
 * A sublcass of Error that is used to semantically communicate how an error
 * should impact error tracking and messages to the client (UI messages)
 *
 * BasicError#clientMessage should be set to whatever message you would like
 * to show to the client in the UI
 *
 * BasicError#causedBy allows for error-wrapping. This allows us to return a more
 * semantic error (BasicError), while holding on-to the actual error for inspection
 * later on (perhaps by sending the cause to Sentry, or any other error-tracking
 * facility)
 *
 * BasicError should not be used directly, rather it should be extended from a
 * concrete implementation.
 */
export class BasicError extends Error {
  constructor(msg) {
    super(msg)
    this.causedBy = null
    this.name = this.constructor.name
    this.scope = 'developer'
    this.clientMessage = 'Oops, it looks like something went wrong. We have been notified and will look into what caused this. In the meantime, please try again later.'
  }

  setClientMessage(msg) {
    this.clientMessage = msg
    return this
  }

  setCausedBy(error) {
    this.causedBy = error
    return this
  }

  useCausedByStack() {
    if (this.causedBy) {
      this.stack = causeTraverser(this)
    }
    return this
  }

  /**
   * This method causes the error-stack traverser to stop at this level. This means that,
   * in the future, stack traces will be equal to the trace that led-up to this
   * error being thrown.
   *
   * Order matters! This method needs to be called before using the useCausedByStack
   * method, which is typically used by the concrete implementations of this class.
   */
  setAsRoot() {
    this.isRoot = true
    return this
  }
}
